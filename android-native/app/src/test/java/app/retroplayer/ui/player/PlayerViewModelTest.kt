package app.retroplayer.ui.player

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.playback.NowPlaying
import app.retroplayer.runVmTest
import app.retroplayer.ui.art.EmbeddedArt
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PlayerViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var viewModel: PlayerViewModel

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        viewModel = PlayerViewModel(lib.playback, lib.store)
    }

    @After
    fun tearDown() = lib.close()

    private suspend fun stateWhere(predicate: (PlayerUiState) -> Boolean) = viewModel.state.first(predicate)

    @Test
    fun `exposes now playing from the controls`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(title = "Song", subtitle = "Tester", hasTrack = true)
        val state = stateWhere { it.nowPlaying.title == "Song" }
        assertThat(state.nowPlaying.subtitle).isEqualTo("Tester")
        assertThat(state.visible).isTrue()
    }

    @Test
    fun `nothing to show without a track or a restored title`() = main.runVmTest {
        assertThat(viewModel.state.value.visible).isFalse()
    }

    @Test
    fun `toggle forwards to the controls`() = main.runVmTest {
        viewModel.toggle()
        viewModel.previous()
        viewModel.next()
        viewModel.seekTo(42_000)
        assertThat(lib.playback.calls).containsExactly("toggle", "previous", "next", "seekTo:42000").inOrder()
    }

    @Test
    fun `breadcrumbs follow the playing track`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(
            itemId = "folder:" + lib.p("Rock").value,
            trackId = lib.p("Rock/Album/01 Song.mp3").value,
            title = "Song",
            hasTrack = true,
        )
        val state = stateWhere { it.crumbs.size > 1 }
        assertThat(state.crumbs.map { it.label }).containsExactly("", "Music", "Rock", "Album", "Song").inOrder()
        assertThat(state.crumbs[3].path).isEqualTo(lib.p("Rock/Album"))
    }

    @Test
    fun `embedded art loads from the track document`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(title = "Song", artworkUri = "doc:a", trackUri = "doc:a", hasTrack = true)
        assertThat(stateWhere { it.nowPlaying.title == "Song" }.artModel).isEqualTo(EmbeddedArt("doc:a"))
    }

    @Test
    fun `folder art is used as is`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(title = "Song", artworkUri = "doc:cover.jpg", trackUri = "doc:a", hasTrack = true)
        assertThat(stateWhere { it.nowPlaying.title == "Song" }.artModel).isEqualTo("doc:cover.jpg")
    }

    @Test
    fun `jump back and forward forward to the controls`() = main.runVmTest {
        viewModel.jumpBack()
        viewModel.jumpForward()
        assertThat(lib.playback.calls).containsExactly("jumpBack", "jumpForward").inOrder()
    }

    @Test
    fun `speed down stops at the minimum`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(speed = 0.5f, hasTrack = true)
        viewModel.speedDown()
        assertThat(lib.playback.calls).containsExactly("speed:0.5")
    }

    @Test
    fun `speed up stops at the maximum`() = main.runVmTest {
        lib.playback.nowPlaying.value = NowPlaying(speed = 2f, hasTrack = true)
        viewModel.speedUp()
        assertThat(lib.playback.calls).containsExactly("speed:2.0")
    }
}

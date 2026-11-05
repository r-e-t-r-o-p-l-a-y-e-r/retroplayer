package app.retroplayer.ui.queue

import androidx.lifecycle.SavedStateHandle
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.runVmTest
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
class SavePlaylistViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var viewModel: SavePlaylistViewModel

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot("Music")
        lib.docs.file("Mix/a.mp3")
        lib.docs.file("Mix/b.mp3")
        lib.docs.file("Talk/c.mp3")
        lib.queue.add(listOf(lib.p("Mix/a.mp3"), lib.p("Mix/b.mp3")))
        viewModel = lib.owned { SavePlaylistViewModel(SavedStateHandle(), lib.repository, lib.store, lib.settings, lib.playlists, lib.access) }
    }

    @After
    fun tearDown() = lib.close()

    private suspend fun shown(folder: String?) = viewModel.state.first { !it.loading && it.folder?.value == folder }

    @Test
    fun `starts at the library sources`() = main.runVmTest {
        val state = shown(null)
        assertThat(state.folders.map { it.name }).containsExactly("Music")
        assertThat(state.canSaveHere).isFalse()
    }

    @Test
    fun `opening a source lists its folders`() = main.runVmTest {
        viewModel.open(app.retroplayer.domain.LibraryPath(lib.rootId))
        val state = shown(lib.rootId)
        assertThat(state.title).isEqualTo("Music")
        assertThat(state.folders.map { it.name }).containsExactly("Mix", "Talk").inOrder()
        assertThat(state.canSaveHere).isTrue()
    }

    @Test
    fun `up walks back to the library sources and stops there`() = main.runVmTest {
        viewModel.open(lib.p("Mix"))
        shown(lib.p("Mix").value)
        assertThat(viewModel.up()).isTrue()
        shown(lib.rootId)
        assertThat(viewModel.up()).isTrue()
        shown(null)
        assertThat(viewModel.up()).isFalse()
    }

    @Test
    fun `save is refused at the library sources`() = main.runVmTest {
        shown(null)
        assertThat(viewModel.save("Trip")).isEqualTo(SavePlaylistOutcome.NotInFolder)
    }

    @Test
    fun `save writes an app playlist in the chosen folder`() = main.runVmTest {
        lib.store.setCanWrite(lib.rootId, true)
        viewModel.open(lib.p("Talk"))
        shown(lib.p("Talk").value)
        assertThat(viewModel.save("Road Trip")).isEqualTo(SavePlaylistOutcome.Saved(lib.p("Talk/Road Trip.m3u")))
        assertThat(lib.docs.text("Talk/Road Trip.m3u")).isEqualTo("#EXTM3U\n../Mix/a.mp3\n../Mix/b.mp3\n")
        assertThat(lib.store.isAppPlaylist(lib.p("Talk/Road Trip.m3u"))).isTrue()
    }

    @Test
    fun `save asks for write access on a read only source`() = main.runVmTest {
        viewModel.open(lib.p("Talk"))
        shown(lib.p("Talk").value)
        assertThat(viewModel.save("Road Trip")).isInstanceOf(SavePlaylistOutcome.NeedsWrite::class.java)
    }
}

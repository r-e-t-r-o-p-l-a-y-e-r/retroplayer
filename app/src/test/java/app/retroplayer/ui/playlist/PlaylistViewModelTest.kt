package app.retroplayer.ui.playlist

import androidx.lifecycle.SavedStateHandle
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.data.library.SaveResult
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
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
class PlaylistViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var viewModel: PlaylistViewModel

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.docs.file("Mix/a.mp3")
        lib.docs.file("Mix/b.mp3")
    }

    @After
    fun tearDown() = lib.close()

    private fun vm(path: String) = PlaylistViewModel(
        SavedStateHandle(mapOf(PlaylistViewModel.PATH_ARG to path)),
        lib.playlists,
        lib.scanner,
        lib.store,
        lib.playback,
    )

    private suspend fun ready() = viewModel.state.first { it is PlaylistUiState.Ready } as PlaylistUiState.Ready

    @Test
    fun `read only playlist offers no edits`() = main.runVmTest {
        lib.docs.file("Mix/Disk.m3u", "#EXTM3U\na.mp3\n".toByteArray())
        viewModel = vm(lib.p("Mix/Disk.m3u").value)
        val state = ready()
        assertThat(state.editable).isFalse()
        viewModel.removeIndices(setOf(0))
        assertThat(lib.playlists.read(lib.p("Mix/Disk.m3u")).entries).hasSize(1)
    }

    @Test
    fun `app playlist can remove an entry`() = main.runVmTest {
        lib.store.setCanWrite(lib.rootId, true)
        val folder = lib.p("Mix")
        val saved = lib.playlists.save(folder, "Mine", listOf(lib.p("Mix/a.mp3"), lib.p("Mix/b.mp3"))) as SaveResult.Saved
        viewModel = vm(saved.path.value)
        assertThat(ready().editable).isTrue()
        viewModel.requestRemove(setOf(0))
        viewModel.confirmRemove()
        viewModel.state.first { it is PlaylistUiState.Ready && it.entries.map { e -> e.path } == listOf(lib.p("Mix/b.mp3")) }
        assertThat(lib.docs.text("Mix/Mine.m3u")).isEqualTo("#EXTM3U\nb.mp3\n")
    }

    @Test
    fun `delete removes the file and the registry entry`() = main.runVmTest {
        lib.store.setCanWrite(lib.rootId, true)
        val saved = lib.playlists.save(lib.p("Mix"), "Mine", listOf(lib.p("Mix/a.mp3"))) as SaveResult.Saved
        viewModel = vm(saved.path.value)
        ready()
        assertThat(viewModel.state.value).isInstanceOf(PlaylistUiState.Ready::class.java)
        val done = kotlinx.coroutines.CompletableDeferred<Unit>()
        viewModel.requestDelete()
        viewModel.confirmDelete { done.complete(Unit) }
        done.await()
        assertThat(lib.store.isAppPlaylist(saved.path)).isFalse()
        assertThat(runCatching { lib.docs.text("Mix/Mine.m3u") }.isFailure).isTrue()
    }

    @Test
    fun `tap plays the playlist from that entry`() = main.runVmTest {
        lib.store.setCanWrite(lib.rootId, true)
        val folder = lib.p("Mix")
        val saved = lib.playlists.save(folder, "Mine", listOf(lib.p("Mix/a.mp3"), lib.p("Mix/b.mp3"))) as SaveResult.Saved
        viewModel = vm(saved.path.value)
        val state = viewModel.state.first { it is PlaylistUiState.Ready && (it as PlaylistUiState.Ready).entries.size == 2 } as PlaylistUiState.Ready
        viewModel.play(state.entries[1])
        assertThat(lib.playback.played).containsExactly(
            PlaybackItem.playlistId(saved.path) to lib.p("Mix/b.mp3").value,
        )
    }
}

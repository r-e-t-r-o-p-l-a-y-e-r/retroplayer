package app.retroplayer.ui.queue

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.data.library.SaveResult
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.TrackMetadata
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
class QueueViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var viewModel: QueueViewModel

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.docs.file("a.mp3")
        lib.docs.file("b.mp3")
        lib.docs.file("c.mp3")
        lib.queue.add(listOf(lib.p("a.mp3"), lib.p("b.mp3")))
        viewModel = QueueViewModel(lib.queue, lib.settings, lib.playback, lib.playlists, lib.store, lib.access)
    }

    @After
    fun tearDown() = lib.close()

    private suspend fun ready() = viewModel.state.first { it is QueueUiState.Ready } as QueueUiState.Ready

    @Test
    fun `shows queued tracks in order`() = main.runVmTest {
        val state = ready()
        assertThat(state.entries.map { it.path }).containsExactly(lib.p("a.mp3"), lib.p("b.mp3")).inOrder()
        assertThat(state.entries.mapNotNull { it.track?.fileName }).containsExactly("a.mp3", "b.mp3").inOrder()
    }

    @Test
    fun `tap plays the queue from that track`() = main.runVmTest {
        val state = ready()
        viewModel.play(state.entries[1])
        assertThat(lib.playback.played).containsExactly(PlaybackItem.QUEUE_ID to lib.p("b.mp3").value)
    }

    @Test
    fun `remove updates the queue`() = main.runVmTest {
        viewModel.remove(0)
        val state = ready()
        assertThat(state.entries.map { it.path }).containsExactly(lib.p("b.mp3"))
    }

    @Test
    fun `move updates the queue`() = main.runVmTest {
        viewModel.move(0, 1)
        val state = ready()
        assertThat(state.entries.map { it.path }).containsExactly(lib.p("b.mp3"), lib.p("a.mp3")).inOrder()
    }

    @Test
    fun `clear asks first`() = main.runVmTest {
        ready()
        viewModel.requestClear()
        val asking = viewModel.state.first { it is QueueUiState.Ready && it.confirmClear } as QueueUiState.Ready
        assertThat(asking.confirmClear).isTrue()
        viewModel.dismissClear()
        val dismissed = viewModel.state.first { it is QueueUiState.Ready && !it.confirmClear } as QueueUiState.Ready
        assertThat(dismissed.confirmClear).isFalse()
    }

    @Test
    fun `confirm clear empties the queue`() = main.runVmTest {
        ready()
        viewModel.requestClear()
        viewModel.confirmClear()
        val state = viewModel.state.first { it is QueueUiState.Ready && it.entries.isEmpty() } as QueueUiState.Ready
        assertThat(state.entries).isEmpty()
    }

    @Test
    fun `save is refused at the library root`() = main.runVmTest {
        lib.settings.setBrowsePath(null)
        ready()
        assertThat(viewModel.saveAsPlaylist("Trip")).isEqualTo(SavePlaylistOutcome.NotInFolder)
    }

    @Test
    fun `save writes an app playlist in the open folder`() = main.runVmTest {
        lib.queue.clear()
        lib.store.setCanWrite(lib.rootId, true)
        lib.docs.file("Mix/a.mp3")
        lib.docs.file("Mix/b.mp3")
        lib.settings.setBrowsePath(lib.p("Mix"))
        lib.queue.add(listOf(lib.p("Mix/a.mp3"), lib.p("Mix/b.mp3")))
        ready()
        val outcome = viewModel.saveAsPlaylist("Road Trip")
        assertThat(outcome).isEqualTo(SavePlaylistOutcome.Saved(lib.p("Mix/Road Trip.m3u")))
        viewModel.state.first { it is QueueUiState.Ready }
        assertThat(lib.docs.text("Mix/Road Trip.m3u")).isEqualTo("#EXTM3U\na.mp3\nb.mp3\n")
        assertThat(lib.store.isAppPlaylist(lib.p("Mix/Road Trip.m3u"))).isTrue()
    }
}

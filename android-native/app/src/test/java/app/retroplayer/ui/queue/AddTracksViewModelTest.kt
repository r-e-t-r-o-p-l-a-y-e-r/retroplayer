package app.retroplayer.ui.queue

import androidx.lifecycle.SavedStateHandle
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.runVmTest
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.flow.first
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AddTracksViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var viewModel: AddTracksViewModel

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(
            tmp,
            mapOf(
                "t1.mp3" to TrackMetadata(title = "Zebra", album = "Alb", trackNumber = 2),
                "t2.mp3" to TrackMetadata(title = "Apple", album = "Alb", trackNumber = 1),
            ),
        )
        lib.addRoot()
        lib.docs.file("Albums/Alb/t1.mp3")
        lib.docs.file("Albums/Alb/t2.mp3")
        lib.docs.file("Loose/x.mp3")
        viewModel = AddTracksViewModel(
            SavedStateHandle(mapOf(AddTracksViewModel.PATH_ARG to lib.p("Albums/Alb").value)),
            lib.repository,
            lib.store,
            lib.queue,
            lib.settings,
            lib.playlists,
        )
    }

    @After
    fun tearDown() = lib.close()

    @Test
    fun `selecting an album adds its tracks in album order`() = main.runVmTest {
        val browse = viewModel.state.first { it is AddTracksUiState.Browse } as AddTracksUiState.Browse
        val album = browse.audio.filterIsInstance<LibraryItem.Album>().single().album
        viewModel.toggleAlbum(album)
        viewModel.state.first { it is AddTracksUiState.Browse && (it as AddTracksUiState.Browse).selected.isNotEmpty() }
        val expected = lib.repository.albumOrdering().order(album.tracks, lib.store.albumSort(album.id)).map { it.fileName }
        assertThat(viewModel.selectedAlbumTrackPaths(album).map { it.name }).isEqualTo(expected)
    }

    @Test
    fun `selecting a folder adds every track under it in play order`() = main.runVmTest {
        viewModel.openFolder(lib.p("Albums").parent!!)
        viewModel.toggleFolder(lib.p("Albums"))
        val browse = viewModel.state.first { it is AddTracksUiState.Browse && it.selected.isNotEmpty() } as AddTracksUiState.Browse
        assertThat(browse.checkedFolders).containsExactly(lib.p("Albums"))
        val result = CompletableDeferred<AddTracksConfirmResult>()
        viewModel.confirm { result.complete(it) }
        assertThat(result.await()).isEqualTo(AddTracksConfirmResult.Added(2))
        assertThat(lib.settings.session.first().queue.map { it.name }).containsExactly("t2.mp3", "t1.mp3").inOrder()
    }

    @Test
    fun `selecting a folder again clears it`() = main.runVmTest {
        viewModel.openFolder(lib.p("Loose").parent!!)
        viewModel.toggleFolder(lib.p("Loose"))
        val checked = viewModel.state.first { it is AddTracksUiState.Browse && it.selected.isNotEmpty() } as AddTracksUiState.Browse
        assertThat(checked.checkedFolders).containsExactly(lib.p("Loose"))
        viewModel.toggleFolder(lib.p("Loose"))
        val browse = viewModel.state.first { it is AddTracksUiState.Browse && it.selected.isEmpty() } as AddTracksUiState.Browse
        assertThat(browse.checkedFolders).isEmpty()
    }

    @Test
    fun `an opened album lists its tracks in album order to pick single ones`() = main.runVmTest {
        val browse = viewModel.state.first { it is AddTracksUiState.Browse && it.complete } as AddTracksUiState.Browse
        viewModel.openAlbum(browse.audio.filterIsInstance<LibraryItem.Album>().single().album)
        val album = viewModel.state.first { it is AddTracksUiState.AlbumTracks } as AddTracksUiState.AlbumTracks
        assertThat(album.tracks.map { it.fileName }).containsExactly("t2.mp3", "t1.mp3").inOrder()
        viewModel.toggleTrack(album.tracks.last().path)
        val result = CompletableDeferred<AddTracksConfirmResult>()
        viewModel.confirm { result.complete(it) }
        assertThat(result.await()).isEqualTo(AddTracksConfirmResult.Added(1))
        assertThat(lib.settings.session.first().queue.map { it.name }).containsExactly("t1.mp3")
    }

    @Test
    fun `back returns to the previous place, then leaves`() = main.runVmTest {
        val browse = viewModel.state.first { it is AddTracksUiState.Browse } as AddTracksUiState.Browse
        viewModel.openAlbum(browse.audio.filterIsInstance<LibraryItem.Album>().single().album)
        viewModel.state.first { it is AddTracksUiState.AlbumTracks }
        assertThat(viewModel.back()).isTrue()
        val again = viewModel.state.first { it is AddTracksUiState.Browse } as AddTracksUiState.Browse
        assertThat(again.path).isEqualTo(lib.p("Albums/Alb"))
        assertThat(viewModel.back()).isFalse()
    }

    @Test
    fun `already queued tracks are not added twice`() = main.runVmTest {
        lib.queue.add(listOf(lib.p("Albums/Alb/t1.mp3")))
        viewModel.toggleTrack(lib.p("Albums/Alb/t1.mp3"))
        val result = CompletableDeferred<AddTracksConfirmResult>()
        viewModel.confirm { result.complete(it) }
        assertThat(result.await()).isEqualTo(AddTracksConfirmResult.NothingAdded)
    }
}

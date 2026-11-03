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
    fun `already queued tracks are not added twice`() = main.runVmTest {
        lib.queue.add(listOf(lib.p("Albums/Alb/t1.mp3")))
        viewModel.toggleTrack(lib.p("Albums/Alb/t1.mp3"))
        val result = CompletableDeferred<AddTracksConfirmResult>()
        viewModel.confirm { result.complete(it) }
        assertThat(result.await()).isEqualTo(AddTracksConfirmResult.NothingAdded)
    }
}

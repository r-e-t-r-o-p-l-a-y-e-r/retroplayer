package app.retroplayer.ui.album

import androidx.lifecycle.SavedStateHandle
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.runVmTest
import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.TrackMetadata
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.last
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AlbumViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var tagged: String
    private lateinit var loose: String

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(
            tmp,
            mapOf(
                "t1.mp3" to TrackMetadata(title = "Zebra", album = "Alb", trackNumber = 2),
                "t2.mp3" to TrackMetadata(title = "Apple", album = "Alb", trackNumber = 1),
                "b.mp3" to TrackMetadata(trackNumber = 1),
            ),
        )
        lib.addRoot()
        lib.docs.file("Albums/Alb/t1.mp3")
        lib.docs.file("Albums/Alb/t2.mp3")
        lib.docs.file("Albums/Loose/a.mp3")
        lib.docs.file("Albums/Loose/b.mp3")
        tagged = (lib.repository.folder(lib.p("Albums/Alb")).last().items.single() as LibraryItem.Album).id
        loose = AlbumIds.folder(lib.p("Albums/Loose"))
    }

    @After
    fun tearDown() = lib.close()

    private fun viewModel(id: String) =
        lib.owned { AlbumViewModel(SavedStateHandle(mapOf("albumId" to id)), lib.repository, lib.store, lib.settings, lib.playback, lib.queue) }

    private suspend fun AlbumViewModel.ready(predicate: (AlbumUiState.Ready) -> Boolean = { true }) =
        state.first { it is AlbumUiState.Ready && predicate(it) } as AlbumUiState.Ready

    @Test
    fun `album loads in tag order with breadcrumbs to its folder`() = main.runVmTest {
        val ready = viewModel(tagged).ready()
        assertThat(ready.album.title).isEqualTo("Alb")
        assertThat(ready.tracks.map { it.displayTitle }).containsExactly("Apple", "Zebra").inOrder()
        assertThat(ready.mode).isEqualTo(AlbumSortMode.TAG)
        assertThat(ready.crumbs.map { it.label }).containsExactly("", "Music", "Albums", "Alb").inOrder()
    }

    @Test
    fun `unknown album is reported`() = main.runVmTest {
        assertThat(viewModel(AlbumIds.folder(lib.p("Nope"))).state.first { it != AlbumUiState.Loading })
            .isEqualTo(AlbumUiState.NotFound)
    }

    @Test
    fun `choosing another order applies and persists it, choosing the default stores nothing`() = main.runVmTest {
        val vm = viewModel(tagged)
        vm.ready()
        vm.selectSort(AlbumSortMode.TITLE)
        assertThat(vm.ready { it.mode == AlbumSortMode.TITLE }.tracks.map { it.displayTitle }).containsExactly("Apple", "Zebra").inOrder()
        vm.selectSort(AlbumSortMode.FILE_NAME)
        assertThat(vm.ready { it.mode == AlbumSortMode.FILE_NAME }.tracks.map { it.fileName }).containsExactly("t1.mp3", "t2.mp3").inOrder()
        assertThat(lib.store.albumSort(tagged)).isEqualTo(AlbumSortChoice.FILE_NAME)
        vm.selectSort(AlbumSortMode.TAG)
        vm.ready { it.mode == AlbumSortMode.TAG }
        assertThat(lib.store.albumSorts.first()).doesNotContainKey(tagged)
    }

    @Test
    fun `album with missing tags falls back to file names`() = main.runVmTest {
        val ready = viewModel(loose).ready()
        assertThat(ready.mode).isEqualTo(AlbumSortMode.FILE_NAME)
        assertThat(ready.tagsUsable).isFalse()
        assertThat(ready.tracks.map { it.fileName }).containsExactly("a.mp3", "b.mp3").inOrder()
    }

    @Test
    fun `tag order with missing tags asks first and applies only when confirmed`() = main.runVmTest {
        val vm = viewModel(loose)
        vm.ready()
        vm.selectSort(AlbumSortMode.TAG)
        assertThat(vm.confirmTagOrder.value).isEqualTo(1)
        vm.dismissTagOrder()
        assertThat(vm.confirmTagOrder.value).isNull()
        assertThat(lib.store.albumSorts.first()).doesNotContainKey(loose)

        vm.selectSort(AlbumSortMode.TAG)
        vm.confirmTagOrder()
        assertThat(vm.confirmTagOrder.value).isNull()
        val ready = vm.ready { it.mode == AlbumSortMode.TAG }
        assertThat(ready.tracks.map { it.fileName }).containsExactly("b.mp3", "a.mp3").inOrder()
        assertThat(lib.store.albumSort(loose)).isEqualTo(AlbumSortChoice.TAG_FORCED)
    }

    @Test
    fun `tapping a track plays the album from it`() = main.runVmTest {
        val vm = viewModel(tagged)
        val ready = vm.ready()
        vm.play(ready.tracks[1])
        vm.playAll()
        assertThat(lib.playback.played).containsExactly(tagged to ready.tracks[1].id, tagged to null).inOrder()
    }

    @Test
    fun `adding a track to the queue adds only that track, once`() = main.runVmTest {
        val vm = viewModel(tagged)
        val track = vm.ready().tracks.first()
        suspend fun add() = CompletableDeferred<Int>().also { done -> vm.addToQueue(track) { done.complete(it) } }.await()
        assertThat(listOf(add(), add())).containsExactly(1, 0).inOrder()
        assertThat(lib.settings.session.first().queue).containsExactly(track.path)
        assertThat(lib.playback.played).isEmpty()
    }

    @Test
    fun `open album is remembered while shown`() = main.runVmTest {
        viewModel(tagged).onShown()
        assertThat(lib.settings.session.first().openAlbumId).isEqualTo(tagged)
    }

    @Test
    fun `album art is its folder picture`() = main.runVmTest {
        lib.docs.file("Albums/Alb/cover.jpg")
        lib.repository.folder(lib.p("Albums/Alb")).last()
        assertThat(viewModel(tagged).ready().artUri).isEqualTo("doc:root/Albums/Alb/cover.jpg")
        assertThat(viewModel(loose).ready().artUri).isNull()
    }
}

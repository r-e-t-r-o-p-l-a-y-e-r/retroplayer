package app.retroplayer.ui.library

import androidx.lifecycle.SavedStateHandle
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.runVmTest
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.TrackMetadata
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
class FolderViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp, mapOf("t1.mp3" to TrackMetadata(album = "Alb", trackNumber = 1), "t2.mp3" to TrackMetadata(album = "Alb", trackNumber = 2)))
        lib.addRoot()
        lib.docs.file("Books/Alpha/01.mp3")
        lib.docs.file("Books/Beta 10/01.mp3")
        lib.docs.file("Books/Beta 2/01.mp3")
        lib.docs.file("Books/mix.m3u")
        lib.docs.file("Books/single.mp3")
        lib.docs.file("Albums/Alb/t1.mp3")
        lib.docs.file("Albums/Alb/t2.mp3")
    }

    @After
    fun tearDown() = lib.close()

    private fun viewModel(path: String?) = FolderViewModel(
        SavedStateHandle(mapOf("path" to path)),
        lib.repository,
        lib.store,
        lib.settings,
        lib.playback,
        lib.access,
        lib.items,
        lib.queue,
    )

    private suspend fun FolderViewModel.folder() = state.first { it is FolderUiState.Folder && it.complete } as FolderUiState.Folder

    @Test
    fun `library root lists roots and favorite links`() = main.runVmTest {
        lib.store.toggleFavorite(lib.p("Books/Alpha"))
        val root = viewModel(null).state.first { it is FolderUiState.Root } as FolderUiState.Root
        assertThat(root.roots.map { it.name }).containsExactly("Music")
        assertThat(root.favorites.map { it.label }).containsExactly("Alpha")
        assertThat(root.favorites.single().rootName).isEqualTo("Music")
    }

    @Test
    fun `moving roots and favorites saves the new order`() = main.runVmTest {
        lib.store.toggleFavorite(lib.p("Books/Alpha"))
        lib.store.toggleFavorite(lib.p("Albums/Alb"))
        lib.addRoot("Books")
        val vm = viewModel(null)
        vm.moveRoot(1, 0)
        vm.moveFavorite(1, 0)
        val root = vm.state.first { it is FolderUiState.Root && it.roots.first().name == "Books" && it.favorites.first().label == "Alb" }
            as FolderUiState.Root
        assertThat(root.roots.map { it.name }).containsExactly("Books", "Music").inOrder()
        assertThat(root.favorites.map { it.label }).containsExactly("Alb", "Alpha").inOrder()
    }

    @Test
    fun `folder splits into folders, playlists and audio with breadcrumbs`() = main.runVmTest {
        val folder = viewModel(lib.p("Books").value).folder()
        assertThat(folder.folders.map { it.entry.path.name }).containsExactly("Alpha", "Beta 2", "Beta 10").inOrder()
        assertThat(folder.playlists.map { it.displayName }).containsExactly("mix")
        assertThat(folder.audio.map { it.title }).containsExactly("single")
        assertThat(folder.crumbs.map { it.label }).containsExactly("", "Music", "Books").inOrder()
        assertThat(folder.crumbs.first().isLibraryRoot).isTrue()
    }

    @Test
    fun `tag album shows as one audio row`() = main.runVmTest {
        val folder = viewModel(lib.p("Albums/Alb").value).folder()
        assertThat((folder.audio.single() as LibraryItem.Album).album.title).isEqualTo("Alb")
    }

    @Test
    fun `toggling a favorite marks the folder row`() = main.runVmTest {
        val vm = viewModel(lib.p("Books").value)
        vm.folder()
        vm.toggleFavorite(lib.p("Books/Alpha"))
        val folder = vm.state.first { it is FolderUiState.Folder && it.folders.any { row -> row.isFavorite } } as FolderUiState.Folder
        assertThat(folder.folders.filter { it.isFavorite }.map { it.entry.path.name }).containsExactly("Alpha")
    }

    @Test
    fun `play actions start the matching playback item`() = main.runVmTest {
        val vm = viewModel(lib.p("Books").value)
        val folder = vm.folder()
        vm.play(folder.audio.single())
        vm.playFolder()
        vm.playFolder(lib.p("Books/Alpha"))
        assertThat(lib.playback.played.map { it.first }).containsExactly(
            lib.p("Books/single.mp3").value,
            PlaybackItem.folderId(lib.p("Books")),
            PlaybackItem.folderId(lib.p("Books/Alpha")),
        ).inOrder()
    }

    @Test
    fun `add to queue appends what play would play without playing it`() = main.runVmTest {
        val vm = viewModel(lib.p("Albums/Alb").value)
        val album = vm.folder().audio.single()
        suspend fun add(itemId: String) = CompletableDeferred<Int>().also { done -> vm.addToQueue(itemId) { done.complete(it) } }.await()
        val counts = listOf(album.id, lib.p("Books/single.mp3").value, PlaybackItem.folderId(lib.p("Books/Alpha")), album.id).map { add(it) }

        assertThat(lib.settings.session.first().queue).containsExactly(
            lib.p("Albums/Alb/t1.mp3"),
            lib.p("Albums/Alb/t2.mp3"),
            lib.p("Books/single.mp3"),
            lib.p("Books/Alpha/01.mp3"),
        ).inOrder()
        assertThat(counts).containsExactly(2, 1, 1, 0).inOrder()
        assertThat(lib.playback.played).isEmpty()
    }

    @Test
    fun `showing a folder remembers it as the browse path and closes the album`() = main.runVmTest {
        lib.settings.setOpenAlbum("dir:x")
        viewModel(lib.p("Books").value).onShown()
        assertThat(lib.settings.session.first().openAlbumId).isNull()
        assertThat(lib.settings.session.first().browsePath).isEqualTo(lib.p("Books"))
        viewModel(null).onShown()
        assertThat(lib.settings.session.first().browsePath).isNull()
    }

    @Test
    fun `missing folder is reported`() = main.runVmTest {
        val state = viewModel(lib.p("Gone").value).state.first { it !is FolderUiState.Loading }
        assertThat(state).isEqualTo(FolderUiState.Missing)
    }

    @Test
    fun `adding and removing roots goes through storage access`() = main.runVmTest {
        val vm = viewModel(null)
        vm.addRoot("content://tree/Audiobooks")
        assertThat(lib.access.added).containsExactly("content://tree/Audiobooks")
        val root = vm.state.first { it is FolderUiState.Root && it.roots.size == 2 } as FolderUiState.Root
        vm.removeRoot(root.roots.first { it.name == "Music" }.id)
        val after = vm.state.first { it is FolderUiState.Root && it.roots.size == 1 } as FolderUiState.Root
        assertThat(after.roots.map { it.name }).containsExactly("Audiobooks")
    }
}

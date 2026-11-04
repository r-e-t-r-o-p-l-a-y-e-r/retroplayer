package app.retroplayer.playback

import app.retroplayer.data.library.FolderEntry
import app.retroplayer.data.library.FolderView
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.domain.model.TrackMetadata
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Test

class LibraryTreeTest {
    private val music = LibraryPath("1")
    private val books = LibraryPath("1/Books")
    private val t1 = AudioTrack(books.child("Alb/t1.mp3"), "doc:1", TrackMetadata(title = "One"))
    private val t2 = AudioTrack(books.child("Alb/t2.mp3"), "doc:2", TrackMetadata(title = "Two"))
    private val album = AudioAlbum("dir:1/Books/Alb", "Alb", "Ann", listOf(t1, t2), AlbumSource.DIRECTORY, books.child("Alb"))
    private val single = AudioTrack(books.child("single.mp3"), "doc:s")
    private val mix = PlaylistRef(books.child("mix.m3u"), "doc:m")

    private val tree = LibraryTree(
        roots = { listOf(music to "Music") },
        favorites = { listOf(books) },
        folder = { path ->
            if (path != books) null else FolderView(
                path = books,
                folders = listOf(FolderEntry(books.child("Alpha"), "doc:a")),
                items = listOf(LibraryItem.Album(album), LibraryItem.Track(single), LibraryItem.Playlist(mix)),
                artUri = null, scanned = 1, total = 1, complete = true, exists = true,
            )
        },
        albumTracks = { id -> if (id == album.id) listOf(t2, t1) else null },
        labels = TreeLabels(sources = "Library sources", favorites = "Favorites", queue = "Queue"),
    )

    @Test
    fun `root lists sources favorites and queue`() = runTest {
        val nodes = tree.children(LibraryTree.ROOT_ID)
        assertThat(nodes.map { it.title }).containsExactly("Library sources", "Favorites", "Queue").inOrder()
        assertThat(nodes.last().id).isEqualTo(PlaybackItem.QUEUE_ID)
        assertThat(nodes.last().playable).isTrue()
        assertThat(tree.children(LibraryTree.SOURCES_ID).single()).isEqualTo(
            TreeNode(PlaybackItem.folderId(music), "Music", browsable = true, playable = true),
        )
        assertThat(tree.children(LibraryTree.FAVORITES_ID).single().id).isEqualTo(PlaybackItem.folderId(books))
    }

    @Test
    fun `folder lists subfolders playlists then albums and tracks`() = runTest {
        val nodes = tree.children(PlaybackItem.folderId(books))
        assertThat(nodes.map { it.title }).containsExactly("Alpha", "mix", "Alb", "single").inOrder()
        assertThat(nodes.map { it.browsable }).containsExactly(true, false, true, false).inOrder()
        assertThat(nodes.all { it.playable }).isTrue()
        assertThat(nodes.map { it.id }).containsExactly(
            PlaybackItem.folderId(books.child("Alpha")), mix.id, album.id, single.id,
        ).inOrder()
    }

    @Test
    fun `album children are its tracks in effective order and play the album from there`() = runTest {
        val nodes = tree.children(album.id)
        assertThat(nodes.map { it.title }).containsExactly("Two", "One").inOrder()
        val request = PlaybackRequests.parseId(nodes.first().id)
        assertThat(request).isEqualTo(PlaybackRequest(album.id, t2.id))
        assertThat(PlaybackRequests.parseId(single.id)).isEqualTo(PlaybackRequest(single.id, null))
    }

    @Test
    fun `paging slices children`() = runTest {
        val id = PlaybackItem.folderId(books)
        assertThat(tree.children(id, page = 1, pageSize = 3).map { it.title }).containsExactly("single")
        assertThat(tree.children(id, page = 2, pageSize = 3)).isEmpty()
    }

    @Test
    fun `unknown id returns no children`() = runTest {
        assertThat(tree.children("nope")).isEmpty()
        assertThat(tree.children(PlaybackItem.folderId(LibraryPath("9/x")))).isEmpty()
    }
}

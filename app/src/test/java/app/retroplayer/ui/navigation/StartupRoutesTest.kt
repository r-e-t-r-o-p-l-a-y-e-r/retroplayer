package app.retroplayer.ui.navigation

import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.playback.NowPlaying
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class StartupRoutesTest {
    private val roots = setOf("1")

    @Test
    fun `fresh start shows the library root`() {
        assertThat(StartupRoutes.build(null, null, roots)).containsExactly(FolderRoute())
    }

    @Test
    fun `saved folder is reached through its parents`() {
        assertThat(StartupRoutes.build(LibraryPath("1/Books/Tolkien"), null, roots)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Books"),
            FolderRoute("1/Books/Tolkien"),
        ).inOrder()
    }

    @Test
    fun `open album goes on top of its folder`() {
        val album = AlbumIds.folder(LibraryPath("1/Books/Hobbit"))
        assertThat(StartupRoutes.build(LibraryPath("1/Books/Hobbit"), album, roots)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Books"),
            FolderRoute("1/Books/Hobbit"),
            AlbumRoute(album),
        ).inOrder()
    }

    @Test
    fun `paths under removed roots fall back to the library root`() {
        val album = AlbumIds.folder(LibraryPath("2/Gone"))
        assertThat(StartupRoutes.build(LibraryPath("2/Gone"), album, roots)).containsExactly(FolderRoute())
    }

    @Test
    fun `folder chain lists the library root and every ancestor`() {
        assertThat(StartupRoutes.folderChain(null)).containsExactly(FolderRoute())
        assertThat(StartupRoutes.folderChain(LibraryPath("1/A"))).containsExactly(FolderRoute(), FolderRoute("1"), FolderRoute("1/A")).inOrder()
    }

    @Test
    fun `locate in an album builds folder chain plus album`() {
        val album = AlbumIds.folder(LibraryPath("1/Books/Hobbit"))
        val now = NowPlaying(itemId = album, trackId = "1/Books/Hobbit/01.mp3")
        assertThat(StartupRoutes.locate(now, roots)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Books"),
            FolderRoute("1/Books/Hobbit"),
            AlbumRoute(album),
        ).inOrder()
    }

    @Test
    fun `locate in a played folder opens the album holding the track`() {
        val album = AlbumIds.folder(LibraryPath("1/Books/Hobbit"))
        val now = NowPlaying(itemId = PlaybackItem.folderId(LibraryPath("1/Books")), trackId = "1/Books/Hobbit/01.mp3")
        assertThat(StartupRoutes.locate(now, roots, albumOfTrack = album)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Books"),
            FolderRoute("1/Books/Hobbit"),
            AlbumRoute(album),
        ).inOrder()
    }

    @Test
    fun `locate for a loose track opens its folder`() {
        val now = NowPlaying(trackId = "1/Music/demo.mp3")
        assertThat(StartupRoutes.locate(now, roots)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Music"),
        ).inOrder()
    }

    @Test
    fun `locate for a playlist opens the playlist detail`() {
        val playlist = LibraryPath("1/Lists/set.m3u")
        val now = NowPlaying(itemId = PlaybackItem.playlistId(playlist), trackId = "1/Lists/set.m3u#0")
        assertThat(StartupRoutes.locate(now, roots)).containsExactly(
            FolderRoute(),
            FolderRoute("1"),
            FolderRoute("1/Lists"),
            PlaylistRoute("1/Lists/set.m3u"),
        ).inOrder()
    }
}

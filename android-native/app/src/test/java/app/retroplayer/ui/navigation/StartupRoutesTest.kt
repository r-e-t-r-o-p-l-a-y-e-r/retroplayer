package app.retroplayer.ui.navigation

import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
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
}

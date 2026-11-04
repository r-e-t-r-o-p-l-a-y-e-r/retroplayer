package app.retroplayer.domain

import app.retroplayer.domain.model.PlaybackItem
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class BreadcrumbsTest {
    private val rootName: (String) -> String? = { if (it == "1") "Music" else null }

    @Test
    fun `library root alone when not browsing`() {
        val crumbs = Breadcrumbs.library(null, rootName)
        assertThat(crumbs).containsExactly(Crumb(label = "", path = null, isLibraryRoot = true))
    }

    @Test
    fun `root display name then each folder`() {
        val crumbs = Breadcrumbs.library(LibraryPath("1/Books/Dune"), rootName)
        assertThat(crumbs.map { it.label }).containsExactly("", "Music", "Books", "Dune").inOrder()
        assertThat(crumbs.map { it.path?.value }).containsExactly(null, "1", "1/Books", "1/Books/Dune").inOrder()
    }

    @Test
    fun `unknown root shows library root and the folder name only`() {
        val crumbs = Breadcrumbs.library(LibraryPath("9/x"), rootName)
        assertThat(crumbs.map { it.label }).containsExactly("", "x").inOrder()
        assertThat(crumbs.last().path).isNull()
    }

    @Test
    fun `playback crumbs end with the track and include the playlist when playing one`() {
        val song = track("1/Books/Dune/01.mp3", title = "Opening")
        assertThat(Breadcrumbs.playback(song, null, rootName).map { it.label })
            .containsExactly("", "Music", "Books", "Dune", "Opening").inOrder()

        val playlistId = PlaybackItem.playlistId(LibraryPath("1/Lists/Road.m3u"))
        val crumbs = Breadcrumbs.playback(song, playlistId, rootName)
        assertThat(crumbs.map { it.label }).containsExactly("", "Music", "Lists", "Road", "Opening").inOrder()
        assertThat(crumbs[3].path).isEqualTo(LibraryPath("1/Lists/Road.m3u"))
    }
}

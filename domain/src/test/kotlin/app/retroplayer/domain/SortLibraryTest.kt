package app.retroplayer.domain

import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaylistRef
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.util.Locale

class SortLibraryTest {
    private val sort = SortLibrary(NaturalOrder(Locale.ENGLISH))

    @Test
    fun `orders by track number then natural title with playlists last`() {
        val items = listOf(
            LibraryItem.Playlist(PlaylistRef(LibraryPath("1/a/Mix.m3u"), "u")),
            LibraryItem.Track(track("1/a/x.mp3", title = "Song 10")),
            LibraryItem.Track(track("1/a/y.mp3", title = "Song 2")),
            LibraryItem.Track(track("1/a/z.mp3", title = "Zed", trackNumber = 1)),
        )
        assertThat(sort(items).map { it.title }).containsExactly("Zed", "Song 2", "Song 10", "Mix").inOrder()
    }

    @Test
    fun `folders sort naturally`() {
        assertThat(sort.folders(listOf("CD10", "cd2", "CD1").map { LibraryPath("1/$it") }).map { it.name })
            .containsExactly("CD1", "cd2", "CD10").inOrder()
    }
}

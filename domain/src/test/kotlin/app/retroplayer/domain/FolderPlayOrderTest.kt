package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSortChoice
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.util.Locale

class FolderPlayOrderTest {
    private val natural = NaturalOrder(Locale.ENGLISH)
    private val order = FolderPlayOrder(GroupTracksIntoAlbums(), SortLibrary(natural), AlbumOrdering(natural))

    private fun play(folder: String, tracks: List<app.retroplayer.domain.model.AudioTrack>, choices: Map<String, AlbumSortChoice> = emptyMap()) =
        order(LibraryPath(folder), tracks) { choices[it] ?: AlbumSortChoice.AUTOMATIC }.map { it.path.value }

    @Test
    fun `disc folders play in natural order`() {
        val tracks = listOf("CD10", "CD1", "CD2").flatMap { cd ->
            listOf(track("1/Book/$cd/02.mp3"), track("1/Book/$cd/01.mp3"))
        }
        assertThat(play("1/Book", tracks)).containsExactly(
            "1/Book/CD1/01.mp3", "1/Book/CD1/02.mp3",
            "1/Book/CD2/01.mp3", "1/Book/CD2/02.mp3",
            "1/Book/CD10/01.mp3", "1/Book/CD10/02.mp3",
        ).inOrder()
    }

    @Test
    fun `own tracks play before subfolders`() {
        val tracks = listOf(
            track("1/Mix/Sub/a.mp3"),
            track("1/Mix/Sub/b.mp3"),
            track("1/Mix/z.mp3", title = "Z"),
        )
        assertThat(play("1/Mix", tracks)).containsExactly("1/Mix/z.mp3", "1/Mix/Sub/a.mp3", "1/Mix/Sub/b.mp3").inOrder()
    }

    @Test
    fun `nested folders are walked depth first`() {
        val tracks = listOf(
            track("1/R/B/x.mp3"),
            track("1/R/A/Deep/y.mp3"),
            track("1/R/A/w.mp3"),
        )
        assertThat(play("1/R", tracks)).containsExactly("1/R/A/w.mp3", "1/R/A/Deep/y.mp3", "1/R/B/x.mp3").inOrder()
    }

    @Test
    fun `album sort choice is respected inside the walk`() {
        val tracks = listOf(
            track("1/R/Alb/b.mp3", album = "Alb", trackNumber = 1),
            track("1/R/Alb/a.mp3", album = "Alb", trackNumber = 2),
        )
        assertThat(play("1/R", tracks)).containsExactly("1/R/Alb/b.mp3", "1/R/Alb/a.mp3").inOrder()
        val albumId = GroupTracksIntoAlbums()(tracks).filterIsInstance<app.retroplayer.domain.model.LibraryItem.Album>().single().album.id
        assertThat(play("1/R", tracks, mapOf(albumId to AlbumSortChoice.FILE_NAME)))
            .containsExactly("1/R/Alb/a.mp3", "1/R/Alb/b.mp3").inOrder()
    }

    @Test
    fun `tracks outside the folder are ignored`() {
        val tracks = listOf(track("1/R/a.mp3"), track("1/Other/b.mp3"))
        assertThat(play("1/R", tracks)).containsExactly("1/R/a.mp3")
    }
}

package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.LibraryItem
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class GroupTracksIntoAlbumsTest {
    private val group = GroupTracksIntoAlbums()

    private fun albums(items: List<LibraryItem>) = items.filterIsInstance<LibraryItem.Album>().map { it.album }

    @Test
    fun `groups tracks with same album tag into one album in tag order`() {
        val items = group(
            listOf(
                track("1/book/ch02.mp3", album = "Test Book", trackNumber = 2),
                track("1/book/ch01.mp3", album = "Test Book", trackNumber = 1),
            ),
        )
        val album = albums(items).single()
        assertThat(items).hasSize(1)
        assertThat(album.title).isEqualTo("Test Book")
        assertThat(album.source).isEqualTo(AlbumSource.TAG)
        assertThat(album.tracks.map { it.metadata.trackNumber }).containsExactly(1, 2).inOrder()
    }

    @Test
    fun `merges album tags that differ only by case and keeps the most common spelling`() {
        val items = group(
            listOf(
                track("1/book/ch01.mp3", album = "Test Book", trackNumber = 1),
                track("1/book/ch02.mp3", album = "test book", trackNumber = 2),
                track("1/book/ch03.mp3", album = "Test Book", trackNumber = 3),
            ),
        )
        val album = albums(items).single()
        assertThat(album.title).isEqualTo("Test Book")
        assertThat(album.tracks).hasSize(3)
    }

    @Test
    fun `groups untagged files in one folder by folder name with parent as artist`() {
        val items = group(
            listOf(
                track("1/Author/Book Title/01-intro.mp3"),
                track("1/Author/Book Title/02-body.mp3"),
            ),
        )
        val album = albums(items).single()
        assertThat(album.title).isEqualTo("Book Title")
        assertThat(album.artist).isEqualTo("Author")
        assertThat(album.source).isEqualTo(AlbumSource.DIRECTORY)
    }

    @Test
    fun `folder album prefers the artist tag over the parent folder name`() {
        val items = group(
            listOf(
                track("1/Author/Book/01.mp3", artist = "Real Narrator"),
                track("1/Author/Book/02.mp3", artist = "Real Narrator"),
            ),
        )
        assertThat(albums(items).single().artist).isEqualTo("Real Narrator")
    }

    @Test
    fun `parent folder name for a folder directly under a root uses the root display name`() {
        val grouping = GroupTracksIntoAlbums(folderName = { if (it.isRoot) "My Author" else it.name })
        val album = albums(grouping(listOf(track("1/Book/01.mp3"), track("1/Book/02.mp3")))).single()
        assertThat(album.artist).isEqualTo("My Author")
    }

    @Test
    fun `leaves a single loose file as standalone track`() {
        val items = group(listOf(track("1/music/single.mp3", title = "Single Song")))
        assertThat(items.single()).isInstanceOf(LibraryItem.Track::class.java)
    }

    @Test
    fun `groups series subfolders under a parent author folder`() {
        val items = group(
            listOf(
                track("1/Author/Book1/ch01.mp3"),
                track("1/Author/Book1/ch02.mp3"),
                track("1/Author/Book2/ch01.mp3"),
                track("1/Author/Book2/ch02.mp3"),
            ),
        )
        assertThat(albums(items).map { it.title }).containsExactly("Book1", "Book2")
    }

    @Test
    fun `splits same album tag in one folder by disc number`() {
        val items = group(
            listOf(
                track("1/Unplugged/01.mp3", album = "Unplugged", trackNumber = 1, discNumber = 1),
                track("1/Unplugged/02.mp3", album = "Unplugged", trackNumber = 2, discNumber = 1),
                track("1/Unplugged/03.mp3", album = "Unplugged", trackNumber = 1, discNumber = 2),
                track("1/Unplugged/04.mp3", album = "Unplugged", trackNumber = 2, discNumber = 2),
            ),
        )
        val all = albums(items)
        assertThat(all).hasSize(2)
        all.forEach { album ->
            assertThat(album.tracks.map { it.metadata.discNumber }.toSet()).hasSize(1)
            assertThat(album.tracks.map { it.metadata.trackNumber }).containsExactly(1, 2).inOrder()
        }
    }

    @Test
    fun `album ids are stable for the same folder and tag`() {
        val tracks = listOf(
            track("1/b/1.mp3", album = "X", trackNumber = 1),
            track("1/b/2.mp3", album = "x", trackNumber = 2),
        )
        assertThat(albums(group(tracks)).single().id).isEqualTo(albums(group(tracks.reversed())).single().id)
    }
}

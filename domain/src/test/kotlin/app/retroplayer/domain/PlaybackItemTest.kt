package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.PlaybackItem
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class PlaybackItemTest {
    @Test
    fun `item ids round trip folder and playlist paths`() {
        val folder = LibraryPath("1/Books/Dune")
        assertThat(PlaybackItem.folderPathFromId(PlaybackItem.folderId(folder))).isEqualTo(folder)
        val playlist = LibraryPath("1/Mix.m3u")
        assertThat(PlaybackItem.playlistPathFromId(PlaybackItem.playlistId(playlist))).isEqualTo(playlist)
        assertThat(PlaybackItem.folderPathFromId("queue")).isNull()
    }

    @Test
    fun `album playback copies album title and artist into tracks without tags and resets speed`() {
        val album = AudioAlbum(
            id = "dir:1/a/book",
            title = "Book",
            artist = "Author",
            tracks = listOf(track("1/a/book/1.mp3"), track("1/a/book/2.mp3", artist = "Narrator", album = "Real")),
            source = AlbumSource.DIRECTORY,
            directory = LibraryPath("1/a/book"),
        )
        val item = PlaybackItem.Album(album, album.tracks)
        assertThat(item.id).isEqualTo("dir:1/a/book")
        assertThat(item.defaultSpeed).isEqualTo(1f)
        assertThat(item.tracks[0].metadata.artist).isEqualTo("Author")
        assertThat(item.tracks[0].metadata.album).isEqualTo("Book")
        assertThat(item.tracks[1].metadata.artist).isEqualTo("Narrator")
        assertThat(item.tracks[1].metadata.album).isEqualTo("Real")
    }

    @Test
    fun `queue item has the composed queue id and keeps speed`() {
        val item = PlaybackItem.Queue(listOf(track("1/a.mp3")))
        assertThat(item.id).isEqualTo(PlaybackItem.QUEUE_ID)
        assertThat(item.defaultSpeed).isNull()
    }
}

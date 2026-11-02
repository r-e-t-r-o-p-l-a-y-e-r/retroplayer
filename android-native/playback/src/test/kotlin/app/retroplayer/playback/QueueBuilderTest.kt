package app.retroplayer.playback

import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState
import app.retroplayer.domain.model.TrackMetadata
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class QueueBuilderTest {
    private fun track(name: String, metadata: TrackMetadata = TrackMetadata()) =
        AudioTrack(LibraryPath("1/Book/$name"), "doc:root/Book/$name", metadata)

    private val tracks = listOf(track("01 Intro.mp3"), track("02 Middle.mp3"), track("03 End.mp3"))
    private val folder = PlaybackItem.Folder(LibraryPath("1/Book"), tracks)

    private fun build(
        item: PlaybackItem = folder,
        saved: SavedPlaybackState? = null,
        startTrackId: String? = null,
    ) = QueueBuilder.build(item, saved, startTrackId) { Uri.parse("${it.uri}#art") }

    @Test
    fun `request carries the item id and the start track`() {
        val request = PlaybackRequests.request("folder:1/Book", startTrackId = "1/Book/02 Middle.mp3")
        assertThat(PlaybackRequests.parse(request)).isEqualTo(PlaybackRequest("folder:1/Book", "1/Book/02 Middle.mp3"))
        assertThat(PlaybackRequests.parse(MediaItem.Builder().setMediaId("1/x.mp3").build()))
            .isEqualTo(PlaybackRequest("1/x.mp3", null))
        assertThat(PlaybackRequests.parse(MediaItem.Builder().build())).isNull()
    }

    @Test
    fun `media items carry the document uri for embedded art`() {
        val first = build()!!.mediaItems.first()
        assertThat(PlaybackRequests.trackUriOf(first)).isEqualTo("doc:root/Book/01 Intro.mp3")
        assertThat(PlaybackRequests.trackUriOf(PlaybackRequests.request("folder:1/Book"))).isNull()
    }

    @Test
    fun `empty items are not playable`() {
        assertThat(build(PlaybackItem.Queue(emptyList()))).isNull()
    }

    @Test
    fun `media items carry track ids, uris, display metadata and the owning item`() {
        val tagged = track("04.mp3", TrackMetadata(title = "Tagged", artist = "Ann", album = "Alb", trackNumber = 4, durationMs = 5000))
        val queue = build(PlaybackItem.Folder(LibraryPath("1/Book"), tracks + tagged))!!
        val first = queue.mediaItems.first()
        assertThat(first.mediaId).isEqualTo("1/Book/01 Intro.mp3")
        assertThat(first.localConfiguration!!.uri.toString()).isEqualTo("doc:root/Book/01 Intro.mp3")
        assertThat(first.mediaMetadata.title.toString()).isEqualTo("Intro")
        assertThat(first.mediaMetadata.albumTitle.toString()).isEqualTo("Book")
        assertThat(first.mediaMetadata.artworkUri.toString()).isEqualTo("doc:root/Book/01 Intro.mp3#art")
        assertThat(first.mediaMetadata.isPlayable).isTrue()
        assertThat(first.mediaMetadata.isBrowsable).isFalse()
        assertThat(PlaybackRequests.itemIdOf(first)).isEqualTo("folder:1/Book")

        val last = queue.mediaItems.last().mediaMetadata
        assertThat(last.title.toString()).isEqualTo("Tagged")
        assertThat(last.artist.toString()).isEqualTo("Ann")
        assertThat(last.albumTitle.toString()).isEqualTo("Alb")
        assertThat(last.trackNumber).isEqualTo(4)
        assertThat(last.durationMs).isEqualTo(5000)
        assertThat(last.mediaType).isEqualTo(MediaMetadata.MEDIA_TYPE_MUSIC)
    }

    @Test
    fun `fresh item starts at the beginning at default speed`() {
        val album = AudioAlbum("dir:1/Book", "Book", null, tracks, AlbumSource.DIRECTORY, LibraryPath("1/Book"))
        val queue = build(PlaybackItem.Album(album, tracks))!!
        assertThat(queue.startIndex).isEqualTo(0)
        assertThat(queue.startPositionMs).isEqualTo(0)
        assertThat(queue.speed).isEqualTo(1f)
        assertThat(build()!!.speed).isNull()
    }

    @Test
    fun `saved state resumes track, position and speed`() {
        val saved = SavedPlaybackState("1/Book/02 Middle.mp3", positionMs = 42_000, speed = 1.5f)
        val queue = build(saved = saved)!!
        assertThat(queue.itemId).isEqualTo("folder:1/Book")
        assertThat(queue.startIndex).isEqualTo(1)
        assertThat(queue.startPositionMs).isEqualTo(42_000)
        assertThat(queue.speed).isEqualTo(1.5f)
    }

    @Test
    fun `tapping another track starts it from zero but keeps the item speed`() {
        val saved = SavedPlaybackState("1/Book/02 Middle.mp3", positionMs = 42_000, speed = 1.5f)
        val queue = build(saved = saved, startTrackId = "1/Book/03 End.mp3")!!
        assertThat(queue.startIndex).isEqualTo(2)
        assertThat(queue.startPositionMs).isEqualTo(0)
        assertThat(queue.speed).isEqualTo(1.5f)
    }

    @Test
    fun `tapping the saved track resumes its position`() {
        val saved = SavedPlaybackState("1/Book/02 Middle.mp3", positionMs = 42_000)
        assertThat(build(saved = saved, startTrackId = "1/Book/02 Middle.mp3")!!.startPositionMs).isEqualTo(42_000)
    }

    @Test
    fun `saved track that vanished starts at the beginning`() {
        val saved = SavedPlaybackState("1/Book/gone.mp3", positionMs = 42_000, speed = 0.75f)
        val queue = build(saved = saved)!!
        assertThat(queue.startIndex).isEqualTo(0)
        assertThat(queue.startPositionMs).isEqualTo(0)
        assertThat(queue.speed).isEqualTo(0.75f)
    }

    @Test
    fun `additions name the track and the item they join`() {
        val addition = PlaybackRequests.addition("1/Book/03.mp3", PlaybackItem.QUEUE_ID)
        assertThat(addition.mediaId).isEqualTo("1/Book/03.mp3")
        assertThat(addition.localConfiguration).isNull()
        assertThat(PlaybackRequests.additionTargetOf(addition)).isEqualTo(PlaybackItem.QUEUE_ID)
        assertThat(PlaybackRequests.additionTargetOf(PlaybackRequests.request("folder:1/Book"))).isNull()
    }
}

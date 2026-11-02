package app.retroplayer.playback

import android.net.Uri
import android.os.Bundle
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import app.retroplayer.domain.PlaybackResume
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState

/** What a controller asks to play: a playback item id and optionally the track to start with. */
data class PlaybackRequest(val itemId: String, val startTrackId: String?)

/**
 * Controllers (the app UI, Android Auto, the widget) send a single media item whose media id is the
 * playback item id; the session expands it into the real queue.
 */
object PlaybackRequests {
    private const val EXTRA_START_TRACK = "app.retroplayer.START_TRACK"
    private const val EXTRA_ITEM_ID = "app.retroplayer.ITEM_ID"
    private const val EXTRA_TRACK_URI = "app.retroplayer.TRACK_URI"

    fun request(itemId: String, startTrackId: String? = null): MediaItem = MediaItem.Builder()
        .setMediaId(itemId)
        .setRequestMetadata(
            MediaItem.RequestMetadata.Builder()
                .setExtras(Bundle().apply { startTrackId?.let { putString(EXTRA_START_TRACK, it) } })
                .build(),
        )
        .build()

    /** Asks the session to append the playback item [mediaId] to the playing [intoItemId] (the queue). */
    fun addition(mediaId: String, intoItemId: String): MediaItem = MediaItem.Builder()
        .setMediaId(mediaId)
        .setRequestMetadata(
            MediaItem.RequestMetadata.Builder()
                .setExtras(Bundle().apply { putString(EXTRA_ITEM_ID, intoItemId) })
                .build(),
        )
        .build()

    fun additionTargetOf(item: MediaItem): String? = item.requestMetadata.extras?.getString(EXTRA_ITEM_ID)

    fun parse(item: MediaItem): PlaybackRequest? {
        if (item.mediaId.isEmpty() || item.mediaId == MediaItem.DEFAULT_MEDIA_ID) return null
        return PlaybackRequest(item.mediaId, item.requestMetadata.extras?.getString(EXTRA_START_TRACK))
    }

    /** Playback item a queued media item belongs to. */
    fun itemIdOf(item: MediaItem?): String? = item?.mediaMetadata?.extras?.getString(EXTRA_ITEM_ID)

    /** Document the queued track plays; the UI loads embedded art from it (controllers do not see the media uri). */
    fun trackUriOf(item: MediaItem?): String? = item?.mediaMetadata?.extras?.getString(EXTRA_TRACK_URI)

    fun itemExtras(itemId: String, trackUri: String? = null) = Bundle().apply {
        putString(EXTRA_ITEM_ID, itemId)
        trackUri?.let { putString(EXTRA_TRACK_URI, it) }
    }
}

data class PreparedQueue(
    val itemId: String,
    val mediaItems: List<MediaItem>,
    val startIndex: Int,
    val startPositionMs: Long,
    /** Speed to apply; null keeps the player's current speed. */
    val speed: Float?,
)

object QueueBuilder {
    fun build(
        item: PlaybackItem,
        saved: SavedPlaybackState?,
        startTrackId: String?,
        artwork: (AudioTrack) -> Uri?,
    ): PreparedQueue? {
        val tracks = item.tracks
        if (tracks.isEmpty()) return null
        val requested = startTrackId?.let { id -> tracks.indexOfFirst { it.id == id } }?.takeIf { it >= 0 }
        val (index, position) = if (requested != null && tracks[requested].id != saved?.trackId) {
            requested to 0L
        } else {
            val plan = PlaybackResume.resolve(tracks, saved)
            plan.startIndex to (plan.positionMs ?: 0L)
        }
        return PreparedQueue(
            itemId = item.id,
            mediaItems = tracks.map { it.toMediaItem(item.id, artwork(it)) },
            startIndex = index,
            startPositionMs = position,
            speed = saved?.speed ?: item.defaultSpeed,
        )
    }

    fun AudioTrack.toMediaItem(itemId: String, artworkUri: Uri?): MediaItem = MediaItem.Builder()
        .setMediaId(id)
        .setUri(uri)
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(displayTitle)
                .setArtist(displayArtist)
                .setAlbumTitle(albumTag ?: directory.name)
                .setAlbumArtist(metadata.albumArtist)
                .setTrackNumber(displayTrackNumber)
                .setDiscNumber(displayDiscNumber)
                .setDurationMs(durationMs)
                .setArtworkUri(artworkUri)
                .setIsPlayable(true)
                .setIsBrowsable(false)
                .setMediaType(if (path.extension == "m4b") MediaMetadata.MEDIA_TYPE_AUDIO_BOOK else MediaMetadata.MEDIA_TYPE_MUSIC)
                .setExtras(PlaybackRequests.itemExtras(itemId, uri))
                .build(),
        )
        .build()
}

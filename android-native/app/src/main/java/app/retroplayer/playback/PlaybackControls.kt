package app.retroplayer.playback

import kotlinx.coroutines.flow.StateFlow

/** What the player shows right now; [hasTrack] is false until the engine has a playable queue. */
data class NowPlaying(
    val itemId: String? = null,
    val trackId: String? = null,
    val title: String? = null,
    val subtitle: String? = null,
    val artworkUri: String? = null,
    val isPlaying: Boolean = false,
    val hasTrack: Boolean = false,
    val positionMs: Long = 0,
    val durationMs: Long = 0,
    val speed: Float = 1f,
    val queueIndex: Int = 0,
    val queueSize: Int = 0,
    val hasPrevious: Boolean = false,
    val hasNext: Boolean = false,
)

/** The UI's handle on the playback service. */
interface PlaybackControls {
    val nowPlaying: StateFlow<NowPlaying>

    /** Plays a playback item, resuming its saved position unless another [startTrackId] is chosen. */
    fun play(itemId: String, startTrackId: String? = null)

    fun togglePlayPause()

    fun seekTo(positionMs: Long)

    /** 15 s back, stopping at a chapter start (the service player applies the rules). */
    fun jumpBack()

    fun jumpForward()

    fun skipToPrevious()

    fun skipToNext()

    fun setSpeed(speed: Float)

    /** Stops playback and drops the loaded queue (the stored queue and bookmarks stay). */
    fun stop()
}

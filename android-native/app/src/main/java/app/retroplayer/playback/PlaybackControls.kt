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
)

/** The UI's handle on the playback service. */
interface PlaybackControls {
    val nowPlaying: StateFlow<NowPlaying>

    /** Plays a playback item, resuming its saved position unless another [startTrackId] is chosen. */
    fun play(itemId: String, startTrackId: String? = null)
}

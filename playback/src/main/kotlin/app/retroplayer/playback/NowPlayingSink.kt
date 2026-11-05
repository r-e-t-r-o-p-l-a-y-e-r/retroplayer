package app.retroplayer.playback

import androidx.annotation.OptIn
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.common.util.Util

/** What surfaces outside the app (the home-screen widget) show of the session. */
data class NowPlayingSnapshot(
    val title: String? = null,
    val subtitle: String? = null,
    /** True while play is requested (also while buffering), so the button shows pause. */
    val isPlaying: Boolean = false,
    val artUri: String? = null,
) {
    companion object {
        @OptIn(UnstableApi::class)
        fun of(player: Player): NowPlayingSnapshot {
            if (player.currentMediaItem == null) return NowPlayingSnapshot()
            val metadata = player.mediaMetadata
            return NowPlayingSnapshot(
                title = metadata.title?.toString(),
                subtitle = (metadata.artist ?: metadata.albumTitle)?.toString(),
                isPlaying = !Util.shouldShowPlayButton(player),
                artUri = metadata.artworkUri?.toString(),
            )
        }
    }
}

/** Receives a snapshot whenever the service's player changes. */
fun interface NowPlayingSink {
    fun update(snapshot: NowPlayingSnapshot)
}

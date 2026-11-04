package app.retroplayer.playback

import androidx.media3.common.Player
import app.retroplayer.domain.model.SavedPlaybackState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Bookmarks the playing item: on pause, seek, skip and speed change, every [intervalMs] while playing,
 * and on demand (the app leaving). A finished queue is bookmarked at its start.
 * Must be used on the player's application thread.
 */
class ProgressSaver(
    private val player: Player,
    private val scope: CoroutineScope,
    private val intervalMs: Long = 10_000,
    private val save: suspend (itemId: String, state: SavedPlaybackState) -> Unit,
) : Player.Listener {
    private var ticker: Job? = null

    fun start() {
        player.addListener(this)
        updateTicker()
    }

    fun stop() {
        player.removeListener(this)
        ticker?.cancel()
        ticker = null
    }

    fun saveNow() {
        if (player.playbackState == Player.STATE_ENDED) return saveStart()
        val item = player.currentMediaItem ?: return
        val itemId = PlaybackRequests.itemIdOf(item) ?: return
        val state = SavedPlaybackState(
            trackId = item.mediaId,
            positionMs = player.currentPosition.coerceAtLeast(0),
            speed = player.playbackParameters.speed,
            displayTitle = item.mediaMetadata.title?.toString(),
            subtitle = (item.mediaMetadata.artist ?: item.mediaMetadata.albumTitle)?.toString(),
            durationMs = player.duration.takeIf { it > 0 } ?: item.mediaMetadata.durationMs,
        )
        scope.launch { save(itemId, state) }
    }

    private fun saveStart() {
        if (player.mediaItemCount == 0) return
        val first = player.getMediaItemAt(0)
        val itemId = PlaybackRequests.itemIdOf(first) ?: return
        val state = SavedPlaybackState(
            trackId = first.mediaId,
            positionMs = 0,
            speed = player.playbackParameters.speed,
            displayTitle = first.mediaMetadata.title?.toString(),
            subtitle = (first.mediaMetadata.artist ?: first.mediaMetadata.albumTitle)?.toString(),
            durationMs = first.mediaMetadata.durationMs,
        )
        scope.launch { save(itemId, state) }
    }

    override fun onEvents(player: Player, events: Player.Events) {
        if (events.contains(Player.EVENT_IS_PLAYING_CHANGED)) updateTicker()
        val ended = events.contains(Player.EVENT_PLAYBACK_STATE_CHANGED) && player.playbackState == Player.STATE_ENDED
        if (ended || events.containsAny(*SAVE_EVENTS)) saveNow()
    }

    private fun updateTicker() {
        if (player.isPlaying) {
            if (ticker?.isActive == true) return
            ticker = scope.launch {
                while (true) {
                    delay(intervalMs)
                    saveNow()
                }
            }
        } else {
            ticker?.cancel()
            ticker = null
        }
    }

    private companion object {
        val SAVE_EVENTS = intArrayOf(
            Player.EVENT_IS_PLAYING_CHANGED,
            Player.EVENT_POSITION_DISCONTINUITY,
            Player.EVENT_MEDIA_ITEM_TRANSITION,
            Player.EVENT_PLAYBACK_PARAMETERS_CHANGED,
        )
    }
}

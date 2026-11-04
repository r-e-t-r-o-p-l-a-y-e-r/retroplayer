package app.retroplayer.playback

import androidx.media3.common.C
import androidx.media3.common.ForwardingPlayer
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import app.retroplayer.domain.TransportRules
import app.retroplayer.domain.settings.HeadsetSettings

/**
 * The player every controller sees: ±15 s jumps that stop at chapter starts, and a short rewind when
 * a long track resumes after a long pause.
 */
@UnstableApi
class RetroPlayer(
    player: Player,
    private val rewind: AutoRewindTracker,
    private val headset: () -> HeadsetSettings,
    private val chapterStartsMs: () -> List<Long>,
) : ForwardingPlayer(player) {
    init {
        player.addListener(object : Player.Listener {
            override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {
                if (!playWhenReady && player.playbackState != Player.STATE_ENDED) rewind.onPaused()
            }

            override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) = rewind.reset()
        })
    }

    override fun getSeekBackIncrement(): Long = TransportRules.JUMP_MS

    override fun getSeekForwardIncrement(): Long = TransportRules.JUMP_MS

    override fun seekBack() = jump(-TransportRules.JUMP_MS)

    override fun seekForward() = jump(TransportRules.JUMP_MS)

    override fun play() {
        applyRewind()
        super.play()
    }

    override fun setPlayWhenReady(playWhenReady: Boolean) {
        if (playWhenReady && !this.playWhenReady) applyRewind()
        super.setPlayWhenReady(playWhenReady)
    }

    private fun jump(deltaMs: Long) {
        val duration = duration.takeIf { it != C.TIME_UNSET }
        seekTo(TransportRules.jumpTarget(currentPosition, deltaMs, duration, chapterStartsMs()))
    }

    private fun applyRewind() {
        val duration = duration.takeIf { it != C.TIME_UNSET }
        val back = rewind.rewindOnPlay(duration, currentPosition, headset())
        if (back > 0) seekTo(currentPosition - back)
    }
}

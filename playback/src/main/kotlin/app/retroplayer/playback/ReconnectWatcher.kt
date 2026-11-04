package app.retroplayer.playback

import android.annotation.SuppressLint
import android.media.AudioDeviceInfo
import androidx.media3.common.Player
import app.retroplayer.domain.ReconnectPolicy

/** Resumes playback when headphones come back shortly after their unplugging paused it. Main thread. */
class ReconnectWatcher(
    private val clock: () -> Long,
    private val enabled: () -> Boolean,
    private val play: () -> Unit,
) {
    private var pausedByNoisyAtMs: Long? = null

    fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {
        if (playWhenReady) {
            pausedByNoisyAtMs = null
        } else if (reason == Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY) {
            pausedByNoisyAtMs = clock()
        }
    }

    /** [types] are `AudioDeviceInfo.TYPE_*` of newly added outputs. */
    fun onOutputsAdded(types: List<Int>) {
        if (types.none { it in HEADPHONES }) return
        if (!ReconnectPolicy.shouldResume(pausedByNoisyAtMs, clock(), enabled())) return
        pausedByNoisyAtMs = null
        play()
    }

    private companion object {
        @SuppressLint("InlinedApi")
        val HEADPHONES = setOf(
            AudioDeviceInfo.TYPE_WIRED_HEADSET,
            AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
            AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
            AudioDeviceInfo.TYPE_USB_HEADSET,
            AudioDeviceInfo.TYPE_BLE_HEADSET,
        )
    }
}

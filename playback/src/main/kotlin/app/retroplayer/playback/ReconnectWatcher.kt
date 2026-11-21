package app.retroplayer.playback

import android.annotation.SuppressLint
import android.media.AudioDeviceInfo

/** An audio output: `AudioDeviceInfo.id` and `AudioDeviceInfo.TYPE_*`. */
data class Output(val id: Int, val type: Int)

/** Starts playback whenever headphones connect while the option is on. Main thread. */
class ReconnectWatcher(
    private val enabled: () -> Boolean,
    private val isPlaying: () -> Boolean,
    private val play: () -> Unit,
) {
    private val known = mutableSetOf<Output>()

    /** [current] are the outputs present at registration; they never start playback. */
    fun start(current: List<Output>) {
        known.clear()
        known += current
    }

    fun onOutputsAdded(added: List<Output>) {
        val connected = added.filter { it.type in HEADPHONES && it !in known }
        known += added
        if (connected.isNotEmpty() && enabled() && !isPlaying()) play()
    }

    fun onOutputsRemoved(removed: List<Output>) {
        known -= removed.toSet()
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

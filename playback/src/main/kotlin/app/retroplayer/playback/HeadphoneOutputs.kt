package app.retroplayer.playback

import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Handler
import android.os.Looper

/** Feeds the system's audio outputs into [watcher]. Register and unregister on the main thread. */
class HeadphoneOutputs(private val audioManager: AudioManager, private val watcher: ReconnectWatcher) {
    private val callback = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) =
            watcher.onOutputsAdded(addedDevices.outputs())

        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) =
            watcher.onOutputsRemoved(removedDevices.outputs())
    }

    fun register() {
        watcher.start(audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).outputs())
        audioManager.registerAudioDeviceCallback(callback, Handler(Looper.getMainLooper()))
    }

    fun unregister() = audioManager.unregisterAudioDeviceCallback(callback)

    // Not `isSink`: devices without a role (Robolectric's) count as outputs; headset microphones do not.
    private fun Array<out AudioDeviceInfo>.outputs() = filterNot { it.isSource }.map { Output(it.id, it.type) }
}

package app.retroplayer.playback

import android.media.AudioDeviceInfo
import androidx.media3.common.Player
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReconnectWatcherTest {
    private var now = 1_000_000L
    private var enabled = true
    private var plays = 0
    private val watcher = ReconnectWatcher(clock = { now }, enabled = { enabled }, play = { plays++ })

    private fun unplug() = watcher.onPlayWhenReadyChanged(false, Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY)

    @Test
    fun `headphones back soon after unplugging resume playback once`() {
        unplug()
        now += 30_000
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_BLUETOOTH_A2DP))
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_BLUETOOTH_A2DP))
        assertThat(plays).isEqualTo(1)
    }

    @Test
    fun `a pause by the user is not resumed`() {
        watcher.onPlayWhenReadyChanged(false, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_WIRED_HEADSET))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `playing again forgets the unplugging`() {
        unplug()
        watcher.onPlayWhenReadyChanged(true, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
        watcher.onPlayWhenReadyChanged(false, Player.PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_WIRED_HEADPHONES))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `outputs that are not headphones are ignored`() {
        unplug()
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_BUILTIN_SPEAKER, AudioDeviceInfo.TYPE_HDMI))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `nothing resumes while the option is off`() {
        enabled = false
        unplug()
        watcher.onOutputsAdded(listOf(AudioDeviceInfo.TYPE_USB_HEADSET))
        assertThat(plays).isEqualTo(0)
    }
}

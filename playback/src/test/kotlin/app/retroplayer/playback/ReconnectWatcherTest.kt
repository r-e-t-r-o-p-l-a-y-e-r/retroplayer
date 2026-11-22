package app.retroplayer.playback

import android.media.AudioDeviceInfo
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReconnectWatcherTest {
    private var enabled = true
    private var playing = false
    private var plays = 0
    private val watcher = ReconnectWatcher(enabled = { enabled }, isPlaying = { playing }, play = { plays++ })

    private val car = Output(id = 7, type = AudioDeviceInfo.TYPE_BLUETOOTH_A2DP)
    private val carBle = Output(id = 8, type = AudioDeviceInfo.TYPE_BLE_HEADSET)
    private val wired = Output(id = 3, type = AudioDeviceInfo.TYPE_WIRED_HEADPHONES)
    private val speaker = Output(id = 1, type = AudioDeviceInfo.TYPE_BUILTIN_SPEAKER)

    @Test
    fun `a headphone connecting starts playback when the option is on`() {
        watcher.start(listOf(speaker))
        watcher.onOutputsAdded(listOf(car))
        assertThat(plays).isEqualTo(1)
    }

    @Test
    fun `headphones already connected at start do not start playback`() {
        watcher.start(listOf(speaker, wired))
        watcher.onOutputsAdded(listOf(wired))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `one connect reporting several outputs plays once`() {
        watcher.start(listOf(speaker))
        watcher.onOutputsAdded(listOf(car, carBle))
        watcher.onOutputsAdded(listOf(car))
        assertThat(plays).isEqualTo(1)
    }

    @Test
    fun `disconnect and reconnect plays again each time`() {
        watcher.start(listOf(speaker, car))
        repeat(3) {
            watcher.onOutputsRemoved(listOf(car))
            watcher.onOutputsAdded(listOf(car))
        }
        assertThat(plays).isEqualTo(3)
    }

    @Test
    fun `a connect long after the pause still plays`() {
        watcher.start(listOf(speaker, wired))
        watcher.onOutputsRemoved(listOf(wired))
        watcher.onOutputsAdded(listOf(car))
        assertThat(plays).isEqualTo(1)
    }

    @Test
    fun `a connect while playing does nothing`() {
        playing = true
        watcher.start(listOf(speaker))
        watcher.onOutputsAdded(listOf(car))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `outputs that are not headphones are ignored`() {
        watcher.start(emptyList())
        watcher.onOutputsAdded(listOf(speaker, Output(id = 9, type = AudioDeviceInfo.TYPE_HDMI)))
        assertThat(plays).isEqualTo(0)
    }

    @Test
    fun `nothing plays while the option is off`() {
        enabled = false
        watcher.start(listOf(speaker))
        watcher.onOutputsAdded(listOf(Output(id = 4, type = AudioDeviceInfo.TYPE_USB_HEADSET)))
        assertThat(plays).isEqualTo(0)
    }
}

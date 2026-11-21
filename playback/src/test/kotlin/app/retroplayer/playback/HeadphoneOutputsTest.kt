package app.retroplayer.playback

import android.content.Context
import android.content.Intent
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.test.core.app.ApplicationProvider
import com.google.common.truth.Truth.assertThat
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.shadows.AudioDeviceInfoBuilder

@RunWith(RobolectricTestRunner::class)
class HeadphoneOutputsTest {
    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val audioManager = context.getSystemService(AudioManager::class.java)
    private val car = AudioDeviceInfoBuilder.newBuilder().setType(AudioDeviceInfo.TYPE_BLUETOOTH_A2DP).build()
    private lateinit var exo: ExoPlayer
    private lateinit var outputs: HeadphoneOutputs

    @Before
    fun setUp() {
        exo = TestExoPlayerBuilder(context).setMediaSourceFactory(FakeMediaSourceFactory()).build()
        exo.setHandleAudioBecomingNoisy(true)
        exo.setMediaItem(MediaItem.fromUri("doc:a"))
        exo.prepare()
        advance(exo).untilState(Player.STATE_READY)
        outputs = HeadphoneOutputs(audioManager, ReconnectWatcher({ true }, { exo.playWhenReady }, exo::play))
    }

    @After
    fun tearDown() {
        outputs.unregister()
        exo.release()
    }

    private fun idle() {
        advance(exo).untilPendingCommandsAreFullyHandled()
        shadowOf(Looper.getMainLooper()).idle()
    }

    private fun connect(device: AudioDeviceInfo) {
        shadowOf(audioManager).addOutputDevice(device, true)
        idle()
    }

    private fun disconnect(device: AudioDeviceInfo) {
        context.sendBroadcast(Intent(AudioManager.ACTION_AUDIO_BECOMING_NOISY))
        shadowOf(audioManager).removeOutputDevice(device, true)
        idle()
    }

    @Test
    fun `bluetooth disconnect pauses and reconnect resumes`() {
        connect(car)
        outputs.register()
        exo.play()
        idle()

        repeat(2) {
            disconnect(car)
            assertThat(exo.playWhenReady).isFalse()
            connect(car)
            assertThat(exo.playWhenReady).isTrue()
        }
    }

    @Test
    fun `headphones present when registering do not start playback`() {
        connect(car)
        outputs.register()
        idle()
        assertThat(exo.playWhenReady).isFalse()
    }

    @Test
    fun `unregister stops reacting to new devices`() {
        outputs.register()
        outputs.unregister()
        connect(car)
        assertThat(exo.playWhenReady).isFalse()
    }
}

package app.retroplayer.playback

import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.FakeTimeline
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.domain.TransportRules
import app.retroplayer.domain.settings.HeadsetSettings
import com.google.common.truth.Truth.assertThat
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class RetroPlayerTest {
    private lateinit var exo: ExoPlayer
    private lateinit var player: RetroPlayer
    private var now = 0L
    private var chapters = emptyList<Long>()
    private var headset = HeadsetSettings(autoRewind = true, autoRewindSeconds = 10)
    private val hourUs = 60 * 60 * 1_000_000L

    @Before
    fun setUp() {
        exo = TestExoPlayerBuilder(ApplicationProvider.getApplicationContext())
            .setMediaSourceFactory(FakeMediaSourceFactory(FakeTimeline.TimelineWindowDefinition.Builder().setDurationUs(hourUs).setDefaultPositionUs(0)))
            .build()
        player = RetroPlayer(exo, AutoRewindTracker { now }, headset = { headset }, chapterStartsMs = { chapters })
        player.setMediaItems(listOf(MediaItem.fromUri("doc:a"), MediaItem.fromUri("doc:b")))
        player.prepare()
        advance(exo).untilState(Player.STATE_READY)
    }

    @After
    fun tearDown() = exo.release()

    private fun idle() {
        advance(exo).untilPendingCommandsAreFullyHandled()
        shadowOf(Looper.getMainLooper()).idle()
    }

    @Test
    fun `jump increments are fifteen seconds`() {
        assertThat(player.seekBackIncrement).isEqualTo(TransportRules.JUMP_MS)
        assertThat(player.seekForwardIncrement).isEqualTo(TransportRules.JUMP_MS)
    }

    @Test
    fun `jumps move fifteen seconds and clamp at the start`() {
        player.seekTo(100_000)
        player.seekForward()
        assertThat(player.currentPosition).isEqualTo(115_000)
        player.seekTo(5_000)
        player.seekBack()
        assertThat(player.currentPosition).isEqualTo(0)
    }

    @Test
    fun `jumps stop at a chapter start`() {
        chapters = listOf(0L, 110_000L)
        player.seekTo(100_000)
        player.seekForward()
        assertThat(player.currentPosition).isEqualTo(110_000)
        player.seekTo(120_000)
        player.seekBack()
        assertThat(player.currentPosition).isEqualTo(110_000)
    }

    @Test
    fun `resuming after a long pause rewinds`() {
        player.seekTo(300_000)
        player.play()
        idle()
        player.pause()
        idle()
        now += 10 * 60_000
        val before = player.currentPosition
        player.play()
        assertThat(player.currentPosition).isEqualTo(before - 10_000)
    }

    @Test
    fun `auto rewind can be switched off`() {
        headset = headset.copy(autoRewind = false)
        player.seekTo(300_000)
        player.play()
        idle()
        player.pause()
        idle()
        now += 10 * 60_000
        val before = player.currentPosition
        player.play()
        assertThat(player.currentPosition).isEqualTo(before)
    }

    @Test
    fun `skipping to another track while paused does not rewind`() {
        player.seekTo(300_000)
        player.play()
        idle()
        player.pause()
        idle()
        player.seekToNextMediaItem()
        idle()
        player.seekTo(200_000)
        now += 10 * 60_000
        player.play()
        assertThat(player.currentPosition).isEqualTo(200_000)
    }
}

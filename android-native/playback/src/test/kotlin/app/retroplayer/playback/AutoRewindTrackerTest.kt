package app.retroplayer.playback

import app.retroplayer.domain.settings.HeadsetSettings
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class AutoRewindTrackerTest {
    private var now = 1_000_000L
    private val tracker = AutoRewindTracker { now }
    private val longTrack = 60 * 60_000L
    private val settings = HeadsetSettings(autoRewind = true, autoRewindSeconds = 5)

    @Test
    fun `no rewind without a pause`() {
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(0)
    }

    @Test
    fun `long pause on a long track rewinds once`() {
        tracker.onPaused()
        now += 5 * 60_000
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(5_000)
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(0)
    }

    @Test
    fun `short pause does not rewind`() {
        tracker.onPaused()
        now += 10_000
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(0)
    }

    @Test
    fun `changing track forgets the pause`() {
        tracker.onPaused()
        now += 5 * 60_000
        tracker.reset()
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(0)
    }

    @Test
    fun `the first pause counts when paused repeatedly`() {
        tracker.onPaused()
        now += 50_000
        tracker.onPaused()
        now += 20_000
        assertThat(tracker.rewindOnPlay(longTrack, 100_000, settings)).isEqualTo(5_000)
    }
}

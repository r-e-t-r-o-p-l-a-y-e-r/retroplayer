package app.retroplayer.domain

import app.retroplayer.domain.settings.HeadsetSettings
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class TransportRulesTest {
    @Test
    fun `jump moves by fifteen seconds and stops at track bounds`() {
        assertThat(TransportRules.JUMP_MS).isEqualTo(15_000)
        assertThat(TransportRules.jumpTarget(positionMs = 40_000, deltaMs = 15_000, durationMs = 100_000)).isEqualTo(55_000)
        assertThat(TransportRules.jumpTarget(5_000, -15_000, 100_000)).isEqualTo(0)
        assertThat(TransportRules.jumpTarget(95_000, 15_000, 100_000)).isEqualTo(100_000)
        assertThat(TransportRules.jumpTarget(95_000, 15_000, null)).isEqualTo(110_000)
    }

    @Test
    fun `jump stops at chapter starts when chapters are known`() {
        val chapters = listOf(0L, 60_000L, 120_000L)
        assertThat(TransportRules.jumpTarget(65_000, -15_000, 200_000, chapters)).isEqualTo(60_000)
        assertThat(TransportRules.jumpTarget(60_000, -15_000, 200_000, chapters)).isEqualTo(45_000)
        assertThat(TransportRules.jumpTarget(110_000, 15_000, 200_000, chapters)).isEqualTo(120_000)
    }

    @Test
    fun `speed is limited to half to double speed`() {
        assertThat(TransportRules.clampSpeed(0.1f)).isEqualTo(0.5f)
        assertThat(TransportRules.clampSpeed(3f)).isEqualTo(2f)
        assertThat(TransportRules.clampSpeed(1.25f)).isEqualTo(1.25f)
    }

    @Test
    fun `auto rewind only after a long pause in a long track`() {
        val settings = HeadsetSettings.DEFAULT
        val longTrack = 30 * 60_000L
        assertThat(TransportRules.autoRewindMs(pausedForMs = 120_000, trackDurationMs = longTrack, positionMs = 600_000, settings = settings))
            .isEqualTo(settings.autoRewindSeconds * 1000L)
        assertThat(TransportRules.autoRewindMs(5_000, longTrack, 600_000, settings)).isEqualTo(0)
        assertThat(TransportRules.autoRewindMs(120_000, 3 * 60_000L, 60_000, settings)).isEqualTo(0)
        assertThat(TransportRules.autoRewindMs(120_000, longTrack, 1_000, settings)).isEqualTo(1_000)
        assertThat(TransportRules.autoRewindMs(120_000, longTrack, 600_000, settings.copy(autoRewind = false))).isEqualTo(0)
    }
}

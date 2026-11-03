package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReconnectPolicyTest {
    private val now = 100_000_000L

    @Test
    fun `resumes when enabled and unplugged a minute ago`() {
        assertThat(ReconnectPolicy.shouldResume(pausedByNoisyAtMs = now - 60_000, nowMs = now, enabled = true)).isTrue()
    }

    @Test
    fun `does not resume when the option is off`() {
        assertThat(ReconnectPolicy.shouldResume(pausedByNoisyAtMs = now - 60_000, nowMs = now, enabled = false)).isFalse()
    }

    @Test
    fun `does not resume when playback was not paused by unplugging`() {
        assertThat(ReconnectPolicy.shouldResume(pausedByNoisyAtMs = null, nowMs = now, enabled = true)).isFalse()
    }

    @Test
    fun `does not resume ten minutes or more after unplugging`() {
        assertThat(ReconnectPolicy.shouldResume(pausedByNoisyAtMs = now - ReconnectPolicy.WINDOW_MS, nowMs = now, enabled = true)).isFalse()
        assertThat(ReconnectPolicy.shouldResume(pausedByNoisyAtMs = now - ReconnectPolicy.WINDOW_MS + 1, nowMs = now, enabled = true)).isTrue()
    }
}

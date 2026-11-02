package app.retroplayer.ui

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.util.Locale

class FormatTest {
    @Test
    fun `durations show padded minutes and seconds, hours only when needed`() {
        assertThat(formatDuration(0)).isEqualTo("00:00")
        assertThat(formatDuration(5_000)).isEqualTo("00:05")
        assertThat(formatDuration(65_999)).isEqualTo("01:05")
        assertThat(formatDuration(59 * 60_000L + 59_000)).isEqualTo("59:59")
        assertThat(formatDuration(3_600_000)).isEqualTo("01:00:00")
        assertThat(formatDuration(10 * 3_600_000L + 61_000)).isEqualTo("10:01:01")
    }

    @Test
    fun `negative or unknown durations show as zero`() {
        assertThat(formatDuration(-1)).isEqualTo("00:00")
    }

    @Test
    fun `speed shows without trailing zeros`() {
        assertThat(formatSpeed(1f, Locale.US)).isEqualTo("1×")
        assertThat(formatSpeed(1.5f, Locale.US)).isEqualTo("1.5×")
        assertThat(formatSpeed(0.75f, Locale.US)).isEqualTo("0.75×")
    }

    @Test
    fun `speed uses the locale decimal separator`() {
        assertThat(formatSpeed(1.25f, Locale.GERMANY)).isEqualTo("1,25×")
    }
}

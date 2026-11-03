package app.retroplayer.ui.settings

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.time.ZoneId

class BuildTimeTest {
    @Test
    fun `build time shows date and time of day in the device zone`() {
        // 2026-11-03T21:10:49Z
        assertThat(buildTimeLabel(1_793_740_249, ZoneId.of("Europe/Zurich"))).isEqualTo("2026-11-03 22:10:49")
    }

    @Test
    fun `an unknown build time stays unknown`() {
        assertThat(buildTimeLabel(0, ZoneId.of("UTC"))).isEqualTo("unknown")
    }
}

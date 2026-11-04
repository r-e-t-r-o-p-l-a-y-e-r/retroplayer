package app.retroplayer.domain

import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class EqualizerTest {
    @Test
    fun `presets have five gains matching the standard bands`() {
        assertThat(EqualizerSettings.BAND_HZ).containsExactly(60, 230, 910, 3600, 14000).inOrder()
        assertThat(EqualizerPreset.BASS_BOOST.gainsDb).containsExactly(6f, 4f, 1f, 0f, 0f).inOrder()
        assertThat(EqualizerPreset.TREBLE_BOOST.gainsDb).containsExactly(0f, 0f, 1f, 4f, 5f).inOrder()
        assertThat(EqualizerPreset.VOICE.gainsDb).containsExactly(-4f, 5f, 3f, 1f, -2f).inOrder()
        EqualizerPreset.entries.forEach { assertThat(it.gainsDb).hasSize(5) }
    }

    @Test
    fun `default is off and flat`() {
        val default = EqualizerSettings.DEFAULT
        assertThat(default.enabled).isFalse()
        assertThat(default.effectiveGainsDb()).containsExactly(0f, 0f, 0f, 0f, 0f).inOrder()
    }

    @Test
    fun `effective gains come from the preset unless manual`() {
        val preset = EqualizerSettings(enabled = true, preset = EqualizerPreset.VOICE, manualGainsDb = listOf(1f, 1f, 1f, 1f, 1f))
        assertThat(preset.effectiveGainsDb()).isEqualTo(EqualizerPreset.VOICE.gainsDb)
        assertThat(preset.copy(preset = EqualizerPreset.MANUAL).effectiveGainsDb()).containsExactly(1f, 1f, 1f, 1f, 1f)
        assertThat(preset.copy(enabled = false).effectiveGainsDb()).containsExactly(0f, 0f, 0f, 0f, 0f)
    }

    @Test
    fun `device bands take the gain of the nearest standard band on a log scale`() {
        val settings = EqualizerSettings(enabled = true, preset = EqualizerPreset.BASS_BOOST)
        // Typical Android 5-band layout (center frequencies in Hz).
        assertThat(settings.gainsForDevice(listOf(60, 230, 910, 3600, 14000))).isEqualTo(EqualizerPreset.BASS_BOOST.gainsDb)
        // A 3-band device: 100 Hz is nearest 60, 1 kHz nearest 910, 10 kHz nearest 14 kHz.
        assertThat(settings.gainsForDevice(listOf(100, 1000, 10000))).containsExactly(6f, 1f, 0f).inOrder()
    }

    @Test
    fun `gains are clamped to the device range`() {
        val settings = EqualizerSettings(enabled = true, preset = EqualizerPreset.MANUAL, manualGainsDb = listOf(20f, -20f, 0f, 0f, 0f))
        assertThat(settings.gainsForDevice(listOf(60, 230), minDb = -15f, maxDb = 15f)).containsExactly(15f, -15f).inOrder()
    }
}

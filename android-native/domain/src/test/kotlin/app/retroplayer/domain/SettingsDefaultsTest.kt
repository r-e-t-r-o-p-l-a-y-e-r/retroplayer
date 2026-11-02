package app.retroplayer.domain

import app.retroplayer.domain.settings.AppSettings
import app.retroplayer.domain.settings.ThemePreference
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class SettingsDefaultsTest {
    @Test
    fun `defaults are system theme and language, equalizer off, speed one`() {
        val d = AppSettings.DEFAULT
        assertThat(d.theme).isEqualTo(ThemePreference.SYSTEM)
        assertThat(d.languageTag).isNull()
        assertThat(d.equalizer.enabled).isFalse()
        assertThat(AppSettings.DEFAULT_SPEED).isEqualTo(1f)
    }

    @Test
    fun `theme parses stored values and falls back to system`() {
        assertThat(ThemePreference.fromStorage("dark")).isEqualTo(ThemePreference.DARK)
        assertThat(ThemePreference.fromStorage(null)).isEqualTo(ThemePreference.SYSTEM)
        assertThat(ThemePreference.fromStorage("neon")).isEqualTo(ThemePreference.SYSTEM)
        assertThat(ThemePreference.LIGHT.storage).isEqualTo("light")
    }
}

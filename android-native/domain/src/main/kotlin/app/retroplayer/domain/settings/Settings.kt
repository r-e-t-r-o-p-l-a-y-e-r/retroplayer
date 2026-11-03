package app.retroplayer.domain.settings

import kotlin.math.abs
import kotlin.math.ln

enum class ThemePreference(val storage: String) {
    SYSTEM("system"), LIGHT("light"), DARK("dark");

    companion object {
        fun fromStorage(value: String?): ThemePreference = entries.firstOrNull { it.storage == value } ?: SYSTEM
    }
}

enum class EqualizerPreset(val gainsDb: List<Float>) {
    MANUAL(listOf(0f, 0f, 0f, 0f, 0f)),
    BASS_BOOST(listOf(6f, 4f, 1f, 0f, 0f)),
    TREBLE_BOOST(listOf(0f, 0f, 1f, 4f, 5f)),
    VOICE(listOf(-4f, 5f, 3f, 1f, -2f)),
}

data class EqualizerSettings(
    val enabled: Boolean = false,
    val preset: EqualizerPreset = EqualizerPreset.MANUAL,
    val manualGainsDb: List<Float> = FLAT,
) {
    fun effectiveGainsDb(): List<Float> = when {
        !enabled -> FLAT
        preset == EqualizerPreset.MANUAL -> manualGainsDb
        else -> preset.gainsDb
    }

    /** Gains for a device's bands: each takes the nearest standard band (log frequency), clamped to the device range. */
    fun gainsForDevice(deviceCentersHz: List<Int>, minDb: Float = -15f, maxDb: Float = 15f): List<Float> {
        val gains = effectiveGainsDb()
        return deviceCentersHz.map { center ->
            val nearest = BAND_HZ.indices.minBy { abs(ln(BAND_HZ[it].toDouble()) - ln(center.coerceAtLeast(1).toDouble())) }
            gains[nearest].coerceIn(minDb, maxDb)
        }
    }

    companion object {
        val BAND_HZ = listOf(60, 230, 910, 3600, 14000)
        val FLAT = listOf(0f, 0f, 0f, 0f, 0f)
        val DEFAULT = EqualizerSettings()
    }
}

data class HeadsetSettings(
    val autoRewind: Boolean = true,
    val autoRewindSeconds: Int = 5,
    val resumeOnReconnect: Boolean = false,
) {
    companion object {
        val DEFAULT = HeadsetSettings()
    }
}

/** User settings. Every field has its default here; storage keeps only values that differ. */
data class AppSettings(
    val theme: ThemePreference = ThemePreference.SYSTEM,
    val equalizer: EqualizerSettings = EqualizerSettings.DEFAULT,
    val headset: HeadsetSettings = HeadsetSettings.DEFAULT,
) {
    companion object {
        const val DEFAULT_SPEED = 1f
        val DEFAULT = AppSettings()
    }
}

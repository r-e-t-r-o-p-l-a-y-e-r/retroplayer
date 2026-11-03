package app.retroplayer.playback

import android.media.audiofx.AudioEffect
import android.media.audiofx.Equalizer
import app.retroplayer.domain.settings.EqualizerSettings
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

/** One audio effect bound to one audio session. */
interface EqualizerEngine {
    val centersHz: List<Int>
    val rangeDb: ClosedFloatingPointRange<Float>
    fun apply(gainsDb: List<Float>)
    fun setEnabled(enabled: Boolean)
    fun release()
}

/** What the device equalizer offers; null where it reports one means unavailable. */
data class EqualizerInfo(val centersHz: List<Int>, val rangeDb: ClosedFloatingPointRange<Float>)

/** Whether the platform offers an equalizer effect at all, before any audio session exists. */
fun interface EqualizerProbe {
    fun deviceHasEqualizer(): Boolean
}

/**
 * The device equalizer for the settings UI: [supported] from the [EqualizerProbe],
 * [info] as the playback service last saw it on a live session (null = none).
 */
@Singleton
class EqualizerAvailability @Inject constructor(private val probe: EqualizerProbe) {
    val supported: Boolean by lazy { runCatching { probe.deviceHasEqualizer() }.getOrDefault(false) }

    private val current = MutableStateFlow<EqualizerInfo?>(null)
    val info: StateFlow<EqualizerInfo?> = current.asStateFlow()

    fun report(info: EqualizerInfo?) {
        current.value = info
    }
}

/**
 * Keeps one [EqualizerEngine] on the player's current audio session and
 * applies the latest settings to it. [create] returns null when the device
 * has no usable equalizer; [report] gets the device bands or null.
 */
class EqualizerBinder(
    private val create: (sessionId: Int) -> EqualizerEngine?,
    private val report: (EqualizerInfo?) -> Unit,
) {
    private var engine: EqualizerEngine? = null
    private var sessionId = NO_SESSION
    private var settings = EqualizerSettings.DEFAULT

    fun onSession(id: Int) {
        if (id == NO_SESSION || id == sessionId) return
        engine?.release()
        sessionId = id
        engine = runCatching { create(id) }.getOrNull()
        report(engine?.let { EqualizerInfo(it.centersHz, it.rangeDb) })
        applySettings()
    }

    fun onSettings(value: EqualizerSettings) {
        settings = value
        applySettings()
    }

    fun release() {
        engine?.release()
        engine = null
        sessionId = NO_SESSION
        report(null)
    }

    private fun applySettings() {
        val current = engine ?: return
        runCatching {
            if (settings.enabled) {
                current.apply(settings.gainsForDevice(current.centersHz, current.rangeDb.start, current.rangeDb.endInclusive))
            }
            current.setEnabled(settings.enabled)
        }
    }

    companion object {
        /** Media3's `C.AUDIO_SESSION_ID_UNSET`. */
        const val NO_SESSION = 0
    }
}

/** [EqualizerEngine] over the platform effect (gains in millibels). */
class AudioFxEqualizer(sessionId: Int) : EqualizerEngine {
    private val effect = Equalizer(0, sessionId)

    override val centersHz: List<Int> = (0 until effect.numberOfBands).map { effect.getCenterFreq(it.toShort()) / 1000 }

    override val rangeDb: ClosedFloatingPointRange<Float> = effect.bandLevelRange.let { (it[0] / 100f)..(it[1] / 100f) }

    override fun apply(gainsDb: List<Float>) {
        gainsDb.forEachIndexed { band, db -> effect.setBandLevel(band.toShort(), (db * 100).toInt().toShort()) }
    }

    override fun setEnabled(enabled: Boolean) {
        effect.enabled = enabled
    }

    override fun release() = effect.release()

    companion object {
        fun deviceHasEqualizer(): Boolean =
            AudioEffect.queryEffects().orEmpty().any { it.type == AudioEffect.EFFECT_TYPE_EQUALIZER }

        /** Null when the device has no equalizer for this session. */
        fun createOrNull(sessionId: Int): EqualizerEngine? = runCatching { AudioFxEqualizer(sessionId) }.getOrNull()
    }
}

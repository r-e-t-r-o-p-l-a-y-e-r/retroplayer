package app.retroplayer

import android.media.audiofx.Equalizer
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class EqualizerPlugin : MethodChannel.MethodCallHandler {
    private var equalizer: Equalizer? = null
    private var sessionId: Int = 0

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app.retroplayer/equalizer",
        ).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (!enabled) {
                    releaseEqualizer()
                }
                result.success(null)
            }
            "setBands" -> {
                val session = call.argument<Int>("sessionId")
                val enabled = call.argument<Boolean>("enabled") ?: false
                @Suppress("UNCHECKED_CAST")
                val bands = call.argument<List<Map<String, Any>>>("bands")

                if (session == null || bands == null) {
                    result.error("invalid_args", "sessionId and bands required", null)
                    return
                }

                if (!enabled) {
                    releaseEqualizer()
                    result.success(null)
                    return
                }

                try {
                    attachEqualizer(session)
                    applyBands(bands)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("equalizer_error", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun attachEqualizer(session: Int) {
        if (equalizer != null && sessionId == session) return
        releaseEqualizer()
        sessionId = session
        equalizer = Equalizer(0, session).apply { enabled = true }
    }

    private fun applyBands(bands: List<Map<String, Any>>) {
        val eq = equalizer ?: return
        val targetHz = bands.map { (it["hz"] as Number).toInt() }
        val targetGainMilliBel =
            bands.map { ((it["gainDb"] as Number).toDouble() * 100).toInt() }

        for (i in 0 until eq.numberOfBands) {
            val range = eq.getBandFreqRange(i.toShort())
            val centerHz = (range[0] + range[1]) / 2
            var nearest = 0
            var nearestDelta = Int.MAX_VALUE
            for (j in targetHz.indices) {
                val delta = kotlin.math.abs(centerHz - targetHz[j])
                if (delta < nearestDelta) {
                    nearestDelta = delta
                    nearest = j
                }
            }
            val gainMb = targetGainMilliBel[nearest].coerceIn(
                eq.bandLevelRange[0].toInt(),
                eq.bandLevelRange[1].toInt(),
            )
            eq.setBandLevel(i.toShort(), gainMb.toShort())
        }
    }

    private fun releaseEqualizer() {
        equalizer?.release()
        equalizer = null
        sessionId = 0
    }
}

package app.retroplayer.playback

import app.retroplayer.domain.TransportRules
import app.retroplayer.domain.settings.HeadsetSettings

/** Remembers when playback paused so resuming a long track can step back a few seconds. */
class AutoRewindTracker(private val clock: () -> Long) {
    private var pausedAt: Long? = null

    fun onPaused() {
        if (pausedAt == null) pausedAt = clock()
    }

    fun reset() {
        pausedAt = null
    }

    fun rewindOnPlay(durationMs: Long?, positionMs: Long, settings: HeadsetSettings): Long {
        val since = pausedAt ?: return 0
        pausedAt = null
        return TransportRules.autoRewindMs(clock() - since, durationMs, positionMs, settings)
    }
}

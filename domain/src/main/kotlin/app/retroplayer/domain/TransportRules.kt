package app.retroplayer.domain

import app.retroplayer.domain.settings.HeadsetSettings

object TransportRules {
    const val JUMP_MS = 15_000L
    const val MIN_SPEED = 0.5f
    const val MAX_SPEED = 2f

    /** Pauses shorter than this never rewind. */
    const val AUTO_REWIND_MIN_PAUSE_MS = 60_000L

    /** Only long tracks (audiobook chapters, lectures) rewind; music does not. */
    const val AUTO_REWIND_MIN_TRACK_MS = 20 * 60_000L

    /** Target of a ±jump: clamped to the track and stopped at the first chapter start it crosses. */
    fun jumpTarget(positionMs: Long, deltaMs: Long, durationMs: Long?, chapterStartsMs: List<Long> = emptyList()): Long {
        var target = (positionMs + deltaMs).coerceAtLeast(0)
        if (durationMs != null && durationMs > 0) target = target.coerceAtMost(durationMs)
        val crossed = if (deltaMs < 0) {
            chapterStartsMs.filter { it in (target + 1) until positionMs }.maxOrNull()
        } else {
            chapterStartsMs.filter { it in (positionMs + 1) until target }.minOrNull()
        }
        return crossed ?: target
    }

    fun clampSpeed(speed: Float): Float = speed.coerceIn(MIN_SPEED, MAX_SPEED)

    fun autoRewindMs(pausedForMs: Long, trackDurationMs: Long?, positionMs: Long, settings: HeadsetSettings): Long {
        if (!settings.autoRewind || pausedForMs < AUTO_REWIND_MIN_PAUSE_MS) return 0
        if ((trackDurationMs ?: 0) < AUTO_REWIND_MIN_TRACK_MS) return 0
        return minOf(settings.autoRewindSeconds * 1000L, positionMs.coerceAtLeast(0))
    }
}

package app.retroplayer.domain

/** Whether headphones coming back should resume playback that their unplugging paused. */
object ReconnectPolicy {
    const val WINDOW_MS = 10 * 60_000L

    fun shouldResume(pausedByNoisyAtMs: Long?, nowMs: Long, enabled: Boolean): Boolean =
        enabled && pausedByNoisyAtMs != null && nowMs - pausedByNoisyAtMs in 0 until WINDOW_MS
}

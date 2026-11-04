package app.retroplayer.domain

import app.retroplayer.domain.model.Chapter

/** Chapter skips inside one track, like track skips: "previous" first restarts the current chapter. */
object ChapterNavigation {
    /** Within this time after a chapter start, "previous" goes to the chapter before. */
    const val RESTART_WINDOW_MS = 3_000L

    fun current(chapters: List<Chapter>, positionMs: Long): Chapter? =
        chapters.filter { it.startMs <= positionMs }.maxByOrNull { it.startMs }

    /** Start of the next chapter, or null in the last one. */
    fun next(chapters: List<Chapter>, positionMs: Long): Long? =
        chapters.map { it.startMs }.filter { it > positionMs }.minOrNull()

    fun previous(chapters: List<Chapter>, positionMs: Long): Long? {
        val starts = chapters.map { it.startMs }.sorted()
        val current = starts.lastOrNull { it <= positionMs } ?: return starts.firstOrNull()
        if (positionMs - current >= RESTART_WINDOW_MS) return current
        return starts.lastOrNull { it < current } ?: current
    }
}

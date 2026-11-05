package app.retroplayer.domain

/** Edits of the user's queue (UC-08). Each path appears at most once; invalid indices change nothing. */
object QueueEdits {
    fun add(queue: List<LibraryPath>, paths: List<LibraryPath>): List<LibraryPath> =
        (queue + paths).distinct()

    fun move(queue: List<LibraryPath>, from: Int, to: Int): List<LibraryPath> {
        if (from !in queue.indices || to !in queue.indices) return queue
        return queue.toMutableList().apply { add(to, removeAt(from)) }
    }

    fun remove(queue: List<LibraryPath>, index: Int): List<LibraryPath> {
        if (index !in queue.indices) return queue
        return queue.toMutableList().apply { removeAt(index) }
    }
}

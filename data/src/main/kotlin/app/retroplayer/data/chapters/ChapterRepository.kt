package app.retroplayer.data.chapters

import app.retroplayer.domain.model.Chapter
import kotlinx.coroutines.CancellationException
import java.util.Collections

/** Reads the chapters of one audio document (read only); may throw when the file cannot be opened. */
fun interface ChapterSource {
    suspend fun read(uri: String): List<Chapter>
}

/**
 * Chapters of audiobook files, read when a track plays and kept for the process.
 * Shared by the playback service and the UI, which run in the same process.
 */
class ChapterRepository(private val source: ChapterSource) {
    private val cache: MutableMap<String, List<Chapter>> = Collections.synchronizedMap(
        object : LinkedHashMap<String, List<Chapter>>(MAX_CACHED, 0.75f, true) {
            override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, List<Chapter>>) = size > MAX_CACHED
        },
    )

    suspend fun chapters(uri: String, fileName: String): List<Chapter> {
        if (fileName.substringAfterLast('.', "").lowercase() !in CHAPTER_FORMATS) return emptyList()
        cache[uri]?.let { return it }
        val read = try {
            source.read(uri).sortedBy { it.startMs }
        } catch (cancelled: CancellationException) {
            throw cancelled
        } catch (_: Exception) {
            emptyList()
        }
        cache[uri] = read
        return read
    }

    /** Chapters already read for [uri], or null. */
    fun cached(uri: String): List<Chapter>? = cache[uri]

    private companion object {
        const val MAX_CACHED = 32
        val CHAPTER_FORMATS = setOf("m4b", "m4a", "mp4")
    }
}

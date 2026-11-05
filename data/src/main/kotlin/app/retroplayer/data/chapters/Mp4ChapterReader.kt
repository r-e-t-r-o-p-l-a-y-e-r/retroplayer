package app.retroplayer.data.chapters

import app.retroplayer.domain.model.Chapter
import java.nio.channels.FileChannel
import java.nio.ByteBuffer

/** Random access to file bytes; reads past the end return fewer bytes. */
interface ByteSource {
    val size: Long
    fun read(position: Long, length: Int): ByteArray

    companion object {
        fun of(bytes: ByteArray): ByteSource = object : ByteSource {
            override val size = bytes.size.toLong()
            override fun read(position: Long, length: Int): ByteArray {
                if (position < 0 || position >= size) return ByteArray(0)
                return bytes.copyOfRange(position.toInt(), minOf(size, position + length).toInt())
            }
        }

        /** Over an open file channel, e.g. from a SAF `ParcelFileDescriptor`. */
        fun of(channel: FileChannel): ByteSource = object : ByteSource {
            override val size = channel.size()
            override fun read(position: Long, length: Int): ByteArray {
                val buffer = ByteBuffer.allocate(length)
                while (buffer.hasRemaining()) {
                    if (channel.read(buffer, position + buffer.position()) <= 0) break
                }
                return buffer.array().copyOf(buffer.position())
            }
        }
    }
}

/**
 * Chapters of an MP4/M4B/M4A file: Nero `moov/udta/chpl`, else a QuickTime
 * chapter text track (`tref/chap`). Anything malformed yields no chapters.
 */
object Mp4ChapterReader {
    private const val MAX_CHAPTERS = 10_000
    private const val MAX_DEPTH = 8
    private val CONTAINERS = setOf("moov", "trak", "mdia", "minf", "stbl", "udta", "tref", "edts")

    fun read(source: ByteSource): List<Chapter> = runCatching {
        val moov = boxes(source, 0, source.size).firstOrNull { it.type == "moov" } ?: return emptyList()
        nero(source, moov).ifEmpty { quickTime(source, moov) }
    }.getOrDefault(emptyList())

    private class Box(val type: String, val start: Long, val bodyStart: Long, val end: Long) {
        val bodySize: Long get() = end - bodyStart
    }

    private fun boxes(source: ByteSource, from: Long, to: Long): List<Box> {
        val result = mutableListOf<Box>()
        var at = from
        while (at + 8 <= to) {
            val header = source.read(at, 16)
            if (header.size < 8) throw MalformedMp4()
            var size = header.u32(0)
            val type = String(header, 4, 4, Charsets.ISO_8859_1)
            var headerSize = 8
            if (size == 1L) {
                if (header.size < 16) throw MalformedMp4()
                size = ByteBuffer.wrap(header, 8, 8).long
                headerSize = 16
            } else if (size == 0L) {
                size = to - at
            }
            if (size < headerSize || at + size > to) throw MalformedMp4()
            result += Box(type, at, at + headerSize, at + size)
            at += size
        }
        return result
    }

    private fun children(source: ByteSource, box: Box) = boxes(source, box.bodyStart, box.end)

    private fun find(source: ByteSource, box: Box, vararg path: String): Box? {
        var current = box
        for (type in path) current = children(source, current).firstOrNull { it.type == type } ?: return null
        return current
    }

    private fun body(source: ByteSource, box: Box): ByteArray {
        if (box.bodySize > Int.MAX_VALUE) throw MalformedMp4()
        return source.read(box.bodyStart, box.bodySize.toInt()).also { if (it.size.toLong() != box.bodySize) throw MalformedMp4() }
    }

    private fun nero(source: ByteSource, moov: Box): List<Chapter> {
        val chpl = find(source, moov, "udta", "chpl") ?: return emptyList()
        val b = body(source, chpl)
        var at = 4 + if (b[0].toInt() != 0) 4 else 0
        val count = b[at++].toInt() and 0xff
        return List(count) {
            val start = ByteBuffer.wrap(b, at, 8).long
            val length = b[at + 8].toInt() and 0xff
            if (at + 9 + length > b.size) throw MalformedMp4()
            val title = String(b, at + 9, length, Charsets.UTF_8)
            at += 9 + length
            Chapter(start / 10_000, title)
        }
    }

    private fun quickTime(source: ByteSource, moov: Box): List<Chapter> {
        val tracks = children(source, moov).filter { it.type == "trak" }
        val ids = tracks.associateBy { trackId(source, it) }
        val chapterId = tracks.firstNotNullOfOrNull { trak ->
            find(source, trak, "tref", "chap")?.let { body(source, it) }?.takeIf { it.size >= 4 }?.u32(0)
        } ?: return emptyList()
        val track = ids[chapterId] ?: return emptyList()
        val mdia = find(source, track, "mdia") ?: return emptyList()
        val timescale = timescale(source, mdia).takeIf { it > 0 } ?: return emptyList()
        val stbl = find(source, mdia, "minf", "stbl") ?: return emptyList()
        val times = sampleTimes(body(source, find(source, stbl, "stts") ?: return emptyList()))
        val offsets = sampleOffsets(source, stbl)
        val sizes = sampleSizes(body(source, find(source, stbl, "stsz") ?: return emptyList()))
        val count = minOf(times.size, offsets.size, sizes.size, MAX_CHAPTERS)
        return List(count) { i ->
            val sample = source.read(offsets[i], sizes[i].coerceAtMost(4096))
            val length = if (sample.size >= 2) ((sample[0].toInt() and 0xff) shl 8) or (sample[1].toInt() and 0xff) else 0
            if (2 + length > sample.size) throw MalformedMp4()
            Chapter(times[i] * 1000 / timescale, String(sample, 2, length, Charsets.UTF_8))
        }
    }

    private fun trackId(source: ByteSource, trak: Box): Long {
        val b = body(source, find(source, trak, "tkhd") ?: return -1)
        return if (b[0].toInt() == 1) b.u32(20) else b.u32(12)
    }

    private fun timescale(source: ByteSource, mdia: Box): Long {
        val b = body(source, find(source, mdia, "mdhd") ?: return 0)
        return if (b[0].toInt() == 1) b.u32(20) else b.u32(12)
    }

    private fun sampleTimes(stts: ByteArray): List<Long> {
        val entries = stts.u32(4)
        val times = mutableListOf<Long>()
        var t = 0L
        for (e in 0 until entries) {
            val count = stts.u32(8 + 8 * e.toInt())
            val delta = stts.u32(12 + 8 * e.toInt())
            repeat(count.coerceAtMost(MAX_CHAPTERS.toLong()).toInt()) {
                if (times.size >= MAX_CHAPTERS) return times
                times += t
                t += delta
            }
        }
        return times
    }

    private fun sampleSizes(stsz: ByteArray): List<Int> {
        val fixed = stsz.u32(4)
        val count = stsz.u32(8).coerceAtMost(MAX_CHAPTERS.toLong()).toInt()
        return List(count) { if (fixed != 0L) fixed.toInt() else stsz.u32(12 + 4 * it).toInt() }
    }

    private fun sampleOffsets(source: ByteSource, stbl: Box): List<Long> {
        val stco = find(source, stbl, "stco")
        val co64 = find(source, stbl, "co64")
        val chunks: List<Long> = when {
            stco != null -> body(source, stco).let { b -> List(b.u32(4).coerceAtMost(MAX_CHAPTERS.toLong()).toInt()) { b.u32(8 + 4 * it) } }
            co64 != null -> body(source, co64).let { b -> List(b.u32(4).coerceAtMost(MAX_CHAPTERS.toLong()).toInt()) { ByteBuffer.wrap(b, 8 + 8 * it, 8).long } }
            else -> return emptyList()
        }
        val stsc = body(source, find(source, stbl, "stsc") ?: return emptyList())
        val runs = List(stsc.u32(4).toInt()) { stsc.u32(8 + 12 * it) to stsc.u32(12 + 12 * it) }
        val sizes = sampleSizes(body(source, find(source, stbl, "stsz") ?: return emptyList()))
        val offsets = mutableListOf<Long>()
        var sample = 0
        chunks.forEachIndexed { index, chunkOffset ->
            val perChunk = runs.lastOrNull { it.first <= index + 1 }?.second ?: return@forEachIndexed
            var at = chunkOffset
            repeat(perChunk.toInt()) {
                if (sample >= sizes.size) return offsets
                offsets += at
                at += sizes[sample++]
            }
        }
        return offsets
    }

    private fun ByteArray.u32(at: Int): Long {
        if (at + 4 > size) throw MalformedMp4()
        return ByteBuffer.wrap(this, at, 4).int.toLong() and 0xffffffffL
    }

    private class MalformedMp4 : Exception()
}

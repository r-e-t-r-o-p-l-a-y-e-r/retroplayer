package app.retroplayer.data.chapters

import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class Mp4ChapterReaderTest {
    private fun read(bytes: ByteArray) = Mp4ChapterReader.read(ByteSource.of(bytes))

    @Test
    fun `reads nero chapters`() {
        val file = ftyp() + box("moov", box("udta", chpl(0L to "Intro", 600_000_000L to "Part Two")))
        assertThat(read(file)).containsExactly(Chapter(0, "Intro"), Chapter(60_000, "Part Two")).inOrder()
    }

    @Test
    fun `reads quicktime chapter track`() {
        assertThat(read(quickTime(timescale = 1000, deltas = listOf(1500, 2500))))
            .containsExactly(Chapter(0, "Opening"), Chapter(1500, "Middle"), Chapter(4000, "Ending")).inOrder()
    }

    @Test
    fun `chapter times use the media timescale`() {
        assertThat(read(quickTime(timescale = 600, deltas = listOf(3000, 600))).map { it.startMs })
            .containsExactly(0L, 5000L, 6000L).inOrder()
    }

    @Test
    fun `nero chapters win over a chapter track`() {
        val withNero = quickTime(timescale = 1000, deltas = listOf(1, 1), extra = box("udta", chpl(0L to "Nero")))
        assertThat(read(withNero)).containsExactly(Chapter(0, "Nero"))
    }

    @Test
    fun `reads chapters from a file written by ffmpeg`() {
        val bytes = javaClass.getResourceAsStream("/chapters/ffmpeg-chapters.m4b")!!.use { it.readBytes() }
        assertThat(read(bytes)).containsExactly(Chapter(0, "Anfang"), Chapter(1500, "Schluss ü")).inOrder()
    }

    @Test
    fun `no chapters returns empty`() {
        assertThat(read(ftyp() + box("moov", box("udta", box("meta", ByteArray(4)))))).isEmpty()
    }

    @Test
    fun `truncated file returns empty without throwing`() {
        val file = ftyp() + box("moov", box("udta", chpl(0L to "Intro", 10L to "Two")))
        for (cut in listOf(3, 20, file.size - 5)) assertThat(read(file.copyOf(cut))).isEmpty()
        assertThat(read(ByteArray(0))).isEmpty()
    }

    // --- builders -------------------------------------------------------

    private fun u32(v: Long) = ByteBuffer.allocate(4).putInt(v.toInt()).array()
    private fun u64(v: Long) = ByteBuffer.allocate(8).putLong(v).array()
    private fun u16(v: Int) = byteArrayOf((v shr 8).toByte(), v.toByte())
    private fun full(version: Int = 0) = byteArrayOf(version.toByte(), 0, 0, 0)
    private fun cat(vararg parts: ByteArray) = ByteArrayOutputStream().apply { parts.forEach(::write) }.toByteArray()
    private fun box(type: String, vararg payload: ByteArray): ByteArray {
        val body = cat(*payload)
        return cat(u32(8L + body.size), type.toByteArray(), body)
    }
    private fun ftyp() = box("ftyp", "M4B ".toByteArray(), u32(0))

    private fun chpl(vararg chapters: Pair<Long, String>) = box(
        "chpl",
        full(version = 1),
        u32(0),
        byteArrayOf(chapters.size.toByte()),
        *chapters.map { (start, title) -> title.toByteArray().let { cat(u64(start), byteArrayOf(it.size.toByte()), it) } }.toTypedArray(),
    )

    private fun tkhd(id: Long) = box("tkhd", full(), u32(0), u32(0), u32(id), ByteArray(60))
    private fun mdhd(timescale: Long) = box("mdhd", full(), u32(0), u32(0), u32(timescale), u32(0), ByteArray(4))

    /** Audio track 1 points at text track 2 via tref/chap; text samples live in mdat right after ftyp. */
    private fun quickTime(timescale: Long, deltas: List<Int>, extra: ByteArray = ByteArray(0)): ByteArray {
        val titles = listOf("Opening", "Middle", "Ending").take(deltas.size + 1)
        val samples = titles.map { cat(u16(it.toByteArray().size), it.toByteArray()) }
        val head = ftyp()
        val mdatPayload = cat(*samples.toTypedArray())
        val mdat = box("mdat", mdatPayload)
        val firstSample = head.size + 8L
        val stts = box("stts", full(), u32(deltas.size + 1L), *(deltas + 1).map { cat(u32(1), u32(it.toLong())) }.toTypedArray())
        val stsz = box("stsz", full(), u32(0), u32(samples.size.toLong()), *samples.map { u32(it.size.toLong()) }.toTypedArray())
        val stsc = box("stsc", full(), u32(1), u32(1), u32(samples.size.toLong()), u32(1))
        val stco = box("stco", full(), u32(1), u32(firstSample))
        val audio = box("trak", tkhd(1), box("tref", box("chap", u32(2))), box("mdia", mdhd(44_100)))
        val text = box("trak", tkhd(2), box("mdia", mdhd(timescale), box("minf", box("stbl", stts, stsz, stsc, stco))))
        return cat(head, mdat, box("moov", audio, text, extra))
    }
}

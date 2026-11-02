package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.nio.charset.Charset

class M3uTest {
    private val playlist = LibraryPath("1/Mix/Lists/road.m3u")
    private val noAbsolute: (String) -> LibraryPath? = { null }

    @Test
    fun `parses relative entries and skips comments and blank lines`() {
        val text = "#EXTM3U\n#EXTINF:123,Song\n../Album/01.mp3\n\n  b.flac  \r\n"
        assertThat(M3u.parse(text, playlist, noAbsolute)).containsExactly(
            LibraryPath("1/Mix/Album/01.mp3"),
            LibraryPath("1/Mix/Lists/b.flac"),
        ).inOrder()
    }

    @Test
    fun `rejects remote entries and entries above the root`() {
        val text = "https://example.com/a.mp3\nrtsp://x/y\n../../../escape.mp3\nok.mp3"
        assertThat(M3u.parse(text, playlist, noAbsolute)).containsExactly(LibraryPath("1/Mix/Lists/ok.mp3"))
    }

    @Test
    fun `absolute and file URI entries go through the absolute resolver`() {
        val resolver: (String) -> LibraryPath? = { abs ->
            if (abs.startsWith("/storage/emulated/0/Music/")) LibraryPath("1/" + abs.removePrefix("/storage/emulated/0/Music/")) else null
        }
        val text = "/storage/emulated/0/Music/Mix/a.mp3\nfile:///storage/emulated/0/Music/Mix/b%20c.mp3\n/elsewhere/c.mp3\nC:\\Music\\d.mp3"
        assertThat(M3u.parse(text, playlist, resolver)).containsExactly(
            LibraryPath("1/Mix/a.mp3"),
            LibraryPath("1/Mix/b c.mp3"),
        ).inOrder()
    }

    @Test
    fun `decodes UTF-8 with BOM, plain UTF-8 and falls back to Windows-1250`() {
        val utf8 = "Kuća.mp3".toByteArray(Charsets.UTF_8)
        assertThat(M3u.decode(byteArrayOf(0xEF.toByte(), 0xBB.toByte(), 0xBF.toByte()) + utf8)).isEqualTo("Kuća.mp3")
        assertThat(M3u.decode(utf8)).isEqualTo("Kuća.mp3")
        assertThat(M3u.decode("Đorđe.mp3".toByteArray(Charset.forName("windows-1250")))).isEqualTo("Đorđe.mp3")
        assertThat(M3u.decode(ByteArray(0))).isEmpty()
    }

    @Test
    fun `writes extended header and relative entries`() {
        val out = M3u.write(
            playlist,
            listOf(LibraryPath("1/Mix/Album/01.mp3"), LibraryPath("1/Mix/Lists/b.flac"), LibraryPath("2/Other/x.mp3")),
        )
        assertThat(out.text).isEqualTo("#EXTM3U\n../Album/01.mp3\nb.flac\n")
        assertThat(out.skipped).containsExactly(LibraryPath("2/Other/x.mp3"))
    }

    @Test
    fun `write then parse round trips`() {
        val entries = listOf(LibraryPath("1/Mix/A b/ü.mp3"), LibraryPath("1/Mix/Lists/z.ogg"))
        assertThat(M3u.parse(M3u.write(playlist, entries).text, playlist, noAbsolute)).isEqualTo(entries)
    }
}

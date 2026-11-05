package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class TagFallbacksTest {
    @Test
    fun `blank and placeholder values count as missing`() {
        listOf(null, "", "   ", "Unknown", "unknown artist", "<Unknown>", "Unknown Album", "Track 01", "track 7")
            .forEach { assertThat(TagFallbacks.clean(it)).isNull() }
        assertThat(TagFallbacks.clean("  Abbey Road ")).isEqualTo("Abbey Road")
    }

    @Test
    fun `clean also repairs mojibake`() {
        val misread = String("Kuća".toByteArray(Charsets.UTF_8), Charsets.ISO_8859_1)
        assertThat(TagFallbacks.clean(misread)).isEqualTo("Kuća")
    }

    @Test
    fun `title falls back to file name without leading track number`() {
        assertThat(TagFallbacks.title(null, "01 - Intro.mp3")).isEqualTo("Intro")
        assertThat(TagFallbacks.title(null, "1-05 Song.flac")).isEqualTo("Song")
        assertThat(TagFallbacks.title(null, "03. The End.m4a")).isEqualTo("The End")
        assertThat(TagFallbacks.title(null, "07_chapter seven.mp3")).isEqualTo("chapter seven")
        assertThat(TagFallbacks.title("Track 01", "02 Real.mp3")).isEqualTo("Real")
        assertThat(TagFallbacks.title("Tagged", "01 - Intro.mp3")).isEqualTo("Tagged")
    }

    @Test
    fun `title keeps names that are only a number or start with a year`() {
        assertThat(TagFallbacks.title(null, "01.mp3")).isEqualTo("01")
        assertThat(TagFallbacks.title(null, "1984 - Orwell.mp3")).isEqualTo("1984 - Orwell")
        assertThat(TagFallbacks.title(null, "Track 3.mp3")).isEqualTo("Track 3")
    }

    @Test
    fun `track number falls back to the leading number in the file name`() {
        assertThat(TagFallbacks.trackNumber(5, "01 Intro.mp3")).isEqualTo(5)
        assertThat(TagFallbacks.trackNumber(null, "01 Intro.mp3")).isEqualTo(1)
        assertThat(TagFallbacks.trackNumber(null, "1-05 Song.mp3")).isEqualTo(5)
        assertThat(TagFallbacks.trackNumber(null, "Track 3.mp3")).isEqualTo(3)
        assertThat(TagFallbacks.trackNumber(null, "Intro.mp3")).isNull()
        assertThat(TagFallbacks.trackNumber(null, "1984 - Orwell.mp3")).isNull()
    }

    @Test
    fun `disc number falls back to file name then folder name`() {
        assertThat(TagFallbacks.discNumber(2, "01.mp3", "CD1")).isEqualTo(2)
        assertThat(TagFallbacks.discNumber(null, "1-05 Song.mp3", "Album")).isEqualTo(1)
        assertThat(TagFallbacks.discNumber(null, "05 Song.mp3", "CD2")).isEqualTo(2)
        assertThat(TagFallbacks.discNumber(null, "05 Song.mp3", "Disc 3")).isEqualTo(3)
        assertThat(TagFallbacks.discNumber(null, "05 Song.mp3", "disk10")).isEqualTo(10)
        assertThat(TagFallbacks.discNumber(null, "05 Song.mp3", "Part 4")).isEqualTo(4)
        assertThat(TagFallbacks.discNumber(null, "05 Song.mp3", "Album")).isNull()
    }

    @Test
    fun `artist prefers artist then album artist then composer`() {
        assertThat(TagFallbacks.artist("A", "B", "C")).isEqualTo("A")
        assertThat(TagFallbacks.artist(" ", "B", "C")).isEqualTo("B")
        assertThat(TagFallbacks.artist("Unknown Artist", null, "C")).isEqualTo("C")
        assertThat(TagFallbacks.artist(null, null, null)).isNull()
    }
}

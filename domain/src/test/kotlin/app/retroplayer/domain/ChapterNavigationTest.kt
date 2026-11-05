package app.retroplayer.domain

import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ChapterNavigationTest {
    private val chapters = listOf(Chapter(0, "One"), Chapter(60_000, "Two"), Chapter(120_000, "Three"))

    @Test
    fun `next chapter from inside a chapter`() {
        assertThat(ChapterNavigation.next(chapters, 70_000)).isEqualTo(120_000)
    }

    @Test
    fun `there is no next chapter in the last one`() {
        assertThat(ChapterNavigation.next(chapters, 130_000)).isNull()
    }

    @Test
    fun `previous chapter goes back to the start of the current one`() {
        assertThat(ChapterNavigation.previous(chapters, 70_000)).isEqualTo(60_000)
    }

    @Test
    fun `previous chapter within 3 s of a start goes to the one before`() {
        assertThat(ChapterNavigation.previous(chapters, 62_000)).isEqualTo(0)
    }

    @Test
    fun `previous chapter in the first one restarts it`() {
        assertThat(ChapterNavigation.previous(chapters, 1_000)).isEqualTo(0)
    }

    @Test
    fun `current chapter is the last one started`() {
        assertThat(ChapterNavigation.current(chapters, 60_000)).isEqualTo(chapters[1])
        assertThat(ChapterNavigation.current(chapters, 59_999)).isEqualTo(chapters[0])
    }

    @Test
    fun `before the first chapter there is no current one`() {
        assertThat(ChapterNavigation.current(listOf(Chapter(5_000, "Late")), 1_000)).isNull()
        assertThat(ChapterNavigation.current(emptyList(), 1_000)).isNull()
    }

    @Test
    fun `unsorted chapters are handled in time order`() {
        assertThat(ChapterNavigation.next(chapters.reversed(), 70_000)).isEqualTo(120_000)
    }
}

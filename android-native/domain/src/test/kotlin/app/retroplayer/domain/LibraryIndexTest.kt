package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class LibraryIndexTest {
    @Test
    fun `labels follow symbol digit then A to Z`() {
        assertThat(LibraryIndex.labelsFor(listOf(".dot", "9live", "Alpha", "beta"))).containsExactly(
            LibraryIndex.OTHER,
            LibraryIndex.DIGIT,
            "A",
            "B",
        ).inOrder()
    }

    @Test
    fun `first matching index finds the row`() {
        val titles = listOf("Alpha", "Beta", "Zulu")
        assertThat(LibraryIndex.firstMatchingIndex(titles, "Z")).isEqualTo(2)
        assertThat(LibraryIndex.firstMatchingIndex(titles, "X")).isNull()
    }

    @Test
    fun `lazy column index skips section headers`() {
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(0, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(1)
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(2, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(4)
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(3, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(6)
    }
}

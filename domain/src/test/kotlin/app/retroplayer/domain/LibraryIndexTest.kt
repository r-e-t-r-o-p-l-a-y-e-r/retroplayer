package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class LibraryIndexTest {
    private val alphabet = ('A'..'Z').map { it.toString() }

    @Test
    fun `labels follow symbol digit then A to Z`() {
        assertThat(LibraryIndex.labelsFor(listOf(".dot", "9live", "Alpha", "beta")))
            .containsExactlyElementsIn(listOf(LibraryIndex.OTHER, LibraryIndex.DIGIT) + alphabet)
            .inOrder()
    }

    @Test
    fun `labels always list the whole alphabet`() {
        assertThat(LibraryIndex.labelsFor(listOf("Alpha", "beta"))).containsExactlyElementsIn(alphabet).inOrder()
    }

    @Test
    fun `accented letters index under their base letter`() {
        assertThat(LibraryIndex.charFor("Äpfel")).isEqualTo("A")
        assertThat(LibraryIndex.charFor("élan")).isEqualTo("E")
        assertThat(LibraryIndex.charFor("Привет")).isEqualTo(LibraryIndex.OTHER)
    }

    @Test
    fun `first matching index finds the row`() {
        val titles = listOf("Alpha", "Beta", "Zulu")
        assertThat(LibraryIndex.firstMatchingIndex(titles, "Z")).isEqualTo(2)
        assertThat(LibraryIndex.firstMatchingIndex(titles, "X")).isNull()
    }

    @Test
    fun `jump target falls through to the next letter`() {
        val titles = listOf("Alpha", "Delta", "Zulu")
        assertThat(LibraryIndex.jumpIndex(titles, "B")).isEqualTo(1)
        assertThat(LibraryIndex.jumpIndex(titles, LibraryIndex.DIGIT)).isEqualTo(0)
    }

    @Test
    fun `jump target past the last letter is the last row`() {
        assertThat(LibraryIndex.jumpIndex(listOf("Alpha", "Delta"), "Z")).isEqualTo(1)
    }

    @Test
    fun `jump target prefers an exact match in a later section`() {
        assertThat(LibraryIndex.jumpIndex(listOf("Beta", "Zulu", "Alpha"), "A")).isEqualTo(2)
    }

    @Test
    fun `jump target of an empty list is null`() {
        assertThat(LibraryIndex.jumpIndex(emptyList(), "A")).isNull()
    }

    @Test
    fun `lazy column index skips section headers`() {
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(0, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(1)
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(2, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(4)
        assertThat(LibraryIndex.lazyColumnIndexForSelectableRow(3, folderCount = 2, playlistCount = 1, audioCount = 1)).isEqualTo(6)
    }
}

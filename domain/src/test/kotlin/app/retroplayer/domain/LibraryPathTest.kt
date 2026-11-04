package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class LibraryPathTest {
    @Test
    fun `root path has no parent and root id as name`() {
        val root = LibraryPath.root("7")
        assertThat(root.parent).isNull()
        assertThat(root.isRoot).isTrue()
        assertThat(root.rootId).isEqualTo("7")
        assertThat(root.value).isEqualTo("7")
    }

    @Test
    fun `child and parent are inverse`() {
        val book = LibraryPath.root("7").child("Author").child("Book")
        assertThat(book.value).isEqualTo("7/Author/Book")
        assertThat(book.name).isEqualTo("Book")
        assertThat(book.parent).isEqualTo(LibraryPath("7/Author"))
        assertThat(book.segments).containsExactly("Author", "Book").inOrder()
    }

    @Test
    fun `isWithin is true for itself and descendants only`() {
        val author = LibraryPath("7/Author")
        assertThat(LibraryPath("7/Author/Book/01.mp3").isWithin(author)).isTrue()
        assertThat(author.isWithin(author)).isTrue()
        assertThat(LibraryPath("7/Authors").isWithin(author)).isFalse()
        assertThat(LibraryPath("8/Author").isWithin(author)).isFalse()
    }

    @Test
    fun `resolve handles dot segments relative to a folder`() {
        val dir = LibraryPath("7/Mix/Lists")
        assertThat(dir.resolve("../Album/01.mp3")).isEqualTo(LibraryPath("7/Mix/Album/01.mp3"))
        assertThat(dir.resolve("./a.mp3")).isEqualTo(LibraryPath("7/Mix/Lists/a.mp3"))
        assertThat(dir.resolve("sub\\b.mp3")).isEqualTo(LibraryPath("7/Mix/Lists/sub/b.mp3"))
    }

    @Test
    fun `resolve above the library root is rejected`() {
        assertThat(LibraryPath("7/Mix").resolve("../../x.mp3")).isNull()
    }

    @Test
    fun `relativeTo builds dot dot paths between folders`() {
        val from = LibraryPath("7/Mix/Lists")
        assertThat(LibraryPath("7/Mix/Lists/a.mp3").relativeTo(from)).isEqualTo("a.mp3")
        assertThat(LibraryPath("7/Mix/Album/01.mp3").relativeTo(from)).isEqualTo("../Album/01.mp3")
        assertThat(LibraryPath("8/Other/a.mp3").relativeTo(from)).isNull()
    }

    @Test
    fun `extension and base name`() {
        val file = LibraryPath("7/Book/01 - Intro.MP3")
        assertThat(file.extension).isEqualTo("mp3")
        assertThat(file.baseName).isEqualTo("01 - Intro")
        assertThat(LibraryPath("7/.folder").baseName).isEqualTo(".folder")
    }
}

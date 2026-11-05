package app.retroplayer.data.chapters

import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Test

class ChapterRepositoryTest {
    private val book = listOf(Chapter(0, "Intro"), Chapter(60_000, "Two"))
    private val reads = mutableListOf<String>()
    private val repository = ChapterRepository { uri ->
        reads += uri
        if (uri == "doc:broken") error("unreadable") else book
    }

    @Test
    fun `reads chapters of an audiobook file`() = runTest {
        assertThat(repository.chapters("doc:book", "Book.m4b")).isEqualTo(book)
    }

    @Test
    fun `other formats have no chapters and are not opened`() = runTest {
        assertThat(repository.chapters("doc:song", "song.mp3")).isEmpty()
        assertThat(reads).isEmpty()
    }

    @Test
    fun `a file is read once`() = runTest {
        repository.chapters("doc:book", "Book.M4A")
        repository.chapters("doc:book", "Book.M4A")
        assertThat(reads).containsExactly("doc:book")
    }

    @Test
    fun `an unreadable file has no chapters`() = runTest {
        assertThat(repository.chapters("doc:broken", "Broken.mp4")).isEmpty()
    }

    @Test
    fun `cached chapters are available without reading`() = runTest {
        assertThat(repository.cached("doc:book")).isNull()
        repository.chapters("doc:book", "Book.m4b")
        assertThat(repository.cached("doc:book")).isEqualTo(book)
    }
}

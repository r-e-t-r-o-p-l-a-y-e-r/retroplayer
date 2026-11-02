package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class PlaylistEntriesTest {
    private val roots = listOf(LibraryPath.root("1"), LibraryPath.root("2"))

    @Test
    fun `keeps supported audio under a root without duplicates in input order`() {
        val added = PlaylistEntries.filterNew(
            candidates = listOf("1/a.mp3", "1/cover.jpg", "3/x.mp3", "2/b.flac", "1/a.mp3", "1/c.m3u").map(::LibraryPath),
            roots = roots,
            existing = setOf(LibraryPath("2/b.flac")),
        )
        assertThat(added).containsExactly(LibraryPath("1/a.mp3"))
    }
}

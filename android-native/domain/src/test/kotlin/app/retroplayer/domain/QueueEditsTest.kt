package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class QueueEditsTest {
    private val a = LibraryPath("1/a.mp3")
    private val b = LibraryPath("1/b.mp3")
    private val c = LibraryPath("1/c.mp3")
    private val d = LibraryPath("1/d.mp3")

    @Test
    fun `add appends new paths in order`() {
        assertThat(QueueEdits.add(listOf(a), listOf(c, b))).containsExactly(a, c, b).inOrder()
    }

    @Test
    fun `add skips paths already queued`() {
        assertThat(QueueEdits.add(listOf(a, b), listOf(b, c, c, a))).containsExactly(a, b, c).inOrder()
    }

    @Test
    fun `move reorders`() {
        assertThat(QueueEdits.move(listOf(a, b, c, d), from = 0, to = 2)).containsExactly(b, c, a, d).inOrder()
        assertThat(QueueEdits.move(listOf(a, b, c, d), from = 3, to = 1)).containsExactly(a, d, b, c).inOrder()
    }

    @Test
    fun `remove drops one entry`() {
        assertThat(QueueEdits.remove(listOf(a, b, c), 1)).containsExactly(a, c).inOrder()
    }

    @Test
    fun `out of range edits leave the queue unchanged`() {
        val queue = listOf(a, b)
        assertThat(QueueEdits.move(queue, from = 2, to = 0)).isEqualTo(queue)
        assertThat(QueueEdits.move(queue, from = 0, to = -1)).isEqualTo(queue)
        assertThat(QueueEdits.remove(queue, 5)).isEqualTo(queue)
        assertThat(QueueEdits.remove(queue, -1)).isEqualTo(queue)
    }
}

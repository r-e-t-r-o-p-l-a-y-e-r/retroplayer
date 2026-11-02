package app.retroplayer.playback

import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SessionQueueTest {
    private fun track(name: String) = AudioTrack(LibraryPath("1/Book/$name"), "doc:root/Book/$name")

    private val folder = PlaybackItem.Folder(LibraryPath("1/Book"), listOf(track("01.mp3"), track("02.mp3")))
    private val empty = PlaybackItem.Folder(LibraryPath("1/Empty"), emptyList())
    private val single = PlaybackItem.Single(track("03.mp3"))
    private val items = mapOf(folder.id to folder, empty.id to empty, single.id to single)
    private val saved = mutableMapOf<String, SavedPlaybackState>()
    private var lastItem: String? = null

    private val queue = SessionQueue(
        items = { items[it] },
        savedState = { saved[it] },
        lastItemId = { lastItem },
        rememberLastItem = { lastItem = it },
        artwork = { null },
    )

    @Test
    fun `a request resumes the saved state and becomes the last item`() = runTest {
        saved[folder.id] = SavedPlaybackState("1/Book/02.mp3", positionMs = 9_000, speed = 1.25f)
        val prepared = queue.prepare(PlaybackRequest(folder.id, null))!!
        assertThat(prepared.startIndex).isEqualTo(1)
        assertThat(prepared.startPositionMs).isEqualTo(9_000)
        assertThat(prepared.speed).isEqualTo(1.25f)
        assertThat(lastItem).isEqualTo(folder.id)
    }

    @Test
    fun `unknown and empty items are not prepared and do not replace the last item`() = runTest {
        lastItem = "before"
        assertThat(queue.prepare(PlaybackRequest("folder:1/Nope", null))).isNull()
        assertThat(queue.prepare(PlaybackRequest(empty.id, null))).isNull()
        assertThat(lastItem).isEqualTo("before")
    }

    @Test
    fun `resumption rebuilds the last item at its saved position`() = runTest {
        lastItem = folder.id
        saved[folder.id] = SavedPlaybackState("1/Book/02.mp3", positionMs = 3_000)
        val prepared = queue.resumption()!!
        assertThat(prepared.itemId).isEqualTo(folder.id)
        assertThat(prepared.startIndex).isEqualTo(1)
        assertThat(prepared.startPositionMs).isEqualTo(3_000)
    }

    @Test
    fun `nothing to resume on a fresh install`() = runTest {
        assertThat(queue.resumption()).isNull()
    }

    @Test
    fun `tracks added to another item carry that item's id`() = runTest {
        val expanded = queue.expand(listOf(single.id), intoItemId = PlaybackItem.QUEUE_ID)
        assertThat(expanded.map { it.mediaId }).containsExactly("1/Book/03.mp3")
        assertThat(PlaybackRequests.itemIdOf(expanded.single())).isEqualTo(PlaybackItem.QUEUE_ID)
    }

    @Test
    fun `expanding plain media ids resolves each into its tracks`() = runTest {
        val expanded = queue.expand(listOf(folder.id, "1/Nope.mp3", folder.id))
        assertThat(expanded.map { it.mediaId }).containsExactly("1/Book/01.mp3", "1/Book/02.mp3", "1/Book/01.mp3", "1/Book/02.mp3").inOrder()
    }
}

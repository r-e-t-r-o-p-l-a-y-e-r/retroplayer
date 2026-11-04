package app.retroplayer.playback

import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.FakeTimeline
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.TestLibrary
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class PlayerConnectionTest {
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private lateinit var exo: ExoPlayer
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val player = CompletableDeferred<Player?>()
    private val minuteUs = 60 * 1_000_000L

    @Before
    fun setUp() {
        lib = TestLibrary(tmp)
        exo = TestExoPlayerBuilder(ApplicationProvider.getApplicationContext())
            .setMediaSourceFactory(
                FakeMediaSourceFactory(FakeTimeline.TimelineWindowDefinition.Builder().setDurationUs(minuteUs).setDefaultPositionUs(0)),
            )
            .build()
    }

    @After
    fun tearDown() {
        scope.cancel()
        exo.release()
        lib.close()
    }

    private fun connection() = PlayerConnection(scope, lib.store, lib.settings) { player.await() }

    private fun queued(vararg ids: String, itemId: String = "album") = ids.map { id ->
        MediaItem.Builder()
            .setMediaId(id)
            .setUri("doc:$id")
            .setMediaMetadata(MediaMetadata.Builder().setTitle(id).setExtras(PlaybackRequests.itemExtras(itemId, "doc:$id")).build())
            .build()
    }

    private fun loadQueue(vararg ids: String, itemId: String = "album") {
        exo.setMediaItems(queued(*ids, itemId = itemId))
        exo.prepare()
        advance(exo).untilState(Player.STATE_READY)
    }

    /** Runs main-looper work, player commands and background Room/DataStore work until [done] holds. */
    private fun waitUntil(done: () -> Boolean) {
        val deadline = System.currentTimeMillis() + 5_000
        while (true) {
            advance(exo).untilPendingCommandsAreFullyHandled()
            shadowOf(Looper.getMainLooper()).idle()
            if (done()) return
            check(System.currentTimeMillis() < deadline) { "condition not met in time" }
            Thread.sleep(10)
        }
    }

    private fun connected(vararg ids: String = arrayOf("a", "b"), itemId: String = "album"): PlayerConnection {
        loadQueue(*ids, itemId = itemId)
        val connection = connection()
        player.complete(exo)
        waitUntil { connection.nowPlaying.value.hasTrack }
        return connection
    }

    @Test
    fun `toggle pauses a playing player and resumes a paused one`() {
        val connection = connected()
        connection.togglePlayPause()
        waitUntil { connection.nowPlaying.value.isPlaying }
        assertThat(exo.playWhenReady).isTrue()

        connection.togglePlayPause()
        waitUntil { !connection.nowPlaying.value.isPlaying }
        assertThat(exo.playWhenReady).isFalse()
    }

    @Test
    fun `toggle after the queue ended plays the last track again`() {
        val connection = connected("a", "b")
        exo.seekTo(1, minuteUs / 1_000 - 10)
        exo.play()
        advance(exo).untilState(Player.STATE_ENDED)
        waitUntil { !connection.nowPlaying.value.isPlaying }

        connection.togglePlayPause()
        waitUntil { connection.nowPlaying.value.isPlaying }
        assertThat(exo.currentMediaItemIndex).isEqualTo(1)
    }

    @Test
    fun `seekTo moves the position and publishes it`() {
        val connection = connected()
        connection.seekTo(30_000)
        waitUntil { connection.nowPlaying.value.positionMs == 30_000L }
        assertThat(exo.currentPosition).isEqualTo(30_000)
    }

    @Test
    fun `setSpeed clamps to the allowed range`() {
        val connection = connected()
        connection.setSpeed(3f)
        waitUntil { exo.playbackParameters.speed == 2f }
        assertThat(connection.nowPlaying.value.speed).isEqualTo(2f)

        connection.setSpeed(0.1f)
        waitUntil { exo.playbackParameters.speed == 0.5f }
    }

    @Test
    fun `skipToNext moves to the next queue entry and publishes index and size`() {
        val connection = connected("a", "b")
        connection.nowPlaying.value.let {
            assertThat(it.queueIndex).isEqualTo(0)
            assertThat(it.queueSize).isEqualTo(2)
            assertThat(it.hasPrevious).isFalse()
            assertThat(it.hasNext).isTrue()
        }

        connection.skipToNext()
        waitUntil { connection.nowPlaying.value.queueIndex == 1 }
        connection.nowPlaying.value.let {
            assertThat(it.trackId).isEqualTo("b")
            assertThat(it.hasPrevious).isTrue()
            assertThat(it.hasNext).isFalse()
        }
    }

    @Test
    fun `skipToPrevious goes back to the previous entry`() {
        val connection = connected("a", "b")
        exo.seekTo(1, 0)
        waitUntil { connection.nowPlaying.value.queueIndex == 1 }

        connection.skipToPrevious()
        waitUntil { connection.nowPlaying.value.queueIndex == 0 }
    }

    @Test
    fun `jumps use the player's seek increments`() {
        val connection = connected()
        exo.seekTo(30_000)
        waitUntil { connection.nowPlaying.value.positionMs == 30_000L }

        connection.jumpForward()
        waitUntil { exo.currentPosition == 30_000 + exo.seekForwardIncrement }
        connection.jumpBack()
        waitUntil { exo.currentPosition == 30_000 + exo.seekForwardIncrement - exo.seekBackIncrement }
    }

    @Test
    fun `publishes the document uri of the current track`() {
        val connection = connected("a", "b")
        assertThat(connection.nowPlaying.value.trackUri).isEqualTo("doc:a")
    }

    @Test
    fun `play announces the request so the player can expand`() = runBlocking {
        val connection = connected("a", "b")
        val announced = async(start = CoroutineStart.UNDISPATCHED) { connection.playRequests.first() }
        connection.play("album", startTrackId = "b")
        assertThat(withTimeout(2_000) { announced.await() }).isEqualTo("album")
    }

    @Test
    fun `stop clears the queue and publishes no track`() {
        val connection = connected()
        connection.stop()
        waitUntil { exo.mediaItemCount == 0 }
        waitUntil { connection.nowPlaying.value == NowPlaying() }
    }

    @Test
    fun `actions before the player connects run once it is connected`() {
        loadQueue("a", "b")
        val connection = connection()
        connection.seekTo(10_000)
        connection.setSpeed(1.5f)

        player.complete(exo)
        waitUntil { exo.playbackParameters.speed == 1.5f }
        assertThat(exo.currentPosition).isEqualTo(10_000)
    }

    @Test
    fun `cold start restores the last item paused with its saved title`() {
        runBlocking {
            lib.settings.setLastItem("album")
            lib.store.savePlayback("album", SavedPlaybackState(trackId = "b", positionMs = 42_000, displayTitle = "Song B", subtitle = "Tester"))
        }
        val connection = connection()
        player.complete(exo)

        waitUntil { exo.mediaItemCount == 1 }
        waitUntil { connection.nowPlaying.value.title == "Song B" }
        assertThat(exo.getMediaItemAt(0).mediaId).isEqualTo("album")
        assertThat(exo.playWhenReady).isFalse()
        connection.nowPlaying.value.let {
            assertThat(it.itemId).isEqualTo("album")
            assertThat(it.subtitle).isEqualTo("Tester")
        }
    }

    private fun ids() = List(exo.mediaItemCount) { exo.getMediaItemAt(it).mediaId }

    private fun storeQueue(vararg ids: String) = runBlocking { lib.settings.setQueue(ids.map(::LibraryPath)) }

    @Test
    fun `queue edits apply to the live player when the queue plays`() {
        storeQueue("a", "b", "c")
        connected("a", "b", "c", itemId = PlaybackItem.QUEUE_ID)

        storeQueue("c", "a")
        waitUntil { ids() == listOf("c", "a") }
        assertThat(exo.currentMediaItem?.mediaId).isEqualTo("a")

        storeQueue("c", "a", "d")
        waitUntil { ids() == listOf("c", "a", "d") }
        assertThat(PlaybackRequests.additionTargetOf(exo.getMediaItemAt(2))).isEqualTo(PlaybackItem.QUEUE_ID)
        assertThat(exo.currentMediaItem?.mediaId).isEqualTo("a")
    }

    @Test
    fun `queue edits do not touch the player when an album plays`() {
        storeQueue("a", "b")
        connected("a", "b")

        storeQueue("b")
        waitUntil { runBlocking { lib.settings.session.first().queue } == listOf(LibraryPath("b")) }
        repeat(5) { waitUntil { true } }
        assertThat(ids()).containsExactly("a", "b").inOrder()
    }

    @Test
    fun `clearing the playing queue stops playback`() {
        storeQueue("a", "b")
        val connection = connected("a", "b", itemId = PlaybackItem.QUEUE_ID)

        storeQueue()
        waitUntil { exo.mediaItemCount == 0 }
        waitUntil { !connection.nowPlaying.value.hasTrack }
    }
}

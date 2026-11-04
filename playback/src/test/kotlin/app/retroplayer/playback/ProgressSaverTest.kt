package app.retroplayer.playback

import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.play
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.playback.QueueBuilder.toMediaItem
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceTimeBy
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class ProgressSaverTest {
    private lateinit var player: ExoPlayer
    private val saved = mutableListOf<Pair<String, SavedPlaybackState>>()
    private val itemId = PlaybackItem.folderId(LibraryPath("1/Book"))

    private fun item(name: String) = AudioTrack(
        LibraryPath("1/Book/$name"),
        "doc:root/Book/$name",
        TrackMetadata(title = "T $name", artist = "Ann", durationMs = 10_000),
    ).toMediaItem(itemId, null)

    @Before
    fun setUp() {
        player = TestExoPlayerBuilder(ApplicationProvider.getApplicationContext())
            .setMediaSourceFactory(FakeMediaSourceFactory())
            .build()
    }

    @After
    fun tearDown() = player.release()

    private fun TestScope.saver(items: List<MediaItem> = listOf(item("01.mp3"), item("02.mp3"))): ProgressSaver {
        player.setMediaItems(items)
        player.prepare()
        advance(player).untilState(Player.STATE_READY)
        return ProgressSaver(player, backgroundScope, intervalMs = 10_000) { id, state -> saved += id to state }.also { it.start() }
    }

    private fun idle() {
        advance(player).untilPendingCommandsAreFullyHandled()
        shadowOf(Looper.getMainLooper()).idle()
    }

    @Test
    fun `pausing saves item, track, position, speed and display text`() = runTest(UnconfinedTestDispatcher()) {
        saver()
        player.seekTo(3_000)
        player.setPlaybackSpeed(1.5f)
        saved.clear()
        play(player).untilPlayWhenReadyIs(true)
        player.pause()
        idle()

        val (id, state) = saved.last()
        assertThat(id).isEqualTo(itemId)
        assertThat(state.trackId).isEqualTo("1/Book/01.mp3")
        assertThat(state.positionMs).isAtLeast(3_000)
        assertThat(state.speed).isEqualTo(1.5f)
        assertThat(state.displayTitle).isEqualTo("T 01.mp3")
        assertThat(state.subtitle).isEqualTo("Ann")
    }

    @Test
    fun `seeking and changing speed save at once`() = runTest(UnconfinedTestDispatcher()) {
        saver()
        player.seekTo(4_000)
        idle()
        assertThat(saved.last().second.positionMs).isEqualTo(4_000)
        player.setPlaybackSpeed(0.75f)
        idle()
        assertThat(saved.last().second.speed).isEqualTo(0.75f)
    }

    @Test
    fun `skipping saves the new track`() = runTest(UnconfinedTestDispatcher()) {
        saver()
        player.seekToNextMediaItem()
        idle()
        assertThat(saved.last().second.trackId).isEqualTo("1/Book/02.mp3")
        assertThat(saved.last().second.positionMs).isEqualTo(player.currentPosition)
    }

    @Test
    fun `saves on an interval only while playing`() = runTest(UnconfinedTestDispatcher()) {
        saver()
        saved.clear()
        advanceTimeBy(25_000)
        assertThat(saved).isEmpty()

        player.play()
        idle()
        saved.clear()
        advanceTimeBy(10_001)
        assertThat(saved).hasSize(1)
        advanceTimeBy(10_000)
        assertThat(saved).hasSize(2)
    }

    @Test
    fun `finishing the queue saves the start so it replays from the beginning`() = runTest(UnconfinedTestDispatcher()) {
        saver()
        play(player).untilState(Player.STATE_ENDED)
        idle()
        val state = saved.last().second
        assertThat(state.trackId).isEqualTo("1/Book/01.mp3")
        assertThat(state.positionMs).isEqualTo(0)
    }

    @Test
    fun `media without an owning item is never saved`() = runTest(UnconfinedTestDispatcher()) {
        saver(listOf(MediaItem.fromUri("doc:root/x.mp3")))
        player.seekTo(2_000)
        idle()
        assertThat(saved).isEmpty()
    }
}

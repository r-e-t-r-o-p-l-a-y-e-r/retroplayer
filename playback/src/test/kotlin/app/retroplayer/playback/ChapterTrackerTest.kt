package app.retroplayer.playback

import android.os.Looper
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.FakeTimeline
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class ChapterTrackerTest {
    private lateinit var exo: ExoPlayer
    private lateinit var tracker: ChapterTracker
    private val book = listOf(Chapter(0, "One"), Chapter(600_000, "Two"), Chapter(1_200_000, "Three"))
    private val published = mutableListOf<List<Chapter>>()

    @Before
    fun setUp() {
        exo = TestExoPlayerBuilder(ApplicationProvider.getApplicationContext())
            .setMediaSourceFactory(
                FakeMediaSourceFactory(FakeTimeline.TimelineWindowDefinition.Builder().setDurationUs(3_600_000_000L).setDefaultPositionUs(0)),
            )
            .build()
        exo.setMediaItems(
            listOf(
                MediaItem.Builder().setMediaId("1/Book.m4b").setUri("doc:book").build(),
                MediaItem.Builder().setMediaId("1/song.mp3").setUri("doc:song").build(),
            ),
        )
        exo.prepare()
        advance(exo).untilState(Player.STATE_READY)
        tracker = ChapterTracker(exo, CoroutineScope(UnconfinedTestDispatcher()), load = { item -> if (item.mediaId.endsWith(".m4b")) book else emptyList() }) {
            published += it
        }
    }

    @After
    fun tearDown() = exo.release()

    private fun idle() {
        advance(exo).untilPendingCommandsAreFullyHandled()
        shadowOf(Looper.getMainLooper()).idle()
    }

    @Test
    fun `the current track's chapters are loaded and published`() {
        assertThat(tracker.chapters).isEqualTo(book)
        assertThat(published.last()).isEqualTo(book)
    }

    @Test
    fun `the next track without chapters clears them`() {
        exo.seekToNextMediaItem()
        idle()
        assertThat(tracker.chapters).isEmpty()
        assertThat(published.last()).isEmpty()
    }

    @Test
    fun `chapter targets follow the position`() {
        exo.seekTo(700_000)
        idle()
        assertThat(tracker.nextTarget()).isEqualTo(1_200_000)
        assertThat(tracker.previousTarget()).isEqualTo(600_000)
    }
}

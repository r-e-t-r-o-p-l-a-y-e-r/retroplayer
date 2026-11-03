package app.retroplayer.ui.queue

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.test.core.app.ApplicationProvider
import android.content.Context
import app.retroplayer.R
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.ui.components.PLAYING_STRIP_TAG
import app.retroplayer.ui.theme.RetroTheme
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class QueueContentTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()

    private val track = AudioTrack(
        LibraryPath("1/a.mp3"),
        "doc:a",
        TrackMetadata(title = "Alpha", artist = "Ann", durationMs = 61_000),
    )

    @Test
    fun `empty queue shows the empty text`() {
        compose.setContent {
            RetroTheme {
                QueueContent(QueueUiState.Ready(emptyList(), null, false), QueueActions())
            }
        }
        compose.onNodeWithTag(QUEUE_EMPTY_TAG).assertIsDisplayed()
    }

    @Test
    fun `missing entry shows missing track`() {
        val state = QueueUiState.Ready(listOf(QueueEntry(LibraryPath("1/gone.mp3"), null)), null, false)
        compose.setContent { RetroTheme { QueueContent(state, QueueActions()) } }
        compose.onNodeWithText(context.getString(R.string.missing_track)).assertIsDisplayed()
    }

    @Test
    fun `playing row is highlighted`() {
        val state = QueueUiState.Ready(
            listOf(QueueEntry(track.path, track)),
            playingTrackId = track.id,
            confirmClear = false,
        )
        compose.setContent { RetroTheme { QueueContent(state, QueueActions()) } }
        compose.onNodeWithTag(PLAYING_STRIP_TAG).assertIsDisplayed()
    }
}

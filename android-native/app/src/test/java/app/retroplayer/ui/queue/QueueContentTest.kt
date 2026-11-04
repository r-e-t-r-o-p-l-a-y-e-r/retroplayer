package app.retroplayer.ui.queue

import com.google.common.truth.Truth.assertThat
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.hasAnyDescendant
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.performClick
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

    private val filled = QueueUiState.Ready(listOf(QueueEntry(track.path, track)), playingTrackId = null, confirmClear = false)

    @Test
    fun `clear queue is an icon in the top bar`() {
        val calls = mutableListOf<String>()
        compose.setContent { RetroTheme { QueueContent(filled, QueueActions(requestClear = { calls += "clear" })) } }
        compose.onNodeWithText(context.getString(R.string.clear_queue)).assertDoesNotExist()
        compose.onNodeWithContentDescription(context.getString(R.string.clear_queue)).performClick()
        assertThat(calls).containsExactly("clear")
    }

    @Test
    fun `save as playlist opens the folder picker`() {
        val calls = mutableListOf<String>()
        compose.setContent { RetroTheme { QueueContent(filled, QueueActions(saveAsPlaylist = { calls += "save" })) } }
        compose.onNodeWithText(context.getString(R.string.save_as_playlist)).performClick()
        assertThat(calls).containsExactly("save")
    }

    @Test
    fun `an empty queue offers neither clearing nor saving`() {
        compose.setContent { RetroTheme { QueueContent(QueueUiState.Ready(emptyList(), null, false), QueueActions()) } }
        compose.onNodeWithContentDescription(context.getString(R.string.clear_queue)).assertDoesNotExist()
        compose.onNodeWithText(context.getString(R.string.save_as_playlist)).assertDoesNotExist()
    }

    @Test
    fun `add tracks is a floating button`() {
        val calls = mutableListOf<String>()
        compose.setContent { RetroTheme { QueueContent(filled, QueueActions(addTracks = { calls += "add" })) } }
        compose.onNodeWithContentDescription(context.getString(R.string.add_tracks)).assertIsDisplayed().performClick()
        assertThat(calls).containsExactly("add")
    }

    @Test
    fun `screen readers hear remove once per row`() {
        compose.setContent { RetroTheme { QueueContent(filled, QueueActions()) } }
        val labels = compose
            .onNode(hasAnyDescendant(hasText("Alpha")) and SemanticsMatcher.keyIsDefined(SemanticsActions.CustomActions))
            .fetchSemanticsNode().config[SemanticsActions.CustomActions].map { it.label }
        assertThat(labels.filter { it == context.getString(R.string.remove) }).hasSize(1)
    }
}

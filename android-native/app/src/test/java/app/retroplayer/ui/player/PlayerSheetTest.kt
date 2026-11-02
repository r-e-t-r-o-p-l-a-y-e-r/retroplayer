package app.retroplayer.ui.player

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.performSemanticsAction
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.components.PROGRESS_TAG
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ApplicationProvider
import android.content.Context
import app.retroplayer.R
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PlayerSheetTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val calls = mutableListOf<String>()
    private val actions = PlayerActions(
        toggle = { calls += "toggle" },
        previous = { calls += "previous" },
        next = { calls += "next" },
        seekTo = { calls += "seek:$it" },
    )
    private var expanded by mutableStateOf(false)

    private val playing = PlayerUiState(
        NowPlaying(
            title = "Song 2",
            subtitle = "Tester",
            hasTrack = true,
            isPlaying = true,
            hasNext = true,
            positionMs = 30_000,
            durationMs = 180_000,
        ),
        crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Song 2", null)),
    )

    private fun show(state: PlayerUiState) = compose.setContent {
        RetroTheme {
            PlayerHost(state, expanded, { expanded = it }, actions) {
                Column {
                    Text("library content")
                    PlayerToggleAction()
                }
            }
        }
    }

    @Test
    fun `mini player shows progress and transport`() {
        show(playing)
        compose.onNodeWithText("00:30").assertIsDisplayed()
        compose.onNodeWithText("03:00").assertIsDisplayed()
        compose.onNodeWithContentDescription(context.getString(R.string.previous)).performClick()
        compose.onNodeWithContentDescription(context.getString(R.string.next)).performClick()
        compose.onNodeWithTag(PROGRESS_TAG).performSemanticsAction(SemanticsActions.SetProgress) { it(90_000f) }
        assertThat(calls).containsExactly("previous", "next", "seek:90000").inOrder()
        assertThat(expanded).isFalse()
    }

    @Test
    fun `library top bar action expands the player`() {
        show(playing)
        compose.onNodeWithContentDescription(context.getString(R.string.expand_player)).performClick()
        compose.waitForIdle()
        assertThat(expanded).isTrue()
    }

    @Test
    fun `library top bar action is absent without a track`() {
        show(PlayerUiState())
        compose.onNodeWithContentDescription(context.getString(R.string.expand_player)).assertDoesNotExist()
    }

    @Test
    fun `expanded player shows its title and the playing breadcrumbs`() {
        expanded = true
        show(playing)
        compose.onNodeWithText(context.getString(R.string.now_playing)).assertIsDisplayed()
        compose.onNodeWithText("Music").assertIsDisplayed()
        compose.onNodeWithText("library content").assertDoesNotExist()
    }

    @Test
    fun `mini player shows title and subtitle`() {
        show(playing)
        compose.onNodeWithTag(MINI_PLAYER_TAG).assertIsDisplayed()
        compose.onNodeWithText("Song 2", useUnmergedTree = true).assertIsDisplayed()
        compose.onNodeWithText("Tester", useUnmergedTree = true).assertIsDisplayed()
        compose.onNodeWithText("library content").assertIsDisplayed()
    }

    @Test
    fun `mini player is hidden without a track`() {
        show(PlayerUiState())
        compose.onNodeWithTag(MINI_PLAYER_TAG).assertDoesNotExist()
        compose.onNodeWithText("library content").assertIsDisplayed()
    }

    @Test
    fun `tapping the mini player expands`() {
        show(playing)
        compose.onNodeWithText("Song 2", useUnmergedTree = true).performClick()
        compose.waitForIdle()
        assertThat(expanded).isTrue()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertIsDisplayed()
    }

    @Test
    fun `play button toggles without expanding`() {
        show(playing)
        compose.onNodeWithContentDescription(context.getString(R.string.pause)).performClick()
        assertThat(calls).containsExactly("toggle")
        assertThat(expanded).isFalse()
    }

    @Test
    fun `expanded player offers previous play pause and next`() {
        expanded = true
        show(playing)
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertIsDisplayed()
        compose.onNodeWithContentDescription(context.getString(R.string.previous)).performClick()
        compose.onNodeWithContentDescription(context.getString(R.string.next)).performClick()
        assertThat(calls).containsExactly("previous", "next").inOrder()
    }

    @Test
    fun `collapse button shows the library again`() {
        expanded = true
        show(playing)
        compose.onNodeWithContentDescription(context.getString(R.string.show_library)).performClick()
        compose.waitForIdle()
        assertThat(expanded).isFalse()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertDoesNotExist()
    }
}

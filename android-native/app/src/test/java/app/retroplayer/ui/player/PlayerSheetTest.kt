package app.retroplayer.ui.player

import androidx.compose.material3.Text
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
    )
    private var expanded by mutableStateOf(false)

    private val playing = PlayerUiState(NowPlaying(title = "Song 2", subtitle = "Tester", hasTrack = true, isPlaying = true, hasNext = true))

    private fun show(state: PlayerUiState) = compose.setContent {
        RetroTheme {
            PlayerHost(state, expanded, { expanded = it }, actions) { Text("library content") }
        }
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
        compose.onNodeWithTag(MINI_PLAYER_TAG).performClick()
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

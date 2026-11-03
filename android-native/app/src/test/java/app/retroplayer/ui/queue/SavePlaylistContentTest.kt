package app.retroplayer.ui.queue

import android.content.Context
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTextInput
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SavePlaylistContentTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val calls = mutableListOf<String>()
    private val actions = SavePlaylistActions(
        back = { calls += "back" },
        open = { calls += "open:${it.value}" },
        save = { calls += "save:$it" },
    )
    private val sources = SavePlaylistUiState(
        folder = null,
        title = null,
        folders = listOf(SaveFolderChoice(LibraryPath("1"), "Music")),
        loading = false,
    )
    private val inMusic = SavePlaylistUiState(
        folder = LibraryPath("1"),
        title = "Music",
        folders = listOf(SaveFolderChoice(LibraryPath("1/Mix"), "Mix")),
        loading = false,
    )

    private fun show(state: SavePlaylistUiState) = compose.setContent { RetroTheme { SavePlaylistContent(state, actions) } }

    @Test
    fun `the library sources ask for a folder and cannot be saved to`() {
        show(sources)
        compose.onNodeWithText(context.getString(R.string.choose_playlist_folder)).assertIsDisplayed()
        compose.onNode(hasSetTextAction()).performTextInput("Trip")
        compose.onNode(hasText(context.getString(R.string.save))).assertIsNotEnabled()
        compose.onNodeWithText("Music").performClick()
        assertThat(calls).containsExactly("open:1")
    }

    @Test
    fun `a named playlist saves into the open folder`() {
        show(inMusic)
        compose.onNode(hasText(context.getString(R.string.save))).assertIsNotEnabled()
        compose.onNode(hasSetTextAction()).performTextInput("Trip")
        compose.onNode(hasText(context.getString(R.string.save))).assertIsEnabled().performClick()
        assertThat(calls).containsExactly("save:Trip")
    }
}

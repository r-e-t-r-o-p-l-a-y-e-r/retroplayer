package app.retroplayer.ui.player

import androidx.activity.ComponentActivity
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.navigation.AbsorbBackAtRoot
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/** UC-14 order: expanded player, then detail/folder pages, then absorb at the library root. */
@RunWith(RobolectricTestRunner::class)
class BackChainTest {
    @get:Rule val compose = createAndroidComposeRule<ComponentActivity>()

    private var expanded by mutableStateOf(false)
    private lateinit var nav: NavHostController
    private val state = PlayerUiState(NowPlaying(title = "Song", hasTrack = true))
    private val actions = PlayerActions(toggle = {}, previous = {}, next = {})

    private fun show() = compose.setContent {
        RetroTheme {
            nav = rememberNavController()
            PlayerHost(state, expanded, { expanded = it }, actions) {
                NavHost(nav, startDestination = "root") {
                    composable("root") {
                        AbsorbBackAtRoot(isRoot = true)
                        Text("root page")
                    }
                    composable("album") { Text("album page") }
                }
            }
        }
    }

    private fun pressBack() {
        compose.runOnUiThread { compose.activity.onBackPressedDispatcher.onBackPressed() }
        compose.waitForIdle()
    }

    @Test
    fun `back collapses the expanded player first`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        expanded = true
        compose.waitForIdle()

        pressBack()
        assertThat(expanded).isFalse()
        compose.onNodeWithText("album page").assertIsDisplayed()
    }

    @Test
    fun `back from an album returns to its folder`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        compose.waitForIdle()

        pressBack()
        compose.onNodeWithText("root page").assertIsDisplayed()
    }

    @Test
    fun `back at the library root is absorbed`() {
        show()
        pressBack()
        assertThat(compose.activity.isFinishing).isFalse()
        compose.onNodeWithText("root page").assertIsDisplayed()
    }

    @Test
    fun `back at the root collapses the expanded player instead of being absorbed`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        compose.waitForIdle()
        pressBack()
        expanded = true
        compose.waitForIdle()

        pressBack()
        assertThat(expanded).isFalse()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertDoesNotExist()
    }
}

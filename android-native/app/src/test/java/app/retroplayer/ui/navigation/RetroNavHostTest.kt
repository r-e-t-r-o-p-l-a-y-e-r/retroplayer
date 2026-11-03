package app.retroplayer.ui.navigation

import androidx.activity.ComponentActivity
import androidx.compose.material3.Text
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.navigation.NavHostController
import androidx.navigation.compose.composable
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RetroNavHostTest {
    @get:Rule val compose = createAndroidComposeRule<ComponentActivity>()

    private lateinit var nav: NavHostController

    private fun show() = compose.setContent {
        nav = rememberRestoredNavController(listOf(FolderRoute())) {
            composable<FolderRoute> { Text("library") }
            composable<SettingsRoute> { Text("settings") }
        }
        RetroNavHost(nav)
    }

    @Test
    fun `opening a page finishes quickly`() {
        show()
        compose.waitForIdle()
        compose.mainClock.autoAdvance = false
        compose.runOnUiThread { nav.navigate(SettingsRoute) }
        compose.mainClock.advanceTimeBy(TRANSITION_BUDGET_MS)
        compose.onNodeWithText("settings").assertIsDisplayed()
        compose.onNodeWithText("library").assertDoesNotExist()
    }

    @Test
    fun `going back finishes quickly`() {
        show()
        compose.runOnUiThread { nav.navigate(SettingsRoute) }
        compose.waitForIdle()
        compose.mainClock.autoAdvance = false
        compose.runOnUiThread { compose.activity.onBackPressedDispatcher.onBackPressed() }
        compose.mainClock.advanceTimeBy(TRANSITION_BUDGET_MS)
        compose.onNodeWithText("library").assertIsDisplayed()
        compose.onNodeWithText("settings").assertDoesNotExist()
    }

    private companion object {
        const val TRANSITION_BUDGET_MS = 350L
    }
}

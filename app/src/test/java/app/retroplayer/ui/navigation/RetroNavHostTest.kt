package app.retroplayer.ui.navigation

import androidx.activity.BackEventCompat
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.getBoundsInRoot
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.width
import com.google.common.truth.Truth.assertThat
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
            composable<FolderRoute> { Box(Modifier.fillMaxSize().testTag("library")) { Text("library") } }
            composable<SettingsRoute> { Box(Modifier.fillMaxSize().testTag("settings")) { Text("settings") } }
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

    @Test
    fun `a back swipe slides the page with the finger instead of shrinking it`() {
        show()
        compose.runOnUiThread { nav.navigate(SettingsRoute) }
        compose.waitForIdle()
        val width = compose.onRoot().getBoundsInRoot().width
        val dispatcher = compose.activity.onBackPressedDispatcher
        compose.runOnUiThread {
            dispatcher.dispatchOnBackStarted(BackEventCompat(0f, 500f, 0f, BackEventCompat.EDGE_LEFT))
            dispatcher.dispatchOnBackProgressed(BackEventCompat(400f, 500f, 0.5f, BackEventCompat.EDGE_LEFT))
        }
        compose.waitForIdle()
        val page = compose.onNodeWithTag("settings").getBoundsInRoot()
        assertThat(page.width).isEqualTo(width)
        assertThat(page.left).isGreaterThan(0.dp)
        assertThat(page.left).isLessThan(width)
        compose.onNodeWithTag("library").assertExists()
    }

    private companion object {
        const val TRANSITION_BUDGET_MS = 350L
    }
}

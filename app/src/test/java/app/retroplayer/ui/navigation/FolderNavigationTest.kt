package app.retroplayer.ui.navigation

import androidx.activity.ComponentActivity
import androidx.compose.material3.Text
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.v2.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.toRoute
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.openFolder
import app.retroplayer.ui.showFolder
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class FolderNavigationTest {
    @get:Rule val compose = createAndroidComposeRule<ComponentActivity>()

    private lateinit var nav: NavHostController

    private fun show() = compose.setContent {
        nav = rememberNavController()
        NavHost(nav, startDestination = FolderRoute()) {
            composable<FolderRoute> { Text("folder " + (it.toRoute<FolderRoute>().path ?: "library")) }
        }
    }

    private fun go(action: NavHostController.() -> Unit) {
        compose.runOnUiThread { nav.action() }
        compose.waitForIdle()
    }

    private fun pressBack() = go { compose.activity.onBackPressedDispatcher.onBackPressed() }

    @Test
    fun `opening a root from the library pushes it`() {
        show()
        go { openFolder(LibraryPath("1")) }
        compose.onNodeWithText("folder 1").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder library").assertIsDisplayed()
    }

    @Test
    fun `opening a subfolder pushes it above its parent`() {
        show()
        go { openFolder(LibraryPath("1")) }
        go { openFolder(LibraryPath("1/Books")) }
        compose.onNodeWithText("folder 1/Books").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder 1").assertIsDisplayed()
    }

    @Test
    fun `opening another root replaces the one that was open`() {
        show()
        go { openFolder(LibraryPath("1/Books")) }
        go { openFolder(LibraryPath("2")) }
        compose.onNodeWithText("folder 2").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder library").assertIsDisplayed()
    }

    @Test
    fun `a crumb goes back up to its folder`() {
        show()
        go { openFolder(LibraryPath("1")) }
        go { openFolder(LibraryPath("1/Books")) }
        go { showFolder(null) }
        compose.onNodeWithText("folder library").assertIsDisplayed()
    }

    @Test
    fun `a playback crumb opens the whole chain to a deep folder`() {
        show()
        go { showFolder(LibraryPath("1/Books")) }
        compose.onNodeWithText("folder 1/Books").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder 1").assertIsDisplayed()
    }

    @Test
    fun `opening the folder that is already open does not stack it twice`() {
        show()
        go { openFolder(LibraryPath("1")) }
        go { openFolder(LibraryPath("1")) }
        pressBack()
        compose.onNodeWithText("folder library").assertIsDisplayed()
    }
}

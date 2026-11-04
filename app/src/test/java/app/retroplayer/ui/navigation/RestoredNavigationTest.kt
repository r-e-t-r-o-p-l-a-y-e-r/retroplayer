package app.retroplayer.ui.navigation

import androidx.activity.ComponentActivity
import androidx.compose.material3.Text
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.StateRestorationTester
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable

import androidx.navigation.toRoute
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RestoredNavigationTest {
    @get:Rule val compose = createAndroidComposeRule<ComponentActivity>()

    private val shown = mutableListOf<String>()
    private lateinit var nav: NavHostController

    private fun showWithPages(routes: List<Any>) = compose.setContent {
        nav = rememberRestoredNavController(routes) {
            composable<FolderRoute> { entry ->
                val label = "folder:" + entry.toRoute<FolderRoute>().path
                LaunchedEffect(Unit) { shown += label }
                Text(label)
            }
            composable<AlbumRoute> { entry ->
                val label = "album:" + entry.toRoute<AlbumRoute>().albumId
                LaunchedEffect(Unit) { shown += label }
                Text(label)
            }
        }
        NavHost(nav, nav.graph)
    }

    private fun pressBack() {
        compose.runOnUiThread { compose.activity.onBackPressedDispatcher.onBackPressed() }
        compose.waitForIdle()
    }

    private val chain = listOf(FolderRoute(), FolderRoute("1"), FolderRoute("1/A"), AlbumRoute("dir:1/A"))

    @Test
    fun `restored back stack shows only the top page`() {
        showWithPages(chain)
        compose.onNodeWithText("album:dir:1/A").assertIsDisplayed()
        assertThat(shown).containsExactly("album:dir:1/A")
    }

    @Test
    fun `back walks up the restored chain`() {
        showWithPages(chain)
        pressBack()
        compose.onNodeWithText("folder:1/A").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder:1").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder:null").assertIsDisplayed()
    }

    @Test
    fun `recreation keeps the back stack instead of rebuilding it`() {
        val restoration = StateRestorationTester(compose)
        restoration.setContent {
            nav = rememberRestoredNavController(chain) {
                composable<FolderRoute> { entry -> Text("folder:" + entry.toRoute<FolderRoute>().path) }
                composable<AlbumRoute> { entry -> Text("album:" + entry.toRoute<AlbumRoute>().albumId) }
            }
            NavHost(nav, nav.graph)
        }
        pressBack()
        compose.onNodeWithText("folder:1/A").assertIsDisplayed()

        restoration.emulateSavedInstanceStateRestore()
        compose.onNodeWithText("folder:1/A").assertIsDisplayed()
        pressBack()
        compose.onNodeWithText("folder:1").assertIsDisplayed()
    }
}

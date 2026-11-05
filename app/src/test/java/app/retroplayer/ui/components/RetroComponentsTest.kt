package app.retroplayer.ui.components

import androidx.compose.material3.Text
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.assertHasClickAction
import androidx.compose.ui.test.assertHasNoClickAction
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performSemanticsAction
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RetroComponentsTest {
    @get:Rule val compose = createComposeRule()

    @Test
    fun `playing row shows the accent strip`() {
        compose.setContent {
            RetroTheme {
                RetroListRow(title = { Text("Song") }, playing = true, onClick = {})
            }
        }
        compose.onNodeWithTag(PLAYING_STRIP_TAG, useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun `other rows have no strip`() {
        compose.setContent {
            RetroTheme {
                RetroListRow(title = { Text("Song") }, onClick = {})
            }
        }
        compose.onNodeWithTag(PLAYING_STRIP_TAG, useUnmergedTree = true).assertDoesNotExist()
    }

    @Test
    fun `breadcrumb strip opens parents and marks the current crumb`() {
        val opened = mutableListOf<String?>()
        compose.setContent {
            RetroTheme {
                BreadcrumbStrip(
                    crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1"))),
                    onCrumb = { opened += it.path?.value },
                )
            }
        }
        compose.onNodeWithText("Library").assertHasClickAction().performClick()
        compose.onNodeWithText("Music").assertHasNoClickAction()
        assertThat(opened).containsExactly(null)
    }

    @Test
    fun `progress shows elapsed and total time`() {
        compose.setContent {
            RetroTheme { PlaybackProgress(positionMs = 65_000, durationMs = 245_000, onSeek = {}) }
        }
        compose.onNodeWithText("01:05").assertIsDisplayed()
        compose.onNodeWithText("04:05").assertIsDisplayed()
    }

    @Test
    fun `releasing the progress bar seeks once`() {
        val seeks = mutableListOf<Long>()
        compose.setContent {
            RetroTheme { PlaybackProgress(positionMs = 0, durationMs = 200_000, onSeek = { seeks += it }) }
        }
        compose.onNodeWithTag(PROGRESS_TAG).performSemanticsAction(SemanticsActions.SetProgress) { it(50_000f) }
        compose.waitForIdle()
        assertThat(seeks).containsExactly(50_000L)
    }
}

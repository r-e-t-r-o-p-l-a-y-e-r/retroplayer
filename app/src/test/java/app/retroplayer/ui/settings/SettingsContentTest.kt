package app.retroplayer.ui.settings

import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasClickAction
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.onAllNodesWithText
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.BuildConfig
import app.retroplayer.R
import androidx.compose.ui.test.assertIsNotSelected
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.unit.toSize
import androidx.compose.ui.test.isSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class SettingsContentTest {
    @get:Rule val compose = createComposeRule()

    private var theme: ThemePreference = ThemePreference.SYSTEM
    private var resetKeep: Boolean? = null

    @Test
    fun `theme choice is checked`() {
        compose.setContent {
            RetroTheme {
                SettingsContent(
                    SettingsUiState(theme = ThemePreference.DARK, languages = emptyList()),
                    SettingsActions(setTheme = { theme = it }),
                )
            }
        }
        compose.onNodeWithText("Dark mode").assertIsSelected()
        compose.onNodeWithText("System theme").assertIsNotSelected()
        compose.onNodeWithText("Light mode").performClick()
        assertThat(theme).isEqualTo(ThemePreference.LIGHT)
    }

    @Test
    fun `reset asks first`() {
        compose.setContent {
            RetroTheme {
                SettingsContent(
                    SettingsUiState(languages = emptyList()),
                    SettingsActions(
                        resetDatabase = { resetKeep = it },
                    ),
                )
            }
        }
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("Reset database"))
        compose.onNodeWithText("Reset database").performClick()
        compose.waitForIdle()
        compose.onNodeWithText("Reset database?").assertIsDisplayed()
        compose.onNodeWithText("Keep library folders").performClick()
        assertThat(resetKeep).isTrue()
    }

    @Test
    fun `reset buttons are stacked and end aligned, keeping folders first`() {
        compose.setContent { RetroTheme { SettingsContent(SettingsUiState(), SettingsActions()) } }
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("Reset database"))
        compose.onNodeWithText("Reset database").performClick()
        compose.waitForIdle()
        val buttons = listOf("Keep library folders", "Clear everything", "Cancel").map {
            compose.onNode(hasText(it) and hasClickAction()).fetchSemanticsNode().boundsInRoot
        }
        assertThat(buttons.map { it.top }).isInStrictOrder()
        assertThat(buttons.map { it.right }.distinct()).hasSize(1)
    }

    @Test
    fun `languages are picked from a dropdown`() {
        var chosen: String? = "none"
        compose.setContent {
            RetroTheme {
                SettingsContent(
                    SettingsUiState(languageTag = null, languages = listOf(LanguageOption("de", "Deutsch"), LanguageOption("fi", "suomi"))),
                    SettingsActions(setLanguage = { chosen = it }),
                )
            }
        }
        compose.onNodeWithText("Deutsch").assertDoesNotExist()
        compose.onNodeWithText("System language").performClick()
        compose.onNodeWithText("Deutsch").performClick()
        assertThat(chosen).isEqualTo("de")
    }

    @Test
    @Config(qualifiers = "w360dp-h800dp")
    fun `the language list opens below the field at its width`() {
        compose.setContent {
            RetroTheme {
                SettingsContent(SettingsUiState(languageTag = "de", languages = listOf(LanguageOption("de", "Deutsch"))), SettingsActions())
            }
        }
        compose.onNodeWithTag(LANGUAGE_DROPDOWN_TAG).performClick()
        // The list is a popup window: compare positions on screen, not in each window's root.
        val field = compose.onNodeWithTag(LANGUAGE_DROPDOWN_TAG).fetchSemanticsNode().let { Rect(it.positionOnScreen, it.size.toSize()) }
        val item = compose.onNode(hasText("System language") and hasClickAction()).fetchSemanticsNode()
            .let { Rect(it.positionOnScreen, it.size.toSize()) }
        assertThat(item.top).isAtLeast(field.bottom)
        assertThat(item.left).isWithin(4f).of(field.left)
        assertThat(item.right).isWithin(4f).of(field.right)
        compose.onNode(hasText("Deutsch") and hasClickAction() and isSelected()).assertExists()
    }

    @Test
    fun `about is shown on the settings page`() {
        compose.setContent { RetroTheme { SettingsContent(SettingsUiState(), SettingsActions()) } }
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("Version"))
        compose.onNodeWithText("Version").assertIsDisplayed()
        compose.onNodeWithText(BuildConfig.VERSION_NAME).assertIsDisplayed()
    }

    @Test
    fun `about shows the commit but not the branch, which differs between clones of one tag`() {
        compose.setContent { RetroTheme { SettingsContent(SettingsUiState(), SettingsActions()) } }
        val context = ApplicationProvider.getApplicationContext<Context>()
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(context.getString(R.string.about_git_commit)))
        compose.onNodeWithText(BuildConfig.GIT_COMMIT).assertIsDisplayed()
        compose.onNodeWithText("Branch").assertDoesNotExist()
    }

    @Test
    fun `the equalizer is shown on the settings page`() {
        compose.setContent { RetroTheme { SettingsContent(SettingsUiState(), SettingsActions()) } }
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasContentDescription("60 Hz"))
        compose.onNode(hasContentDescription("60 Hz")).assertIsDisplayed()
    }

    @Test
    fun `system language is shown when no language is chosen`() {
        compose.setContent {
            RetroTheme {
                SettingsContent(
                    SettingsUiState(languageTag = null, languages = listOf(LanguageOption("de", "Deutsch"))),
                    SettingsActions(),
                )
            }
        }
        compose.onNodeWithText("System language").assertIsDisplayed()
        compose.onNodeWithText("System language").performClick()
        compose.onAllNodesWithText("System language").assertCountEquals(2)
    }
}

package app.retroplayer.ui.settings

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsNotSelected
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasText
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
    fun `system language is always offered and checked when no language is chosen`() {
        compose.setContent {
            RetroTheme {
                SettingsContent(
                    SettingsUiState(languageTag = null, languages = listOf(LanguageOption("de", "Deutsch"))),
                    SettingsActions(),
                )
            }
        }
        compose.onNodeWithText("System language").assertIsSelected()
        compose.onNodeWithText("Deutsch").assertIsNotSelected()
    }
}

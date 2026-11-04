package app.retroplayer.ui.settings

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertIsNotSelected
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onAllNodesWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performSemanticsAction
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class EqualizerSectionTest {
    @get:Rule val compose = createComposeRule()

    private val presetLabels = listOf("Manually", "Bass", "Treble", "Voice")
    private var moved: Pair<Int, Float>? = null

    private fun show(state: EqualizerUiState, width: Int? = null, fontScale: Float = 1f) = compose.setContent {
        val density = LocalDensity.current
        CompositionLocalProvider(LocalDensity provides Density(density.density, fontScale)) {
            RetroTheme {
                Box(if (width != null) Modifier.width(width.dp) else Modifier) {
                    EqualizerSection(state, EqualizerActions(setBand = { band, db -> moved = band to db }))
                }
            }
        }
    }

    private val available = EqualizerUiState(available = true, settings = EqualizerSettings(enabled = true))

    @Test
    fun `unavailable disables the controls`() {
        show(EqualizerUiState(available = false))
        compose.onNodeWithText("Equalizer is not available on this platform.").assertIsDisplayed()
        presetLabels.forEach { compose.onNode(hasText(it)).assertIsNotEnabled() }
        compose.onAllNodesWithContentDescription("Hz", substring = true).fetchSemanticsNodes().forEach { node ->
            assertThat(node.config.contains(SemanticsProperties.Disabled)).isTrue()
        }
    }

    @Test
    fun `presets fit a narrow screen at a large font`() {
        show(available, width = 220, fontScale = 1.6f)
        val right = compose.onRoot().fetchSemanticsNode().boundsInRoot.right
        presetLabels.forEach { label ->
            val chip = compose.onNode(hasText(label)).assertIsDisplayed().fetchSemanticsNode().boundsInRoot
            assertThat(chip.right).isAtMost(right)
        }
    }

    @Test
    fun `each band slider names its frequency and value`() {
        show(available.copy(settings = EqualizerSettings(enabled = true, preset = EqualizerPreset.BASS_BOOST)))
        listOf("60 Hz" to "6 dB", "230 Hz" to "4 dB", "910 Hz" to "1 dB", "3.6 kHz" to "0 dB", "14 kHz" to "0 dB")
            .forEach { (hz, db) ->
                compose.onNode(hasContentDescription(hz) and SemanticsMatcher.expectValue(SemanticsProperties.StateDescription, db))
                    .assertExists()
            }
    }

    @Test
    fun `moving a slider reports its band`() {
        show(available)
        compose.onNode(hasContentDescription("910 Hz"))
            .performSemanticsAction(SemanticsActions.SetProgress) { it(5f) }
        assertThat(moved).isEqualTo(2 to 5f)
    }

    @Test
    fun `the chosen preset is selected`() {
        show(available.copy(settings = EqualizerSettings(enabled = true, preset = EqualizerPreset.VOICE)))
        compose.onNode(hasText("Voice")).assertIsSelected()
        compose.onNode(hasText("Manually")).assertIsNotSelected()
    }
}

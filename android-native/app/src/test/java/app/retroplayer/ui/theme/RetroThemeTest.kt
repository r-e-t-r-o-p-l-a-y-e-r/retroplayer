package app.retroplayer.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color
import com.google.common.truth.Truth.assertWithMessage
import org.junit.Test

class RetroThemeTest {

    @Test
    fun `light scheme uses no Material baseline colors`() =
        assertNoBaseline(retroColorScheme(dark = false), lightColorScheme())

    @Test
    fun `dark scheme uses no Material baseline colors`() =
        assertNoBaseline(retroColorScheme(dark = true), darkColorScheme())

    private fun assertNoBaseline(scheme: ColorScheme, baseline: ColorScheme) {
        val slots: List<Pair<String, (ColorScheme) -> Color>> = listOf(
            "primaryContainer" to { it.primaryContainer },
            "secondaryContainer" to { it.secondaryContainer },
            "onSecondaryContainer" to { it.onSecondaryContainer },
            "tertiary" to { it.tertiary },
            "tertiaryContainer" to { it.tertiaryContainer },
            "inversePrimary" to { it.inversePrimary },
            "inverseSurface" to { it.inverseSurface },
            "surfaceTint" to { it.surfaceTint },
            "surfaceContainerLowest" to { it.surfaceContainerLowest },
            "surfaceContainerLow" to { it.surfaceContainerLow },
            "surfaceContainerHigh" to { it.surfaceContainerHigh },
            "surfaceContainerHighest" to { it.surfaceContainerHighest },
        )
        for ((name, slot) in slots) {
            assertWithMessage(name).that(slot(scheme)).isNotEqualTo(slot(baseline))
        }
    }
}

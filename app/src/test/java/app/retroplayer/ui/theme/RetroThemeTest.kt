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

    @Test
    fun `light scheme uses the Flutter slot colors`() {
        val p = RetroPalette.Light
        assertFlutterSlots(retroColorScheme(dark = false), p, onAccent = Color.White, primaryContainer = Color(0xFFF5DFD0))
    }

    @Test
    fun `dark scheme uses the Flutter slot colors`() {
        val p = RetroPalette.Dark
        assertFlutterSlots(retroColorScheme(dark = true), p, onAccent = p.textPrimary, primaryContainer = Color(0xFF3D2A1F))
    }

    private fun assertFlutterSlots(scheme: ColorScheme, p: RetroPalette, onAccent: Color, primaryContainer: Color) {
        val expected: List<Triple<String, Color, Color>> = listOf(
            Triple("primary", scheme.primary, p.accent),
            Triple("onPrimary", scheme.onPrimary, onAccent),
            Triple("secondary", scheme.secondary, p.accentSecondary),
            Triple("onSecondary", scheme.onSecondary, Color.White),
            Triple("error", scheme.error, p.error),
            Triple("onError", scheme.onError, onAccent),
            Triple("errorContainer", scheme.errorContainer, p.error),
            Triple("onErrorContainer", scheme.onErrorContainer, onAccent),
            Triple("surfaceContainerHighest", scheme.surfaceContainerHighest, p.chrome),
            Triple("outline", scheme.outline, p.divider),
            Triple("primaryContainer", scheme.primaryContainer, primaryContainer),
            Triple("onPrimaryContainer", scheme.onPrimaryContainer, p.accent),
        )
        for ((name, actual, want) in expected) {
            assertWithMessage(name).that(actual).isEqualTo(want)
        }
    }

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

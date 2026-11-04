package app.retroplayer.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import app.retroplayer.domain.settings.ThemePreference

/** Retro Player colors (Studio Warm light, Studio Night dark), as in the Flutter app. */
@Immutable
data class RetroPalette(
    val body: Color,
    val chrome: Color,
    val screen: Color,
    val screenElevated: Color,
    val textPrimary: Color,
    val textSecondary: Color,
    val textMuted: Color,
    val accent: Color,
    val accentMuted: Color,
    val accentSecondary: Color,
    val divider: Color,
    val playingHighlight: Color,
    val iconChip: Color,
    val albumPlaceholderStart: Color,
    val albumPlaceholderEnd: Color,
    val error: Color,
) {
    companion object {
        val Light = RetroPalette(
            body = Color(0xFFEBE4D9),
            chrome = Color(0xFFD8CFC2),
            screen = Color(0xFFF7F2EA),
            screenElevated = Color(0xFFFFFCF7),
            textPrimary = Color(0xFF2B2118),
            textSecondary = Color(0xFF5C534A),
            textMuted = Color(0xFF8A8178),
            accent = Color(0xFFC45C26),
            accentMuted = Color(0xFFE8956A),
            accentSecondary = Color(0xFF2A6F6F),
            divider = Color(0xFFC9BFB3),
            playingHighlight = Color(0x24C45C26),
            iconChip = Color(0xFFE8E0D4),
            albumPlaceholderStart = Color(0xFFD8CFC2),
            albumPlaceholderEnd = Color(0xFFB8AEA2),
            error = Color(0xFFB3261E),
        )

        val Dark = RetroPalette(
            body = Color(0xFF181512),
            chrome = Color(0xFF2A2520),
            screen = Color(0xFF181512),
            screenElevated = Color(0xFF221E1A),
            textPrimary = Color(0xFFF7F2EA),
            textSecondary = Color(0xFFC9BFB3),
            textMuted = Color(0xFF8A8178),
            accent = Color(0xFFE8956A),
            accentMuted = Color(0xFFF0B896),
            accentSecondary = Color(0xFF3D9A9A),
            divider = Color(0xFF4A4038),
            playingHighlight = Color(0x24E8956A),
            iconChip = Color(0xFF2A2420),
            albumPlaceholderStart = Color(0xFF2A2420),
            albumPlaceholderEnd = Color(0xFF3D342B),
            error = Color(0xFFF2B8B5),
        )
    }
}

val LocalRetroPalette = staticCompositionLocalOf { RetroPalette.Light }

@Composable
fun RetroTheme(theme: ThemePreference = ThemePreference.SYSTEM, content: @Composable () -> Unit) {
    val dark = when (theme) {
        ThemePreference.LIGHT -> false
        ThemePreference.DARK -> true
        ThemePreference.SYSTEM -> isSystemInDarkTheme()
    }
    val palette = if (dark) RetroPalette.Dark else RetroPalette.Light
    CompositionLocalProvider(LocalRetroPalette provides palette) {
        MaterialTheme(colorScheme = retroColorScheme(dark), typography = RetroTypography, content = content)
    }
}

/** Flutter `RetroTypography`: semibold condensed titles, small spaced section headers. */
val RetroTypography: Typography = Typography().run {
    copy(
        headlineSmall = headlineSmall.copy(fontWeight = FontWeight.SemiBold, letterSpacing = (-0.3).sp),
        titleMedium = titleMedium.copy(fontWeight = FontWeight.SemiBold, letterSpacing = (-0.2).sp),
        titleSmall = titleSmall.copy(fontWeight = FontWeight.SemiBold, letterSpacing = 0.8.sp, fontSize = 12.sp),
        labelLarge = labelLarge.copy(fontWeight = FontWeight.Medium, letterSpacing = 0.1.sp),
    )
}

/** Every slot Material components read is mapped, so no baseline purple leaks into chips, menus or sheets. */
fun retroColorScheme(dark: Boolean): ColorScheme {
    val p = if (dark) RetroPalette.Dark else RetroPalette.Light
    val inverse = if (dark) RetroPalette.Light else RetroPalette.Dark
    val selected = lerp(p.screen, p.accent, 0.25f)
    val tertiaryContainer = lerp(p.screen, p.accentSecondary, 0.25f)
    return if (dark) {
        darkColorScheme(
            primary = p.accent,
            onPrimary = p.textPrimary,
            primaryContainer = Color(0xFF3D2A1F),
            onPrimaryContainer = p.accent,
            inversePrimary = inverse.accent,
            secondary = p.accentSecondary,
            onSecondary = Color.White,
            secondaryContainer = selected,
            onSecondaryContainer = p.textPrimary,
            tertiary = p.accentSecondary,
            onTertiary = p.textPrimary,
            tertiaryContainer = tertiaryContainer,
            onTertiaryContainer = p.textPrimary,
            background = p.screen,
            onBackground = p.textPrimary,
            surface = p.screen,
            onSurface = p.textPrimary,
            surfaceVariant = p.screenElevated,
            onSurfaceVariant = p.textSecondary,
            surfaceTint = p.accent,
            inverseSurface = inverse.screen,
            inverseOnSurface = inverse.textPrimary,
            surfaceContainerLowest = p.body,
            surfaceContainerLow = p.screenElevated,
            surfaceContainer = p.chrome,
            surfaceContainerHigh = p.chrome,
            surfaceContainerHighest = p.chrome,
            outline = p.divider,
            outlineVariant = p.divider,
            error = p.error,
            onError = p.textPrimary,
            errorContainer = p.error,
            onErrorContainer = p.textPrimary,
        )
    } else {
        lightColorScheme(
            primary = p.accent,
            onPrimary = Color.White,
            primaryContainer = Color(0xFFF5DFD0),
            onPrimaryContainer = p.accent,
            inversePrimary = inverse.accent,
            secondary = p.accentSecondary,
            onSecondary = Color.White,
            secondaryContainer = selected,
            onSecondaryContainer = p.textPrimary,
            tertiary = p.accentSecondary,
            onTertiary = p.screenElevated,
            tertiaryContainer = tertiaryContainer,
            onTertiaryContainer = p.textPrimary,
            background = p.screen,
            onBackground = p.textPrimary,
            surface = p.screen,
            onSurface = p.textPrimary,
            surfaceVariant = p.iconChip,
            onSurfaceVariant = p.textSecondary,
            surfaceTint = p.accent,
            inverseSurface = inverse.screen,
            inverseOnSurface = inverse.textPrimary,
            surfaceContainerLowest = p.screenElevated,
            surfaceContainerLow = p.screen,
            surfaceContainer = p.chrome,
            surfaceContainerHigh = p.chrome,
            surfaceContainerHighest = p.chrome,
            outline = p.divider,
            outlineVariant = p.divider,
            error = p.error,
            onError = Color.White,
            errorContainer = p.error,
            onErrorContainer = Color.White,
        )
    }
}

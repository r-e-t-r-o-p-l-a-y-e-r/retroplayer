import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(RetroPalette.light, isDark: false);

  static ThemeData dark() => _build(RetroPalette.dark, isDark: true);

  static ThemeData _build(RetroPalette palette, {required bool isDark}) {
    final scheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: palette.accent,
      onPrimary: isDark ? palette.textPrimary : Colors.white,
      secondary: palette.accentSecondary,
      onSecondary: Colors.white,
      error: palette.error,
      onError: isDark ? palette.textPrimary : Colors.white,
      surface: palette.screen,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.chrome,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.divider,
      outlineVariant: palette.divider,
      primaryContainer: isDark
          ? const Color(0xFF3D2A1F)
          : const Color(0xFFF5DFD0),
      onPrimaryContainer: palette.accent,
    );

    const multiScriptFallback = [
      'Noto Sans',
      'Noto Sans CJK SC',
      'Noto Sans Arabic',
      'Noto Sans Devanagari',
      'Noto Sans JP',
      'Noto Sans KR',
    ];

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.screen,
      visualDensity: VisualDensity.standard,
      extensions: [palette],
    );

    return base.copyWith(
      textTheme: RetroTypography.textTheme(base.textTheme, palette).apply(
        fontFamilyFallback: multiScriptFallback,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: palette.screenElevated,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle:
            RetroTypography.textTheme(base.textTheme, palette).titleMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: palette.chrome,
        indicatorColor: palette.screenElevated,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.accent, size: 24);
          }
          return IconThemeData(color: palette.textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.accent,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: palette.textMuted,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        iconColor: palette.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: isDark ? 1.0 : 0.5,
        space: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: isDark ? palette.textPrimary : Colors.white,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: RetroSpacing.progressTrackHeight,
        activeTrackColor: palette.accent,
        inactiveTrackColor: palette.divider,
        thumbColor: palette.screenElevated,
        overlayColor: palette.accent.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: RetroSpacing.progressThumbRadius,
          elevation: 2,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
          disabledForegroundColor: palette.textMuted.withValues(alpha: 0.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.screenElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: palette.divider.withValues(alpha: isDark ? 0.85 : 0.6),
          ),
        ),
      ),
    );
  }
}

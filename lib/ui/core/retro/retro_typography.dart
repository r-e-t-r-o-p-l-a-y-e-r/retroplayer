import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';

/// Typography tuned for condensed titles and tabular playback times.
abstract final class RetroTypography {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(TextTheme base, RetroPalette palette) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: palette.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: palette.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        fontSize: 12,
        color: palette.textMuted,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: palette.textSecondary),
      bodySmall: base.bodySmall?.copyWith(color: palette.textMuted),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }

  static TextStyle trackTitle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontSize: 20,
          height: 1.2,
        );
  }

  static TextStyle trackSubtitle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 15,
        );
  }

  static TextStyle timeLabel(BuildContext context, {bool compact = false}) {
    return TextStyle(
      fontFamily: 'monospace',
      fontFeatures: _tabular,
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w500,
      color: RetroPalette.of(context).textMuted,
      letterSpacing: 0.2,
    );
  }

  /// ±15 s jump labels on the circular art-side buttons (must stay legible at ~40dp).
  static TextStyle jumpSecondsLabel(Color color) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle sectionHeader(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!;
  }
}

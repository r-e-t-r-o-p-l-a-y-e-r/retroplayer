import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';

/// Reusable box decorations for retro chrome and screen panels.
abstract final class RetroDecorations {
  static double _borderAlpha(RetroPalette palette) =>
      palette == RetroPalette.dark ? 0.85 : 0.6;

  static BoxDecoration screenPanel(RetroPalette palette, {BorderRadius? radius}) {
    return BoxDecoration(
      color: palette.screenElevated,
      borderRadius: radius ?? BorderRadius.circular(12),
      border: Border.all(
        color: palette.divider.withValues(alpha: _borderAlpha(palette)),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration albumFrame(RetroPalette palette, {double? size}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.albumPlaceholderStart,
          palette.albumPlaceholderEnd,
        ],
      ),
      border: Border.all(color: palette.divider, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
        BoxShadow(
          color: Color(0xFFFFFFFF),
          blurRadius: 0,
          spreadRadius: 0,
          offset: Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration deviceBezel(RetroPalette palette) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(RetroSpacing.deviceRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [palette.screen, palette.chrome, palette.divider],
      ),
      border: Border.all(color: palette.deskLight, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 32,
          spreadRadius: 2,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration iconChip(RetroPalette palette) {
    return BoxDecoration(
      color: palette.iconChip,
      borderRadius: BorderRadius.circular(RetroSpacing.iconChipRadius),
    );
  }
}

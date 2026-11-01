import 'package:flutter/material.dart';

/// Theme-aware Retro Player palette (Studio Warm light, Studio Night dark).
@immutable
class RetroPalette extends ThemeExtension<RetroPalette> {
  const RetroPalette({
    required this.body,
    required this.chrome,
    required this.screen,
    required this.screenElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentMuted,
    required this.accentSecondary,
    required this.divider,
    required this.deskDark,
    required this.deskLight,
    required this.playingHighlight,
    required this.iconChip,
    required this.albumPlaceholderStart,
    required this.albumPlaceholderEnd,
    required this.error,
  });

  final Color body;
  final Color chrome;
  final Color screen;
  final Color screenElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentMuted;
  final Color accentSecondary;
  final Color divider;
  final Color deskDark;
  final Color deskLight;
  final Color playingHighlight;
  final Color iconChip;
  final Color albumPlaceholderStart;
  final Color albumPlaceholderEnd;
  final Color error;

  static const light = RetroPalette(
    body: Color(0xFFEBE4D9),
    chrome: Color(0xFFD8CFC2),
    screen: Color(0xFFF7F2EA),
    screenElevated: Color(0xFFFFFCF7),
    textPrimary: Color(0xFF2B2118),
    textSecondary: Color(0xFF5C534A),
    textMuted: Color(0xFF8A8178),
    accent: Color(0xFFC45C26),
    accentMuted: Color(0xFFE8956A),
    accentSecondary: Color(0xFF2A6F6F),
    divider: Color(0xFFC9BFB3),
    deskDark: Color(0xFF1A1612),
    deskLight: Color(0xFF3D342B),
    playingHighlight: Color(0x24C45C26),
    iconChip: Color(0xFFE8E0D4),
    albumPlaceholderStart: Color(0xFFD8CFC2),
    albumPlaceholderEnd: Color(0xFFB8AEA2),
    error: Color(0xFFB3261E),
  );

  static const dark = RetroPalette(
    body: Color(0xFF181512),
    chrome: Color(0xFF2A2520),
    screen: Color(0xFF181512),
    screenElevated: Color(0xFF221E1A),
    textPrimary: Color(0xFFF7F2EA),
    textSecondary: Color(0xFFC9BFB3),
    textMuted: Color(0xFF8A8178),
    accent: Color(0xFFE8956A),
    accentMuted: Color(0xFFF0B896),
    accentSecondary: Color(0xFF3D9A9A),
    divider: Color(0xFF4A4038),
    deskDark: Color(0xFF0A0908),
    deskLight: Color(0xFF1A1612),
    playingHighlight: Color(0x24E8956A),
    iconChip: Color(0xFF2A2420),
    albumPlaceholderStart: Color(0xFF2A2420),
    albumPlaceholderEnd: Color(0xFF3D342B),
    error: Color(0xFFF2B8B5),
  );

  static RetroPalette of(BuildContext context) =>
      Theme.of(context).extension<RetroPalette>() ?? light;

  @override
  RetroPalette copyWith({
    Color? body,
    Color? chrome,
    Color? screen,
    Color? screenElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentMuted,
    Color? accentSecondary,
    Color? divider,
    Color? deskDark,
    Color? deskLight,
    Color? playingHighlight,
    Color? iconChip,
    Color? albumPlaceholderStart,
    Color? albumPlaceholderEnd,
    Color? error,
  }) {
    return RetroPalette(
      body: body ?? this.body,
      chrome: chrome ?? this.chrome,
      screen: screen ?? this.screen,
      screenElevated: screenElevated ?? this.screenElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      divider: divider ?? this.divider,
      deskDark: deskDark ?? this.deskDark,
      deskLight: deskLight ?? this.deskLight,
      playingHighlight: playingHighlight ?? this.playingHighlight,
      iconChip: iconChip ?? this.iconChip,
      albumPlaceholderStart:
          albumPlaceholderStart ?? this.albumPlaceholderStart,
      albumPlaceholderEnd: albumPlaceholderEnd ?? this.albumPlaceholderEnd,
      error: error ?? this.error,
    );
  }

  @override
  RetroPalette lerp(ThemeExtension<RetroPalette>? other, double t) {
    if (other is! RetroPalette) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return RetroPalette(
      body: lerpColor(body, other.body),
      chrome: lerpColor(chrome, other.chrome),
      screen: lerpColor(screen, other.screen),
      screenElevated: lerpColor(screenElevated, other.screenElevated),
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      textMuted: lerpColor(textMuted, other.textMuted),
      accent: lerpColor(accent, other.accent),
      accentMuted: lerpColor(accentMuted, other.accentMuted),
      accentSecondary: lerpColor(accentSecondary, other.accentSecondary),
      divider: lerpColor(divider, other.divider),
      deskDark: lerpColor(deskDark, other.deskDark),
      deskLight: lerpColor(deskLight, other.deskLight),
      playingHighlight: lerpColor(playingHighlight, other.playingHighlight),
      iconChip: lerpColor(iconChip, other.iconChip),
      albumPlaceholderStart:
          lerpColor(albumPlaceholderStart, other.albumPlaceholderStart),
      albumPlaceholderEnd:
          lerpColor(albumPlaceholderEnd, other.albumPlaceholderEnd),
      error: lerpColor(error, other.error),
    );
  }
}

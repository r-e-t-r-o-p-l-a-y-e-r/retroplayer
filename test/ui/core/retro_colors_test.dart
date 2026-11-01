/// RetroColors Studio Warm palette invariants (accent, screen, highlight).
///
/// Evidence:
/// - `accent is warm amber not iOS blue`
/// - `screen uses warm parchment background`
/// - `accentSecondary is deep teal`
/// - `playingHighlight is semi-transparent amber`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/retro/retro_colors.dart';

void main() {
  group('RetroColors Studio Warm palette', () {
    test('accent is warm amber not iOS blue', () {
      expect(RetroColors.accent, const Color(0xFFC45C26));
      expect(RetroColors.accent, isNot(const Color(0xFF007AFF)));
    });

    test('screen uses warm parchment background', () {
      expect(RetroColors.screen, const Color(0xFFF7F2EA));
    });

    test('accentSecondary is deep teal', () {
      expect(RetroColors.accentSecondary, const Color(0xFF2A6F6F));
    });

    test('playingHighlight is semi-transparent amber', () {
      expect(RetroColors.playingHighlight.a, closeTo(0.14, 0.02));
      expect(RetroColors.playingHighlight.r, closeTo(0xC4 / 255, 0.02));
    });
  });
}

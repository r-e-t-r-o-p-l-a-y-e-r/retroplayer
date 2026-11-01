/// AppTheme Studio Warm / Studio Night color tokens.
///
/// Evidence:
/// - `AppTheme.light uses Studio Warm primary accent`
/// - `AppTheme.dark uses Studio Night surface and accent`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/theme.dart';

void main() {
  test('AppTheme.light uses Studio Warm primary accent', () {
    final theme = AppTheme.light();
    expect(theme.colorScheme.primary, const Color(0xFFC45C26));
    expect(theme.colorScheme.secondary, const Color(0xFF2A6F6F));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF7F2EA));
  });

  test('AppTheme.dark uses Studio Night surface and accent', () {
    final theme = AppTheme.dark();
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFFE8956A));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF181512));
    expect(
      theme.colorScheme.surfaceContainerHighest,
      const Color(0xFF2A2520),
    );
    expect(
      theme.scaffoldBackgroundColor.toARGB32() <
          theme.cardTheme.color!.toARGB32(),
      isTrue,
    );
  });
}

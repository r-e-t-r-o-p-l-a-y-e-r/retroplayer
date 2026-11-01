/// Theme enables multi-script font fallbacks for localized UI.
///
/// Evidence:
/// - `app theme defines fontFamilyFallback for multi-script UI`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/theme.dart';

void main() {
  test('app theme defines fontFamilyFallback for multi-script UI', () {
    final style = AppTheme.light().textTheme.bodyLarge!;
    expect(style.fontFamilyFallback, isNotNull);
    expect(style.fontFamilyFallback, contains('Noto Sans'));
    expect(style.fontFamilyFallback, contains('Noto Sans Arabic'));
  });
}

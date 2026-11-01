/// Code-based locale preference storage round-trip.
///
/// Evidence:
/// - `fromStorage null or system yields system preference`
/// - `fromStorage en and de round-trip storage codes`
/// - `fromStorage unknown code falls back to system`
/// - `language preferences are equal by storage code`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';

void main() {
  test('fromStorage null or system yields system preference', () {
    expect(LocalePreference.fromStorage(null), LocalePreference.system);
    expect(LocalePreference.fromStorage('system'), LocalePreference.system);
  });

  test('fromStorage en and de round-trip storage codes', () {
    final en = LocalePreference.fromStorage('en');
    final de = LocalePreference.fromStorage('de');
    expect(en, LocalePreference.language('en'));
    expect(de, LocalePreference.language('de'));
    expect(en.toStorage(), 'en');
    expect(de.toStorage(), 'de');
  });

  test('fromStorage unknown code falls back to system', () {
    expect(LocalePreference.fromStorage('xx'), LocalePreference.system);
  });

  test('language preferences are equal by storage code', () {
    expect(
      LocalePreference.language('fr'),
      LocalePreference.language('fr'),
    );
    expect(
      LocalePreference.language('fr'),
      isNot(LocalePreference.language('de')),
    );
    expect(LocalePreference.system, LocalePreference.system);
    expect(
      LocalePreference.language('fr').hashCode,
      LocalePreference.language('fr').hashCode,
    );
  });
}

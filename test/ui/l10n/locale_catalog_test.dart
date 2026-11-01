/// App locale catalog invariants.
///
/// Evidence:
/// - `catalog storage codes are unique`
/// - `every entry has non-empty endonym`
/// - `catalog includes de en fr zh ja ar for population coverage`
/// - `localeForPreference system returns null flutter locale`
/// - `catalog endonyms are non-ascii for non-latin locales`
/// - `catalog supported locales match generated l10n after sync`
library;

import 'package:retroplayer/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/supported_locale_codes.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';

void main() {
  test('catalog storage codes are unique', () {
    final codes = AppLocaleCatalog.entries.map((e) => e.storageCode).toList();
    expect(codes.length, codes.toSet().length);
  });

  test('every entry has non-empty endonym', () {
    for (final entry in AppLocaleCatalog.entries) {
      expect(entry.endonym.trim(), isNotEmpty);
    }
  });

  test('catalog includes de en fr zh ja ar for population coverage', () {
    final codes = AppLocaleCatalog.entries.map((e) => e.storageCode).toSet();
    expect(codes, containsAll(['de', 'en', 'fr', 'zh', 'ja', 'ar']));
  });

  test('localeForPreference system returns null flutter locale', () {
    expect(
      AppLocaleCatalog.localeForPreference(LocalePreference.system),
      isNull,
    );
    expect(
      AppLocaleCatalog.localeForPreference(LocalePreference.language('de')),
      const Locale('de'),
    );
  });

  test('catalog matches supported locale codes set', () {
    final catalogCodes =
        AppLocaleCatalog.entries.map((e) => e.storageCode).toSet();
    expect(catalogCodes, SupportedLocaleCodes.codes);
  });

  test('catalog endonyms are non-ascii for non-latin locales', () {
    final ar = AppLocaleCatalog.entryForCode('ar')!;
    expect(ar.endonym.runes.any((r) => r >= 0x0600 && r <= 0x06FF), isTrue);
  });

  test('picker entries sort alphabetically by endonym for locale', () {
    final sorted = AppLocaleCatalog.pickerEntries(const Locale('en'));
    final endonyms = sorted.map((e) => e.endonym).toList();
    expect(endonyms, equals(List<String>.from(endonyms)..sort()));
    final deIndex = sorted.indexWhere((e) => e.storageCode == 'de');
    final etIndex = sorted.indexWhere((e) => e.storageCode == 'et');
    expect(deIndex, lessThan(etIndex), reason: 'Deutsch before Eesti in Latin collation');
  });

  test('catalog supported locales match generated l10n after sync', () {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    for (final entry in AppLocaleCatalog.entries) {
      expect(supported, contains(entry.storageCode));
    }
  });
}

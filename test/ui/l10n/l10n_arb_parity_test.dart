/// ARB files stay aligned with the locale catalog and UTF-8 safe.
///
/// Evidence:
/// - `every catalog locale has app arb file`
/// - `all arb files have same keys as app_en`
/// - `catalog locales are supported by AppLocalizations`
/// - `all arb files decode as valid utf-8`
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/supported_locale_codes.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';

void main() {
  final l10nDir = p.join(Directory.current.path, 'lib', 'l10n');
  final templatePath = p.join(l10nDir, 'app_en.arb');
  late Set<String> templateKeys;

  setUp(() {
    final template =
        jsonDecode(utf8.decode(File(templatePath).readAsBytesSync()))
            as Map<String, dynamic>;
    templateKeys = template.keys
        .where((k) => !k.startsWith('@') && k != '@@locale')
        .toSet();
  });

  test('every catalog locale has app arb file', () {
    for (final code in SupportedLocaleCodes.codes) {
      expect(
        File(p.join(l10nDir, 'app_$code.arb')).existsSync(),
        isTrue,
        reason: code,
      );
    }
  });

  test('all arb files have same keys as app_en', () {
    for (final code in SupportedLocaleCodes.codes) {
      final path = p.join(l10nDir, 'app_$code.arb');
      final map = jsonDecode(utf8.decode(File(path).readAsBytesSync()))
          as Map<String, dynamic>;
      final keys = map.keys
          .where((k) => !k.startsWith('@') && k != '@@locale')
          .toSet();
      expect(keys, templateKeys, reason: code);
    }
  });

  test('catalog locales are supported by AppLocalizations', () {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    for (final entry in AppLocaleCatalog.entries) {
      expect(supported, contains(entry.storageCode));
    }
  });

  test('translated locales differ from English for settings label', () {
    final en =
        jsonDecode(utf8.decode(File(templatePath).readAsBytesSync()))
            as Map<String, dynamic>;
    final enSettings = en['settings'] as String;
    for (final code in ['fr', 'et', 'ja', 'ar']) {
      final path = p.join(l10nDir, 'app_$code.arb');
      final map = jsonDecode(utf8.decode(File(path).readAsBytesSync()))
          as Map<String, dynamic>;
      expect(
        map['settings'],
        isNot(enSettings),
        reason: 'app_$code.arb should be translated',
      );
    }
  });

  test('all arb files decode as valid utf-8', () {
    for (final code in SupportedLocaleCodes.codes) {
      final bytes = File(p.join(l10nDir, 'app_$code.arb')).readAsBytesSync();
      expect(() => utf8.decode(bytes, allowMalformed: false), returnsNormally);
    }
  });
}

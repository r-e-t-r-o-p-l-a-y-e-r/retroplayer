/// Playlist ICU plural strings must stay translated and structurally valid.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/supported_locale_codes.dart';

void main() {
  final l10nDir = p.join(Directory.current.path, 'lib', 'l10n');
  const icuKeys = [
    'playlistTrackCount',
    'playlistSelectedCount',
    'removePlaylistTrackTitle',
    'removePlaylistTrackBody',
  ];

  /// Branch text copied from [app_en.arb] — MT must not leave these in non-English files.
  const englishFragments = {
    'playlistTrackCount': '1 track',
    'playlistSelectedCount': 'Select tracks',
    'removePlaylistTrackTitle': 'Remove track from playlist?',
    'removePlaylistTrackBody':
        'This removes the entry from the playlist file when you save.',
  };

  late Map<String, dynamic> en;

  setUp(() {
    final enPath = p.join(l10nDir, 'app_en.arb');
    en = jsonDecode(utf8.decode(File(enPath).readAsBytesSync()))
        as Map<String, dynamic>;
  });

  test('English template defines ICU plural keys', () {
    for (final key in icuKeys) {
      final value = en[key] as String;
      expect(value, contains('{count,plural,'), reason: key);
    }
  });

  test('every non-English locale differs from English on all ICU keys', () {
    for (final code in SupportedLocaleCodes.codes) {
      if (code == 'en') {
        continue;
      }
      final path = p.join(l10nDir, 'app_$code.arb');
      final map = jsonDecode(utf8.decode(File(path).readAsBytesSync()))
          as Map<String, dynamic>;
      for (final key in icuKeys) {
        final enVal = en[key] as String;
        final value = map[key] as String;
        expect(
          value,
          isNot(equals(enVal)),
          reason: 'app_$code.arb $key still English template',
        );
        expect(
          value,
          contains('{count,plural,'),
          reason: 'app_$code.arb $key lost ICU structure',
        );
      }
    }
  });

  test('ICU keys do not retain English branch fragments (sample + gap locales)', () {
    const sampleCodes = [
      'fr',
      'sk',
      'de',
      'pl',
      'hi',
      'bn',
      'ca',
      'sq',
      'mk',
      'bs',
      'sr',
      'ga',
      'mt',
      'is',
      'hr',
    ];
    for (final code in sampleCodes) {
      final path = p.join(l10nDir, 'app_$code.arb');
      final map = jsonDecode(utf8.decode(File(path).readAsBytesSync()))
          as Map<String, dynamic>;
      for (final key in icuKeys) {
        final fragment = englishFragments[key]!;
        final value = map[key] as String;
        expect(
          value.contains(fragment),
          isFalse,
          reason: 'app_$code.arb $key still contains "$fragment"',
        );
      }
    }
  });
}

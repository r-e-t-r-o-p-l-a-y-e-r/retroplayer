/// Equalizer preset labels use consistent initial capitalization (Latin scripts).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/supported_locale_codes.dart';

const _eqKeys = ['eqManually', 'eqBass', 'eqTreble', 'eqVoice'];

bool _isLatinLetter(String char) {
  if (char.isEmpty) return false;
  final code = char.codeUnitAt(0);
  return (code >= 0x41 && code <= 0x5A) ||
      (code >= 0x61 && code <= 0x7A) ||
      (code >= 0xC0 && code <= 0x024F);
}

void main() {
  final l10nDir = p.join(Directory.current.path, 'lib', 'l10n');

  test('Latin equalizer preset labels share capitalization', () {
    for (final code in SupportedLocaleCodes.codes) {
      if (code == 'en') continue;
      final path = p.join(l10nDir, 'app_$code.arb');
      final map = jsonDecode(utf8.decode(File(path).readAsBytesSync()))
          as Map<String, dynamic>;
      final values = <String>[];
      for (final key in _eqKeys) {
        final v = map[key];
        if (v is String && v.isNotEmpty && _isLatinLetter(v[0])) {
          values.add(v);
        }
      }
      if (values.length < 2) continue;
      final ups = values.map((v) => v[0].toUpperCase() == v[0]).toSet();
      expect(
        ups.length,
        1,
        reason:
            'app_$code.arb EQ presets mix upper/lower initial (e.g. ručno vs Bas): $values',
      );
    }
  });
}

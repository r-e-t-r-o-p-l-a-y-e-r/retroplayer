/// repairMetadataText recovers Slavic letters mis-decoded as Latin-1.
///
/// Evidence:
/// - `recovers UTF-8 bytes that were decoded as Latin-1 (ćčš)`
/// - `recovers Windows-1250 bytes that were decoded as Latin-1`
/// - `leaves correct Unicode unchanged`
/// - `leaves pure ASCII unchanged`
/// - `returns empty string unchanged`
/// - `returns null for null input`
library;
import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/text_encoding.dart';

void main() {
  group('repairMetadataText', () {
    test('recovers UTF-8 bytes that were decoded as Latin-1 (ćčš)', () {
      const original = 'Kuća i šuma — čaj';
      final misread = latin1.decode(utf8.encode(original));

      expect(misread, isNot(original));
      expect(repairMetadataText(misread), original);
    });

    test('recovers Windows-1250 bytes that were decoded as Latin-1', () {
      const original = 'Đorđe i Željko — ćevapčići';
      final bytes = windows1250.encode(original);
      final misread = latin1.decode(bytes);

      expect(misread, isNot(original));
      expect(repairMetadataText(misread), original);
    });

    test('leaves correct Unicode unchanged', () {
      const original = 'Pravilno: ćčšžđ';
      expect(repairMetadataText(original), original);
    });

    test('leaves pure ASCII unchanged', () {
      expect(repairMetadataText('Hello Album'), 'Hello Album');
    });

    test('returns empty string unchanged', () {
      expect(repairMetadataText(''), '');
    });

    test('returns null for null input', () {
      expect(repairMetadataText(null), isNull);
    });
  });
}

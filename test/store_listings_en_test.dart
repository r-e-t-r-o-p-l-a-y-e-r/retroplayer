/// English store listing files stay in sync with source.en.json.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('store-listings/en matches source.en.json', () {
    final root = Directory.current;
    final source = jsonDecode(
      File(p.join(root.path, 'store-listings/source.en.json')).readAsStringSync(),
    ) as Map<String, dynamic>;

    void expectFile(String file, String key) {
      final path = p.join(root.path, 'store-listings/en', file);
      expect(File(path).existsSync(), isTrue, reason: path);
      final text = File(path).readAsStringSync().trim();
      expect(text, source[key]?.toString().trim());
    }

    expectFile('title.txt', 'title');
    expectFile('short_description.txt', 'short_description');
    expectFile('full_description.txt', 'full_description');
    expectFile('whats_new.txt', 'whats_new');
    expectFile('privacy_policy_url.txt', 'privacy_policy_url');
  });
}

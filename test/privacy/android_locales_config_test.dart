/// Android per-app language list matches supported locales.
///
/// Evidence:
/// - `AndroidManifest references localeConfig`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('AndroidManifest references localeConfig', () {
    final manifest = File(
      p.join(
        Directory.current.path,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      ),
    ).readAsStringSync();
    expect(manifest, contains('android:localeConfig="@xml/locales_config"'));
  });
}

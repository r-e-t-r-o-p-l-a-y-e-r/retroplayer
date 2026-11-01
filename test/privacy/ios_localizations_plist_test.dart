/// iOS declares supported localizations for the app bundle.
///
/// Evidence:
/// - `Info plist lists CFBundleLocalizations`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('Info plist lists CFBundleLocalizations', () {
    final plist = File(
      p.join(Directory.current.path, 'ios', 'Runner', 'Info.plist'),
    ).readAsStringSync();
    expect(plist, contains('<key>CFBundleLocalizations</key>'));
    expect(plist, contains('<string>de</string>'));
    expect(plist, contains('<string>ja</string>'));
  });
}

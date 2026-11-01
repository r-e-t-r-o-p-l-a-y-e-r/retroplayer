/// Release AndroidManifest: no INTERNET; cleartext denied via networkSecurityConfig.
///
/// Evidence:
/// - `release AndroidManifest does not declare INTERNET`
/// - `network security config denies cleartext`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release AndroidManifest does not declare INTERNET', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    expect(manifest.existsSync(), isTrue);
    final text = manifest.readAsStringSync();
    expect(
      text.contains('android.permission.INTERNET'),
      isFalse,
      reason: 'Release builds must not request INTERNET',
    );
    expect(text.contains('usesCleartextTraffic="false"'), isTrue);
    expect(
      text.contains('android:networkSecurityConfig="@xml/network_security_config"'),
      isTrue,
    );
  });

  test('network security config denies cleartext', () {
    final config =
        File('android/app/src/main/res/xml/network_security_config.xml');
    expect(config.existsSync(), isTrue);
    final text = config.readAsStringSync();
    expect(text.contains('cleartextTrafficPermitted="false"'), isTrue);
  });
}

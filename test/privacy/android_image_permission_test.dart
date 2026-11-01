/// Android manifest declares image permission for cover.jpg sidecars.
///
/// Evidence:
/// - `declares READ_MEDIA_IMAGES for folder artwork`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declares READ_MEDIA_IMAGES for folder artwork', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    final text = manifest.readAsStringSync();
    expect(text.contains('android.permission.READ_MEDIA_AUDIO'), isTrue);
    expect(text.contains('android.permission.READ_MEDIA_IMAGES'), isTrue);
  });
}

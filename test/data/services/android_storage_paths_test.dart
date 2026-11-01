/// Neutral Android storage path helper for Add-folder picker.
///
/// Evidence:
/// - `returns null off Android`
/// - `prefers existing primary storage candidate when forced`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/android_storage_paths.dart';

void main() {
  test('returns null off Android', () {
    if (Platform.isAndroid) return;
    expect(androidPrimaryStoragePath(), isNull);
  }, skip: Platform.isAndroid ? 'Host is Android' : false);

  test('prefers existing primary storage candidate when present', () {
    if (!Platform.isAndroid) return;
    final path = androidPrimaryStoragePath();
    expect(path, isNotNull);
    expect(Directory(path!).existsSync(), isTrue);
  }, skip: !Platform.isAndroid ? 'Requires Android' : false);
}

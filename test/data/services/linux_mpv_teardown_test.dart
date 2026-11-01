/// teardownStaleMpvPlayers safety before Linux media_kit init.
///
/// Evidence:
/// - `is a no-op off Linux or in release mode`
/// - `completes when no reference holder file exists`
library;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/linux_mpv_teardown.dart';

void main() {
  group('teardownStaleMpvPlayers', () {
    test('is a no-op off Linux or in release mode', () async {
      if (Platform.isLinux && kDebugMode) return;

      await teardownStaleMpvPlayers(settleDelay: Duration.zero);
    });

    test(
      'completes when no reference holder file exists',
      () async {
        final path = nativeReferenceHolderPathForTesting();
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }

        await teardownStaleMpvPlayers(settleDelay: Duration.zero);
      },
      skip: Platform.isLinux && kDebugMode ? false : 'Linux debug only',
    );
  });
}

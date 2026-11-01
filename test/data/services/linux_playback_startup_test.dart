/// prepareLinuxPlaybackBackend platform gating and completion.
///
/// Evidence:
/// - `is a no-op off Linux`
/// - `completes on Linux`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/linux_playback_startup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('prepareLinuxPlaybackBackend', () {
    test('is a no-op off Linux', () async {
      if (Platform.isLinux) return;

      await prepareLinuxPlaybackBackend(mpvSettleDelay: Duration.zero);
    });

    test(
      'completes on Linux',
      () async {
        final temp = Directory.systemTemp.createTempSync('rpc-startup-temp-');
        final cache = Directory.systemTemp.createTempSync('rpc-startup-cache-');
        addTearDown(() {
          temp.deleteSync(recursive: true);
          cache.deleteSync(recursive: true);
        });

        await prepareLinuxPlaybackBackend(
          tempPath: temp.path,
          cachePath: cache.path,
          mpvSettleDelay: Duration.zero,
        );
      },
      skip: Platform.isLinux ? false : 'Linux only',
    );
  });
}

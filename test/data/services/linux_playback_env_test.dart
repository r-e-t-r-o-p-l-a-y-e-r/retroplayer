/// configureLinuxPlaybackEnvironment temp/cache binding for MPV.
///
/// Evidence:
/// - `is a no-op off Linux`
/// - `binds libc setenv and points MPV at writable directories`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/linux_playback_env.dart';

void main() {
  group('configureLinuxPlaybackEnvironment', () {
    test('is a no-op off Linux', () async {
      if (Platform.isLinux) return;

      await configureLinuxPlaybackEnvironment();
    });

    test(
      'binds libc setenv and points MPV at writable directories',
      () async {
        final temp = Directory.systemTemp.createTempSync('rpc-temp-');
        final cache = Directory.systemTemp.createTempSync('rpc-cache-');
        addTearDown(() {
          temp.deleteSync(recursive: true);
          cache.deleteSync(recursive: true);
        });

        await configureLinuxPlaybackEnvironment(
          tempPath: temp.path,
          cachePath: cache.path,
        );

        expect(getProcessEnvForTesting('TMPDIR'), temp.path);
        expect(getProcessEnvForTesting('TEMP'), temp.path);
        expect(getProcessEnvForTesting('TMP'), temp.path);
        expect(getProcessEnvForTesting('XDG_CACHE_HOME'), cache.path);
        expect(Directory('${cache.path}/mpv').existsSync(), isTrue);
      },
      skip: Platform.isLinux ? false : 'Linux FFI only',
    );
  });
}

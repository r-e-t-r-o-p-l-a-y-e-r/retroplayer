/// Linux JustAudio/MPV lifecycle across dispose and player replacement.
///
/// Evidence:
/// - `dispose then re-init can play again`
/// - `abandoned player then startup teardown can play again (hot-restart path)`
@Tags(['linux', 'requires-mpv'])
library;

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/linux_playback_env.dart';
import 'package:retroplayer/data/services/linux_playback_startup.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

import '../helpers/minimal_wav.dart';
import '../helpers/track_factory.dart';

/// Simulates what happens on Flutter hot restart: the old isolate is torn down
/// without calling [JustAudioPlaybackService.dispose], then [main] runs again.
///
/// This cannot trigger a real hot restart from a test, but it exercises the
/// same native MPV cleanup path our startup code uses.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Linux playback lifecycle', () {
    late Directory tempDir;
    late AudioTrack track;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rpc_playback_lifecycle_');
      final wav = await writeMinimalWav(tempDir);
      track = testTrack(
        filePath: wav.path,
        directoryPath: tempDir.path,
        metadata: const TrackMetadata(duration: Duration(milliseconds: 100)),
      );
    });

    tearDown(() async {
      if (Platform.isLinux) {
        setProcessEnvForTesting('TMPDIR', '/tmp');
        setProcessEnvForTesting('TEMP', '/tmp');
        setProcessEnvForTesting('TMP', '/tmp');
      }
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'dispose then re-init can play again',
      () async {
        await prepareLinuxPlaybackBackend(
          tempPath: tempDir.path,
          cachePath: tempDir.path,
          mpvSettleDelay: Duration.zero,
        );

        final first = JustAudioPlaybackService();
        await first.setQueue([track]);
        await first.play();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await first.dispose();

        await prepareLinuxPlaybackBackend(
          tempPath: tempDir.path,
          cachePath: tempDir.path,
          mpvSettleDelay: Duration.zero,
        );

        final second = JustAudioPlaybackService();
        await second.setQueue([track]);
        await second.play();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(second.currentTrack?.id, track.id);
        await second.dispose();
      },
      skip: _skipUnlessLinuxMpv,
    );

    test(
      'abandoned player then startup teardown can play again (hot-restart path)',
      () async {
        await prepareLinuxPlaybackBackend(
          tempPath: tempDir.path,
          cachePath: tempDir.path,
          mpvSettleDelay: Duration.zero,
        );

        final abandoned = JustAudioPlaybackService();
        await abandoned.setQueue([track]);
        await abandoned.play();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        // No dispose — mimics hot restart killing the isolate.

        await prepareLinuxPlaybackBackend(
          tempPath: tempDir.path,
          cachePath: tempDir.path,
          mpvSettleDelay: const Duration(milliseconds: 300),
        );

        final replacement = JustAudioPlaybackService();
        await replacement.setQueue([track]);
        await replacement.play();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        expect(replacement.currentTrack?.id, track.id);
        await replacement.dispose();
      },
      skip: _skipUnlessLinuxMpv,
    );
  });
}

String? get _skipUnlessLinuxMpv {
  if (!Platform.isLinux) return 'Linux only';
  for (final name in ['libmpv.so', 'libmpv.so.2', 'libmpv.so.1']) {
    try {
      DynamicLibrary.open(name);
      return null;
    } on Object {
      continue;
    }
  }
  return 'libmpv not installed';
}

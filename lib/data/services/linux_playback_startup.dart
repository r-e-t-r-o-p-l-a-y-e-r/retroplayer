import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:retroplayer/data/services/linux_mpv_teardown.dart';
import 'package:retroplayer/data/services/linux_playback_env.dart';
import 'package:retroplayer/data/services/local_only_media_kit.dart';

/// Initializes Linux playback (env vars + media_kit) and waits for any stale
/// native MPV players from a prior hot restart to finish shutting down.
///
/// Without teardown before media_kit init, MPV can invoke Dart callbacks after
/// the old isolate is deleted, crashing with "Callback invoked after it has
/// been deleted".
Future<void> prepareLinuxPlaybackBackend({
  String? tempPath,
  String? cachePath,
  Duration mpvSettleDelay = mpvTeardownSettleDelay,
}) {
  return runLinuxPlaybackStartup(
    configureEnvironment: () => configureLinuxPlaybackEnvironment(
      tempPath: tempPath,
      cachePath: cachePath,
    ),
    teardownStaleMpv: () =>
        teardownStaleMpvPlayers(settleDelay: mpvSettleDelay),
    ensureMediaKit: () {
      configureLocalOnlyMediaKit();
      JustAudioMediaKit.ensureInitialized();
    },
  );
}

/// Shared startup sequence used by [prepareLinuxPlaybackBackend] and tests.
@visibleForTesting
Future<void> runLinuxPlaybackStartup({
  required Future<void> Function() configureEnvironment,
  required Future<void> Function() teardownStaleMpv,
  required void Function() ensureMediaKit,
}) async {
  if (kIsWeb || !Platform.isLinux) return;

  await configureEnvironment();
  await teardownStaleMpv();
  ensureMediaKit();
}

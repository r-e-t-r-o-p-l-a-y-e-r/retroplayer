import 'dart:io';

import 'package:flutter/services.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';

/// Android Recents dismiss when [AudioService.onTaskRemoved] is not delivered.
///
/// [MainActivity] invokes [activityTaskRemovedMethod] from `onStop` when
/// `isFinishing` is true.
class AndroidRecentsPlaybackBridge {
  static const _channel = MethodChannel('app.retroplayer/playback_lifecycle');
  static const activityTaskRemovedMethod = 'activityTaskRemoved';

  static void install({
    required PlaybackRepository playbackRepository,
    required Future<void> Function() idleMediaSession,
  }) {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method != activityTaskRemovedMethod) return;
      await playbackRepository.stopPlaybackForRecentsDismiss();
      await idleMediaSession();
    });
  }
}

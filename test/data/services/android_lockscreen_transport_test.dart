/// Lockscreen and notification transport must reach the engine reliably.
///
/// Evidence:
/// - `lockscreen play bypasses external route gate`
/// - `transport play activates audio session before engine play`
/// - `playback state exposes system play pause skip actions`
/// - `click media button toggles play and pause via transport path`
/// - `android audio service config keeps foreground session when paused`
library;

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/data/services/android_audio_service_config.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';

import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';

/// Fails if lockscreen transport incorrectly calls gated [play] instead of
/// [RecordingPlayback.playForMediaTransport].
class _GateAwarePlayback extends RecordingPlayback {
  bool gatedPlayCalled = false;

  @override
  Future<void> play() async {
    gatedPlayCalled = true;
    throw StateError('gated play must not run from media session transport');
  }

  @override
  Future<void> playForMediaTransport() async {
    playForMediaTransportCalled = true;
  }
}

void main() {
  group('RetroAudioHandler lockscreen transport', () {
    test('lockscreen play bypasses external route gate', () async {
      final playback = _GateAwarePlayback();
      final handler = RetroAudioHandler(playback);

      await handler.play();

      expect(playback.playForMediaTransportCalled, isTrue);
      expect(playback.gatedPlayCalled, isFalse);
    });

    test('transport play activates audio session before engine play', () async {
      final playback = RecordingPlayback();
      var activated = false;
      final handler = RetroAudioHandler(
        playback,
        activateAudioSession: () async {
          activated = true;
          return true;
        },
      );

      await handler.play();

      expect(activated, isTrue);
      expect(playback.playForMediaTransportCalled, isTrue);
    });

    test('playback state exposes system play pause skip actions', () async {
      final playback = RecordingPlayback();
      final handler = RetroAudioHandler(playback);
      final track = testTrack(filePath: '/m/01.mp3', directoryPath: '/m');
      await playback.setQueue([track]);
      playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      final actions = handler.playbackState.value.systemActions;
      expect(actions, contains(MediaAction.play));
      expect(actions, contains(MediaAction.pause));
      expect(actions, contains(MediaAction.playPause));
      expect(actions, contains(MediaAction.skipToNext));
      expect(actions, contains(MediaAction.skipToPrevious));
    });

    test('click media button toggles play and pause via transport path',
        () async {
      final playback = RecordingPlayback();
      final handler = RetroAudioHandler(playback);
      playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      await handler.click(MediaButton.media);
      expect(playback.playForMediaTransportCalled, isTrue);

      playback.emitPlayerState(PlayerState(true, ProcessingState.ready));
      await Future<void>.delayed(Duration.zero);

      await handler.click(MediaButton.media);
      expect(playback.pauseCalled, isTrue);
    });
  });

  test('android audio service config keeps foreground session when paused', () {
    final config = retroPlayerAndroidAudioServiceConfig();

    expect(config.androidStopForegroundOnPause, isFalse);
    expect(config.androidNotificationOngoing, isFalse);
  });
}

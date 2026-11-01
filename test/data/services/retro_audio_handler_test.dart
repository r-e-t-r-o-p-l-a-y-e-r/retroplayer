/// RetroAudioHandler stops playback when the Android task is removed.
///
/// Evidence:
/// - `onTaskRemoved invokes shutdown callback`
/// - `onTaskRemoved stops playback when no callback is set`
/// - `onTaskRemoved stops playback when callback throws`
/// - `stop stops the underlying playback service`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';

import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';

void main() {
  test('onTaskRemoved invokes persist callback and stops playback', () async {
    final playback = RecordingPlayback();
    playback.currentTrackOverride = testTrack(filePath: '/music/a.mp3');
    var persistCalls = 0;
    final handler = RetroAudioHandler(
      playback,
      onRecentsDismiss: () async {
        persistCalls += 1;
        await playback.stop();
      },
    );

    await handler.onTaskRemoved();

    expect(persistCalls, 1);
    expect(playback.stopCalled, isTrue);
  });

  test('onTaskRemoved stops playback when callback throws', () async {
    final playback = RecordingPlayback();
    final handler = RetroAudioHandler(
      playback,
      onRecentsDismiss: () async {
        throw StateError('save failed');
      },
    );

    await handler.onTaskRemoved();

    expect(playback.stopCalled, isTrue);
  });

  test('onTaskRemoved stops playback when no callback is set', () async {
    final playback = RecordingPlayback();
    final handler = RetroAudioHandler(playback);

    await handler.onTaskRemoved();

    expect(playback.stopCalled, isTrue);
  });

  test('stop stops the underlying playback service', () async {
    final playback = RecordingPlayback();
    final handler = RetroAudioHandler(playback);

    await handler.stop();

    expect(playback.stopCalled, isTrue);
  });
}

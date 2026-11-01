import 'dart:async';

import 'package:retroplayer/domain/models/audio_track.dart';

import 'recording_playback.dart';

/// [RecordingPlayback] that blocks [setQueue] until [completeSetQueue].
class SlowCompletingPlayback extends RecordingPlayback {
  Completer<void>? _setQueueGate;
  bool setQueueStarted = false;

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    setQueueStarted = true;
    _setQueueGate = Completer<void>();
    await _setQueueGate!.future;
    return super.setQueue(
      tracks,
      startIndex: startIndex,
      initialPosition: initialPosition,
    );
  }

  void completeSetQueue() {
    final gate = _setQueueGate;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }
}

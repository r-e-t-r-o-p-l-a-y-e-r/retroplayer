import 'package:retroplayer/domain/models/audio_track.dart';

/// The queue-level player operations the application layer needs.
///
/// Implemented by the audio service in `data/`; tests fake it without audio.
abstract interface class PlaybackEngine {
  List<AudioTrack> get queue;
  int? get currentQueueIndex;
  AudioTrack? get currentTrack;
  Duration get position;

  /// Decoder-reported length when known (may exceed tag metadata).
  Duration? get duration;

  double get speed;

  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  });
  Future<void> play();
  Future<void> seek(Duration position);
  Future<void> seekToQueueIndex(int index);
  Future<void> setSpeed(double speed);
}

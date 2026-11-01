import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';

/// Fake playback service that records queue/resume calls for persistence tests.
class RecordingPlayback implements AudioPlaybackService {
  List<AudioTrack>? lastQueue;
  int lastStartIndex = 0;
  Duration? lastInitialPosition;
  double lastSpeed = 1.0;
  AudioTrack? currentTrackOverride;
  Duration positionOverride = Duration.zero;
  Duration? durationOverride;

  /// When set, [setQueue] reports this length synchronously (cold-start tests).
  Duration? durationOnSetQueue;

  double speedOverride = 1.0;
  bool playCalled = false;
  bool pauseCalled = false;
  bool stopCalled = false;
  bool disposeCalled = false;
  bool seekToQueueIndexCalled = false;
  int? _queueIndex;
  int? lastSeekToQueueIndex;
  int skipNextCalls = 0;
  int skipPreviousCalls = 0;
  int setQueueCalls = 0;
  final seeks = <Duration>[];

  final _positions = StreamController<Duration>.broadcast();
  final _durations = StreamController<Duration?>.broadcast();
  final _playerStates = StreamController<PlayerState>.broadcast();
  final _tracks = StreamController<AudioTrack?>.broadcast();

  /// Pushes a position tick as the real player would while playing.
  void emitPosition(Duration position) {
    positionOverride = position;
    _positions.add(position);
  }

  void emitDuration(Duration? duration) {
    durationOverride = duration;
    _durations.add(duration);
  }

  void emitPlayerState(PlayerState state) => _playerStates.add(state);

  void emitTrack(AudioTrack? track) {
    currentTrackOverride = track;
    _tracks.add(track);
  }

  @override
  AudioTrack? get currentTrack => currentTrackOverride;

  @override
  Duration get position => positionOverride;

  @override
  Duration? get duration => durationOverride;

  @override
  Stream<AudioTrack?> get currentTrackStream => _tracks.stream;

  @override
  List<AudioTrack> get queue => lastQueue ?? const [];

  @override
  bool get hasNext {
    final index = _queueIndex;
    final q = lastQueue;
    if (index == null || q == null) return false;
    return index + 1 < q.length;
  }

  @override
  bool get hasPrevious {
    final index = _queueIndex;
    if (index == null) return false;
    return index > 0;
  }

  @override
  int? get currentQueueIndex => _queueIndex;

  @override
  double get speed => speedOverride;

  @override
  int? get androidAudioSessionId => null;

  @override
  Stream<int?> get androidAudioSessionIdStream => const Stream.empty();

  @override
  Stream<Duration> get positionStream => _positions.stream;

  @override
  Stream<Duration?> get durationStream => _durations.stream;

  @override
  Stream<PlayerState> get playerStateStream => _playerStates.stream;

  @override
  Stream<bool> get playingStream => const Stream.empty();

  @override
  Future<void> dispose() async {
    disposeCalled = true;
  }

  @override
  Future<void> pause() async {
    pauseCalled = true;
  }

  @override
  Future<void> play() async {
    playCalled = true;
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    positionOverride = position;
  }

  @override
  Future<void> seekToQueueIndex(int index) async {
    seekToQueueIndexCalled = true;
    lastSeekToQueueIndex = index;
    lastStartIndex = index;
    _queueIndex = index;
    if (lastQueue != null && index >= 0 && index < lastQueue!.length) {
      currentTrackOverride = lastQueue![index];
      positionOverride = Duration.zero;
    }
  }

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    setQueueCalls += 1;
    lastQueue = tracks;
    lastStartIndex = startIndex;
    _queueIndex = startIndex;
    lastInitialPosition = initialPosition;
    if (startIndex >= 0 && startIndex < tracks.length) {
      currentTrackOverride = tracks[startIndex];
      positionOverride = initialPosition ?? Duration.zero;
      emitTrack(currentTrackOverride);
    }
    final simulated = durationOnSetQueue;
    if (simulated != null) {
      emitDuration(simulated);
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    lastSpeed = speed;
    speedOverride = speed;
  }

  @override
  Future<void> skipToNext() async {
    skipNextCalls += 1;
    final index = _queueIndex;
    final q = lastQueue;
    if (index == null || q == null || index + 1 >= q.length) return;
    await seekToQueueIndex(index + 1);
    emitTrack(currentTrackOverride);
  }

  @override
  Future<void> skipToPrevious() async {
    skipPreviousCalls += 1;
    final index = _queueIndex;
    if (index == null || index <= 0) return;
    await seekToQueueIndex(index - 1);
    emitTrack(currentTrackOverride);
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
    currentTrackOverride = null;
  }

  @override
  void replaceQueueTracks(List<AudioTrack> tracks) {
    final current = lastQueue;
    if (current == null || current.length != tracks.length) return;
    for (var i = 0; i < current.length; i++) {
      if (normalizeLibraryPath(current[i].filePath) !=
          normalizeLibraryPath(tracks[i].filePath)) {
        return;
      }
    }
    lastQueue = tracks;
    final index = _queueIndex;
    if (index != null && index >= 0 && index < tracks.length) {
      emitTrack(tracks[index]);
    }
  }
}

import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/application/ports/playback_engine.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/local_path_policy.dart';
import 'package:retroplayer/data/services/external_playback_route_gate.dart';
import 'package:retroplayer/domain/models/audio_track.dart';

/// Wraps just_audio for playback operations.
abstract class AudioPlaybackService implements PlaybackEngine {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlayerState> get playerStateStream;
  Stream<bool> get playingStream;
  Stream<AudioTrack?> get currentTrackStream;
  int? get androidAudioSessionId;
  Stream<int?> get androidAudioSessionIdStream;
  bool get hasNext;
  bool get hasPrevious;

  Future<void> pause();
  Future<void> stop();

  /// Swaps tag data on the loaded queue when the file list is unchanged.
  ///
  /// Does not reload audio sources.
  void replaceQueueTracks(List<AudioTrack> tracks);

  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> dispose();

  /// Starts playback without car/BT route-settling delays.
  ///
  /// Lockscreen and notification transport must not block on
  /// [ExternalPlaybackRouteGate.runPlay].
  Future<void> playForMediaTransport() => play();
}

class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService({
    AudioPlayer? player,
    this._externalPlaybackRouteGate,
  })  : _player = player ?? AudioPlayer() {
    _indexSub = _player.currentIndexStream.listen(_onIndexChanged);
  }

  final AudioPlayer _player;
  final ExternalPlaybackRouteGate? _externalPlaybackRouteGate;
  final _currentTrackController = StreamController<AudioTrack?>.broadcast();
  List<AudioTrack> _queue = [];
  AudioTrack? _currentTrack;
  StreamSubscription<int?>? _indexSub;

  /// While [setQueue] is applying sources, just_audio may briefly emit index 0
  /// before [initialIndex] sticks — ignore those so the UI does not jump to the
  /// first queue item mid-load.
  int? _pendingQueueIndex;

  void _onIndexChanged(int? index) {
    if (index == null || index < 0 || index >= _queue.length) return;
    final pending = _pendingQueueIndex;
    if (pending != null && index != pending) return;
    _publishCurrentTrack(index);
  }

  void _publishCurrentTrack(int index) {
    _currentTrack = _queue[index];
    _currentTrackController.add(_currentTrack);
  }

  @override
  AudioTrack? get currentTrack => _currentTrack;

  @override
  List<AudioTrack> get queue => List.unmodifiable(_queue);

  @override
  Stream<AudioTrack?> get currentTrackStream => _currentTrackController.stream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  double get speed => _player.speed;

  @override
  Duration get position => _player.position;

  @override
  Duration? get duration => _player.duration;

  @override
  int? get androidAudioSessionId => _player.androidAudioSessionId;

  @override
  Stream<int?> get androidAudioSessionIdStream =>
      _player.androidAudioSessionIdStream;

  @override
  bool get hasNext => _player.hasNext;

  @override
  bool get hasPrevious => _player.hasPrevious;

  @override
  int? get currentQueueIndex => _player.currentIndex;

  @override
  Future<void> seekToQueueIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _pendingQueueIndex = index;
    try {
      await _player.seek(null, index: index);
      await _waitUntilReady();
      _publishCurrentTrack(index);
    } finally {
      _pendingQueueIndex = null;
    }
  }

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    // Preserve startIndex against the filtered queue (not the raw input list).
    final filtered = <AudioTrack>[
      for (final track in tracks)
        if (isLocalFilesystemPath(track.filePath)) track,
    ];
    if (filtered.isEmpty) {
      _pendingQueueIndex = null;
      _queue = [];
      await _player.stop();
      _currentTrack = null;
      _currentTrackController.add(null);
      return;
    }

    var index = startIndex;
    if (filtered.length != tracks.length) {
      // Remap requested index when non-local paths were dropped.
      if (startIndex >= 0 && startIndex < tracks.length) {
        final wanted = tracks[startIndex];
        final mapped = filtered.indexWhere((t) => t.id == wanted.id);
        index = mapped >= 0 ? mapped : 0;
      } else {
        index = 0;
      }
    }
    index = index.clamp(0, filtered.length - 1);

    _queue = filtered;
    _pendingQueueIndex = index;
    _publishCurrentTrack(index);
    try {
      final sources = _queue
          .map((t) => AudioSource.file(t.filePath, tag: t.id))
          .toList();
      await _player.setAudioSources(
        sources,
        initialIndex: index,
        initialPosition: initialPosition,
      );
      // Re-assert after load — platform may have emitted a transient index 0.
      final live = _player.currentIndex;
      if (live != null && live >= 0 && live < _queue.length) {
        _publishCurrentTrack(live);
      } else {
        _publishCurrentTrack(index);
      }
    } finally {
      _pendingQueueIndex = null;
    }
  }

  @override
  void replaceQueueTracks(List<AudioTrack> tracks) {
    if (!_sameQueueFiles(_queue, tracks)) return;
    _queue = List<AudioTrack>.of(tracks);
    final index = _player.currentIndex;
    if (index != null && index >= 0 && index < _queue.length) {
      _publishCurrentTrack(index);
    }
  }

  @override
  Future<void> play() async {
    final gate = _externalPlaybackRouteGate;
    if (gate == null) {
      await _player.play();
      return;
    }
    await gate.runPlay(() => _player.play());
  }

  @override
  Future<void> playForMediaTransport() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _currentTrackController.add(null);
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    final next = _player.nextIndex;
    if (!_player.hasNext || next == null) return;
    if (next < 0 || next >= _queue.length) return;
    // Avoid seek(Duration.zero) on track change — MPV fails to create file cache
    // when seeking before the next item is ready (just_audio_media_kit on Linux).
    _pendingQueueIndex = next;
    try {
      await _player.seek(null, index: next);
      await _waitUntilReady();
      _publishCurrentTrack(next);
    } finally {
      _pendingQueueIndex = null;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final previous = _player.previousIndex;
    if (!_player.hasPrevious || previous == null) return;
    if (previous < 0 || previous >= _queue.length) return;
    _pendingQueueIndex = previous;
    try {
      await _player.seek(null, index: previous);
      await _waitUntilReady();
      _publishCurrentTrack(previous);
    } finally {
      _pendingQueueIndex = null;
    }
  }

  Future<void> _waitUntilReady() async {
    try {
      await _player.processingStateStream
          .firstWhere((state) => state == ProcessingState.ready)
          .timeout(const Duration(seconds: 15));
    } on Object {
      // Continue if the player never reports ready.
    }
  }

  bool _sameQueueFiles(List<AudioTrack> current, List<AudioTrack> next) {
    if (current.length != next.length || current.isEmpty) return false;
    for (var i = 0; i < current.length; i++) {
      if (normalizeLibraryPath(current[i].filePath) !=
          normalizeLibraryPath(next[i].filePath)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> dispose() async {
    await _indexSub?.cancel();
    _indexSub = null;
    try {
      await _player.stop();
    } on Object {
      // Player may already be stopped or disposed.
    }
    await _player.dispose();
    await _currentTrackController.close();
  }
}

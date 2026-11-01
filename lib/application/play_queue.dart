import 'package:retroplayer/application/ports/playback_engine.dart';
import 'package:retroplayer/application/ports/playback_state_store.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Starts any [PlaybackItem] with resume support and saves its progress.
class PlayQueue {
  PlayQueue({
    required PlaybackEngine engine,
    required PlaybackStateStore store,
  })  : _engine = engine,
        _store = store;

  final PlaybackEngine _engine;
  final PlaybackStateStore _store;

  /// Starts [item] where it was left off.
  ///
  /// [startPosition] overrides the saved position but keeps the saved track.
  Future<void> start(
    PlaybackItem item, {
    Duration? startPosition,
    bool autoPlay = true,
  }) async {
    final tracks = item.tracks;
    if (tracks.isEmpty) return;

    final plan = PlaybackResume.resolve(
      tracks: tracks,
      saved: await _store.getPlaybackState(item.id),
      startPosition: startPosition,
    );
    final speed = plan.speed ?? item.defaultSpeed;
    if (speed != null) await _engine.setSpeed(speed);

    // Same queue already loaded: do not rebuild or re-seek. setAudioSources can
    // briefly emit index 0, and a stale or missing resume key would jump to the
    // first track while the user is already mid-queue.
    if (!_isCurrentQueue(tracks)) {
      await _engine.setQueue(
        tracks,
        startIndex: plan.startIndex,
        initialPosition: plan.initialPosition,
      );
    }
    if (autoPlay) await _engine.play();
  }

  /// Starts [item] at [track] (matched by id, then by file path).
  Future<void> startAt(
    PlaybackItem item,
    AudioTrack track, {
    Duration? startPosition,
  }) async {
    final tracks = item.tracks;
    final startIndex = _indexOf(tracks, track);
    if (startIndex < 0) return;
    final initialPosition = PlaybackResume.resumePosition(startPosition);

    if (_isCurrentQueue(tracks)) {
      final currentIndex = _engine.currentQueueIndex;
      if (currentIndex != startIndex) {
        await _engine.seekToQueueIndex(startIndex);
      }
      if (initialPosition != null) {
        await _engine.seek(initialPosition);
      }
      // Same track already loaded: leave position/duration unchanged.
    } else {
      await _engine.setQueue(
        tracks,
        startIndex: startIndex,
        initialPosition: initialPosition,
      );
    }
    await _engine.play();
  }

  /// Saves the current track and position under [itemId].
  Future<void> saveProgress(String itemId) async {
    final track = _engine.currentTrack;
    if (track == null) return;
    final artist = track.metadata.artist ?? track.metadata.album ?? '';
    await _store.savePlaybackState(
      itemId: itemId,
      trackId: PlaybackResume.trackKey(track),
      positionMs: _engine.position.inMilliseconds,
      speed: _engine.speed,
      displayTitle: track.displayTitle,
      subtitle: artist.isEmpty ? null : artist,
      durationMs: _durationMsForSave(track),
    );
  }

  int? _durationMsForSave(AudioTrack track) {
    final tagMs = track.durationMs;
    if (tagMs != null && tagMs > 0) return tagMs;
    final engine = _engine.duration;
    if (engine == null || engine <= Duration.zero) return null;
    return engine.inMilliseconds;
  }

  bool _isCurrentQueue(List<AudioTrack> tracks) {
    final current = _engine.queue;
    if (current.length != tracks.length || current.isEmpty) return false;
    for (var i = 0; i < tracks.length; i++) {
      if (current[i].id != tracks[i].id &&
          normalizeLibraryPath(current[i].filePath) !=
              normalizeLibraryPath(tracks[i].filePath)) {
        return false;
      }
    }
    return true;
  }

  static int _indexOf(List<AudioTrack> tracks, AudioTrack track) {
    final byId = tracks.indexWhere((t) => t.id == track.id);
    if (byId >= 0) return byId;
    final normalized = normalizeLibraryPath(track.filePath);
    return tracks.indexWhere(
      (t) => normalizeLibraryPath(t.filePath) == normalized,
    );
  }
}

import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';

/// Saved playback row used when resolving resume.
typedef SavedPlaybackState = ({
  String trackId,
  int positionMs,
  double speed,
  String? displayTitle,
  String? subtitle,
  int? durationMs,
});

/// Where a queue starts when playback begins, derived from saved state.
class ResumePlan {
  const ResumePlan({
    required this.startIndex,
    required this.initialPosition,
    required this.speed,
    required this.trackId,
  });

  final int startIndex;
  final Duration? initialPosition;

  /// Saved speed when the saved track was found; otherwise null.
  final double? speed;

  /// Id of the track at [startIndex]; empty for an empty queue.
  final String trackId;
}

/// Helpers for restoring playback position after a library rescan.
class PlaybackResume {
  /// Finds [tracks] index for a saved track key (stable id or legacy file path).
  static int indexOfTrack(List<AudioTrack> tracks, String savedTrackKey) {
    final direct = tracks.indexWhere((t) => t.id == savedTrackKey);
    if (direct >= 0) return direct;

    final normalized = normalizeLibraryPath(savedTrackKey);
    return tracks.indexWhere(
      (t) => normalizeLibraryPath(t.filePath) == normalized,
    );
  }

  /// Key written to playback state for the current track.
  static String trackKey(AudioTrack track) =>
      normalizeLibraryPath(track.filePath);

  /// Resolves where [tracks] (already in queue order) should start.
  ///
  /// A saved track that is no longer in the queue is ignored. [startPosition]
  /// overrides the saved position but keeps the saved track.
  static ResumePlan resolve({
    required List<AudioTrack> tracks,
    SavedPlaybackState? saved,
    Duration? startPosition,
  }) {
    var startIndex = 0;
    var position = startPosition;
    double? speed;

    if (saved != null) {
      final idx = indexOfTrack(tracks, saved.trackId);
      if (idx >= 0) {
        startIndex = idx;
        position ??= Duration(milliseconds: saved.positionMs);
        speed = saved.speed;
      }
    }

    return ResumePlan(
      startIndex: startIndex,
      initialPosition: resumePosition(position),
      speed: speed,
      trackId: tracks.isEmpty ? '' : tracks[startIndex].id,
    );
  }

  /// [resolve] for an album in tag order; speed defaults to 1.0.
  static ResumePlan resolveAlbumResume({
    required AudioAlbum album,
    SavedPlaybackState? saved,
    Duration? startPosition,
  }) {
    final plan = resolve(
      tracks: album.sortedTracks().tracks,
      saved: saved,
      startPosition: startPosition,
    );
    return ResumePlan(
      startIndex: plan.startIndex,
      initialPosition: plan.initialPosition,
      speed: plan.speed ?? 1.0,
      trackId: plan.trackId,
    );
  }

  static Duration? resumePosition(Duration? position) {
    if (position == null || position.inMilliseconds <= 0) return null;
    return position;
  }
}

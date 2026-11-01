import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Saved position per playback item (album, folder, playlist or track id).
abstract interface class PlaybackStateStore {
  Future<SavedPlaybackState?> getPlaybackState(String itemId);

  Future<void> savePlaybackState({
    required String itemId,
    required String trackId,
    required int positionMs,
    required double speed,
    String? displayTitle,
    String? subtitle,
    int? durationMs,
  });
}

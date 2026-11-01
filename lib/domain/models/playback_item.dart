import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';

/// Something the user can start playing: it knows its persisted item id and
/// the queue it plays.
sealed class PlaybackItem {
  const PlaybackItem();

  /// Key for saved playback state and the last active item.
  String get id;

  /// Tracks in queue order.
  List<AudioTrack> get tracks;

  /// Speed applied when no saved state matches; null keeps the current speed.
  double? get defaultSpeed => null;

  /// Item id for a folder queue.
  static String folderId(String folderPath) =>
      'folder:${normalizeLibraryPath(folderPath)}';

  /// Folder path for a [folderId], or null for other item ids.
  static String? folderPathFromId(String itemId) =>
      itemId.startsWith('folder:') ? itemId.substring('folder:'.length) : null;

  /// Stable id for the composed queue stored in the database.
  static const composedQueueId = 'queue';
}

/// The on-the-fly queue. Played tracks stay in [tracks].
final class QueuePlayback extends PlaybackItem {
  const QueuePlayback(this.tracks);

  @override
  final List<AudioTrack> tracks;

  @override
  String get id => PlaybackItem.composedQueueId;
}

/// An album in tag order. Starting an album without saved state resets speed.
final class AlbumPlayback extends PlaybackItem {
  AlbumPlayback(this.album) : tracks = _tracksWithAlbumLabels(album);

  final AudioAlbum album;

  @override
  final List<AudioTrack> tracks;

  @override
  String get id => album.id;

  @override
  double? get defaultSpeed => 1.0;
}

/// Every track under a folder, recursively, ordered by path.
final class FolderPlayback extends PlaybackItem {
  FolderPlayback(this.folderPath, List<AudioTrack> tracks)
    : tracks = sortFolderTracks(tracks);

  final String folderPath;

  @override
  final List<AudioTrack> tracks;

  @override
  String get id => PlaybackItem.folderId(folderPath);
}

/// Resolved entries of a playlist file, in file order.
final class PlaylistPlayback extends PlaybackItem {
  const PlaylistPlayback(this.playlist, this.tracks);

  final PlaylistFile playlist;

  @override
  final List<AudioTrack> tracks;

  @override
  String get id => playlist.id;
}

/// A single loose track.
final class TrackPlayback extends PlaybackItem {
  TrackPlayback(this.track) : tracks = [track];

  final AudioTrack track;

  @override
  final List<AudioTrack> tracks;

  @override
  String get id => track.id;
}

/// Queue copies that carry the album title and artist when a track has none.
///
/// The library album is left unchanged. Parent-folder authors and folder
/// titles reach the car through these copies.
List<AudioTrack> _tracksWithAlbumLabels(AudioAlbum album) {
  return [
    for (final track in album.sortedTracks().tracks)
      track.copyWith(
        metadata: track.metadata.copyWith(
          artist: _nonEmpty(track.metadata.artist) ?? _nonEmpty(album.artist),
          album: _nonEmpty(track.metadata.album) ?? _nonEmpty(album.title),
        ),
      ),
  ];
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// Folder queue order: by file path, then track number.
List<AudioTrack> sortFolderTracks(List<AudioTrack> tracks) {
  final sorted = List<AudioTrack>.from(tracks);
  sorted.sort((a, b) {
    final pathCmp = a.filePath.compareTo(b.filePath);
    if (pathCmp != 0) return pathCmp;
    final aNum = a.trackNumber ?? 9999;
    final bNum = b.trackNumber ?? 9999;
    return aNum.compareTo(bNum);
  });
  return sorted;
}

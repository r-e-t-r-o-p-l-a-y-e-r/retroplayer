import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';

/// Groups scanned tracks into albums/audiobooks or standalone items.
///
/// Cover art is intentionally left unset here. Covers are resolved later when
/// browsing inside a folder ([LibraryRepository.enrichAlbumCovers]) or when
/// starting playback ([PlayerViewModel]).
class GroupTracksIntoAlbums {
  const GroupTracksIntoAlbums();

  List<LibraryItem> call(List<AudioTrack> tracks) {
    if (tracks.isEmpty) return [];

    final items = <LibraryItem>[];
    final usedTrackIds = <String>{};

    items.addAll(_groupByAlbumTag(tracks, usedTrackIds));
    items.addAll(_groupByLeafDirectory(tracks, usedTrackIds));
    items.addAll(_groupBySeriesDirectories(tracks, usedTrackIds));
    items.addAll(_standaloneTracks(tracks, usedTrackIds));

    return items;
  }

  List<LibraryItem> _groupByAlbumTag(
    List<AudioTrack> tracks,
    Set<String> usedTrackIds,
  ) {
    final byAlbum = <String, List<AudioTrack>>{};
    for (final track in tracks) {
      if (usedTrackIds.contains(track.id)) continue;
      final album = track.albumTag;
      if (album == null) continue;
      final disc = track.metadata.discNumber ?? 0;
      final key =
          '${normalizeLibraryPath(track.directoryPath)}::${album.toLowerCase()}::$disc';
      byAlbum.putIfAbsent(key, () => []).add(track);
    }

    return byAlbum.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) {
          final albumTracks = e.value;
          for (final t in albumTracks) {
            usedTrackIds.add(t.id);
          }
          final sorted = _sortTracks(albumTracks);
          final first = sorted.first;
          final normalizedDir = normalizeLibraryPath(first.directoryPath);
          final disc = first.metadata.discNumber ?? 0;
          final groupingKey =
              'tag:${normalizedDir.toLowerCase()}::${_albumTagKey(first.albumTag!)}::$disc';
          return LibraryItem.album(
            album: AudioAlbum(
              id: groupingKey,
              title: _canonicalAlbumTitle(sorted, normalizedDir),
              artist: first.metadata.artist,
              tracks: sorted,
              source: AlbumSource.tag,
              groupingKey: groupingKey,
            ),
          );
        })
        .toList();
  }

  List<LibraryItem> _groupByLeafDirectory(
    List<AudioTrack> tracks,
    Set<String> usedTrackIds,
  ) {
    final byDir = <String, List<AudioTrack>>{};
    for (final track in tracks) {
      if (usedTrackIds.contains(track.id)) continue;
      byDir.putIfAbsent(track.directoryPath, () => []).add(track);
    }

    return byDir.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final albumTracks = e.value;
          for (final t in albumTracks) {
            usedTrackIds.add(t.id);
          }
          final sorted = _sortTracks(albumTracks);
          final normalizedDir = normalizeLibraryPath(e.key);
          final parentName = p.basename(p.dirname(normalizedDir));
          final hasParentContext = parentName.isNotEmpty && parentName != '.';
          final groupingKey = 'dir:${normalizedDir.toLowerCase()}';
          return LibraryItem.album(
            album: AudioAlbum(
              id: groupingKey,
              title: _canonicalAlbumTitle(sorted, normalizedDir),
              artist: hasParentContext ? parentName : sorted.first.metadata.artist,
              tracks: sorted,
              source: AlbumSource.directory,
              groupingKey: groupingKey,
            ),
          );
        })
        .toList();
  }

  List<LibraryItem> _groupBySeriesDirectories(
    List<AudioTrack> tracks,
    Set<String> usedTrackIds,
  ) {
    final byParent = <String, List<AudioTrack>>{};
    for (final track in tracks) {
      if (usedTrackIds.contains(track.id)) continue;
      final parent = p.dirname(track.directoryPath);
      if (parent == track.directoryPath || parent == '.') continue;
      byParent.putIfAbsent(parent, () => []).add(track);
    }

    final items = <LibraryItem>[];
    for (final entry in byParent.entries) {
      final subdirs = entry.value.map((t) => t.directoryPath).toSet();
      if (subdirs.length < 2) continue;

      final bySubdir = <String, List<AudioTrack>>{};
      for (final track in entry.value) {
        if (usedTrackIds.contains(track.id)) continue;
        bySubdir.putIfAbsent(track.directoryPath, () => []).add(track);
      }

      for (final subEntry in bySubdir.entries) {
        if (subEntry.value.length < 2) continue;
        for (final t in subEntry.value) {
          usedTrackIds.add(t.id);
        }
        final sorted = _sortTracks(subEntry.value);
        final normalizedSubdir = normalizeLibraryPath(subEntry.key);
        final groupingKey = 'series:${normalizedSubdir.toLowerCase()}';
        items.add(
          LibraryItem.album(
            album: AudioAlbum(
              id: groupingKey,
              title: p.basename(normalizedSubdir),
              artist: p.basename(normalizeLibraryPath(entry.key)),
              series: p.basename(normalizeLibraryPath(entry.key)),
              tracks: sorted,
              source: AlbumSource.series,
              groupingKey: groupingKey,
            ),
          ),
        );
      }
    }
    return items;
  }

  List<LibraryItem> _standaloneTracks(
    List<AudioTrack> tracks,
    Set<String> usedTrackIds,
  ) {
    return tracks
        .where((t) => !usedTrackIds.contains(t.id))
        .map((t) => LibraryItem.track(track: t))
        .toList();
  }

  String _albumTagKey(String albumTag) => albumTag.trim().toLowerCase();

  String _canonicalAlbumTitle(List<AudioTrack> tracks, String directoryPath) {
    final variantCounts = <String, int>{};
    for (final track in tracks) {
      final album = track.albumTag?.trim();
      if (album == null || album.isEmpty) continue;
      variantCounts[album] = (variantCounts[album] ?? 0) + 1;
    }
    if (variantCounts.isEmpty) {
      return tracks.first.metadata.displayAlbum(directoryPath);
    }
    return variantCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  List<AudioTrack> _sortTracks(List<AudioTrack> tracks) {
    return List<AudioTrack>.from(tracks)
      ..sort((a, b) {
        final aDisc = a.metadata.discNumber ?? 0;
        final bDisc = b.metadata.discNumber ?? 0;
        if (aDisc != bDisc) return aDisc.compareTo(bDisc);
        final aNum = a.trackNumber ?? 9999;
        final bNum = b.trackNumber ?? 9999;
        if (aNum != bNum) return aNum.compareTo(bNum);
        return a.filePath.compareTo(b.filePath);
      });
  }
}

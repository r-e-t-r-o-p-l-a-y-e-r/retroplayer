import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';

/// Scans library directories and produces grouped library items.
class ScanLibrary implements LibraryScanner {
  ScanLibrary({
    required LibraryFileSystem fileScanService,
    required TrackMetadataReader metadataService,
    required GroupTracksIntoAlbums groupTracksIntoAlbums,
  }) : _fileScanService = fileScanService,
       _metadataService = metadataService,
       _groupTracksIntoAlbums = groupTracksIntoAlbums;

  final LibraryFileSystem _fileScanService;
  final TrackMetadataReader _metadataService;
  final GroupTracksIntoAlbums _groupTracksIntoAlbums;

  static const _batchSize = 10;
  static const _batchInterval = Duration(milliseconds: 100);

  /// Reads audio and playlist files in one directory level only.
  @override
  Stream<DirectoryListingUpdate> watchDirectoryShallow(
    String directoryPath,
  ) async* {
    final normalized = normalizeLibraryPath(directoryPath);
    final audioPaths = await _fileScanService.listAudioFilesInDirectory(
      normalized,
    );
    final playlistPaths = await _fileScanService.listPlaylistFilesInDirectory(
      normalized,
    );

    final playlists = <LibraryItem>[];
    for (final path in playlistPaths) {
      playlists.add(
        LibraryItem.playlist(playlist: await _playlistFromPath(path)),
      );
    }

    final pending = <String, AudioTrack>{
      for (final path in audioPaths)
        stableTrackId(path): _placeholderTrack(path),
    };
    final tagged = <String, AudioTrack>{};

    List<LibraryItem> incompleteMultiFileFolder() {
      final taggedItems = _groupTracksIntoAlbums(tagged.values.toList());
      final albums = taggedItems.whereType<LibraryAlbumItem>().toList();
      if (albums.isEmpty) {
        // No album tags yet: one directory album of placeholders.
        return _groupTracksIntoAlbums([...tagged.values, ...pending.values]);
      }
      if (albums.length == 1) {
        final album = albums.single.album;
        final knownIds = {for (final track in album.tracks) track.id};
        final extra = [
          for (final track in pending.values)
            if (!knownIds.contains(track.id)) track,
        ];
        if (extra.isEmpty) return albums;
        return [
          LibraryItem.album(
            album: album.copyWith(tracks: [...album.tracks, ...extra]),
          ),
        ];
      }
      // Several albums already formed: hide leftover placeholders until
      // their tags place them. Showing them as tracks is the flicker.
      return albums;
    }

    List<LibraryItem> compose() {
      if (pending.isEmpty) {
        return [
          ..._groupTracksIntoAlbums(tagged.values.toList()),
          ...playlists,
        ];
      }
      // One-file folders stay as a placeholder track until tags arrive.
      if (audioPaths.length < 2) {
        return [
          ..._groupTracksIntoAlbums([...tagged.values, ...pending.values]),
          ...playlists,
        ];
      }
      // Multi-file folder still scanning: never list untagged files as
      // sibling rows beside a forming album (those titles then vanish).
      return [...incompleteMultiFileFolder(), ...playlists];
    }

    yield DirectoryListingUpdate(
      items: compose(),
      scannedFileCount: 0,
      totalFileCount: audioPaths.length,
      isComplete: audioPaths.isEmpty,
    );

    if (audioPaths.isEmpty) return;

    var scanned = 0;
    var sinceEmit = 0;
    final elapsed = Stopwatch()..start();

    for (final path in audioPaths) {
      final id = stableTrackId(path);
      final track = await _trackFromPath(path);
      pending.remove(id);
      tagged[id] = track;
      scanned++;
      sinceEmit++;
      final shouldEmit =
          sinceEmit >= _batchSize || elapsed.elapsed >= _batchInterval;
      if (!shouldEmit && scanned < audioPaths.length) continue;
      yield DirectoryListingUpdate(
        items: compose(),
        scannedFileCount: scanned,
        totalFileCount: audioPaths.length,
        isComplete: scanned == audioPaths.length,
      );
      sinceEmit = 0;
      elapsed.reset();
    }
  }

  @override
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath) async {
    DirectoryListingUpdate? last;
    await for (final update in watchDirectoryShallow(directoryPath)) {
      last = update;
    }
    return last?.items ?? const [];
  }

  /// Recursively scans audio files under [rootPath].
  @override
  Future<List<AudioTrack>> scanDirectoryRecursive(String rootPath) async {
    final paths = await _fileScanService.scanDirectory(rootPath);
    return _tracksFromPaths(paths);
  }

  @override
  Future<AudioTrack> trackFromPath(String filePath) async =>
      _trackFromPath(filePath);

  Future<List<AudioTrack>> _tracksFromPaths(List<String> paths) async {
    if (paths.isEmpty) return const [];
    final tracks = <AudioTrack>[];
    for (final path in paths) {
      tracks.add(await _trackFromPath(path));
    }
    return tracks;
  }

  Future<AudioTrack> _trackFromPath(String filePath) async {
    final normalized = stableTrackId(filePath);
    final metadata = await _metadataService.readMetadata(filePath);
    return AudioTrack(
      id: normalized,
      filePath: normalized,
      directoryPath: normalizeLibraryPath(p.dirname(normalized)),
      metadata: metadata,
      dateAdded: DateTime.now(),
      durationMs: metadata.duration?.inMilliseconds,
    );
  }

  AudioTrack _placeholderTrack(String filePath) {
    final normalized = stableTrackId(filePath);
    return AudioTrack(
      id: normalized,
      filePath: normalized,
      directoryPath: normalizeLibraryPath(p.dirname(normalized)),
      metadata: TrackMetadata(title: p.basenameWithoutExtension(normalized)),
      dateAdded: DateTime(1970),
    );
  }

  Future<PlaylistFile> _playlistFromPath(String filePath) async {
    final normalized = normalizeLibraryPath(filePath);
    final entries = await _fileScanService.readPlaylistEntries(normalized);
    return PlaylistFile(filePath: normalized, entryPaths: entries);
  }
}

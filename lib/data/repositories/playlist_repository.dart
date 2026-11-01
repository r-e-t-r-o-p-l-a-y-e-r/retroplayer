import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/repositories/directory_listing_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/write_playlist_file.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/local_path_policy.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';

/// Create, edit and delete playlists the app owns. Disk playlists are read-only.
class PlaylistRepository {
  PlaylistRepository({
    required LibraryStorageService storageService,
    required LibraryScanner scanLibrary,
    required DirectoryListingRepository listings,
    WritePlaylistFile writePlaylistFile = const WritePlaylistFile(),
  }) : _storageService = storageService,
       _scanLibrary = scanLibrary,
       _listings = listings,
       _writePlaylistFile = writePlaylistFile;

  final LibraryStorageService _storageService;
  final LibraryScanner _scanLibrary;
  final DirectoryListingRepository _listings;
  final WritePlaylistFile _writePlaylistFile;

  Future<List<AudioTrack>> resolveTracks(PlaylistFile playlist) async {
    final tracks = <AudioTrack>[];
    final seen = <String>{};
    for (final entry in playlist.entryPaths) {
      if (!isLocalFilesystemPath(entry)) continue;
      final normalized = normalizeLibraryPath(entry);
      if (!seen.add(normalized)) continue;
      if (!SupportedFormats.isSupported(normalized)) continue;
      tracks.add(await _scanLibrary.trackFromPath(normalized));
    }
    return tracks;
  }

  /// Playable tracks for [paths] without reading tags.
  List<AudioTrack> previewPaths(List<String> paths) {
    final tracks = <AudioTrack>[];
    final seen = <String>{};
    for (final entry in paths) {
      if (!isLocalFilesystemPath(entry)) continue;
      final normalized = normalizeLibraryPath(entry);
      if (!seen.add(normalized)) continue;
      if (!SupportedFormats.isSupported(normalized)) continue;
      tracks.add(trackWithoutMetadata(normalized));
    }
    return tracks;
  }

  Future<List<AudioTrack>> resolvePaths(List<String> paths) async {
    final tracks = <AudioTrack>[];
    final seen = <String>{};
    for (final entry in paths) {
      if (!isLocalFilesystemPath(entry)) continue;
      final normalized = normalizeLibraryPath(entry);
      if (!seen.add(normalized)) continue;
      if (!SupportedFormats.isSupported(normalized)) continue;
      tracks.add(await _scanLibrary.trackFromPath(normalized));
    }
    return tracks;
  }

  Future<PlaylistFile?> findByPath(String path) async {
    final normalized = normalizeLibraryPath(path);
    final dir = normalizeLibraryPath(p.dirname(normalized));
    await _listings.loadDirectory(dir);
    for (final item in _listings.cachedDirectoryItems(dir) ?? const []) {
      if (item case LibraryPlaylistItem(
        :final playlist,
      ) when playlist.filePath == normalized) {
        return playlist;
      }
    }
    return null;
  }

  Future<PlaylistFile> create({
    required String directory,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Playlist name cannot be empty');
    }
    final lower = trimmed.toLowerCase();
    final fileName = lower.endsWith('.m3u') || lower.endsWith('.m3u8')
        ? trimmed
        : '$trimmed.m3u';
    final path = normalizeLibraryPath(p.join(directory, fileName));
    await _writePlaylistFile(path, const []);
    await _storageService.markAppCreatedPlaylist(path);
    _listings.invalidateDirectory(directory);
    return (await findByPath(path))!;
  }

  Future<PlaylistFile> saveEntries({
    required String playlistPath,
    required List<String> absoluteEntryPaths,
  }) async {
    final normalized = normalizeLibraryPath(playlistPath);
    if (!await _storageService.isAppCreatedPlaylist(normalized)) {
      throw StateError('Only app-created playlists can be edited');
    }
    await _writePlaylistFile(normalized, absoluteEntryPaths);
    _listings.invalidateDirectory(normalizeLibraryPath(p.dirname(normalized)));
    return (await findByPath(normalized))!;
  }

  Future<void> delete(String playlistPath) async {
    final normalized = normalizeLibraryPath(playlistPath);
    if (!await _storageService.isAppCreatedPlaylist(normalized)) {
      throw StateError('Only app-created playlists can be deleted');
    }
    final file = File(normalized);
    if (await file.exists()) {
      await file.delete();
    }
    await _storageService.unmarkAppCreatedPlaylist(normalized);
    _listings.invalidateDirectory(normalizeLibraryPath(p.dirname(normalized)));
  }

  Future<bool> isAppCreated(String path) =>
      _storageService.isAppCreatedPlaylist(path);

  Future<Set<String>> appCreatedPaths() =>
      _storageService.getAppCreatedPlaylistPaths();
}

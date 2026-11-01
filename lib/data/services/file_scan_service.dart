import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/services/parse_playlist_file.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';

/// Scans directories for supported audio files.
class FileScanService implements LibraryFileSystem {
  @override
  Future<List<String>> readPlaylistEntries(String playlistPath) =>
      const ParsePlaylistFile()(playlistPath);

  Future<List<String>> listImmediateSubdirectoryPaths(
    String directoryPath,
  ) async {
    final entries = <String>[];
    await for (final entity in _listDir(directoryPath)) {
      if (entity is! Directory) continue;
      entries.add(normalizeLibraryPath(entity.path));
    }
    entries.sort(
      (a, b) =>
          p.basename(a).toLowerCase().compareTo(p.basename(b).toLowerCase()),
    );
    return entries;
  }

  @override
  Future<List<String>> listAudioFilesInDirectory(String directoryPath) async {
    final results = <String>[];
    await for (final entity in _listDir(directoryPath)) {
      if (entity is! File) continue;
      if (SupportedFormats.isSupported(entity.path)) {
        results.add(normalizeLibraryPath(entity.path));
      }
    }
    results.sort();
    return results;
  }

  @override
  Future<List<String>> listPlaylistFilesInDirectory(
    String directoryPath,
  ) async {
    final results = <String>[];
    await for (final entity in _listDir(directoryPath)) {
      if (entity is! File) continue;
      if (SupportedFormats.isPlaylist(entity.path)) {
        results.add(normalizeLibraryPath(entity.path));
      }
    }
    results.sort();
    return results;
  }

  @override
  Future<List<String>> scanDirectory(String rootPath) async {
    final results = <String>[];
    await for (final entity in _listDir(rootPath, recursive: true)) {
      if (entity is! File) continue;
      if (SupportedFormats.isP0(entity.path)) {
        results.add(normalizeLibraryPath(entity.path));
      }
    }
    results.sort();
    return results;
  }

  Future<List<String>> scanPlaylistFiles(String rootPath) async {
    final results = <String>[];
    await for (final entity in _listDir(rootPath, recursive: true)) {
      if (entity is! File) continue;
      if (SupportedFormats.isPlaylist(entity.path)) {
        results.add(normalizeLibraryPath(entity.path));
      }
    }
    results.sort();
    return results;
  }

  Stream<FileSystemEntity> _listDir(
    String directoryPath, {
    bool recursive = false,
  }) async* {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return;
    try {
      await for (final entity in dir.list(
        recursive: recursive,
        followLinks: false,
      )) {
        yield entity;
      }
    } on PathNotFoundException {
      return;
    } on FileSystemException {
      return;
    }
  }
}

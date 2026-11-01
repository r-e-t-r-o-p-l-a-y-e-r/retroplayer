import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/services/cover_art_service.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';

/// Cache, scan and sort of directory listings.
class DirectoryListingRepository {
  DirectoryListingRepository({
    required this._scanLibrary,
    required this._sortLibrary,
    required this._fileScanService,
    required this._covers,
  });

  final LibraryScanner _scanLibrary;
  final SortLibrary _sortLibrary;
  final FileScanService _fileScanService;
  final CoverArtService _covers;

  final Map<String, List<LibraryItem>> _directoryCache = {};
  final Map<String, List<FolderEntry>> _testChildFolders = {};
  final Map<String, List<AudioTrack>> _testFolderTracks = {};

  List<LibraryItem> get items =>
      _directoryCache.values.expand((items) => items).toList(growable: false);

  Future<List<FolderEntry>> listChildFolders(String directoryPath) async {
    final normalized = normalizeLibraryPath(directoryPath);
    final seeded = _testChildFolders[normalized];
    if (seeded != null) return seeded;

    final paths = await _fileScanService.listImmediateSubdirectoryPaths(
      directoryPath,
    );
    return [
      for (final path in paths) FolderEntry(path: path, name: p.basename(path)),
    ];
  }

  Stream<DirectoryListingUpdate> watchDirectory(String directoryPath) {
    final normalized = normalizeLibraryPath(directoryPath);
    final cached = _directoryCache[normalized];
    if (cached != null) {
      return Stream.value(DirectoryListingUpdate.complete(sortItems(cached)));
    }

    return _scanLibrary.watchDirectoryShallow(normalized).asyncMap((
      update,
    ) async {
      if (update.isComplete) {
        _directoryCache[normalized] = update.items;
      }
      return DirectoryListingUpdate(
        items: sortItems(update.items),
        scannedFileCount: update.scannedFileCount,
        totalFileCount: update.totalFileCount,
        isComplete: update.isComplete,
      );
    });
  }

  Future<List<LibraryItem>> loadDirectory(String directoryPath) async {
    DirectoryListingUpdate? last;
    await for (final update in watchDirectory(directoryPath)) {
      last = update;
    }
    return last?.items ?? const [];
  }

  List<LibraryItem>? cachedDirectoryItems(String directoryPath) =>
      _directoryCache[normalizeLibraryPath(directoryPath)];

  void replaceDirectoryItems(String directoryPath, List<LibraryItem> items) {
    _directoryCache[normalizeLibraryPath(directoryPath)] = items;
  }

  Future<List<LibraryItem>> enrichAlbumCovers(
    List<LibraryItem> items, {
    bool Function()? shouldContinue,
  }) => _covers.enrichAlbumCovers(items, shouldContinue: shouldContinue);

  void invalidateDirectory(String directoryPath) {
    _directoryCache.remove(normalizeLibraryPath(directoryPath));
  }

  void clearCacheUnderRoot(String rootPath) {
    final normalizedRoot = normalizeLibraryPath(rootPath);
    final keysToRemove = _directoryCache.keys
        .where((key) => isPathWithinLibraryRoots(key, [normalizedRoot]))
        .toList();
    for (final key in keysToRemove) {
      _directoryCache.remove(key);
    }
  }

  List<LibraryItem> sortItems(List<LibraryItem> items) => _sortLibrary(items);

  LibraryItem? findById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<List<AudioTrack>> tracksUnderFolder(String folderPath) async {
    final normalized = normalizeLibraryPath(folderPath);
    final seeded = _testFolderTracks[normalized];
    if (seeded != null) return seeded;
    return _scanLibrary.scanDirectoryRecursive(folderPath);
  }

  void seedDirectory(String directoryPath, List<LibraryItem> items) {
    _directoryCache[normalizeLibraryPath(directoryPath)] = items;
  }

  void seedChildFolders(String directoryPath, List<FolderEntry> folders) {
    _testChildFolders[normalizeLibraryPath(directoryPath)] = folders;
  }

  void seedTracksUnderFolder(String folderPath, List<AudioTrack> tracks) {
    _testFolderTracks[normalizeLibraryPath(folderPath)] = tracks;
  }
}

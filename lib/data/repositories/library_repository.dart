import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/cover_art_source.dart';
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/data/repositories/directory_listing_repository.dart';
import 'package:retroplayer/data/repositories/playlist_repository.dart';
import 'package:retroplayer/data/services/cover_art_service.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';

/// Facade over directory listings, playlists and cover art.
class LibraryRepository {
  LibraryRepository({
    required LibraryStorageService storageService,
    required LibraryScanner scanLibrary,
    required SortLibrary sortLibrary,
    required FileScanService fileScanService,
    CoverArtSource? resolveCoverArt,
  }) : _storageService = storageService {
    covers = CoverArtService(source: resolveCoverArt);
    listings = DirectoryListingRepository(
      scanLibrary: scanLibrary,
      sortLibrary: sortLibrary,
      fileScanService: fileScanService,
      covers: covers,
    );
    playlists = PlaylistRepository(
      storageService: storageService,
      scanLibrary: scanLibrary,
      listings: listings,
    );
  }

  final LibraryStorageService _storageService;

  late final DirectoryListingRepository listings;
  late final PlaylistRepository playlists;
  late final CoverArtService covers;

  List<LibraryItem> get items => listings.items;

  Future<List<String>> getLibraryRoots() => _storageService.getLibraryRoots();

  Future<List<FolderEntry>> listChildFolders(String directoryPath) =>
      listings.listChildFolders(directoryPath);

  Stream<DirectoryListingUpdate> watchDirectory(String directoryPath) =>
      listings.watchDirectory(directoryPath);

  Future<List<LibraryItem>> loadDirectory(String directoryPath) =>
      listings.loadDirectory(directoryPath);

  List<LibraryItem>? cachedDirectoryItems(String directoryPath) =>
      listings.cachedDirectoryItems(directoryPath);

  void replaceDirectoryItems(String directoryPath, List<LibraryItem> items) =>
      listings.replaceDirectoryItems(directoryPath, items);

  Future<List<LibraryItem>> enrichAlbumCovers(
    List<LibraryItem> items, {
    bool Function()? shouldContinue,
  }) => listings.enrichAlbumCovers(items, shouldContinue: shouldContinue);

  void invalidateDirectory(String directoryPath) =>
      listings.invalidateDirectory(directoryPath);

  Future<void> addLibraryRoot(String path) =>
      _storageService.addLibraryRoot(path);

  Future<void> removeLibraryRoot(String path) async {
    final normalized = normalizeLibraryPath(path);
    await _storageService.removeLibraryRoot(normalized);
    listings.clearCacheUnderRoot(normalized);
  }

  Future<void> reorderLibraryRoots(int oldIndex, int newIndex) =>
      _storageService.reorderLibraryRoots(oldIndex, newIndex);

  LibraryItem? findById(String id) => listings.findById(id);

  Future<LibraryItem?> findByIdAsync(String id) async {
    final cached = findById(id);
    if (cached != null) return cached;

    if (id.startsWith('playlist:')) {
      final playlistPath = PlaylistFile.playlistPathFromItemId(id);
      if (playlistPath == null) return null;
      final dir = normalizeLibraryPath(p.dirname(playlistPath));
      await loadDirectory(dir);
      return findById(id);
    }

    for (final root in await getLibraryRoots()) {
      await loadDirectory(root);
      final item = findById(id);
      if (item != null) return item;
    }
    return null;
  }

  Future<String?> getSavedBrowsePath() =>
      _storageService.getLibraryBrowsePath();

  Future<void> saveBrowsePath(String? path) =>
      _storageService.setLibraryBrowsePath(path);

  Future<String?> getSavedAlbumDetailId() =>
      _storageService.getLibraryAlbumDetailId();

  Future<void> saveAlbumDetailId(String? albumId) =>
      _storageService.setLibraryAlbumDetailId(albumId);

  Future<bool> getSavedPlayerPanelExpanded() =>
      _storageService.getPlayerPanelExpanded();

  Future<void> savePlayerPanelExpanded(bool expanded) =>
      _storageService.setPlayerPanelExpanded(expanded);

  Future<bool> getSavedSettingsOverlayOpen() =>
      _storageService.getSettingsOverlayOpen();

  Future<void> saveSettingsOverlayOpen(bool open) =>
      _storageService.setSettingsOverlayOpen(open);

  Future<void> resetDatabase({required bool removeLibraryFolders}) =>
      _storageService.resetDatabase(removeLibraryFolders: removeLibraryFolders);

  Future<List<String>> getFavoriteFolders() =>
      _storageService.getFavoriteFolders();

  Future<void> setFavoriteFolders(List<String> paths) =>
      _storageService.setFavoriteFolders(paths);

  Future<({List<String> paths, int index})> getPlaybackQueue() =>
      _storageService.getPlaybackQueue();

  Future<void> setPlaybackQueue({
    required List<String> paths,
    required int index,
  }) => _storageService.setPlaybackQueue(paths: paths, index: index);

  Future<List<AudioTrack>> tracksForPaths(List<String> paths) =>
      playlists.resolvePaths(paths);

  /// Playable tracks for [paths] without reading tags.
  List<AudioTrack> previewTracksForPaths(List<String> paths) =>
      playlists.previewPaths(paths);

  Future<EqualizerSettings> getEqualizerSettings() =>
      _storageService.getEqualizerSettings();

  Future<void> setEqualizerSettings(EqualizerSettings settings) =>
      _storageService.setEqualizerSettings(settings);

  Future<List<AudioTrack>> tracksUnderFolder(String folderPath) =>
      listings.tracksUnderFolder(folderPath);

  Future<List<AudioTrack>> resolvePlaylistTracks(PlaylistFile playlist) =>
      playlists.resolveTracks(playlist);

  Future<PlaylistFile?> findPlaylistByPath(String path) =>
      playlists.findByPath(path);

  Future<PlaylistFile> createPlaylist({
    required String directory,
    required String name,
  }) => playlists.create(directory: directory, name: name);

  Future<PlaylistFile> savePlaylistEntries({
    required String playlistPath,
    required List<String> absoluteEntryPaths,
  }) => playlists.saveEntries(
    playlistPath: playlistPath,
    absoluteEntryPaths: absoluteEntryPaths,
  );

  Future<void> deletePlaylist(String playlistPath) =>
      playlists.delete(playlistPath);

  Future<bool> isAppCreatedPlaylist(String path) =>
      playlists.isAppCreated(path);

  Future<Set<String>> getAppCreatedPlaylistPaths() =>
      playlists.appCreatedPaths();

  @visibleForTesting
  void seedDirectory(String directoryPath, List<LibraryItem> items) =>
      listings.seedDirectory(directoryPath, items);

  @visibleForTesting
  void seedChildFolders(String directoryPath, List<FolderEntry> folders) =>
      listings.seedChildFolders(directoryPath, folders);

  @visibleForTesting
  void seedTracksUnderFolder(String folderPath, List<AudioTrack> tracks) =>
      listings.seedTracksUnderFolder(folderPath, tracks);

  @visibleForTesting
  void seedItems(List<LibraryItem> items, {String directoryPath = '/music'}) {
    seedDirectory(directoryPath, items);
  }
}

LibraryRepository createLibraryRepository(
  LibraryStorageService storage, {
  ResolveCoverArt? resolveCoverArt,
}) {
  final fileScan = FileScanService();
  final metadata = MetadataService();
  final resolve =
      resolveCoverArt ??
      ResolveCoverArt(readEmbeddedArtwork: metadata.readEmbeddedArtwork);
  final scan = ScanLibrary(
    fileScanService: fileScan,
    metadataService: metadata,
    groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
  );
  return LibraryRepository(
    storageService: storage,
    scanLibrary: scan,
    sortLibrary: SortLibrary(),
    fileScanService: fileScan,
    resolveCoverArt: resolve,
  );
}

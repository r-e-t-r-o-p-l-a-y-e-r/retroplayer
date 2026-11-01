import 'package:retroplayer/application/ports/playback_state_store.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/db/daos.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Persists library roots, playback state and settings in drift.
class LibraryStorageService implements PlaybackStateStore {
  LibraryStorageService(AppDatabase db)
    : _db = db,
      roots = LibraryRootsDao(db),
      playback = PlaybackStateDao(db),
      browse = BrowsePrefsDao(db),
      prefs = AppPrefsDao(db),
      playlists = PlaylistRegistryDao(db);

  final AppDatabase _db;

  static const lastActiveItemKey = PlaybackStateDao.lastActiveItemKey;
  static const libraryBrowsePathKey = BrowsePrefsDao.browsePathKey;
  static const libraryAlbumDetailIdKey = BrowsePrefsDao.albumDetailIdKey;
  static const favoriteFoldersKey = BrowsePrefsDao.favoriteFoldersKey;
  static const playbackQueueKey = BrowsePrefsDao.playbackQueueKey;
  static const equalizerModeKey = AppPrefsDao.equalizerModeKey;
  static const equalizerPresetKey = AppPrefsDao.equalizerPresetKey;
  static const equalizerBandsKey = AppPrefsDao.equalizerBandsKey;
  static const themePreferenceKey = AppPrefsDao.themePreferenceKey;
  static const localePreferenceKey = AppPrefsDao.localePreferenceKey;
  static const appCreatedPlaylistPrefix = PlaylistRegistryDao.prefix;

  final LibraryRootsDao roots;
  final PlaybackStateDao playback;
  final BrowsePrefsDao browse;
  final AppPrefsDao prefs;
  final PlaylistRegistryDao playlists;

  Future<List<String>> getLibraryRoots() => roots.getRoots();

  Future<void> addLibraryRoot(String path) => roots.addRoot(path);

  Future<void> removeLibraryRoot(String path) => roots.removeRoot(path);

  Future<void> reorderLibraryRoots(int oldIndex, int newIndex) =>
      roots.reorderRoots(oldIndex, newIndex);

  /// Clears playback and settings. Library folders stay unless
  /// [removeLibraryFolders] is true. Audio files on disk are not touched.
  Future<void> resetDatabase({required bool removeLibraryFolders}) async {
    await _db.delete(_db.playbackStates).go();
    await _db.delete(_db.appSettings).go();
    if (removeLibraryFolders) {
      await _db.delete(_db.libraryRoots).go();
    }
  }

  @override
  Future<void> savePlaybackState({
    required String itemId,
    required String trackId,
    required int positionMs,
    required double speed,
    String? displayTitle,
    String? subtitle,
    int? durationMs,
  }) => playback.save(
    itemId: itemId,
    trackId: trackId,
    positionMs: positionMs,
    speed: speed,
    displayTitle: displayTitle,
    subtitle: subtitle,
    durationMs: durationMs,
  );

  Future<String?> getLastActiveItemId() => playback.getLastActiveItemId();

  Future<void> clearPlaybackState(String itemId) => playback.clear(itemId);

  Future<void> setLibraryBrowsePath(String? path) => browse.setBrowsePath(path);

  Future<String?> getLibraryBrowsePath() => browse.getBrowsePath();

  Future<void> setLibraryAlbumDetailId(String? albumId) =>
      browse.setAlbumDetailId(albumId);

  Future<String?> getLibraryAlbumDetailId() => browse.getAlbumDetailId();

  Future<void> setPlayerPanelExpanded(bool expanded) =>
      browse.setPlayerPanelExpanded(expanded);

  Future<bool> getPlayerPanelExpanded() => browse.getPlayerPanelExpanded();

  Future<void> setSettingsOverlayOpen(bool open) =>
      browse.setSettingsOverlayOpen(open);

  Future<bool> getSettingsOverlayOpen() => browse.getSettingsOverlayOpen();

  Future<List<String>> getFavoriteFolders() => browse.getFavoriteFolders();

  Future<void> setFavoriteFolders(List<String> paths) =>
      browse.setFavoriteFolders(paths);

  Future<({List<String> paths, int index})> getPlaybackQueue() =>
      browse.getPlaybackQueue();

  Future<void> setPlaybackQueue({
    required List<String> paths,
    required int index,
  }) => browse.setPlaybackQueue(paths: paths, index: index);

  Future<void> setPlaybackQueueIndex(int index) async {
    final current = await browse.getPlaybackQueue();
    await browse.setPlaybackQueue(paths: current.paths, index: index);
  }

  @override
  Future<SavedPlaybackState?> getPlaybackState(String itemId) =>
      playback.get(itemId);

  Future<EqualizerSettings> getEqualizerSettings() =>
      prefs.getEqualizerSettings();

  Future<void> setEqualizerSettings(EqualizerSettings settings) =>
      prefs.setEqualizerSettings(settings);

  @Deprecated('Use getEqualizerSettings')
  Future<EqualizerPreset> getEqualizerPreset() async {
    final settings = await getEqualizerSettings();
    return settings.preset;
  }

  @Deprecated('Use setEqualizerSettings')
  Future<void> setEqualizerPreset(EqualizerPreset preset) async {
    await setEqualizerSettings(EqualizerSettings.fromPreset(preset));
  }

  Future<ThemePreference> getThemePreference() => prefs.getThemePreference();

  Future<void> setThemePreference(ThemePreference preference) =>
      prefs.setThemePreference(preference);

  Future<LocalePreference> getLocalePreference() => prefs.getLocalePreference();

  Future<void> setLocalePreference(LocalePreference preference) =>
      prefs.setLocalePreference(preference);

  Future<void> markAppCreatedPlaylist(String path) => playlists.mark(path);

  Future<void> unmarkAppCreatedPlaylist(String path) => playlists.unmark(path);

  Future<bool> isAppCreatedPlaylist(String path) => playlists.isMarked(path);

  Future<Set<String>> getAppCreatedPlaylistPaths() => playlists.allPaths();

  Future<void> close() => _db.close();
}

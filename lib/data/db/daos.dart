import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Reads and writes a single [AppSettings] key.
class _SettingsKv {
  const _SettingsKv(this._db);

  final AppDatabase _db;

  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<void> remove(String key) async {
    await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
  }
}

class LibraryRootsDao {
  LibraryRootsDao(this._db);

  final AppDatabase _db;

  Future<List<String>> getRoots() async {
    final query = _db.select(_db.libraryRoots)
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.id),
      ]);
    final rows = await query.get();
    return rows.map((r) => normalizeLibraryPath(r.path)).toList();
  }

  Future<void> addRoot(String path) async {
    final normalized = normalizeLibraryPath(path);
    final existing = await (_db.select(
      _db.libraryRoots,
    )..where((t) => t.path.equals(normalized))).getSingleOrNull();
    if (existing != null) return;

    final maxOrder = await _maxSortOrder();
    await _db.into(_db.libraryRoots).insert(
          LibraryRootsCompanion.insert(
            path: normalized,
            addedAt: DateTime.now(),
            sortOrder: Value(maxOrder + 1),
          ),
        );
  }

  Future<void> reorderRoots(int oldIndex, int newIndex) async {
    final rows = await (_db.select(_db.libraryRoots)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    if (oldIndex < 0 ||
        oldIndex >= rows.length ||
        newIndex < 0 ||
        newIndex >= rows.length ||
        oldIndex == newIndex) {
      return;
    }
    final ordered = [...rows];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);
    await _db.transaction(() async {
      for (var i = 0; i < ordered.length; i++) {
        await (_db.update(_db.libraryRoots)
              ..where((t) => t.id.equals(ordered[i].id)))
            .write(LibraryRootsCompanion(sortOrder: Value(i)));
      }
    });
  }

  Future<int> _maxSortOrder() async {
    final row = await (_db.selectOnly(_db.libraryRoots)
          ..addColumns([_db.libraryRoots.sortOrder.max()]))
        .getSingleOrNull();
    final max = row?.read(_db.libraryRoots.sortOrder.max());
    return max ?? 0;
  }

  Future<void> removeRoot(String path) async {
    final normalized = normalizeLibraryPath(path);
    await (_db.delete(
      _db.libraryRoots,
    )..where((t) => t.path.equals(normalized))).go();
  }
}

class PlaybackStateDao {
  PlaybackStateDao(this._db) : _kv = _SettingsKv(_db);

  static const lastActiveItemKey = 'last_playback_item_id';

  final AppDatabase _db;
  final _SettingsKv _kv;

  Future<void> save({
    required String itemId,
    required String trackId,
    required int positionMs,
    required double speed,
    String? displayTitle,
    String? subtitle,
    int? durationMs,
  }) async {
    await _db
        .into(_db.playbackStates)
        .insertOnConflictUpdate(
          PlaybackStatesCompanion.insert(
            itemId: itemId,
            trackId: trackId,
            positionMs: positionMs,
            speed: Value(speed),
            displayTitle: Value(displayTitle),
            subtitle: Value(subtitle),
            durationMs: Value(durationMs),
          ),
        );
    await _kv.set(lastActiveItemKey, itemId);
  }

  Future<String?> getLastActiveItemId() => _kv.get(lastActiveItemKey);

  Future<SavedPlaybackState?> get(String itemId) async {
    final row = await (_db.select(
      _db.playbackStates,
    )..where((t) => t.itemId.equals(itemId))).getSingleOrNull();
    if (row == null) return null;
    return (
      trackId: row.trackId,
      positionMs: row.positionMs,
      speed: row.speed,
      displayTitle: row.displayTitle,
      subtitle: row.subtitle,
      durationMs: row.durationMs,
    );
  }

  Future<void> clear(String itemId) async {
    await (_db.delete(
      _db.playbackStates,
    )..where((t) => t.itemId.equals(itemId))).go();
    final lastActive = await getLastActiveItemId();
    if (lastActive == itemId) await _kv.remove(lastActiveItemKey);
  }
}

class BrowsePrefsDao {
  BrowsePrefsDao(AppDatabase db) : _kv = _SettingsKv(db);

  static const browsePathKey = 'library_browse_path';
  static const albumDetailIdKey = 'library_album_detail_id';
  static const playerPanelExpandedKey = 'player_panel_expanded';
  static const settingsOverlayOpenKey = 'settings_overlay_open';
  static const favoriteFoldersKey = 'favorite_folders';
  static const playbackQueueKey = 'playback_queue';

  final _SettingsKv _kv;

  Future<void> setBrowsePath(String? path) async {
    if (path == null) {
      await _kv.remove(browsePathKey);
      return;
    }
    await _kv.set(browsePathKey, normalizeLibraryPath(path));
  }

  Future<String?> getBrowsePath() async {
    final value = await _kv.get(browsePathKey);
    if (value == null || value.isEmpty) return null;
    return normalizeLibraryPath(value);
  }

  Future<void> setAlbumDetailId(String? albumId) async {
    if (albumId == null) {
      await _kv.remove(albumDetailIdKey);
      return;
    }
    await _kv.set(albumDetailIdKey, albumId);
  }

  Future<String?> getAlbumDetailId() async {
    final value = await _kv.get(albumDetailIdKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> setPlayerPanelExpanded(bool expanded) async {
    if (!expanded) {
      await _kv.remove(playerPanelExpandedKey);
      return;
    }
    await _kv.set(playerPanelExpandedKey, 'true');
  }

  Future<bool> getPlayerPanelExpanded() async {
    final value = await _kv.get(playerPanelExpandedKey);
    return value == 'true';
  }

  Future<void> setSettingsOverlayOpen(bool open) async {
    if (!open) {
      await _kv.remove(settingsOverlayOpenKey);
      return;
    }
    await _kv.set(settingsOverlayOpenKey, 'true');
  }

  Future<bool> getSettingsOverlayOpen() async {
    final value = await _kv.get(settingsOverlayOpenKey);
    return value == 'true';
  }

  Future<List<String>> getFavoriteFolders() async {
    final raw = await _kv.get(favoriteFoldersKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final paths = <String>[];
    for (final item in decoded) {
      if (item is! String || item.isEmpty) continue;
      final normalized = normalizeLibraryPath(item);
      if (!paths.contains(normalized)) paths.add(normalized);
    }
    return paths;
  }

  Future<void> setFavoriteFolders(List<String> paths) => _kv.set(
    favoriteFoldersKey,
    jsonEncode([for (final path in paths) normalizeLibraryPath(path)]),
  );

  Future<({List<String> paths, int index})> getPlaybackQueue() async {
    final raw = await _kv.get(playbackQueueKey);
    if (raw == null || raw.isEmpty) return (paths: <String>[], index: 0);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return (paths: <String>[], index: 0);
    final rawPaths = decoded['paths'];
    final paths = <String>[];
    if (rawPaths is List) {
      for (final item in rawPaths) {
        if (item is! String || item.isEmpty) continue;
        final normalized = normalizeLibraryPath(item);
        if (!paths.contains(normalized)) paths.add(normalized);
      }
    }
    final rawIndex = decoded['index'];
    final index = rawIndex is int ? rawIndex : 0;
    if (paths.isEmpty) return (paths: paths, index: 0);
    return (paths: paths, index: index.clamp(0, paths.length - 1));
  }

  Future<void> setPlaybackQueue({
    required List<String> paths,
    required int index,
  }) async {
    final normalized = <String>[];
    for (final path in paths) {
      final next = normalizeLibraryPath(path);
      if (!normalized.contains(next)) normalized.add(next);
    }
    final storedIndex = normalized.isEmpty
        ? 0
        : index.clamp(0, normalized.length - 1);
    await _kv.set(
      playbackQueueKey,
      jsonEncode({'paths': normalized, 'index': storedIndex}),
    );
  }
}

class AppPrefsDao {
  AppPrefsDao(AppDatabase db) : _kv = _SettingsKv(db);

  static const equalizerModeKey = 'equalizer_mode';
  static const equalizerPresetKey = 'equalizer_preset';
  static const equalizerBandsKey = 'equalizer_bands';
  static const themePreferenceKey = 'theme_preference';
  static const localePreferenceKey = 'locale_preference';

  final _SettingsKv _kv;

  Future<EqualizerSettings> getEqualizerSettings() async {
    final modeValue = await _kv.get(equalizerModeKey);
    final presetValue = await _kv.get(equalizerPresetKey);
    final bandsValue = await _kv.get(equalizerBandsKey);

    if (modeValue != null) {
      final mode = EqualizerMode.values.firstWhere(
        (m) => m.name == modeValue,
        orElse: () => EqualizerMode.off,
      );
      return EqualizerSettings(
        mode: mode,
        preset: EqualizerPresetStorage.fromStorage(presetValue),
        bands: parseEqualizerBandsJson(bandsValue),
      );
    }

    return EqualizerSettings.fromPreset(
      EqualizerPresetStorage.fromStorage(presetValue),
    );
  }

  Future<void> setEqualizerSettings(EqualizerSettings settings) async {
    await _kv.set(equalizerModeKey, settings.mode.name);
    await _kv.set(equalizerPresetKey, settings.preset.name);
    await _kv.set(equalizerBandsKey, encodeEqualizerBandsJson(settings.bands));
  }

  Future<ThemePreference> getThemePreference() async =>
      ThemePreference.fromStorage(await _kv.get(themePreferenceKey));

  Future<void> setThemePreference(ThemePreference preference) =>
      _kv.set(themePreferenceKey, preference.name);

  Future<LocalePreference> getLocalePreference() async =>
      LocalePreference.fromStorage(await _kv.get(localePreferenceKey));

  Future<void> setLocalePreference(LocalePreference preference) =>
      _kv.set(localePreferenceKey, preference.toStorage());
}

class PlaylistRegistryDao {
  PlaylistRegistryDao(this._db);

  static const prefix = 'app_created_playlist:';

  final AppDatabase _db;

  String _key(String path) => '$prefix${normalizeLibraryPath(path)}';

  Future<void> mark(String path) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _key(path), value: '1'),
        );
  }

  Future<void> unmark(String path) async {
    await (_db.delete(
      _db.appSettings,
    )..where((t) => t.key.equals(_key(path)))).go();
  }

  Future<bool> isMarked(String path) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(_key(path)))).getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> allPaths() async {
    final rows = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.like('$prefix%'))).get();
    return {for (final row in rows) row.key.substring(prefix.length)};
  }
}

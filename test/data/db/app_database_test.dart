/// Drift AppDatabase schema creation and LibraryStorageService persistence.
///
/// Evidence:
/// - `creates expected tables and persists library root`
/// - `persists playback state`
/// - `reset keeps library folders when asked`
/// - `reset removes library folders when asked`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;
    late LibraryStorageService storage;

    setUp(() {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('creates expected tables and persists library root', () async {
      await storage.addLibraryRoot('/music');
      final roots = await storage.getLibraryRoots();
      expect(roots, ['/music']);
    });

    test('persists playback state', () async {
      await storage.savePlaybackState(
        itemId: 'album-1',
        trackId: 'track-1',
        positionMs: 45000,
        speed: 1.25,
        displayTitle: 'Chapter 1',
        subtitle: 'Author',
        durationMs: 180000,
      );
      final state = await storage.getPlaybackState('album-1');
      expect(state?.trackId, 'track-1');
      expect(state?.positionMs, 45000);
      expect(state?.speed, 1.25);
      expect(state?.displayTitle, 'Chapter 1');
      expect(state?.subtitle, 'Author');
      expect(state?.durationMs, 180000);
    });

    test('reset keeps library folders when asked', () async {
      await storage.addLibraryRoot('/music');
      await storage.savePlaybackState(
        itemId: 'album-1',
        trackId: 'track-1',
        positionMs: 1000,
        speed: 1,
      );
      await storage.setThemePreference(ThemePreference.dark);
      await storage.setFavoriteFolders(['/music/Author']);

      await storage.resetDatabase(removeLibraryFolders: false);

      expect(await storage.getLibraryRoots(), ['/music']);
      expect(await storage.getPlaybackState('album-1'), isNull);
      expect(await storage.getThemePreference(), ThemePreference.system);
      expect(await storage.getFavoriteFolders(), isEmpty);
    });

    test('reset removes library folders when asked', () async {
      await storage.addLibraryRoot('/music');
      await storage.savePlaybackState(
        itemId: 'album-1',
        trackId: 'track-1',
        positionMs: 1000,
        speed: 1,
      );

      await storage.resetDatabase(removeLibraryFolders: true);

      expect(await storage.getLibraryRoots(), isEmpty);
      expect(await storage.getPlaybackState('album-1'), isNull);
    });
  });
}

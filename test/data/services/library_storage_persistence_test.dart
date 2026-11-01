/// LibraryStorageService persistence for playback session and UI navigation keys.
///
/// Evidence:
/// - `savePlaybackState records last active item id`
/// - `last active item id updates when a new session is saved`
/// - `getLastActiveItemId returns null when nothing was saved`
/// - `setLibraryBrowsePath stores and clears browse location`
/// - `setLibraryAlbumDetailId stores and clears open album`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';

void main() {
  group('LibraryStorageService playback persistence', () {
    late AppDatabase db;
    late LibraryStorageService storage;

    setUp(() {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('savePlaybackState records last active item id', () async {
      await storage.savePlaybackState(
        itemId: 'dir:/music/book',
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      expect(await storage.getLastActiveItemId(), 'dir:/music/book');
      final saved = await storage.getPlaybackState('dir:/music/book');
      expect(saved?.trackId, '/music/book/ch02.mp3');
      expect(saved?.positionMs, 45000);
      expect(saved?.speed, 1.25);
    });

    test('last active item id updates when a new session is saved', () async {
      await storage.savePlaybackState(
        itemId: 'dir:/music/book-a',
        trackId: '/music/book-a/ch01.mp3',
        positionMs: 1000,
        speed: 1.0,
      );
      await storage.savePlaybackState(
        itemId: 'folder:/music/podcasts',
        trackId: '/music/podcasts/ep01.mp3',
        positionMs: 2000,
        speed: 1.5,
      );

      expect(await storage.getLastActiveItemId(), 'folder:/music/podcasts');
    });

    test('getLastActiveItemId returns null when nothing was saved', () async {
      expect(await storage.getLastActiveItemId(), isNull);
    });

    test('setLibraryBrowsePath stores and clears browse location', () async {
      await storage.setLibraryBrowsePath('/music/Author/Book');
      expect(await storage.getLibraryBrowsePath(), '/music/Author/Book');

      await storage.setLibraryBrowsePath(null);
      expect(await storage.getLibraryBrowsePath(), isNull);
    });

    test('setLibraryAlbumDetailId stores and clears open album', () async {
      await storage.setLibraryAlbumDetailId('dir:/music/book');
      expect(await storage.getLibraryAlbumDetailId(), 'dir:/music/book');

      await storage.setLibraryAlbumDetailId(null);
      expect(await storage.getLibraryAlbumDetailId(), isNull);
    });
  });
}

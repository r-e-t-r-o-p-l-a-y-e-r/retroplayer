/// PlaybackRepository shutdown progress save and restoreLastSession.
///
/// Evidence:
/// - `saves progress before stopping playback`
/// - `is idempotent when shutdown is called twice`
/// - `does not persist when active item is unset`
/// - `stop before shutdown loses progress (regression guard)`
/// - `stopPlaybackForRecentsDismiss saves progress and stops`
/// - `restores album queue paused at saved position`
/// - `restores folder playback paused at saved position`
/// - `restores composed queue paused at saved position`
/// - `restores single-track playback`
/// - `returns false when no saved session exists`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';
import '../../helpers/test_library_repository.dart';

void main() {
  group('PlaybackRepository shutdown', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late RecordingPlayback playback;
    late PlaybackRepository repository;

    const albumId = 'dir:/music/book';
    final tracks = [
      testTrack(
        filePath: '/music/book/ch01.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 1),
      ),
      testTrack(
        filePath: '/music/book/ch02.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 2),
      ),
    ];

    setUp(() async {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      playback = RecordingPlayback();
      repository = PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      );
      repository.setActiveItemId(albumId);
      playback.currentTrackOverride = tracks[1];
      playback.positionOverride = const Duration(seconds: 45);
      playback.speedOverride = 1.25;
      await playback.setQueue(
        tracks,
        startIndex: 1,
        initialPosition: const Duration(seconds: 45),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('saves progress before stopping playback', () async {
      await repository.shutdown();

      final saved = await storage.getPlaybackState(albumId);
      expect(saved?.trackId, '/music/book/ch02.mp3');
      expect(saved?.positionMs, 45000);
      expect(saved?.speed, 1.25);
      expect(await storage.getLastActiveItemId(), albumId);
      expect(playback.stopCalled, isTrue);
      expect(playback.disposeCalled, isTrue);
    });

    test('is idempotent when shutdown is called twice', () async {
      await repository.shutdown();
      await repository.shutdown();

      expect(playback.disposeCalled, isTrue);
    });

    test('does not persist when active item is unset', () async {
      repository.setActiveItemId(null);
      await repository.shutdown();

      expect(await storage.getPlaybackState(albumId), isNull);
    });

    test('stop before shutdown loses progress (regression guard)', () async {
      await repository.stop();
      await repository.shutdown();

      expect(await storage.getPlaybackState(albumId), isNull);
    });

    test('stopPlaybackForRecentsDismiss saves progress and stops', () async {
      await repository.stopPlaybackForRecentsDismiss();

      final saved = await storage.getPlaybackState(albumId);
      expect(saved?.trackId, '/music/book/ch02.mp3');
      expect(saved?.positionMs, 45000);
      expect(playback.stopCalled, isTrue);
    });
  });

  group('PlaybackRepository restoreLastSession', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late RecordingPlayback playback;
    late PlaybackRepository repository;
    late LibraryRepository library;

    const albumId = 'dir:/music/book';
    final tracks = [
      testTrack(
        filePath: '/music/book/ch01.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 1),
      ),
      testTrack(
        filePath: '/music/book/ch02.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 2),
      ),
    ];

    final album = AudioAlbum(
      id: albumId,
      title: 'Book',
      tracks: tracks,
      source: AlbumSource.directory,
      groupingKey: albumId,
    );

    setUp(() {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      playback = RecordingPlayback();
      repository = PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      );
      library = testLibraryRepository(storage);
    });

    tearDown(() async {
      await db.close();
    });

    test('restores album queue paused at saved position', () async {
      library.seedDirectory('/music/book', [LibraryAlbumItem(album: album)]);

      await storage.savePlaybackState(
        itemId: albumId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      final restored = await repository.restoreLastSession(library);

      expect(restored, isTrue);
      expect(repository.activeItemId, albumId);
      expect(playback.playCalled, isFalse);
      expect(playback.lastStartIndex, 1);
      expect(playback.lastInitialPosition, const Duration(seconds: 45));
      expect(playback.lastSpeed, 1.25);
    });

    test('restores folder playback paused at saved position', () async {
      const folderPath = '/music/book';
      final folderId = PlaybackItem.folderId(folderPath);

      library.seedTracksUnderFolder(folderPath, tracks);

      await storage.savePlaybackState(
        itemId: folderId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 90000,
        speed: 1.5,
      );

      final restored = await repository.restoreLastSession(library);

      expect(restored, isTrue);
      expect(repository.activeItemId, folderId);
      expect(playback.playCalled, isFalse);
      expect(playback.lastStartIndex, 1);
      expect(playback.lastInitialPosition, const Duration(minutes: 1, seconds: 30));
      expect(playback.lastSpeed, 1.5);
    });

    test('restores composed queue paused at saved position', () async {
      library.seedTracksUnderFolder('/music/book', tracks);
      await storage.setPlaybackQueue(
        paths: ['/music/book/ch01.mp3', '/music/book/ch02.mp3'],
        index: 1,
      );
      await storage.savePlaybackState(
        itemId: PlaybackItem.composedQueueId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      final restored = await repository.restoreLastSession(library);

      expect(restored, isTrue);
      expect(repository.activeItemId, PlaybackItem.composedQueueId);
      expect(playback.playCalled, isFalse);
      expect(playback.lastStartIndex, 1);
      expect(playback.lastInitialPosition, const Duration(seconds: 45));
      expect(playback.lastSpeed, 1.25);
      final stored = await storage.getPlaybackQueue();
      expect(stored.paths, ['/music/book/ch01.mp3', '/music/book/ch02.mp3']);
      expect(stored.index, 1);

      await repository.playFolder('/music/book', tracks);

      final afterFolder = await storage.getPlaybackQueue();
      expect(afterFolder.paths, stored.paths);
      expect(afterFolder.index, 1);
      expect(repository.activeItemId, PlaybackItem.folderId('/music/book'));
    });

    test('restores single-track playback', () async {
      const trackId = '/music/book/ch01.mp3';

      library.seedDirectory(
        '/music/book',
        [LibraryItem.track(track: tracks.first)],
      );

      await storage.savePlaybackState(
        itemId: trackId,
        trackId: trackId,
        positionMs: 15000,
        speed: 1.0,
      );

      final restored = await repository.restoreLastSession(library);

      expect(restored, isTrue);
      expect(playback.playCalled, isFalse);
      expect(playback.lastQueue, hasLength(1));
      expect(playback.lastInitialPosition, const Duration(seconds: 15));
    });

    test('returns false when no saved session exists', () async {
      final restored = await repository.restoreLastSession(library);

      expect(restored, isFalse);
      expect(playback.lastQueue, isNull);
    });
  });
}

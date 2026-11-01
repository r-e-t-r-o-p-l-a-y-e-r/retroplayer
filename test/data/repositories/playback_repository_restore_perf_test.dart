/// Restore path work units for cold start (queue size, scans when uncached).
///
/// Evidence:
/// - `restoreLastSession loads full 23-track queue in one setQueue`
/// - `findByIdAsync scans album directory when cache is cold`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';

import '../../helpers/cold_start_fixture.dart';
import '../../helpers/counting_library_scanner.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/test_library_repository.dart';

void main() {
  group('PlaybackRepository restore perf structure', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late RecordingPlayback playback;
    late PlaybackRepository repository;

    setUp(() async {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      playback = RecordingPlayback();
      repository = PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('restoreLastSession loads full 23-track queue in one setQueue', () async {
      final fixture = albumTracksFixture(count: 23);
      final library = testLibraryRepository(storage);
      library.seedDirectory(
        fixture.directoryPath,
        [LibraryAlbumItem(album: fixture.album)],
      );
      await storage.addLibraryRoot('/music');

      await storage.savePlaybackState(
        itemId: fixture.albumId,
        trackId: fixture.tracks[11].filePath,
        positionMs: 45000,
        speed: 1.25,
      );

      final restored = await repository.restoreLastSession(library);

      expect(restored, isTrue);
      expect(playback.setQueueCalls, 1);
      expect(playback.lastQueue?.length, 23);
      expect(playback.lastStartIndex, 11);
      expect(playback.lastInitialPosition, const Duration(seconds: 45));
    });

    test('findByIdAsync scans album directory when cache is cold', () async {
      final fixture = albumTracksFixture(count: 23);
      final paths = [
        for (final track in fixture.tracks) track.filePath,
      ];
      final scanner = CountingLibraryScanner(
        audioFilesByDirectory: {fixture.directoryPath: paths},
      );
      final library = testLibraryRepositoryWithScanner(storage, scanner);
      await storage.addLibraryRoot(fixture.directoryPath);

      final item = await library.findByIdAsync(fixture.albumId);

      expect(item, isNotNull);
      expect(scanner.shallowScanStarts, greaterThanOrEqualTo(1));
      expect(scanner.trackFromPathCalls, 23);
    });
  });
}

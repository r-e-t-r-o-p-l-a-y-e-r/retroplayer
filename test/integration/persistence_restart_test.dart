/// Playback persistence across simulated process restart.
///
/// Evidence:
/// - `shutdown in session 1 restores paused queue in session 2`
/// - `23-track album restores paused at saved index after restart`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import '../helpers/test_library_repository.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import '../helpers/cold_start_fixture.dart';
import '../helpers/recording_playback.dart';
import '../helpers/track_factory.dart';

/// Simulates quitting the app (DB close) and relaunching with a new process.
void main() {
  group('persistence across app restart', () {
    late File dbFile;

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
        durationMs: 360000,
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
      dbFile = File(
        '${Directory.systemTemp.path}/rpc_restart_${DateTime.now().microsecondsSinceEpoch}.db',
      );
    });

    tearDown(() {
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
    });

    test('shutdown in session 1 restores paused queue in session 2', () async {
      final db1 = AppDatabase.openAtPath(dbFile.path);
      final storage1 = LibraryStorageService(db1);
      final playback1 = RecordingPlayback();
      final repository1 = PlaybackRepository(
        playbackService: playback1,
        storageService: storage1,
      );

      repository1.setActiveItemId(albumId);
      playback1.currentTrackOverride = tracks[1];
      playback1.positionOverride = const Duration(seconds: 45);
      playback1.speedOverride = 1.25;
      await playback1.setQueue(
        tracks,
        startIndex: 1,
        initialPosition: const Duration(seconds: 45),
      );

      await repository1.shutdown();
      await db1.close();

      final db2 = AppDatabase.openAtPath(dbFile.path);
      addTearDown(db2.close);
      final storage2 = LibraryStorageService(db2);
      final playback2 = RecordingPlayback();
      final repository2 = PlaybackRepository(
        playbackService: playback2,
        storageService: storage2,
      );

      expect(await storage2.getLastActiveItemId(), albumId);

      final library2 = testLibraryRepository(storage2);
      library2.seedDirectory('/music/book', [LibraryAlbumItem(album: album)]);

      final restored = await repository2.restoreLastSession(library2);

      expect(restored, isTrue);
      expect(playback2.playCalled, isFalse);
      expect(playback2.lastStartIndex, 1);
      expect(playback2.lastInitialPosition, const Duration(seconds: 45));
      expect(playback2.lastSpeed, 1.25);
      expect(playback2.currentTrack?.id, '/music/book/ch02.mp3');
    });

    test('23-track album restores paused at saved index after restart', () async {
      final fixture = albumTracksFixture(count: 23);
      final db1 = AppDatabase.openAtPath(dbFile.path);
      final storage1 = LibraryStorageService(db1);
      final playback1 = RecordingPlayback();
      final repository1 = PlaybackRepository(
        playbackService: playback1,
        storageService: storage1,
      );

      await playback1.setQueue(
        fixture.tracks,
        startIndex: 11,
        initialPosition: const Duration(seconds: 45),
      );
      repository1.setActiveItemId(fixture.albumId);
      await repository1.saveProgress(fixture.albumId);
      await db1.close();

      final db2 = AppDatabase.openAtPath(dbFile.path);
      addTearDown(db2.close);
      final storage2 = LibraryStorageService(db2);
      final playback2 = RecordingPlayback();
      final repository2 = PlaybackRepository(
        playbackService: playback2,
        storageService: storage2,
      );

      final library2 = testLibraryRepository(storage2);
      library2.seedDirectory(
        fixture.directoryPath,
        [LibraryAlbumItem(album: fixture.album)],
      );

      final restored = await repository2.restoreLastSession(library2);

      expect(restored, isTrue);
      expect(playback2.setQueueCalls, 1);
      expect(playback2.lastQueue?.length, 23);
      expect(playback2.lastStartIndex, 11);
      expect(playback2.lastInitialPosition, const Duration(seconds: 45));
      expect(playback2.currentTrack?.filePath, fixture.tracks[11].filePath);
    });
  });
}

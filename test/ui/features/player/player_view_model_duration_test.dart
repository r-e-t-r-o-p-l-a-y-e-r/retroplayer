/// PlayerViewModel keeps engine-reported duration across track changes when
/// scan metadata has no [AudioTrack.durationMs] (language-course MP3s).
///
/// Evidence:
/// - `duration survives currentTrackStream when tags lack durationMs`
/// - `skipNext does not zero duration when tags lack durationMs`
/// - `second playAlbumTrack on same track is a no-op for timing`
/// - `restoreLastSession keeps position and engine duration without tag length`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/track_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerViewModel duration without tag length', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late RecordingPlayback playback;
    late PlaybackRepository repository;
    late LibraryRepository libraryRepository;
    late PlayerViewModel viewModel;

    const albumId = 'dir:/course/audio';
    final ch1 = testTrack(
      filePath: '/course/audio/lesson01.mp3',
      directoryPath: '/course/audio',
      metadata: const TrackMetadata(title: 'Lesson 1'),
      durationMs: null,
    );
    final ch2 = testTrack(
      filePath: '/course/audio/lesson02.mp3',
      directoryPath: '/course/audio',
      metadata: const TrackMetadata(title: 'Lesson 2'),
      durationMs: null,
    );

    final album = AudioAlbum(
      id: albumId,
      title: 'Course',
      tracks: [ch1, ch2],
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
      libraryRepository = testLibraryRepository(storage);
      viewModel = PlayerViewModel(playbackRepository: repository);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> drainMicrotasks() async {
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
    }

    test('duration survives currentTrackStream when tags lack durationMs',
        () async {
      const engineDuration = Duration(minutes: 12, seconds: 34);

      await viewModel.playAlbumTrack(album, ch1);
      playback.emitDuration(engineDuration);
      await drainMicrotasks();

      expect(viewModel.duration, engineDuration);

      playback.emitTrack(ch2);
      await drainMicrotasks();

      expect(viewModel.duration, engineDuration);
      expect(viewModel.title, 'Lesson 2');
    });

    test('skipNext does not zero duration when tags lack durationMs', () async {
      const engineDuration = Duration(minutes: 5);

      await viewModel.playAlbumTrack(album, ch1);
      playback.emitDuration(engineDuration);
      await drainMicrotasks();

      await viewModel.skipNext();
      await drainMicrotasks();

      expect(viewModel.duration, engineDuration);
      expect(viewModel.hasTrack, isTrue);
    });

    test('restoreLastSession keeps position and engine duration without tag length',
        () async {
      const engineDuration = Duration(minutes: 9);

      await storage.savePlaybackState(
        itemId: albumId,
        trackId: ch1.filePath,
        positionMs: 125000,
        speed: 1.0,
        displayTitle: 'Lesson 1',
        durationMs: null,
      );

      libraryRepository.seedDirectory(
        '/course/audio',
        [LibraryAlbumItem(album: album)],
      );

      final coldPlayback = RecordingPlayback()
        ..durationOnSetQueue = engineDuration;
      final coldVm = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: coldPlayback,
          storageService: storage,
        ),
      );

      await coldVm.restoreLastSession(libraryRepository);
      await drainMicrotasks();

      coldPlayback.emitPosition(Duration.zero);
      await drainMicrotasks();

      expect(coldVm.hasTrack, isTrue);
      expect(coldVm.hasSession, isTrue);
      expect(coldVm.position, const Duration(seconds: 125));
      expect(coldVm.duration, engineDuration);

      coldPlayback.emitPosition(const Duration(seconds: 125));
      await drainMicrotasks();
      expect(coldVm.position, const Duration(seconds: 125));
      coldVm.dispose();
    });

    test('second playAlbumTrack on same track keeps duration and position',
        () async {
      const engineDuration = Duration(minutes: 8);
      const midTrack = Duration(minutes: 2);

      await viewModel.playAlbumTrack(album, ch1);
      playback.emitDuration(engineDuration);
      playback.emitPosition(midTrack);
      await drainMicrotasks();

      await viewModel.playAlbumTrack(album, ch1);
      await drainMicrotasks();

      expect(viewModel.duration, engineDuration);
      expect(viewModel.position, midTrack);
      expect(playback.seeks, isEmpty);
    });
  });
}

/// PlayerViewModel restoreLastSession UI fields and active-item registration.
///
/// Evidence:
/// - `restoreLastSession exposes saved track in player UI state`
/// - `playAlbum registers active item for shutdown save`
/// - `stopAndClearIfPlayingPlaylist stops only the matching playlist`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerViewModel persistence', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late RecordingPlayback playback;
    late PlaybackRepository repository;
    late LibraryRepository libraryRepository;
    late PlayerViewModel viewModel;

    const albumId = 'dir:/music/book';
    final tracks = [
      testTrack(
        filePath: '/music/book/ch01.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(
          trackNumber: 1,
          title: 'Chapter 1',
          artist: 'Author',
        ),
      ),
      testTrack(
        filePath: '/music/book/ch02.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(
          trackNumber: 2,
          title: 'Chapter 2',
          artist: 'Author',
        ),
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

    test('restoreLastSession exposes saved track in player UI state', () async {
      await storage.savePlaybackState(
        itemId: albumId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      libraryRepository.seedDirectory(
        '/music/book',
        [LibraryAlbumItem(album: album)],
      );

      await viewModel.restoreLastSession(libraryRepository);

      expect(viewModel.hasTrack, isTrue);
      expect(viewModel.title, 'Chapter 2');
      expect(viewModel.subtitle, 'Author');
      expect(viewModel.position, const Duration(seconds: 45));
      expect(viewModel.speed, 1.25);
      expect(viewModel.isPlaying, isFalse);
      expect(viewModel.currentItemId, albumId);
    });

    test('playAlbum registers active item for shutdown save', () async {
      await viewModel.playAlbum(album);

      expect(repository.activeItemId, albumId);
    });

    test('stopAndClearIfPlayingPlaylist stops only the matching playlist', () async {
      const playlistPath = '/music/road.m3u';
      final playlist = PlaylistFile(
        filePath: playlistPath,
        entryPaths: [tracks.first.filePath],
      );
      await viewModel.playPlaylist(playlist, tracks);
      expect(viewModel.hasTrack, isTrue);

      await viewModel.stopAndClearIfPlayingPlaylist('/music/other.m3u');
      expect(viewModel.hasTrack, isTrue);

      await viewModel.stopAndClearIfPlayingPlaylist(playlistPath);
      expect(viewModel.hasTrack, isFalse);
      expect(viewModel.currentItemId, isNull);
      expect(await storage.getLastActiveItemId(), isNull);
    });
  });
}

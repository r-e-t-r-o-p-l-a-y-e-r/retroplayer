/// AppSessionBootstrap restores player without forcing the library tab.
///
/// Evidence:
/// - `AppSessionBootstrap restores player without opening library tab`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/ui/core/app_session_bootstrap.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/views/player_view.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';

void main() {
  testWidgets(
    'AppSessionBootstrap restores player without opening library tab',
    (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final db = AppDatabase.inMemory();
      addTearDown(() async => db.close());
      final storage = LibraryStorageService(db);
      final playback = RecordingPlayback();
      const albumId = 'dir:/music/book';
      final album = AudioAlbum(
        id: albumId,
        title: 'Book',
        tracks: [
          testTrack(
            filePath: '/music/book/ch02.mp3',
            directoryPath: '/music/book',
            metadata: const TrackMetadata(trackNumber: 2, title: 'Chapter 2'),
          ),
        ],
        source: AlbumSource.directory,
        groupingKey: albumId,
      );
      final libraryItems = [LibraryAlbumItem(album: album)];

      final libraryRepository = testLibraryRepository(storage);
      libraryRepository.seedDirectory('/music/book', libraryItems);
      libraryRepository.seedDirectory('/music', const []);

      await storage.addLibraryRoot('/music');
      await storage.savePlaybackState(
        itemId: albumId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
      final playerVm = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: playback,
          storageService: storage,
        ),
      );

      await tester.pumpWidget(
        wrapWithL10n(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: libraryVm),
              ChangeNotifierProvider(create: (_) => testPanelVm()),
              ChangeNotifierProvider.value(value: playerVm),
              Provider.value(value: libraryRepository),
              Provider.value(
                value: EqualizerService(storage, playbackService: playback),
              ),
            ],
            child: const AppSessionBootstrap(child: PlayerView()),
          ),
        ),
      );

      await pumpFrames(tester, count: 10);

      expect(find.text('Chapter 2'), findsWidgets);
      expect(find.text('book'), findsOneWidget);
      expect(
        find.text('Select something from your library to play.'),
        findsNothing,
      );
    },
  );
}

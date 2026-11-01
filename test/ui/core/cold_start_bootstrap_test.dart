/// Cold-start bootstrap structure: parallel restore and snapshot-first dock.
///
/// Evidence:
/// - `restore starts while library ensureLoaded is still pending`
/// - `player title from snapshot before setQueue completes`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/ui/core/app_session_bootstrap.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/views/player_view.dart';

import '../../helpers/cold_start_fixture.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/slow_completing_playback.dart';
import '../../helpers/slow_library_view_model.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';

void main() {
  testWidgets('restore starts while library ensureLoaded is still pending', (
    tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final fixture = albumTracksFixture(count: 23);
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());
    final storage = LibraryStorageService(db);
    final playback = SlowCompletingPlayback();
    final libraryRepository = testLibraryRepository(storage);
    libraryRepository.seedDirectory(
      fixture.directoryPath,
      [LibraryAlbumItem(album: fixture.album)],
    );
    libraryRepository.seedDirectory('/music', const []);

    await storage.addLibraryRoot('/music');
    await storage.savePlaybackState(
      itemId: fixture.albumId,
      trackId: fixture.tracks[11].filePath,
      positionMs: 45000,
      speed: 1.0,
      displayTitle: 'Chapter 12',
      subtitle: 'Test Author',
      durationMs: 120000,
    );

    final libraryVm = SlowLibraryViewModel(
      libraryRepository: libraryRepository,
    );
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
            ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
            ChangeNotifierProvider<PlayerViewModel>.value(value: playerVm),
            Provider.value(value: libraryRepository),
            Provider.value(
              value: EqualizerService(storage, playbackService: playback),
            ),
          ],
          child: const AppSessionBootstrap(child: PlayerView()),
        ),
      ),
    );

    await tester.pump();
    expect(libraryVm.loadStarted, isTrue);
    expect(playback.setQueueStarted, isTrue);

    libraryVm.releaseLoadGate();
    await pumpFrames(tester, count: 15);

    expect(playback.setQueueStarted, isTrue);
    expect(libraryVm.isLoaded, isTrue);
  });

  testWidgets('player title from snapshot before setQueue completes', (
    tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final fixture = albumTracksFixture(count: 23);
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());
    final storage = LibraryStorageService(db);
    final playback = SlowCompletingPlayback();
    final libraryRepository = testLibraryRepository(storage);
    libraryRepository.seedDirectory(
      fixture.directoryPath,
      [LibraryAlbumItem(album: fixture.album)],
    );
    libraryRepository.seedDirectory('/music', const []);

    await storage.addLibraryRoot('/music');
    await storage.savePlaybackState(
      itemId: fixture.albumId,
      trackId: fixture.tracks[11].filePath,
      positionMs: 45000,
      speed: 1.0,
      displayTitle: 'Chapter 12',
      subtitle: 'Test Author',
      durationMs: 120000,
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
            ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
            ChangeNotifierProvider<PlayerViewModel>.value(value: playerVm),
            Provider.value(value: libraryRepository),
            Provider.value(
              value: EqualizerService(storage, playbackService: playback),
            ),
          ],
          child: const AppSessionBootstrap(child: PlayerView()),
        ),
      ),
    );

    await pumpFrames(tester, count: 15);
    expect(playback.setQueueStarted, isTrue);
    expect(find.text('Chapter 12'), findsWidgets);
    expect(playerVm.hasSession, isTrue);
    expect(playerVm.hasTrack, isFalse);

    playback.completeSetQueue();
    await pumpFrames(tester, count: 10);

    expect(find.text('Chapter 12'), findsWidgets);
    expect(playerVm.hasTrack, isTrue);
    expect(playback.lastQueue?.length, 23);
  });
}

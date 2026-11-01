/// Optional device screenshots (experimental). Prefer widget goldens:
///   ./scripts/capture-tutorial-screenshots.sh --update
///
/// Run on device:
///   flutter test integration_test/tutorial_screenshots_test.dart -d `<serial>`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../test/helpers/library_test_seed.dart';
import '../test/helpers/pump_app.dart';
import '../test/helpers/recording_playback.dart';
import '../test/helpers/test_library_repository.dart';
import '../test/helpers/test_panel.dart';
import '../test/helpers/track_factory.dart';

AudioAlbum _demoAlbum() {
  return AudioAlbum(
    id: 'dir:/music/Demo Artist/Demo Album',
    title: 'Demo Album',
    tracks: [
      testTrack(
        id: 't1',
        filePath: '/music/Demo Artist/Demo Album/01-opening.mp3',
        directoryPath: '/music/Demo Artist/Demo Album',
        metadata: const TrackMetadata(
          trackNumber: 1,
          title: 'Opening',
          artist: 'Demo Artist',
          album: 'Demo Album',
        ),
      ),
      testTrack(
        id: 't2',
        filePath: '/music/Demo Artist/Demo Album/02-middle.mp3',
        directoryPath: '/music/Demo Artist/Demo Album',
        metadata: const TrackMetadata(
          trackNumber: 2,
          title: 'Middle',
          artist: 'Demo Artist',
          album: 'Demo Album',
        ),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/Demo Artist/Demo Album',
  );
}

Future<void> _pumpShell(WidgetTester tester) async {
  final db = AppDatabase.inMemory();
  final storage = LibraryStorageService(db);
  final album = _demoAlbum();
  final libraryRepository = testLibraryRepository(storage);
  await storage.addLibraryRoot('/music');
  seedPlayerBreadcrumbHierarchy(libraryRepository, album);

  final panelVm = testPanelVm();
  final playerVm = PlayerViewModel(
    playbackRepository: PlaybackRepository(
      playbackService: RecordingPlayback(),
      storageService: storage,
    ),
  );
  final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
  await libraryVm.load();
  await playerVm.playAlbumTrack(album, album.tracks.first);

  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: libraryRepository),
        ChangeNotifierProvider.value(value: libraryVm),
        ChangeNotifierProvider.value(value: playerVm),
        ChangeNotifierProvider.value(value: panelVm),
        ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ChangeNotifierProvider(
          create: (_) => EqualizerViewModel(
            equalizerService: EqualizerService(storage),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(storageService: storage),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleViewModel(storageService: storage),
        ),
      ],
      child: wrapRouterWithL10n(
        router: AppRouter.create(initialLocation: AppRouter.library),
      ),
    ),
  );
  await pumpFrames(tester, count: 30);
}

Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await pumpFrames(tester, count: 15);
  await binding.convertFlutterSurfaceToImage();
  await binding.takeScreenshot(name);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture tutorial screenshots', (tester) async {
    await _pumpShell(tester);
    await _shot(binding, tester, '01-library');

    await tester.tap(find.byType(PlayerDragHandle).first);
    await pumpFrames(tester, count: 25);
    await _shot(binding, tester, '02-mini-player');

    await tester.tap(find.byIcon(Icons.expand_less));
    await pumpFrames(tester, count: 30);
    await _shot(binding, tester, '03-expanded-player');

    final albumFinder = find.text('Demo Album');
    if (albumFinder.evaluate().isNotEmpty) {
      await tester.tap(albumFinder.first);
      await pumpFrames(tester, count: 25);
      await _shot(binding, tester, '04-album-detail');
      await tester.pageBack();
      await pumpFrames(tester, count: 20);
    }

    await tester.tap(find.byIcon(Icons.settings));
    await pumpFrames(tester, count: 25);
    await _shot(binding, tester, '06-settings');
  });
}

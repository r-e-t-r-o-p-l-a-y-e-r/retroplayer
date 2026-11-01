/// Tutorial PNGs for doc/USAGE.md and store drafts (real fonts, phone safe area).
///
/// Regenerate: flutter test test/ui/doc/tutorial_screenshots_test.dart
///
/// For Play Store quality, use ./scripts/capture-tutorial-screenshots-adb.sh on a device.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:retroplayer/build_info.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/theme.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';
import '../../helpers/track_factory.dart';
import 'tutorial_screenshot_capture.dart';

final _captureKey = GlobalKey();

AudioAlbum _demoAlbum() {
  return AudioAlbum(
    id: 'dir:/music/DemoAlbum',
    title: 'Demo Album',
    tracks: [
      testTrack(
        id: 't1',
        filePath: '/music/DemoAlbum/01-opening.mp3',
        directoryPath: '/music/DemoAlbum',
        durationMs: 3 * 60 * 1000 + 5 * 1000,
        metadata: const TrackMetadata(
          trackNumber: 1,
          title: 'Opening',
          artist: 'Demo Artist',
          album: 'Demo Album',
        ),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/DemoAlbum',
  );
}

Future<_Harness> _boot(WidgetTester tester) async {
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  final storage = LibraryStorageService(db);
  final album = _demoAlbum();
  final libraryRepository = testLibraryRepository(storage);
  await storage.addLibraryRoot('/music');
  libraryRepository.seedChildFolders('/music', const []);
  libraryRepository.seedDirectory('/music', [LibraryItem.album(album: album)]);

  final panelVm = testPanelVm();
  final playerVm = PlayerViewModel(
    playbackRepository: PlaybackRepository(
      playbackService: RecordingPlayback(),
      storageService: storage,
    ),
  );
  final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
  await libraryVm.load();

  const logicalWidth = 412.0;
  const logicalHeight = 915.0;
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(logicalWidth * dpr, logicalHeight * dpr);
  tester.view.viewPadding = FakeViewPadding(
    top: 24 * dpr,
    bottom: 34 * dpr,
  );
  addTearDown(tester.view.resetPhysicalSize);

  final light = tutorialScreenshotTheme(AppTheme.light());
  final dark = tutorialScreenshotTheme(AppTheme.dark());

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
      child: RepaintBoundary(
        key: _captureKey,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: const Locale('en'),
          localizationsDelegates: testL10nDelegates,
          supportedLocales: AppLocaleCatalog.supportedLocales,
          theme: light,
          darkTheme: dark,
          routerConfig: AppRouter.create(initialLocation: AppRouter.library),
        ),
      ),
    ),
  );
  await pumpFrames(tester, count: 40);

  return _Harness(
    tester: tester,
    panelVm: panelVm,
    playerVm: playerVm,
    album: album,
  );
}

class _Harness {
  _Harness({
    required this.tester,
    required this.panelVm,
    required this.playerVm,
    required this.album,
  });

  final WidgetTester tester;
  final dynamic panelVm;
  final PlayerViewModel playerVm;
  final AudioAlbum album;
}

void main() {
  setUp(() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
        return;
      }
      previous?.call(details);
    };
  });

  testWidgets('write tutorial PNGs for USAGE.md', (tester) async {
    final h = await _boot(tester);
    await captureTutorialFrame(
      h.tester,
      '01-library',
      finder: find.byKey(_captureKey),
    );

    await h.tester.tap(find.text('music'));
    await pumpFrames(h.tester, count: 30);
    await h.tester.tap(find.text('Demo Album'));
    await pumpFrames(h.tester, count: 30);
    await captureTutorialFrame(
      h.tester,
      '04-album-detail',
      finder: find.byKey(_captureKey),
    );
    await h.tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFrames(h.tester, count: 20);
    await h.tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFrames(h.tester, count: 20);

    await h.playerVm.playAlbumTrack(h.album, h.album.tracks.first);
    await pumpFrames(h.tester, count: 30);
    await captureTutorialFrame(
      h.tester,
      '02-mini-player',
      finder: find.byKey(_captureKey),
    );

    await h.tester.tap(find.byType(PlayerDragHandle).first);
    await pumpFrames(h.tester, count: 30);
    await captureTutorialFrame(
      h.tester,
      '03-expanded-player',
      finder: find.byKey(_captureKey),
    );

    await h.tester.tap(find.byIcon(Icons.settings_outlined));
    await pumpFrames(h.tester, count: 30);
    expect(find.byType(SettingsView), findsOneWidget);
    final buildTimeLabel = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(BuildInfo.buildTime.toLocal());
    await captureTutorialFrame(
      h.tester,
      '06-settings',
      finder: find.byKey(_captureKey),
      blurInCapture: [find.text(buildTimeLabel)],
    );
  });
}

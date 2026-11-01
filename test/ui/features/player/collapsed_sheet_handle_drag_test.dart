/// Collapsed player sheet expands only from the drag handle, not the mini body.
///
/// Evidence:
/// - `collapsed body drag does not expand player`
/// - `collapsed handle drag expands player`
/// - `bottom navigation slop drag does not expand player`
/// - `player sheet is flush to screen bottom when gesture insets are set`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';
import '../../../helpers/track_factory.dart';

AudioAlbum _album() {
  return AudioAlbum(
    id: 'dir:/music/Author/Book1',
    title: 'Book1',
    tracks: [
      testTrack(
        id: 't1',
        filePath: '/music/Author/Book1/01.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(trackNumber: 1, title: 'Chapter 1'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/Author/Book1',
  );
}

Future<PlayerPanelViewModel> pumpPlayingShell(
  WidgetTester tester, {
  EdgeInsets systemGestureInsets = EdgeInsets.zero,
}) async {
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  final storage = LibraryStorageService(db);
  final album = _album();
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

  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);

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
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(
            tester.view.physicalSize.width / tester.view.devicePixelRatio,
            tester.view.physicalSize.height / tester.view.devicePixelRatio,
          ),
          devicePixelRatio: tester.view.devicePixelRatio,
          systemGestureInsets: systemGestureInsets,
        ),
        child: wrapRouterWithL10n(
          router: AppRouter.create(initialLocation: AppRouter.library),
        ),
      ),
    ),
  );
  await pumpFrames(tester);
  expect(panelVm.isExpanded, isFalse);
  return panelVm;
}

void main() {
  testWidgets('collapsed body drag does not expand player', (tester) async {
    final panelVm = await pumpPlayingShell(tester);
    final sheetTop = tester.getTopLeft(find.byType(PlayerLibrarySheet));
    final dragStart = sheetTop + const Offset(200, 80);
    await tester.dragFrom(dragStart, const Offset(0, -400));
    await pumpFrames(tester, count: 30);
    expect(panelVm.isExpanded, isFalse);
  });

  testWidgets('collapsed handle drag expands player', (tester) async {
    final panelVm = await pumpPlayingShell(tester);
    await tester.drag(find.byType(PlayerDragHandle).first, const Offset(0, -500));
    await pumpFrames(tester, count: 30);
    expect(panelVm.isExpanded, isTrue);
  });

  testWidgets('bottom navigation slop drag does not expand player', (tester) async {
    final panelVm = await pumpPlayingShell(
      tester,
      systemGestureInsets: const EdgeInsets.only(bottom: 48),
    );
    final sheetRect = tester.getRect(find.byType(PlayerLibrarySheet));
    final dragStart = Offset(
      sheetRect.center.dx,
      sheetRect.bottom - 4,
    );
    await tester.dragFrom(dragStart, const Offset(0, -400));
    await pumpFrames(tester, count: 30);
    expect(panelVm.isExpanded, isFalse);
  });

  testWidgets('player sheet is flush to screen bottom when gesture insets are set',
      (tester) async {
    await pumpPlayingShell(
      tester,
      systemGestureInsets: const EdgeInsets.only(bottom: 48),
    );
    final sheetRect = tester.getRect(find.byType(PlayerLibrarySheet));
    expect(sheetRect.bottom, closeTo(tester.view.physicalSize.height, 1));
  });
}

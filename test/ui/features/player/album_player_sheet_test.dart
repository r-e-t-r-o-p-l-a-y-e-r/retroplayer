/// Album detail hosts the continuous player sheet (not the binary mini bar).
///
/// Evidence:
/// - `album detail shows PlayerLibrarySheet while playing`
/// - `swipe up expands player on album detail without leaving the album`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_panel.dart';

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

void main() {
  testWidgets('album detail shows PlayerLibrarySheet while playing', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final album = _album();
    final libraryRepository = LibraryRepository(
      storageService: storage,
      scanLibrary: ScanLibrary(
        fileScanService: FileScanService(),
        metadataService: MetadataService(),
        groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
      ),
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
    );
    await storage.addLibraryRoot('/music');
    seedPlayerBreadcrumbHierarchy(libraryRepository, album);

    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    final panelVm = testPanelVm();
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
            create: (_) =>
                EqualizerViewModel(equalizerService: EqualizerService(storage)),
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
    await pumpFrames(tester);

    final shellContext = tester.element(find.byType(MainShellView));
    GoRouter.of(shellContext).push(AppRouter.albumDetailLocation, extra: album);
    await pumpFrames(tester, count: 12);

    expect(find.widgetWithText(AppBar, 'Album'), findsOneWidget);
    expect(find.text('Book1'), findsWidgets);
    expect(find.byType(PlayerLibrarySheet), findsOneWidget);
    expect(find.byType(PlayerCollapsedBar), findsNothing);

    final handle = find.byType(PlayerDragHandle).first;
    await tester.drag(handle, const Offset(0, -450));
    await pumpFrames(tester, count: 25);

    expect(panelVm.isExpanded, isTrue);
    // Still on album — continuous sheet, not a binary mini-bar swap.
    expect(find.byType(PlayerLibrarySheet), findsOneWidget);
    expect(find.text('Book1'), findsWidgets);
  });
}

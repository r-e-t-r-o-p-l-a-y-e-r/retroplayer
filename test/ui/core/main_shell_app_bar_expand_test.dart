/// AppBar chrome stays aligned with sheet extent during expand/collapse animation.
///
/// Evidence:
/// - `expand tap keeps Library AppBar title before animation catches up`
/// - `expand tap shows Now Playing only after sheet animation completes`
/// - `collapse tap symmetric mid/end chrome`
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
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../../helpers/library_test_seed.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';
import '../../helpers/test_library_repository.dart';

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
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<PlayerPanelViewModel> pumpAnimatedShell(WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final album = _album();
    final libraryRepository = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedPlayerBreadcrumbHierarchy(libraryRepository, album);

    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    final panelVm = PlayerPanelViewModel(
      animator: const AnimatedSheetAnimator(),
    );
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
    return panelVm;
  }

  String? readAppBarTitle(WidgetTester tester) {
    final title = tester.widget<AppBar>(find.byType(AppBar)).title;
    return switch (title) {
      Text(:final data?) => data,
      _ => null,
    };
  }

  testWidgets('expand tap keeps Library AppBar title before animation catches up', (
    tester,
  ) async {
    await pumpAnimatedShell(tester);
    expect(find.byType(MainShellView), findsOneWidget);
    expect(readAppBarTitle(tester), 'Library');

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pump();

    expect(readAppBarTitle(tester), 'Library');
    expect(find.text('Now Playing'), findsNothing);
    expect(find.byIcon(Icons.queue_music), findsOneWidget);
  });

  testWidgets('expand tap shows Now Playing only after sheet animation completes', (
    tester,
  ) async {
    final panelVm = await pumpAnimatedShell(tester);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await pumpFrames(tester, count: 5);

    expect(panelVm.isExpanded, isTrue);
    expect(readAppBarTitle(tester), 'Now Playing');
    expect(
      find.descendant(
        of: find.byType(LibraryPathSummary),
        matching: find.text('Book1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('collapse tap symmetric mid/end chrome', (tester) async {
    final panelVm = await pumpAnimatedShell(tester);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pump(const Duration(milliseconds: 320));
    await pumpFrames(tester, count: 5);
    expect(readAppBarTitle(tester), 'Now Playing');

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pump();

    expect(readAppBarTitle(tester), 'Now Playing');

    await tester.pump(const Duration(milliseconds: 320));
    await pumpFrames(tester, count: 5);

    expect(panelVm.isExpanded, isFalse);
    expect(readAppBarTitle(tester), 'Library');
    expect(find.text('Now Playing'), findsNothing);
  });
}

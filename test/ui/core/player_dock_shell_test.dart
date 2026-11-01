/// Mini player sheet stays continuous on library; Settings is a root overlay.
///
/// Evidence:
/// - `expanded then open settings keeps player expanded under overlay`
/// - `settings overlay has no mini player dock`
/// - `repeated expand collapse on library shell stays usable`
/// - `swipe up expands and swipe down collapses player sheet`
/// - `predictive-back scrub keeps Now Playing chrome until collapse`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../helpers/library_test_seed.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';

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

  Future<
    ({
      PlayerPanelViewModel panelVm,
      PlayerViewModel playerVm,
      LibraryViewModel libraryVm,
    })
  >
  pumpShell(WidgetTester tester) async {
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
    return (panelVm: panelVm, playerVm: playerVm, libraryVm: libraryVm);
  }

  testWidgets(
    'expanded then open settings keeps player expanded under overlay',
    (tester) async {
      final env = await pumpShell(tester);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(PlayerCollapsedBar), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 20);
      expect(env.panelVm.isExpanded, isTrue);
      expect(find.byType(PlayerCollapsedBar), findsNothing);
      expect(find.text('Now Playing'), findsOneWidget);

      final shellContext = tester.element(find.byType(MainShellView));
      // Do not await push — the future completes only when Settings is popped.
      GoRouter.of(shellContext).push(AppRouter.settings);
      await pumpFrames(tester, count: 12);

      expect(find.byType(SettingsView), findsOneWidget);
      expect(find.byType(PlayerCollapsedBar), findsNothing);
      expect(env.panelVm.isExpanded, isTrue);
    },
  );

  testWidgets('settings overlay has no mini player dock', (tester) async {
    final env = await pumpShell(tester);

    final shellContext = tester.element(find.byType(MainShellView));
    GoRouter.of(shellContext).push(AppRouter.settings);
    await pumpFrames(tester, count: 12);

    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.textContaining('Settings'), findsWidgets);
    expect(find.byType(PlayerCollapsedBar), findsNothing);
    expect(find.byType(PlayerDragHandle), findsNothing);
    expect(env.panelVm.isExpanded, isFalse);
  });

  testWidgets('repeated expand collapse on library shell stays usable', (
    tester,
  ) async {
    final env = await pumpShell(tester);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byType(PlayerDragHandle));
      await pumpFrames(tester, count: 20);
      expect(env.panelVm.isExpanded, isTrue);
      expect(find.text('Now Playing'), findsOneWidget);
      expect(find.byType(PlayerCollapsedBar), findsNothing);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      await tester.tap(find.byType(PlayerDragHandle));
      await pumpFrames(tester, count: 20);
      expect(env.panelVm.isExpanded, isFalse);
      expect(find.byType(PlayerCollapsedBar), findsNothing);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Now Playing'), findsNothing);
      expect(find.byType(MainShellView), findsOneWidget);
    }
  });

  testWidgets('library app bar stays Library inside a folder', (tester) async {
    final env = await pumpShell(tester);
    await env.libraryVm.browseInto('/music/Author');
    await pumpFrames(tester);

    expect(
      tester.widget<AppBar>(find.byType(AppBar)).title,
      isA<Text>().having((text) => text.data, 'data', 'Library'),
    );
    expect(
      find.descendant(
        of: find.byType(LibraryPathSummary),
        matching: find.text('Author'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('swipe up expands and swipe down collapses player sheet', (
    tester,
  ) async {
    final env = await pumpShell(tester);
    expect(env.panelVm.isExpanded, isFalse);
    expect(find.byType(PlayerLibrarySheet), findsOneWidget);

    final handle = find.byType(PlayerDragHandle).first;
    await tester.drag(handle, const Offset(0, -450));
    await pumpFrames(tester, count: 25);
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);

    await tester.drag(handle, const Offset(0, 450));
    await pumpFrames(tester, count: 25);
    expect(env.panelVm.isExpanded, isFalse);
    expect(find.text('Now Playing'), findsNothing);
  });

  testWidgets('predictive-back scrub keeps Now Playing chrome until collapse', (
    tester,
  ) async {
    final env = await pumpShell(tester);

    await tester.tap(find.byType(PlayerDragHandle));
    await pumpFrames(tester, count: 20);
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Book1')),
      findsOneWidget,
    );

    env.panelVm.scrubSheet(0.75);
    await tester.pump();
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Book1')),
      findsOneWidget,
    );

    await env.panelVm.collapse();
    await pumpFrames(tester, count: 20);
    expect(env.panelVm.isExpanded, isFalse);
    expect(find.text('Now Playing'), findsNothing);
  });

  testWidgets('add folder fab sits above collapsed player sheet', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(PlayerDragHandle), findsWidgets);

    final fabBottom = tester.getRect(find.byType(FloatingActionButton)).bottom;
    // Sheet layout box is full-height; the handle marks the visible mini top.
    final miniTop = tester.getRect(find.byType(PlayerDragHandle).first).top;
    expect(fabBottom, lessThanOrEqualTo(miniTop));
  });
}

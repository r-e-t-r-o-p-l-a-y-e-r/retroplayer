/// Closing Settings restores the exact prior shell view.
///
/// Evidence:
/// - `settings pop restores library browse path`
/// - `settings pop restores album detail`
/// - `settings pop restores playlist detail`
/// - `settings pop keeps maximized player expanded`
/// - `settings app bar back then handlePopRoute keeps player expanded`
/// - `settings overlay shows no mini player dock`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/core/player_dock_shell.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/playlist/views/playlist_detail_view.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
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

PlaylistFile _playlist() {
  return PlaylistFile(
    filePath: '/music/road.m3u',
    entryPaths: const ['/music/Author/Book1/01.mp3'],
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
        AudioAlbum album,
        PlaylistFile playlist,
      })> pumpShell(WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final album = _album();
    final playlist = _playlist();
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
    await pumpFrames(tester);
    return (
      panelVm: panelVm,
      playerVm: playerVm,
      libraryVm: libraryVm,
      album: album,
      playlist: playlist,
    );
  }

  Future<void> openSettings(WidgetTester tester) async {
    // PlayerDockShell stays mounted under album/playlist; MainShellView does not.
    final shellContext = tester.element(find.byType(PlayerDockShell));
    // Do not await push — the future completes only when Settings is popped.
    GoRouter.of(shellContext).push(AppRouter.settings);
    await pumpFrames(tester, count: 12);
    expect(find.byType(SettingsView), findsOneWidget);
  }

  Future<void> closeSettingsViaAppBar(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await pumpFrames(tester, count: 12);
    expect(find.byType(SettingsView), findsNothing);
  }

  testWidgets('settings pop restores library browse path', (tester) async {
    final env = await pumpShell(tester);
    await env.libraryVm.navigateToBrowsePath('/music/Author/Book1');
    await pumpFrames(tester, count: 8);
    expect(env.libraryVm.browsePath, '/music/Author/Book1');

    await openSettings(tester);
    expect(find.byType(PlayerCollapsedBar), findsNothing);

    await closeSettingsViaAppBar(tester);
    expect(env.libraryVm.browsePath, '/music/Author/Book1');
    expect(find.byType(MainShellView), findsOneWidget);
  });

  testWidgets('settings pop restores album detail', (tester) async {
    final env = await pumpShell(tester);
    final shellContext = tester.element(find.byType(MainShellView));
    GoRouter.of(shellContext)
        .push(AppRouter.albumDetailLocation, extra: env.album);
    await pumpFrames(tester, count: 12);
    expect(find.byType(AlbumDetailView), findsOneWidget);
    expect(find.text('Book1'), findsWidgets);

    await openSettings(tester);
    expect(find.byType(PlayerCollapsedBar), findsNothing);

    await closeSettingsViaAppBar(tester);
    expect(find.byType(AlbumDetailView), findsOneWidget);
    expect(find.text('Book1'), findsWidgets);
    expect(find.byType(SettingsView), findsNothing);
  });

  testWidgets('settings pop restores playlist detail', (tester) async {
    final env = await pumpShell(tester);
    final shellContext = tester.element(find.byType(MainShellView));
    GoRouter.of(shellContext)
        .push(AppRouter.playlistDetailLocation, extra: env.playlist);
    await pumpFrames(tester, count: 12);
    expect(find.byType(PlaylistDetailView), findsOneWidget);

    await openSettings(tester);
    expect(find.byType(PlayerCollapsedBar), findsNothing);

    await closeSettingsViaAppBar(tester);
    expect(find.byType(PlaylistDetailView), findsOneWidget);
    expect(find.byType(SettingsView), findsNothing);
  });

  testWidgets('settings pop keeps maximized player expanded', (tester) async {
    final env = await pumpShell(tester);
    await tester.tap(find.byIcon(Icons.expand_less));
    await pumpFrames(tester, count: 20);
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);

    await openSettings(tester);
    expect(find.byType(PlayerCollapsedBar), findsNothing);
    // Underlying panel must not collapse while Settings overlays the shell.
    expect(env.panelVm.isExpanded, isTrue);

    await closeSettingsViaAppBar(tester);
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.byType(MainShellView), findsOneWidget);
  });

  testWidgets(
    'settings app bar back then handlePopRoute keeps player expanded',
    (tester) async {
      final env = await pumpShell(tester);
      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 20);
      expect(env.panelVm.isExpanded, isTrue);

      await openSettings(tester);
      await closeSettingsViaAppBar(tester);

      final handled = await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 12);

      expect(find.byType(SettingsView), findsNothing);
      expect(env.panelVm.isExpanded, isTrue);
      expect(handled, isTrue);
    },
  );

  testWidgets('settings overlay shows no mini player dock', (tester) async {
    await pumpShell(tester);
    await openSettings(tester);
    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.byType(PlayerCollapsedBar), findsNothing);
    expect(find.byType(PlayerDragHandle), findsNothing);
  });
}

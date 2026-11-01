/// Player breadcrumbs and MainShell jumps into library/album detail.
///
/// Evidence:
/// - `PlayerView shows breadcrumb path for the now playing file`
/// - `MainShell expanded breadcrumb jumps to library folder`
/// - `MainShell breadcrumb on track opens album in library`
/// - `folder breadcrumb closes album detail left on navigation stack`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:go_router/go_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/views/player_view.dart';
import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

AudioAlbum _testAlbum() {
  const albumId = 'dir:/music/book';
  return AudioAlbum(
    id: albumId,
    title: 'My Book',
    tracks: [
      testTrack(
        filePath: '/music/Author/Book1/ch01.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(trackNumber: 1, title: 'Chapter 1'),
      ),
      testTrack(
        filePath: '/music/Author/Book1/ch02.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(trackNumber: 2, title: 'Chapter 2'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<void> pumpMainShell(
    WidgetTester tester, {
    required LibraryRepository libraryRepository,
    required LibraryViewModel libraryVm,
    required PlayerViewModel playerVm,
    PlayerPanelViewModel? panelVm,
    Size viewport = const Size(1200, 900),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final panel = panelVm ?? testPanelVm();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider.value(value: playerVm),
          ChangeNotifierProvider.value(value: panel),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapRouterWithL10n(
          router: AppRouter.create(initialLocation: AppRouter.library),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  Future<void> expandPlayer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('PlayerView shows breadcrumb path for the now playing file', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final storage = LibraryStorageService(db);
    final album = _testAlbum();
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
    await libraryVm.load();
    await playerVm.playAlbumTrack(album, album.tracks.first);

    await tester.pumpWidget(
      wrapWithL10n(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: libraryVm),
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
          ],
          child: const PlayerView(),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Book1'), findsOneWidget);
    expect(find.text('Chapter 1'), findsWidgets);
    expect(find.text('Now Playing'), findsOneWidget);
  });

  testWidgets('MainShell expanded breadcrumb jumps to library folder', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final storage = LibraryStorageService(db);
    final album = _testAlbum();
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
    await libraryVm.load();
    await playerVm.playAlbumTrack(album, album.tracks[1]);

    await pumpMainShell(
      tester,
      libraryRepository: libraryRepository,
      libraryVm: libraryVm,
      playerVm: playerVm,
    );
    await expandPlayer(tester);

    expect(find.text('Now Playing'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.byType(AppBar), matching: find.text('Author')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Now Playing'), findsNothing);
    expect(libraryVm.browsePath, '/music/Author');
    expect(find.text('Book1'), findsOneWidget);
  });

  testWidgets('MainShell breadcrumb on track opens album in library', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final storage = LibraryStorageService(db);
    final album = _testAlbum();
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
    await libraryVm.load();
    await playerVm.playAlbumTrack(album, album.tracks[1]);

    await pumpMainShell(
      tester,
      libraryRepository: libraryRepository,
      libraryVm: libraryVm,
      playerVm: playerVm,
    );
    await expandPlayer(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Chapter 2'),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('Chapter 1'), findsOneWidget);
    expect(libraryVm.browsePath, '/music/Author/Book1');
  });

  testWidgets(
    'folder breadcrumb closes album detail left on navigation stack',
    (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(() async => db.close());

      final storage = LibraryStorageService(db);
      final album = _testAlbum();
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
      await playerVm.playAlbumTrack(album, album.tracks[1]);

      await pumpMainShell(
        tester,
        libraryRepository: libraryRepository,
        libraryVm: libraryVm,
        playerVm: playerVm,
        panelVm: panelVm,
      );

      final shellContext = tester.element(find.byType(MainShellView));
      final router = GoRouter.of(shellContext);
      router.push(AppRouter.albumDetailLocation, extra: album);
      await pumpFrames(tester);
      expect(find.byType(AlbumDetailView), findsOneWidget);

      await LibraryNavigator.of(shellContext).closeDetails();
      await pumpFrames(tester, count: 5);
      await libraryVm.navigateToBrowsePath('/music/Author');
      await pumpFrames(tester, count: 5);

      expect(find.byType(AlbumDetailView), findsNothing);
      expect(libraryVm.browsePath, '/music/Author');
      expect(find.text('Book1'), findsOneWidget);
    },
  );
}

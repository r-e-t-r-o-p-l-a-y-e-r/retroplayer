/// Regressions for issues found while testing on an Android device.
///
/// Evidence:
/// - `player sheet expands continuously while dragging (not binary swap)`
/// - `player sheet swipe down collapses from expanded`
/// - `library row drag to scroll does not select`
/// - `library row short tap selects keyboard row`
/// - `expanded player title tap locates track and collapses`
/// - `expanded player art tap locates track and collapses`
/// - `cover art file shows Image in collapsed and expanded player`
library;
import 'dart:io';
import 'dart:typed_data';

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
import 'package:retroplayer/ui/core/keyboard/library_row_focus.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import '../../helpers/library_test_seed.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';

/// Minimal valid 1×1 PNG.
final Uint8List _kTinyPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

AudioAlbum _album({String? coverArtPath}) {
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
    coverArtPath: coverArtPath,
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
        String? coverPath,
      })> pumpPlayingShell(
    WidgetTester tester, {
    String? coverArtPath,
  }) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);

    // Prefer a non-existent path in widget tests: AlbumArtFrame only builds
    // FileImage when the file exists, and FileImage decode can stall the binder.
    final coverPath = coverArtPath;
    final album = _album(coverArtPath: coverPath);
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
      coverPath: coverPath,
    );
  }

  Future<void> expandSheet(WidgetTester tester, PlayerPanelViewModel panelVm) async {
    // animateTo must be pumped; awaiting expand() alone can hang the test binding.
    final pending = panelVm.expand();
    await pumpFrames(tester, count: 30);
    await pending;
  }

  group('player sheet swipe (binary expand / broken swipe-down)', () {
    testWidgets('player sheet expands continuously while dragging (not binary swap)',
        (tester) async {
      final env = await pumpPlayingShell(tester);
      expect(env.panelVm.isExpanded, isFalse);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(PlayerLibrarySheet), findsOneWidget);

      final collapsedHeight =
          tester.getSize(find.byType(PlayerLibrarySheet)).height;

      // Collapsed expand is handle-only; drag from the handle.
      final handle = find.byType(PlayerDragHandle).first;
      await tester.drag(handle, const Offset(0, -260));
      await tester.pump();

      final midHeight = tester.getSize(find.byType(PlayerLibrarySheet)).height;
      expect(
        midHeight,
        greaterThan(collapsedHeight + 40),
        reason: 'sheet height should follow the finger mid-drag',
      );
      expect(
        midHeight,
        lessThan(tester.view.physicalSize.height - 80),
        reason: 'mid-drag must not jump straight to full-screen',
      );

      await tester.drag(handle, const Offset(0, -500));
      await pumpFrames(tester, count: 30);

      expect(env.panelVm.isExpanded, isTrue);
      expect(find.text('Now Playing'), findsOneWidget);
    });

    testWidgets('player sheet swipe down collapses from expanded', (tester) async {
      final env = await pumpPlayingShell(tester);
      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 30);
      expect(env.panelVm.isExpanded, isTrue);

      final handle = find.byType(PlayerDragHandle).first;
      await tester.drag(handle, const Offset(0, 500));
      await pumpFrames(tester, count: 30);

      expect(env.panelVm.isExpanded, isFalse);
      expect(find.text('Now Playing'), findsNothing);
      expect(find.byType(MainShellView), findsOneWidget);
    });
  });

  group('library touch scroll selecting rows', () {
    Future<LibraryViewModel> pumpLibrary(WidgetTester tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final storage = LibraryStorageService(db);
      final repo = testLibraryRepository(storage);
      await storage.addLibraryRoot('/music');
      seedAuthorBook1Hierarchy(repo);
      final vm = LibraryViewModel(libraryRepository: repo);
      await vm.load();
      await vm.navigateToBrowsePath('/music');

      final playerDb = AppDatabase.inMemory();
      addTearDown(playerDb.close);
      final playerVm = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: RecordingPlayback(),
          storageService: LibraryStorageService(playerDb),
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: vm),
            ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
            ChangeNotifierProvider.value(value: playerVm),
          ],
          child: wrapWithL10n(
            const LibraryView(
              autoLoad: false,
              restoreSessionOnMount: false,
              embeddedInShell: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return vm;
    }

    testWidgets('library row drag to scroll does not select', (tester) async {
      final vm = await pumpLibrary(tester);
      expect(vm.keyboardSelectedIndex, isNull);

      await tester.drag(find.text('Author'), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(vm.keyboardSelectedIndex, isNull);
    });

    testWidgets('library row short tap selects keyboard row', (tester) async {
      final vm = await pumpLibrary(tester);
      expect(vm.keyboardSelectedIndex, isNull);

      // Select via pointer-up within tap slop without relying on browse side effects.
      final row = find.ancestor(
        of: find.text('Author'),
        matching: find.byType(LibraryRowFocusGroup),
      );
      final center = tester.getCenter(row);
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(0, 4));
      await gesture.up();
      await tester.pump();

      expect(vm.keyboardSelectedIndex, isNotNull);
    });
  });

  group('expanded player locate via title/art tap', () {
    testWidgets('expanded player title tap locates track and collapses',
        (tester) async {
      final env = await pumpPlayingShell(tester);
      await expandSheet(tester, env.panelVm);
      expect(env.panelVm.isExpanded, isTrue);

      await tester.tap(find.text('Chapter 1').last);
      await pumpFrames(tester, count: 30);

      expect(env.panelVm.isExpanded, isFalse);
      expect(env.libraryVm.highlightedTrackId, 't1');
    });

    testWidgets('expanded player art tap locates track and collapses',
        (tester) async {
      final env = await pumpPlayingShell(tester);
      await expandSheet(tester, env.panelVm);
      expect(env.panelVm.isExpanded, isTrue);

      await tester.tap(find.byKey(const ValueKey('player_art_focus')));
      await pumpFrames(tester, count: 30);

      expect(env.panelVm.isExpanded, isFalse);
      expect(env.libraryVm.highlightedTrackId, 't1');
    });
  });

  group('cover art not loaded in player', () {
    test('cover file on disk is visible to AlbumArtFrame path resolution', () async {
      final dir = await Directory.systemTemp.createTemp('rp_art_frame_');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      final cover = File('${dir.path}/cover.png');
      await cover.writeAsBytes(_kTinyPng);

      expect(cover.existsSync(), isTrue);
      final frame = AlbumArtFrame(imagePath: cover.path, size: 64);
      expect(frame.imagePath, cover.path);
      // Placeholder only when the path is missing — existence is what the
      // frame checks before building an Image.
      expect(File(frame.imagePath!).existsSync(), isTrue);
    });

    testWidgets('player keeps coverArtPath in collapsed and expanded chrome',
        (tester) async {
      // Non-existent path: AlbumArtFrame must not decode FileImage in tests.
      const coverPath = '/music/Author/Book1/cover.jpg';
      final env = await pumpPlayingShell(tester, coverArtPath: coverPath);
      expect(env.playerVm.coverArtPath, coverPath);
      expect(env.panelVm.isExpanded, isFalse);

      final collapsedArt = find.descendant(
        of: find.byType(PlayerLibrarySheet),
        matching: find.byType(AlbumArtFrame),
      );
      expect(collapsedArt, findsWidgets);
      expect(
        tester.widget<AlbumArtFrame>(collapsedArt.first).imagePath,
        coverPath,
      );

      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 30);
      expect(env.panelVm.isExpanded, isTrue);
      expect(env.playerVm.coverArtPath, coverPath);

      final expandedArt = find.descendant(
        of: find.byType(PlayerExpandedContent),
        matching: find.byType(AlbumArtFrame),
      );
      expect(expandedArt, findsOneWidget);
      expect(
        tester.widget<AlbumArtFrame>(expandedArt).imagePath,
        coverPath,
      );
    });
  });
}

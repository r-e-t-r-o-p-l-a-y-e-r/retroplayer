import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/app_session_bootstrap.dart';
import 'package:retroplayer/ui/core/cold_start_ui.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/library/add_library_folder.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

import 'library_test_seed.dart';
import 'pump_app.dart';
import 'recording_playback.dart';
import 'test_library_repository.dart';
import 'track_factory.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';

/// Handles to everything [pumpRealApp] wired up.
class RealApp {
  RealApp({
    required this.db,
    required this.storage,
    required this.libraryRepository,
    required this.playback,
    required this.playbackRepository,
    required this.libraryVm,
    required this.playerVm,
    required this.panelVm,
    required this.router,
  });

  final AppDatabase db;
  final LibraryStorageService storage;
  final LibraryRepository libraryRepository;
  final RecordingPlayback playback;
  final PlaybackRepository playbackRepository;
  final LibraryViewModel libraryVm;
  final PlayerViewModel playerVm;
  final PlayerPanelViewModel panelVm;
  final GoRouter router;

  GoRouter get shellRouter =>
      GoRouter.of(_tester.element(find.byType(MainShellView)));

  late WidgetTester _tester;
}

/// The album at `/music/Author/Book1` seeded by default.
AudioAlbum book1Album() {
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
      testTrack(
        id: 't2',
        filePath: '/music/Author/Book1/02.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(trackNumber: 2, title: 'Chapter 2'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/Author/Book1',
  );
}

/// Pumps the production shell: real [AppRouter], [MainShellView], player
/// sheet and the full provider tree, over an in-memory DB.
///
/// By default seeds `/music` → `Author` → `Book1` (holding [book1Album]).
/// [repository] swaps the library repository (e.g. `seededLibraryRepository`);
/// [seed] replaces the default seeding; [browsePath] is opened before the first frame and
/// [playing] starts a queue on its first track. [folderPicker] replaces the
/// storage permission prompt and native folder dialog.
Future<RealApp> pumpRealApp(
  WidgetTester tester, {
  LibraryRepository Function(LibraryStorageService storage)? repository,
  void Function(LibraryRepository repository)? seed,
  String? browsePath,
  AudioAlbum? playing,
  List<String> roots = const ['/music'],
  Size size = const Size(1200, 900),
  LibraryFolderPicker? folderPicker,
  bool useAppSessionBootstrap = false,
  bool restorePlaybackFromStorage = false,
  Future<void> Function(LibraryStorageService storage)? beforePump,
}) async {
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  final storage = LibraryStorageService(db);
  final libraryRepository =
      repository?.call(storage) ?? testLibraryRepository(storage);
  for (final root in roots) {
    await storage.addLibraryRoot(root);
  }
  if (seed != null) {
    seed(libraryRepository);
  } else {
    seedPlayerBreadcrumbHierarchy(libraryRepository, book1Album());
  }

  final playback = RecordingPlayback();
  final playbackRepository = PlaybackRepository(
    playbackService: playback,
    storageService: storage,
  );
  final albumForRestore = playing ?? book1Album();
  if (restorePlaybackFromStorage) {
    await storage.savePlaybackState(
      itemId: albumForRestore.id,
      trackId: albumForRestore.tracks.first.filePath,
      positionMs: 0,
      speed: 1.0,
      displayTitle: albumForRestore.tracks.first.displayTitle,
    );
  }

  if (beforePump != null) {
    await beforePump(storage);
  }

  final coldStartUi = restorePlaybackFromStorage
      ? await ColdStartUi.load(
          storage: storage,
          playbackRepository: playbackRepository,
        )
      : const ColdStartUi();

  final playerVm = restorePlaybackFromStorage
      ? ColdStartUi.createPlayerViewModel(
          playbackRepository: playbackRepository,
          coldStart: coldStartUi,
        )
      : PlayerViewModel(playbackRepository: playbackRepository);
  final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
  final panelVm = ColdStartUi.createPanelViewModel(
    coldStart: coldStartUi,
    animator: const JumpSheetAnimator(),
  );
  await libraryVm.load();
  if (browsePath != null) await libraryVm.browseInto(browsePath);

  if (!restorePlaybackFromStorage && playing != null) {
    await playerVm.playAlbumTrack(playing, playing.tracks.first);
  }

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = AppRouter.create(initialLocation: AppRouter.library);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: libraryRepository),
        Provider.value(value: playbackRepository),
        ChangeNotifierProvider.value(value: libraryVm),
        ChangeNotifierProvider.value(value: playerVm),
        ChangeNotifierProvider.value(value: panelVm),
        ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        if (folderPicker != null) Provider.value(value: folderPicker),
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
        Provider.value(
          value: EqualizerService(storage, playbackService: playback),
        ),
      ],
      child: useAppSessionBootstrap
          ? AppSessionBootstrap(child: wrapRouterWithL10n(router: router))
          : wrapRouterWithL10n(router: router),
    ),
  );
  await pumpFrames(
    tester,
    count: useAppSessionBootstrap ? 30 : 12,
  );

  return RealApp(
    db: db,
    storage: storage,
    libraryRepository: libraryRepository,
    playback: playback,
    playbackRepository: playbackRepository,
    libraryVm: libraryVm,
    playerVm: playerVm,
    panelVm: panelVm,
    router: router,
  ).._tester = tester;
}

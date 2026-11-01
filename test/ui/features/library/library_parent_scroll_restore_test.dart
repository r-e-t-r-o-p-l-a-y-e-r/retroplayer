/// Browse-up restores the parent list scroll offset (no row-alignment snap).
///
/// Evidence:
/// - `browse up restores parent scroll offset and selects opened folder`
/// - `settings overlay restores browse scroll offset when closed`
/// - `breadcrumb tap to parent restores saved scroll offset`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_library_row.dart';
import 'package:retroplayer/ui/core/player_dock_shell.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _router() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => PlayerDockShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LibraryView(
              autoLoad: false,
              restoreSessionOnMount: false,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRouter.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
}

void main() {
  testWidgets('browse up restores parent scroll offset and selects opened folder',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');

    final folders = <FolderEntry>[
      for (var i = 0; i < 30; i++)
        FolderEntry(
          path: '/music/Folder${i.toString().padLeft(2, '0')}',
          name: 'Folder${i.toString().padLeft(2, '0')}',
        ),
    ];
    repo.seedChildFolders('/music', folders);
    repo.seedDirectory('/music', const []);
    for (final folder in folders) {
      repo.seedChildFolders(folder.path, const []);
      repo.seedDirectory(folder.path, const []);
    }

    final libraryVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(libraryVm.dispose);
    await libraryVm.load();
    await libraryVm.navigateToBrowsePath('/music');

    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: RecordingPlayback(),
                storageService: storage,
              ),
            ),
          ),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapRouterWithL10n(router: _router()),
      ),
    );
    await pumpFrames(tester, count: 12);

    expect(libraryVm.folders.length, 30);
    expect(find.text('Folder00'), findsWidgets);

    // Scroll so a mid-list folder is away from the default top snap position.
    final listFinder = find.byType(Scrollable).first;
    await tester.drag(listFinder, const Offset(0, -900));
    await pumpFrames(tester, count: 8);

    final scrollable = tester.state<ScrollableState>(listFinder);
    final offsetBeforeEnter = scrollable.position.pixels;
    expect(offsetBeforeEnter, greaterThan(200));

    await tester.scrollUntilVisible(
      find.text('Folder15'),
      80,
      scrollable: listFinder,
    );
    await pumpFrames(tester, count: 4);
    // scrollUntilVisible may nudge offset; capture the true enter position.
    final offsetAtEnter =
        tester.state<ScrollableState>(listFinder).position.pixels;

    await tester.tap(find.text('Folder15'));
    await pumpFrames(tester, count: 12);
    expect(
      libraryVm.browsePath,
      normalizeLibraryPath('/music/Folder15'),
    );

    await libraryVm.navigateToParentFolder();
    await pumpFrames(tester, count: 20);

    expect(libraryVm.browsePath, normalizeLibraryPath('/music'));
    expect(libraryVm.keyboardSelectedIndex, isNotNull);
    final row = libraryVm.selectableRows[libraryVm.keyboardSelectedIndex!];
    expect(row.kind, SelectableRowKind.folder);
    expect(row.folderPath, normalizeLibraryPath('/music/Folder15'));

    final offsetAfterReturn =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(offsetAfterReturn, closeTo(offsetAtEnter, 1.0));
    expect(find.text('Folder15'), findsOneWidget);
  });

  testWidgets('settings overlay restores browse scroll offset when closed',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');

    final folders = <FolderEntry>[
      for (var i = 0; i < 30; i++)
        FolderEntry(
          path: '/music/Folder${i.toString().padLeft(2, '0')}',
          name: 'Folder${i.toString().padLeft(2, '0')}',
        ),
    ];
    repo.seedChildFolders('/music', folders);
    repo.seedDirectory('/music', const []);
    for (final folder in folders) {
      repo.seedChildFolders(folder.path, const []);
      repo.seedDirectory(folder.path, const []);
    }

    final libraryVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(libraryVm.dispose);
    await libraryVm.load();
    await libraryVm.navigateToBrowsePath('/music');

    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: RecordingPlayback(),
                storageService: storage,
              ),
            ),
          ),
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
        child: wrapRouterWithL10n(router: _router()),
      ),
    );
    await pumpFrames(tester, count: 12);

    final listFinder = find.byType(Scrollable).first;
    await tester.drag(listFinder, const Offset(0, -900));
    await pumpFrames(tester, count: 8);
    final offsetBeforeSettings =
        tester.state<ScrollableState>(listFinder).position.pixels;
    expect(offsetBeforeSettings, greaterThan(200));

    libraryVm.rememberBrowseScrollOffset();
    final router = GoRouter.of(tester.element(find.byType(LibraryView)));
    router.push(AppRouter.settings);
    await pumpFrames(tester, count: 12);
    expect(find.byType(SettingsView), findsOneWidget);

    router.pop();
    await pumpFrames(tester, count: 20);

    final offsetAfterSettings = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    expect(offsetAfterSettings, closeTo(offsetBeforeSettings, 1.0));
  });

  testWidgets('breadcrumb tap to parent restores saved scroll offset',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');

    final folders = <FolderEntry>[
      for (var i = 0; i < 30; i++)
        FolderEntry(
          path: '/music/Folder${i.toString().padLeft(2, '0')}',
          name: 'Folder${i.toString().padLeft(2, '0')}',
        ),
    ];
    repo.seedChildFolders('/music', folders);
    repo.seedDirectory('/music', const []);
    for (final folder in folders) {
      repo.seedChildFolders(folder.path, const []);
      repo.seedDirectory(folder.path, const []);
    }

    final libraryVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(libraryVm.dispose);
    await libraryVm.load();
    await libraryVm.navigateToBrowsePath('/music');

    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: RecordingPlayback(),
                storageService: storage,
              ),
            ),
          ),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapRouterWithL10n(router: _router()),
      ),
    );
    await pumpFrames(tester, count: 12);

    final listFinder = find.byType(Scrollable).first;
    await tester.drag(listFinder, const Offset(0, -900));
    await pumpFrames(tester, count: 8);

    await tester.scrollUntilVisible(
      find.text('Folder15'),
      80,
      scrollable: listFinder,
    );
    await pumpFrames(tester, count: 4);
    final offsetAtEnter =
        tester.state<ScrollableState>(listFinder).position.pixels;

    await tester.tap(find.text('Folder15'));
    await pumpFrames(tester, count: 12);
    expect(libraryVm.browsePath, normalizeLibraryPath('/music/Folder15'));

    await tester.tap(find.text('music'));
    await pumpFrames(tester, count: 20);

    expect(libraryVm.browsePath, normalizeLibraryPath('/music'));
    expect(libraryVm.keyboardSelectedIndex, isNotNull);
    final row = libraryVm.selectableRows[libraryVm.keyboardSelectedIndex!];
    expect(row.folderPath, normalizeLibraryPath('/music/Folder15'));

    final offsetAfterReturn =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(offsetAfterReturn, closeTo(offsetAtEnter, 1.0));
  });
}

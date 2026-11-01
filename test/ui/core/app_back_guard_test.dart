/// AppBackGuard handles system back; the app always owns back on Android.
///
/// Evidence:
/// - `root back is absorbed and browses up when possible`
/// - `root back at library top stays in app without stopping playback`
/// - `edge back browses up after settings overlay is closed`
///
/// Real-shell back flows (Android gesture path) are in system_back_flows_test.dart.
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/core/app_back_guard.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/player_dock_shell.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../helpers/library_test_seed.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/recording_playback.dart';
import '../../helpers/test_library_repository.dart';
import '../../helpers/test_panel.dart';

void main() {
  group('AppBackGuard on a minimal shell', () {
    late AppDatabase db;
    late LibraryViewModel libraryVm;
    late PlayerPanelViewModel panelVm;
    late PlayerViewModel playerVm;
    late RecordingPlayback playback;
    late PlaybackRepository playbackRepository;
    late GoRouter router;

    setUp(() async {
      db = AppDatabase.inMemory();
      final storage = LibraryStorageService(db);
      final repo = testLibraryRepository(storage);
      await storage.addLibraryRoot('/music');
      seedAuthorBook1Hierarchy(repo);
      libraryVm = LibraryViewModel(libraryRepository: repo);
      await libraryVm.load();
      await libraryVm.browseInto('/music/Author');
      panelVm = testPanelVm();
      playback = RecordingPlayback();
      playbackRepository = PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      );
      playerVm = PlayerViewModel(playbackRepository: playbackRepository);

      final rootNavigatorKey = GlobalKey<NavigatorState>();
      router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: '/',
        routes: [
          ShellRoute(
            builder: (context, state, child) => PlayerDockShell(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const Scaffold(body: Text('library-root')),
              ),
            ],
          ),
          GoRoute(
            path: AppRouter.settings,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                const Scaffold(body: Text('settings-overlay')),
          ),
        ],
      );
    });

    tearDown(() async {
      router.dispose();
      await db.close();
    });

    Future<void> pumpGuard(WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: playbackRepository),
            ChangeNotifierProvider.value(value: libraryVm),
            ChangeNotifierProvider.value(value: panelVm),
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
          ],
          child: wrapRouterWithL10n(router: router),
        ),
      );
      await pumpFrames(tester);
    }

    testWidgets('root back is absorbed and browses up when possible', (
      tester,
    ) async {
      await pumpGuard(tester);
      expect(find.byType(AppBackGuard), findsOneWidget);
      expect(libraryVm.browsePath, '/music/Author');

      final handled = await tester.binding.handlePopRoute();
      await pumpFrames(tester);

      expect(handled, isTrue);
      expect(libraryVm.browsePath, '/music');
      expect(playback.stopCalled, isFalse);
      expect(find.text('library-root'), findsOneWidget);
    });

    testWidgets(
      'root back at library top stays in app without stopping playback',
      (tester) async {
        await libraryVm.navigateToBrowsePath(null);
        await pumpGuard(tester);

        final handled = await tester.binding.handlePopRoute();
        await pumpFrames(tester);

        expect(handled, isTrue);
        expect(playback.stopCalled, isFalse);
        expect(find.text('library-root'), findsOneWidget);
      },
    );

    testWidgets('edge back browses up after settings overlay is closed', (
      tester,
    ) async {
      await pumpGuard(tester);

      router.push(AppRouter.settings);
      await pumpFrames(tester, count: 8);
      expect(find.text('settings-overlay'), findsOneWidget);

      router.pop();
      await pumpFrames(tester, count: 8);
      expect(find.text('settings-overlay'), findsNothing);

      final handled = await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 12);

      expect(handled, isTrue);
      expect(libraryVm.browsePath, '/music');
      expect(playback.stopCalled, isFalse);
    });
  });
}

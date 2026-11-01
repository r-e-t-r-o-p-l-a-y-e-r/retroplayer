/// UC-14: Android system back / edge swipe through the real shell.
///
/// Every back here is a predictive back gesture ([sendSystemBackGesture]), the
/// path an edge swipe takes on a device, and every test checks that Android is
/// still told the app owns back ([recordFrameworkHandlesBack]).
///
/// Evidence:
/// - `cold start claims back for the framework`
/// - `settings round trip keeps back claimed and browses one level per back`
/// - `album detail round trip keeps back claimed`
/// - `expanded player on library collapses first`
/// - `expanded player over album collapses before closing it`
/// - `expanded player over playlist collapses before closing it`
/// - `expanded player under settings survives system back gesture without collapsing`
/// - `system back closes settings overlay while player stays expanded`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/playlist/views/playlist_detail_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/real_app.dart';
import '../../helpers/seeded_scan_library.dart';
import '../../helpers/system_back.dart';
import '../../helpers/track_factory.dart';

final _android = TargetPlatformVariant.only(TargetPlatform.android);

void main() {
  late List<bool> handlesBack;

  void expectBackClaimed() {
    expect(handlesBack, isNotEmpty);
    expect(
      handlesBack.last,
      isTrue,
      reason: 'Android would own the next edge swipe and slide the app away',
    );
  }

  double handleTop(WidgetTester tester) =>
      tester.getRect(find.byType(PlayerDragHandle).first).top;

  Future<void> dragPlayerOpen(WidgetTester tester) async {
    await tester.drag(
      find.byType(PlayerDragHandle).first,
      const Offset(0, -600),
    );
    await pumpFrames(tester, count: 25);
  }

  Future<RealApp> start(WidgetTester tester) async {
    handlesBack = recordFrameworkHandlesBack(tester);
    final album = book1Album();
    return pumpRealApp(
      tester,
      browsePath: '/music/Author/Book1',
      playing: album,
    );
  }

  testWidgets('cold start claims back for the framework', (tester) async {
    await start(tester);
    expect(find.byType(MainShellView), findsOneWidget);
    expectBackClaimed();
  }, variant: _android);

  testWidgets(
    'settings round trip keeps back claimed and browses one level per back',
    (tester) async {
      final app = await start(tester);

      app.shellRouter.push(AppRouter.settings);
      await pumpFrames(tester, count: 12);
      expect(find.byType(SettingsView), findsOneWidget);

      await sendSystemBackGesture(tester);
      expect(find.byType(SettingsView), findsNothing);
      expect(app.libraryVm.browsePath, '/music/Author/Book1');
      expectBackClaimed();

      await sendSystemBackGesture(tester);
      expect(app.libraryVm.browsePath, '/music/Author');
      expectBackClaimed();
      await sendSystemBackGesture(tester);
      expect(app.libraryVm.browsePath, '/music');
      await sendSystemBackGesture(tester);
      expect(app.libraryVm.browsePath, isNull);
      // Library root: absorbed, app stays.
      await sendSystemBackGesture(tester);
      expect(find.byType(MainShellView), findsOneWidget);
      expect(app.playback.stopCalled, isFalse);
      expectBackClaimed();
    },
    variant: _android,
  );

  testWidgets('album detail round trip keeps back claimed', (tester) async {
    final app = await start(tester);

    app.shellRouter.push(AppRouter.albumDetailLocation, extra: book1Album());
    await pumpFrames(tester, count: 12);
    expect(find.byType(AlbumDetailView), findsOneWidget);

    await sendSystemBackGesture(tester);
    expect(find.byType(AlbumDetailView), findsNothing);
    expect(find.byType(MainShellView), findsOneWidget);
    expectBackClaimed();

    await sendSystemBackGesture(tester);
    expect(app.libraryVm.browsePath, '/music/Author');
    expectBackClaimed();
  }, variant: _android);

  testWidgets(
    'expanded player under settings survives system back gesture without collapsing',
    (tester) async {
      final app = await start(tester);

      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 20);
      expect(app.panelVm.isExpanded, isTrue);

      app.shellRouter.push(AppRouter.settings);
      await pumpFrames(tester, count: 12);
      expect(find.byType(SettingsView), findsOneWidget);

      await sendSystemBackGesture(tester);
      expect(app.panelVm.isExpanded, isTrue);
    },
    variant: _android,
  );

  testWidgets(
    'system back closes settings overlay while player stays expanded',
    (tester) async {
      final app = await start(tester);

      await tester.tap(find.byIcon(Icons.expand_less));
      await pumpFrames(tester, count: 20);
      expect(app.panelVm.isExpanded, isTrue);

      app.shellRouter.push(AppRouter.settings);
      await pumpFrames(tester, count: 12);
      expect(find.byType(SettingsView), findsOneWidget);

      await sendSystemBackGesture(tester);
      expect(find.byType(SettingsView), findsNothing);
      expect(app.panelVm.isExpanded, isTrue);
    },
    variant: _android,
  );

  testWidgets('expanded player on library collapses first', (tester) async {
    final app = await start(tester);
    final collapsedTop = handleTop(tester);

    await tester.tap(find.byIcon(Icons.expand_less));
    await pumpFrames(tester, count: 20);
    expect(app.panelVm.isExpanded, isTrue);

    await sendSystemBackGesture(tester);
    expect(app.panelVm.isExpanded, isFalse);
    expect(handleTop(tester), closeTo(collapsedTop, 1));
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
    expectBackClaimed();

    await sendSystemBackGesture(tester);
    expect(app.libraryVm.browsePath, '/music/Author');
    expectBackClaimed();
  }, variant: _android);

  testWidgets('expanded player over album collapses before closing it', (
    tester,
  ) async {
    final app = await start(tester);

    app.shellRouter.push(AppRouter.albumDetailLocation, extra: book1Album());
    await pumpFrames(tester, count: 12);
    final collapsedTop = handleTop(tester);

    await dragPlayerOpen(tester);
    expect(app.panelVm.isExpanded, isTrue);
    expect(handleTop(tester), lessThan(collapsedTop - 300));

    await sendSystemBackGesture(tester);
    expect(app.panelVm.isExpanded, isFalse);
    expect(
      handleTop(tester),
      closeTo(collapsedTop, 1),
      reason: 'the sheet itself must slide back down, not just the flag',
    );
    expect(find.byType(AlbumDetailView), findsOneWidget);
    expectBackClaimed();

    await sendSystemBackGesture(tester);
    expect(find.byType(AlbumDetailView), findsNothing);
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
    expectBackClaimed();

    // Library sheet must be bound again after the album sheet is disposed.
    await dragPlayerOpen(tester);
    expect(app.panelVm.isExpanded, isTrue);
    await sendSystemBackGesture(tester);
    expect(app.panelVm.isExpanded, isFalse);
    expect(handleTop(tester), closeTo(collapsedTop, 1));
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
  }, variant: _android);

  testWidgets('expanded player over playlist collapses before closing it', (
    tester,
  ) async {
    handlesBack = recordFrameworkHandlesBack(tester);
    final track1 = testTrack(
      filePath: '/music/track01.mp3',
      directoryPath: '/music',
      metadata: const TrackMetadata(title: 'Track One'),
    );
    final track2 = testTrack(
      filePath: '/music/track02.mp3',
      directoryPath: '/music',
      metadata: const TrackMetadata(title: 'Track Two'),
    );
    final playlist = PlaylistFile(
      filePath: '/music/road.m3u',
      entryPaths: [track1.filePath, track2.filePath],
    );
    final app = await pumpRealApp(
      tester,
      repository: (storage) => seededLibraryRepository(
        storage,
        tracksByPath: {track1.filePath: track1, track2.filePath: track2},
        itemsByDirectory: {
          '/music': [LibraryItem.playlist(playlist: playlist)],
        },
      ),
      seed: (repo) => repo.seedChildFolders('/music', const []),
      browsePath: '/music',
    );

    await tester.tap(find.text('road'));
    await pumpFrames(tester, count: 12);
    expect(find.byType(PlaylistDetailView), findsOneWidget);
    await tester.tap(find.text('Track One'));
    await pumpFrames(tester, count: 12);
    expect(app.playerVm.currentItemId, playlist.id);

    await dragPlayerOpen(tester);
    expect(app.panelVm.isExpanded, isTrue);

    await sendSystemBackGesture(tester);
    expect(app.panelVm.isExpanded, isFalse);
    expect(find.byType(PlaylistDetailView), findsOneWidget);
    expectBackClaimed();

    await sendSystemBackGesture(tester);
    expect(find.byType(PlaylistDetailView), findsNothing);
    expect(find.byType(MainShellView), findsOneWidget);
    expectBackClaimed();
  }, variant: _android);
}

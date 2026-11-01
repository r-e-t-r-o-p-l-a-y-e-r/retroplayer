/// Characterization of the main user flows through the real shell (UC-04,
/// UC-07, UC-12, UC-13). These lock today's behavior before refactoring.
///
/// Evidence:
/// - `browse into three levels and back up restores each folder`
/// - `album detail: open, play a track, close keeps mini player`
/// - `play from library expands the player; collapse returns to the list`
/// - `locate now playing jumps back to the playing folder`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/real_app.dart';
import '../../helpers/system_back.dart';

void main() {
  testWidgets('browse into three levels and back up restores each folder',
      (tester) async {
    final app = await pumpRealApp(tester);
    expect(app.libraryVm.browsePath, isNull);

    await tester.tap(find.text('music'));
    await pumpFrames(tester);
    expect(app.libraryVm.browsePath, '/music');
    await tester.tap(find.text('Author'));
    await pumpFrames(tester);
    expect(app.libraryVm.browsePath, '/music/Author');
    await tester.tap(find.text('Book1'));
    await pumpFrames(tester);
    expect(app.libraryVm.browsePath, '/music/Author/Book1');

    await sendSystemBackGesture(tester);
    expect(app.libraryVm.browsePath, '/music/Author');
    expect(find.text('Book1'), findsOneWidget);
    await sendSystemBackGesture(tester);
    expect(app.libraryVm.browsePath, '/music');
    await sendSystemBackGesture(tester);
    expect(app.libraryVm.browsePath, isNull);
  });

  testWidgets('album detail: open, play a track, close keeps mini player',
      (tester) async {
    final app = await pumpRealApp(tester, browsePath: '/music/Author/Book1');

    app.shellRouter.push(AppRouter.albumDetailLocation, extra: book1Album());
    await pumpFrames(tester, count: 12);
    expect(find.byType(AlbumDetailView), findsOneWidget);

    await tester.tap(find.text('Chapter 2'));
    await pumpFrames(tester, count: 12);
    expect(app.playerVm.currentTrack?.id, 't2');
    expect(app.playback.lastStartIndex, 1);

    await sendSystemBackGesture(tester);
    expect(find.byType(AlbumDetailView), findsNothing);
    expect(find.byType(MainShellView), findsOneWidget);
    expect(find.byType(PlayerDragHandle), findsOneWidget);
    expect(app.playerVm.hasTrack, isTrue);
  });

  testWidgets(
      'play from library expands the player; collapse returns to the list',
      (tester) async {
    final app = await pumpRealApp(tester, browsePath: '/music/Author/Book1');

    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await pumpFrames(tester, count: 20);
    expect(app.playback.playCalled, isTrue);
    expect(app.playerVm.currentItemId, book1Album().id);
    expect(app.panelVm.isExpanded, isTrue);

    await tester.tap(find.byIcon(Icons.expand_more));
    await pumpFrames(tester, count: 20);
    expect(app.panelVm.isExpanded, isFalse);
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
  });

  testWidgets('locate now playing jumps back to the playing folder',
      (tester) async {
    final app = await pumpRealApp(
      tester,
      browsePath: '/music/Author/Book1',
      playing: book1Album(),
    );
    await app.libraryVm.navigateToBrowsePath(null);
    await pumpFrames(tester);
    expect(app.libraryVm.browsePath, isNull);

    await tester.tap(find.text('Chapter 1').first);
    await pumpFrames(tester, count: 20);

    expect(app.libraryVm.browsePath, '/music/Author/Book1');
  });
}

/// jumpToNowPlaying collapses an expanded player sheet.
///
/// Evidence:
/// - `jumpToNowPlaying collapses expanded player and opens album detail`
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';

void main() {
  testWidgets('jumpToNowPlaying collapses expanded player and opens album detail', (
    tester,
  ) async {
    final env = await pumpRealApp(tester, playing: book1Album());
    await tester.tap(find.byIcon(Icons.expand_less));
    await pumpFrames(tester, count: 30);
    expect(env.panelVm.isExpanded, isTrue);

    await LibraryNavigator.of(
      tester.element(find.byType(MainShellView)),
    ).jumpToNowPlaying();
    await pumpFrames(tester, count: 20);

    expect(env.panelVm.isExpanded, isFalse);
    expect(find.byType(AlbumDetailView), findsOneWidget);
    expect(
      env.libraryVm.highlightedTrackId,
      env.playerVm.currentTrack?.id,
    );
  });

  testWidgets(
    'jumpToNowPlaying on same album detail does not replace the route',
    (tester) async {
      final env = await pumpRealApp(tester, playing: book1Album());
      final nav = LibraryNavigator.of(
        tester.element(find.byType(MainShellView)),
      );
      unawaited(
        env.shellRouter.push(
          AppRouter.albumDetailLocation,
          extra: book1Album(),
        ),
      );
      await pumpFrames(tester, count: 20);

      final detailBefore = tester.element(find.byType(AlbumDetailView));

      env.panelVm.expand();
      await pumpFrames(tester, count: 30);
      expect(env.panelVm.isExpanded, isTrue);

      await nav.jumpToNowPlaying();
      await pumpFrames(tester, count: 20);

      expect(env.panelVm.isExpanded, isFalse);
      expect(find.byType(AlbumDetailView), findsOneWidget);
      expect(
        tester.element(find.byType(AlbumDetailView)),
        same(detailBefore),
      );
      expect(
        env.libraryVm.highlightedTrackId,
        env.playerVm.currentTrack?.id,
      );
    },
  );
}

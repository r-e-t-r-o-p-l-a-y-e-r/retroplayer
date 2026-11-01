/// Escape uses the same [BackPolicy] as system back.
///
/// Evidence:
/// - `Escape collapses the expanded player before browsing up`
/// - `Escape pops album detail when the player is collapsed`
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';

import '../../../helpers/keyboard_test_helpers.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';

void main() {
  testWidgets('Escape collapses the expanded player before browsing up', (
    tester,
  ) async {
    final app = await pumpRealApp(
      tester,
      browsePath: '/music/Author/Book1',
      playing: book1Album(),
    );

    await tester.tap(find.byIcon(Icons.expand_less));
    await pumpFrames(tester, count: 20);
    expect(app.panelVm.isExpanded, isTrue);

    await sendPlainKey(tester, LogicalKeyboardKey.escape);
    await pumpFrames(tester, count: 12);

    expect(app.panelVm.isExpanded, isFalse);
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
  });

  testWidgets('Escape pops album detail when the player is collapsed', (
    tester,
  ) async {
    final app = await pumpRealApp(tester, browsePath: '/music/Author/Book1');

    app.shellRouter.push(AppRouter.albumDetailLocation, extra: book1Album());
    await pumpFrames(tester, count: 12);
    expect(find.byType(AlbumDetailView), findsOneWidget);

    await sendPlainKey(tester, LogicalKeyboardKey.escape);
    await pumpFrames(tester, count: 12);

    expect(find.byType(AlbumDetailView), findsNothing);
    expect(app.libraryVm.browsePath, '/music/Author/Book1');
  });
}

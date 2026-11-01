/// Settings reset clears the database and can forget library folders.
///
/// Evidence:
/// - `reset sits above about and keeps or removes library folders`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';

void main() {
  testWidgets('reset sits above about and keeps or removes library folders', (
    tester,
  ) async {
    final app = await pumpRealApp(tester);
    await app.storage.savePlaybackState(
      itemId: 'album-1',
      trackId: 'track-1',
      positionMs: 1500,
      speed: 1,
    );
    await app.storage.setFavoriteFolders(['/music/Author']);
    await app.libraryVm.browseInto('/music');

    app.shellRouter.push(AppRouter.settings);
    await pumpFrames(tester, count: 12);

    final l10n = enL10n(tester);
    await tester.scrollUntilVisible(
      find.text(l10n.about),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byType(SettingsView), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l10n.resetDatabase)).dy,
      lessThan(tester.getTopLeft(find.text(l10n.about)).dy),
    );

    await tester.tap(find.text(l10n.resetDatabase));
    await pumpFrames(tester);
    expect(find.text(l10n.resetDatabaseBody), findsOneWidget);
    expect(find.text(l10n.resetDatabaseKeepFolders), findsOneWidget);
    expect(find.text(l10n.resetDatabaseClearEverything), findsOneWidget);

    await tester.tap(find.text(l10n.resetDatabaseKeepFolders));
    await pumpFrames(tester, count: 8);

    expect(await app.storage.getLibraryRoots(), ['/music']);
    expect(app.libraryVm.libraryRoots, ['/music']);
    expect(app.libraryVm.browsePath, isNull);
    expect(await app.storage.getPlaybackState('album-1'), isNull);
    expect(await app.storage.getFavoriteFolders(), isEmpty);

    await tester.tap(find.text(l10n.resetDatabase));
    await pumpFrames(tester);
    await tester.tap(find.text(l10n.resetDatabaseClearEverything));
    await pumpFrames(tester, count: 8);

    expect(await app.storage.getLibraryRoots(), isEmpty);
    expect(app.libraryVm.libraryRoots, isEmpty);
  });
}

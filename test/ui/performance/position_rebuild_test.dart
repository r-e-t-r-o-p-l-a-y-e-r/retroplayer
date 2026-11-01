/// Position ticks rebuild the progress bar, not the shell or library tiles.
///
/// Evidence:
/// - `position ticks do not rebuild AppBar, PlayerSheetHost or LibraryItemTile`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/library/widgets/library_item_tile.dart';
import 'package:retroplayer/ui/features/player/widgets/playback_progress_bar.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';

import '../../helpers/real_app.dart';

void main() {
  testWidgets(
    'position ticks do not rebuild AppBar, PlayerSheetHost or LibraryItemTile',
    (tester) async {
      final app = await pumpRealApp(
        tester,
        browsePath: '/music/Author/Book1',
        playing: book1Album(),
      );

      expect(find.byType(RetroProgressBar), findsWidgets);
      expect(find.byType(PlayerSheetHost), findsWidgets);
      expect(find.byType(LibraryItemTile), findsWidgets);
      expect(find.byType(AppBar), findsWidgets);

      final rebuilds = <Type, int>{
        AppBar: 0,
        PlayerSheetHost: 0,
        LibraryItemTile: 0,
        RetroProgressBar: 0,
      };
      final previous = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        previous?.call(element, builtOnce);
        final type = element.widget.runtimeType;
        if (rebuilds.containsKey(type)) {
          rebuilds[type] = rebuilds[type]! + 1;
        }
      };
      addTearDown(() => debugOnRebuildDirtyWidget = previous);

      app.playback.emitPosition(const Duration(seconds: 12));
      await tester.pump();
      app.playback.emitPosition(const Duration(seconds: 24));
      await tester.pump();

      expect(rebuilds[AppBar], 0);
      expect(rebuilds[PlayerSheetHost], 0);
      expect(rebuilds[LibraryItemTile], 0);
      expect(find.textContaining('00:24'), findsWidgets);
    },
  );
}

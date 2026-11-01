/// Player album-art focus chrome FocusNode wiring and tap-to-activate.
///
/// Evidence:
/// - `player focus chrome attaches a focus node to album art`
/// - `player focus chrome tap invokes onActivate`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/player_focus.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('player focus chrome attaches a focus node to album art', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: PlayerFocusChrome(
            focusKey: const ValueKey('player_art_focus_node'),
            order: const NumericFocusOrder(1),
            onActivate: () {},
            child: const AlbumArtFrame(size: 120),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final artFocus = tester.widget<Focus>(
      find.byKey(const ValueKey('player_art_focus_node')),
    );
    expect(artFocus.focusNode, isNotNull);
    expect(find.byType(AlbumArtFrame), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsOneWidget);
  });

  testWidgets('player focus chrome tap invokes onActivate', (tester) async {
    var activated = 0;
    await tester.pumpWidget(
      wrapWithL10n(
        FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: PlayerFocusChrome(
            order: const NumericFocusOrder(1),
            onActivate: () => activated++,
            child: const SizedBox(
              width: 200,
              height: 80,
              child: Text('Track Title'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Track Title'));
    await tester.pump();

    expect(activated, 1);
  });
}

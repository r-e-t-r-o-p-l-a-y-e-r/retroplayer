/// Bottom navigation slop for player sheet drags (mirrors folder favorite back edge).
///
/// Evidence:
/// - `drag start in bottom slop is ineligible`
/// - `drag start above bottom slop is eligible`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_gesture.dart';

void main() {
  testWidgets('drag start in bottom slop is ineligible', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          systemGestureInsets: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            expect(
              isPlayerSheetVerticalDragEligible(
                context,
                const Offset(200, 795),
              ),
              isFalse,
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('drag start above bottom slop is eligible', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          systemGestureInsets: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            expect(
              isPlayerSheetVerticalDragEligible(
                context,
                const Offset(200, 700),
              ),
              isTrue,
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });
}

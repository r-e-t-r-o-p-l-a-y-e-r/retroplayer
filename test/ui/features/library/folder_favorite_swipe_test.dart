/// Folder favorite swipe reveals a left action strip like remove on the right.
///
/// Evidence:
/// - `partial swipe right colors only a left strip not the full row`
/// - `partial swipe right leaves most of the row width unstained`
/// - `regression: drag follows finger past row width without a max clamp`
/// - `folder_favorite_swipe source must not reintroduce a max drag cap`
/// - `release before dismiss threshold fraction does not toggle favorite`
/// - `release past dismiss threshold fraction toggles favorite`
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/ui/features/library/widgets/folder_favorite_swipe.dart';

import '../../../helpers/pump_app.dart';

final _folderFavoriteSwipeSource = File(
  p.join(
    Directory.current.path,
    'lib',
    'ui',
    'features',
    'library',
    'widgets',
    'folder_favorite_swipe.dart',
  ),
).readAsStringSync();

const _rowWidth = 300.0;
const _partialDrag = 40.0;

double _commitThresholdPx(double rowWidth) =>
    rowWidth * kFolderFavoriteDismissThreshold;

Widget _harness({required Future<void> Function() onToggle}) {
  return wrapWithL10n(
    Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: _rowWidth,
          child: FolderFavoriteSwipe(
            isFavorite: false,
            onToggle: onToggle,
            child: ListTile(
              key: const ValueKey('folder-row'),
              tileColor: Colors.transparent,
              title: const Text('Author'),
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _primaryColoredBoxes(Color primary) {
  return find.byWidgetPredicate(
    (widget) => widget is ColoredBox && widget.color == primary,
  );
}

void main() {
  test('folder_favorite_swipe source must not reintroduce a max drag cap', () {
    expect(_folderFavoriteSwipeSource, isNot(contains('_maxDrag')));
    expect(_folderFavoriteSwipeSource, isNot(contains('maxDrag')));
    expect(
      RegExp(
        r'_dragExtent\s*=.*\.clamp\s*\(\s*0(?:\.0)?\s*,\s*(?!double\.infinity)[^)]+\)',
      ).hasMatch(_folderFavoriteSwipeSource),
      isFalse,
      reason: 'drag extent must not clamp to a finite upper bound while dragging',
    );
    expect(
      _folderFavoriteSwipeSource,
      contains('kFolderFavoriteDismissThreshold'),
    );
    expect(
      RegExp(r'static const _commitThreshold\s*=\s*\d').hasMatch(
        _folderFavoriteSwipeSource,
      ),
      isFalse,
      reason: 'commit distance must scale with row width, not a fixed pixel constant',
    );
  });

  testWidgets('partial swipe right colors only a left strip not the full row', (
    tester,
  ) async {
    var toggled = false;
    await tester.pumpWidget(_harness(onToggle: () async => toggled = true));
    await pumpFrames(tester);

    final primary = Theme.of(tester.element(find.byType(FolderFavoriteSwipe)))
        .colorScheme
        .primary;
    final rowCenter = tester.getCenter(find.byKey(const ValueKey('folder-row')));

    final gesture = await tester.startGesture(rowCenter);
    await gesture.moveBy(const Offset(_partialDrag, 0));
    await tester.pump();

    final boxes = _primaryColoredBoxes(primary);
    expect(boxes, findsOneWidget);
    final stripWidth = tester.getSize(boxes).width;
    expect(
      stripWidth,
      lessThan(_rowWidth * 0.5),
      reason: 'action color should not cover the full row during a short drag',
    );
    expect(stripWidth, closeTo(_partialDrag, 8));
    expect(toggled, isFalse);
  });

  testWidgets('partial swipe right leaves most of the row width unstained', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(onToggle: () async {}));
    await pumpFrames(tester);

    final primary = Theme.of(tester.element(find.byType(FolderFavoriteSwipe)))
        .colorScheme
        .primary;
    final rowCenter = tester.getCenter(find.byKey(const ValueKey('folder-row')));

    final gesture = await tester.startGesture(rowCenter);
    await gesture.moveBy(const Offset(_partialDrag, 0));
    await tester.pump();

    final stripWidth = tester.getSize(_primaryColoredBoxes(primary)).width;
    expect(_rowWidth - stripWidth, greaterThan(_rowWidth * 0.75));
  });

  testWidgets('regression: drag follows finger past row width without a max clamp', (
    tester,
  ) async {
    const longDrag = 400.0;
    assert(
      longDrag > _rowWidth,
      'must exceed row width so a row-sized cap would fail',
    );

    await tester.pumpWidget(_harness(onToggle: () async {}));
    await pumpFrames(tester);

    final primary = Theme.of(tester.element(find.byType(FolderFavoriteSwipe)))
        .colorScheme
        .primary;
    final rowCenter = tester.getCenter(find.byKey(const ValueKey('folder-row')));

    final gesture = await tester.startGesture(rowCenter);
    await gesture.moveBy(const Offset(longDrag, 0));
    await tester.pump();

    final stripWidth = tester.getSize(_primaryColoredBoxes(primary)).width;
    expect(stripWidth, greaterThan(_rowWidth));
    expect(stripWidth, closeTo(longDrag, 8));
  });

  testWidgets('release before dismiss threshold fraction does not toggle favorite', (
    tester,
  ) async {
    var toggled = false;
    final threshold = _commitThresholdPx(_rowWidth);
    final drag = threshold - 8;

    await tester.pumpWidget(_harness(onToggle: () async => toggled = true));
    await pumpFrames(tester);

    final rowCenter = tester.getCenter(find.byKey(const ValueKey('folder-row')));
    final gesture = await tester.startGesture(rowCenter);
    await gesture.moveBy(Offset(drag, 0));
    await gesture.up();
    await pumpFrames(tester);

    expect(toggled, isFalse);
  });

  testWidgets('release past dismiss threshold fraction toggles favorite', (
    tester,
  ) async {
    var toggled = false;
    final threshold = _commitThresholdPx(_rowWidth);
    final drag = threshold + 8;

    await tester.pumpWidget(_harness(onToggle: () async => toggled = true));
    await pumpFrames(tester);

    final rowCenter = tester.getCenter(find.byKey(const ValueKey('folder-row')));
    final gesture = await tester.startGesture(rowCenter);
    await gesture.moveBy(Offset(drag, 0));
    await gesture.up();
    await pumpFrames(tester);

    expect(toggled, isTrue);
  });
}

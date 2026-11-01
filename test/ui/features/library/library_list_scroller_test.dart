/// LibraryListScroller jumps using the real scroll extent.
///
/// Evidence:
/// - `jumpToRow moves ScrollController toward later rows`
/// - `jumpToOffset restores a captured pixel offset`
/// - `RestoringScrollController paints at pending offset on attach`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';

void main() {
  testWidgets('jumpToRow moves ScrollController toward later rows', (
    tester,
  ) async {
    final controller = ScrollController();
    final scroller = LibraryListScroller()..controller = controller;
    scroller.updateCounts(folders: 40, playlists: 0, audio: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            controller: controller,
            itemCount: 40,
            itemExtent: 50,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
    scroller.jumpToRow(20);
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(100));
    expect(controller.offset, lessThan(controller.position.maxScrollExtent));
  });

  testWidgets('jumpToOffset restores a captured pixel offset', (tester) async {
    final controller = ScrollController();
    final scroller = LibraryListScroller()..controller = controller;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            controller: controller,
            itemCount: 40,
            itemExtent: 50,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.jumpTo(350);
    await tester.pumpAndSettle();
    expect(scroller.currentOffset, 350);

    controller.jumpTo(0);
    await tester.pumpAndSettle();
    scroller.jumpToOffset(350);
    await tester.pumpAndSettle();
    expect(controller.offset, 350);
  });

  testWidgets('RestoringScrollController paints at pending offset on attach', (
    tester,
  ) async {
    final controller = RestoringScrollController()..pendingInitialOffset = 350;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            key: const ValueKey('parent'),
            controller: controller,
            itemCount: 40,
            itemExtent: 50,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(controller.hasClients, isTrue);
    expect(controller.offset, 350);
  });
}

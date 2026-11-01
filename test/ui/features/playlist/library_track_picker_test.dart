/// Library-scoped playlist track picker multi-select.
///
/// Evidence:
/// - `lists only audio under library roots`
/// - `confirms selected paths`
/// - `starts at initialPath under a root`
/// - `tapping a selected title clears it`
/// - `titles already in the playlist stay disabled in folder order`
/// - `select all checks every new title in the folder and clears them again`
/// - `German select all tooltip switches to deselect all`
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/features/playlist/views/library_track_picker_page.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('rpc-lib-picker-');
    final album = Directory(p.join(root.path, 'Album'))..createSync();
    File(p.join(album.path, 'a.mp3')).writeAsStringSync('x');
    File(p.join(album.path, 'b.mp3')).writeAsStringSync('x');
    File(p.join(album.path, 'note.txt')).writeAsStringSync('nope');
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  testWidgets('lists only audio under library roots and confirms selection', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpWidget(
      wrapWithL10n(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await LibraryTrackPickerPage.open(
                    context,
                    libraryRoots: [root.path],
                    initialPath: p.join(root.path, 'Album'),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryTrackPickerPage), findsOneWidget);
    expect(find.text('a.mp3'), findsOneWidget);
    expect(find.text('b.mp3'), findsOneWidget);
    expect(find.text('note.txt'), findsNothing);

    await tester.tap(find.text('a.mp3'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add (1)'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.length, 1);
    expect(result!.first.endsWith('a.mp3'), isTrue);
  });

  testWidgets('tapping a selected title clears it', (tester) async {
    List<String>? result;
    await tester.pumpWidget(
      wrapWithL10n(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await LibraryTrackPickerPage.open(
                    context,
                    libraryRoots: [root.path],
                    initialPath: p.join(root.path, 'Album'),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('a.mp3'));
    await tester.pump();
    await tester.tap(find.text('b.mp3'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Add (2)'), findsOneWidget);

    await tester.tap(find.text('a.mp3'));
    await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Add (1)'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Add (1)'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.length, 1);
    expect(result!.single.endsWith('b.mp3'), isTrue);
  });

  testWidgets('titles already in the playlist stay disabled in folder order', (
    tester,
  ) async {
    final already = p.join(root.path, 'Album', 'a.mp3');
    await tester.pumpWidget(
      wrapWithL10n(
        LibraryTrackPickerPage(
          libraryRoots: [root.path],
          initialPath: p.join(root.path, 'Album'),
          alreadySelected: {already},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(tiles, hasLength(2));
    expect((tiles[0].title! as Text).data, 'a.mp3');
    expect(tiles[0].value, isTrue);
    expect(tiles[0].onChanged, isNull);
    expect((tiles[1].title! as Text).data, 'b.mp3');
    expect(tiles[1].onChanged, isNotNull);

    await tester.tap(find.text('a.mp3'));
    await tester.pump();
    expect(
      tester
          .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
          .value,
      isTrue,
    );
    expect(find.widgetWithText(FilledButton, 'Add (1)'), findsNothing);
  });

  testWidgets(
    'select all checks every new title in the folder and clears them again',
    (tester) async {
      final already = p.join(root.path, 'Album', 'a.mp3');
      await tester.pumpWidget(
        wrapWithL10n(
          LibraryTrackPickerPage(
            libraryRoots: [root.path],
            initialPath: p.join(root.path, 'Album'),
            alreadySelected: {already},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.byTooltip(en.playlistSelectAll), findsOneWidget);
      await tester.tap(find.byTooltip(en.playlistSelectAll));
      await tester.pump();

      expect(find.widgetWithText(FilledButton, 'Add (1)'), findsOneWidget);
      expect(find.byTooltip(en.playlistDeselectAll), findsOneWidget);
      final tiles = tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .toList();
      expect(tiles[0].onChanged, isNull);
      expect(tiles[0].value, isTrue);
      expect(tiles[1].value, isTrue);

      await tester.tap(find.byTooltip(en.playlistDeselectAll));
      await tester.pump();

      expect(find.widgetWithText(FilledButton, 'Add (1)'), findsNothing);
      expect(find.byTooltip(en.playlistSelectAll), findsOneWidget);
      expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .elementAt(1)
            .value,
        isFalse,
      );
    },
  );

  testWidgets('German select all tooltip switches to deselect all', (
    tester,
  ) async {
    final de = lookupAppLocalizations(const Locale('de'));
    await tester.pumpWidget(
      wrapWithL10n(
        LibraryTrackPickerPage(
          libraryRoots: [root.path],
          initialPath: p.join(root.path, 'Album'),
        ),
        locale: const Locale('de'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(de.playlistSelectAll), findsOneWidget);
    await tester.tap(find.byTooltip(de.playlistSelectAll));
    await tester.pump();
    expect(find.text('Hinzufügen (2)'), findsOneWidget);
    expect(find.byTooltip(de.playlistDeselectAll), findsOneWidget);
  });
}

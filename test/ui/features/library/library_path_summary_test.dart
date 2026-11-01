/// LibraryPathSummary breadcrumb rendering and tap navigation.
///
/// Evidence:
/// - `LibraryPathSummary shows breadcrumb trail and handles taps`
/// - `keeps the current folder on screen when the trail is wider`
/// - `ellipsizes a current folder wider than the bar`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('LibraryPathSummary shows breadcrumb trail and handles taps', (
    tester,
  ) async {
    String? navigatedPath;

    await tester.pumpWidget(
      wrapWithL10n(
        Scaffold(
          body: LibraryPathSummary(
            breadcrumbs: const [
              BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true),
              BrowseBreadcrumb(label: 'music', path: '/music'),
              BrowseBreadcrumb(label: 'Author', path: '/music/Author'),
              BrowseBreadcrumb(label: 'Book1', path: '/music/Author/Book1'),
            ],
            onNavigate: (path) => navigatedPath = path,
          ),
        ),
      ),
    );

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('music'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Book1'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));

    final bar = tester.getRect(find.byType(LibraryPathSummary));
    final library = tester.getRect(find.text('Library'));
    final book = tester.getRect(find.text('Book1'));
    expect(library.left, lessThan(bar.left + 40));
    expect(book.left, greaterThan(library.left));
    expect(bar.right - book.right, greaterThan(library.left - bar.left));

    await tester.tap(find.text('Author'));
    await tester.pump();

    expect(navigatedPath, '/music/Author');
  });

  testWidgets('keeps the current folder on screen when the trail is wider', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        const Scaffold(
          body: SizedBox(
            width: 200,
            height: 48,
            child: LibraryPathSummary(
              breadcrumbs: [
                BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true),
                BrowseBreadcrumb(label: 'EarlyFolder', path: '/early'),
                BrowseBreadcrumb(label: 'ParentFolder', path: '/early/parent'),
                BrowseBreadcrumb(
                  label: 'Current',
                  path: '/early/parent/current',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final bar = tester.getRect(find.byType(LibraryPathSummary));
    final current = tester.getRect(find.text('Current'));
    expect(current.left, greaterThanOrEqualTo(bar.left));
    expect(current.right, lessThanOrEqualTo(bar.right + 1));
    expect(tester.getTopLeft(find.text('EarlyFolder')).dx, lessThan(bar.left));

    await tester.drag(find.byType(SingleChildScrollView), const Offset(400, 0));
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('EarlyFolder')).dx,
      greaterThanOrEqualTo(bar.left),
    );
    final currentAfter = tester.getRect(find.text('Current'));
    expect(currentAfter.left, greaterThanOrEqualTo(bar.left));
    expect(currentAfter.right, lessThanOrEqualTo(bar.right + 1));
  });

  testWidgets('ellipsizes a current folder wider than the bar', (tester) async {
    const name = 'A-folder-name-that-is-much-wider-than-the-breadcrumb-bar';
    await tester.pumpWidget(
      wrapWithL10n(
        const Scaffold(
          body: SizedBox(
            width: 160,
            height: 48,
            child: LibraryPathSummary(
              breadcrumbs: [BrowseBreadcrumb(label: name, path: '/music')],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final bar = tester.getRect(find.byType(LibraryPathSummary));
    final label = tester.getRect(find.text(name));
    expect(label.left, greaterThanOrEqualTo(bar.left - 1));
    expect(label.right, lessThanOrEqualTo(bar.right + 1));
  });
}

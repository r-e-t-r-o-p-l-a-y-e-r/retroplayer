/// Desktop AppBar back leading visibility and [backLeadingApplies].
///
/// Evidence:
/// - `backLeadingApplies mirrors BackPolicy absorb vs actionable back`
/// - `AppBarBackLeading hidden when desktopHostCheck is false`
/// - `AppBarBackLeading shows on desktop when browse up applies`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

void main() {
  group('backLeadingApplies', () {
    const library = LibraryLocation();
    const album = AlbumDetailLocation();

    test('false at library root absorb', () {
      expect(
        backLeadingApplies(
          const BackState(location: library, canPop: true),
        ),
        isFalse,
      );
    });

    test('true when browse up', () {
      expect(
        backLeadingApplies(
          const BackState(location: library, canBrowseUp: true),
        ),
        isTrue,
      );
    });

    test('true when detail can pop', () {
      expect(
        backLeadingApplies(
          const BackState(location: album, canPop: true),
        ),
        isTrue,
      );
    });

    test('true when player expanded at root', () {
      expect(
        backLeadingApplies(
          const BackState(location: library, playerExpanded: true),
        ),
        isTrue,
      );
    });
  });

  group('AppBarBackLeading', () {
    late LibraryViewModel libraryVm;

    setUp(() async {
      final db = AppDatabase.inMemory();
      final storage = LibraryStorageService(db);
      final repo = testLibraryRepository(storage);
      await storage.addLibraryRoot('/music');
      seedAuthorBook1Hierarchy(repo);
      libraryVm = LibraryViewModel(libraryRepository: repo);
      await libraryVm.load();
    });

    Widget appBarHarness({required bool desktop}) {
      return wrapWithL10n(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: libraryVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
          ],
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: AppBarBackLeading(desktopHostCheck: () => desktop),
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );
    }

    testWidgets('hidden when desktopHostCheck is false', (tester) async {
      await libraryVm.navigateToBrowsePath('/music/Author/Book1');

      await tester.pumpWidget(appBarHarness(desktop: false));
      await pumpFrames(tester, count: 5);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('visible on desktop when browse up applies', (tester) async {
      await libraryVm.navigateToBrowsePath('/music/Author/Book1');

      await tester.pumpWidget(appBarHarness(desktop: true));
      await pumpFrames(tester, count: 5);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hidden on desktop at library root', (tester) async {
      await libraryVm.navigateToBrowsePath(null);

      await tester.pumpWidget(appBarHarness(desktop: true));
      await pumpFrames(tester, count: 5);

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}

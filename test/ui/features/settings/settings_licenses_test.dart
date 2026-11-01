/// Settings navigates to OpenSourceLicensesView / LicensePage.
///
/// Evidence:
/// - `Settings opens open source licenses page`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/open_source_licenses_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('Settings opens open source licenses page', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => EqualizerViewModel(
              equalizerService: EqualizerService(storage),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeViewModel(storageService: storage),
          ),
          ChangeNotifierProvider(
            create: (_) => LocaleViewModel(storageService: storage),
          ),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapWithL10n(const SettingsView()),
      ),
    );
    await tester.pumpAndSettle();

    final licensesTile = find.byKey(
      const ValueKey('settings_open_source_licenses'),
    );
    await tester.scrollUntilVisible(
      licensesTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    Actions.invoke(
      tester.element(licensesTile),
      const ActivateIntent(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OpenSourceLicensesView), findsOneWidget);
    expect(find.byType(LicensePage), findsOneWidget);
  });
}

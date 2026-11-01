/// Settings About privacy subtitle still claims no telemetry/network.
///
/// Evidence:
/// - `Settings About shows no-network / no-telemetry copy`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('Settings About shows no-network / no-telemetry copy', (
    tester,
  ) async {
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

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsView)),
    );
    await tester.scrollUntilVisible(
      find.text(l10n.aboutSubtitle, findRichText: true),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.aboutSubtitle), findsOneWidget);
    expect(l10n.aboutSubtitle.toLowerCase(), contains('no telemetry'));
    expect(l10n.aboutSubtitle.toLowerCase(), contains('no network'));
  });
}

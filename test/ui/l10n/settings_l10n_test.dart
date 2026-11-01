/// Settings About version/build/git stamp UI and German app bar title.
///
/// Evidence:
/// - `Settings About shows version and build date`
/// - `Settings shows German app bar title`
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
import 'package:retroplayer/app_branding.dart';
import 'package:retroplayer/build_info.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Settings About shows version and build stamp', (tester) async {
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

    await tester.scrollUntilVisible(
      find.text(AppBranding.displayName),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Version'), findsOneWidget);
    expect(find.text(BuildInfo.versionLabel), findsOneWidget);
    expect(find.text('Build time'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')),
      findsOneWidget,
    );
    expect(find.text('Branch'), findsOneWidget);
    expect(find.text(BuildInfo.gitBranch), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text(BuildInfo.gitHash), findsOneWidget);
  });

  testWidgets('Settings shows German app bar title', (tester) async {
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
        child: wrapWithL10n(
          const SettingsView(),
          locale: const Locale('de'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
  });
}

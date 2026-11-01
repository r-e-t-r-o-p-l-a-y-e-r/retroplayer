/// Language picker shows endonyms and replaces segmented locale control.
///
/// Evidence:
/// - `language section does not use segmented button for locale`
/// - `picker lists Francais endonym not English exonym`
/// - `default storage shows system label on summary`
/// - `selecting Deutsch updates locale view model`
/// - `picker catalog uses native endonyms for ar ja hi`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/ui/features/settings/widgets/language_section.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;
  late LocaleViewModel localeViewModel;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
    localeViewModel = LocaleViewModel(storageService: storage);
  });

  tearDown(() => db.close());

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => EqualizerViewModel(
              equalizerService: EqualizerService(storage),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeViewModel(storageService: storage)..load(),
          ),
          ChangeNotifierProvider.value(value: localeViewModel),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapWithL10n(const SettingsView()),
      ),
    );
    await localeViewModel.load();
    await pumpFrames(tester);
  }

  Future<void> openLanguagePicker(WidgetTester tester) async {
    final summary = find.byKey(LanguageSection.summaryTileKey);
    await tester.scrollUntilVisible(
      summary,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(summary);
    await pumpFrames(tester, count: 8);
  }

  testWidgets('language section does not use segmented button for locale', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.byType(SegmentedButton<LocalePreference>), findsNothing);
  });

  testWidgets('picker lists Francais endonym not English exonym', (
    tester,
  ) async {
    await pumpSettings(tester);
    await openLanguagePicker(tester);
    const frKey = ValueKey<String>('language-option-fr');
    await tester.scrollUntilVisible(
      find.byKey(frKey),
      48,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.descendant(of: find.byKey(frKey), matching: find.text('Français')),
      findsOneWidget,
    );
    expect(find.text('French'), findsNothing);
  });

  testWidgets('default storage shows system label on summary', (tester) async {
    await pumpSettings(tester);
    expect(
      find.descendant(
        of: find.byKey(LanguageSection.summaryTileKey),
        matching: find.text('System language'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('selecting Deutsch updates locale view model', (tester) async {
    await pumpSettings(tester);

    await openLanguagePicker(tester);
    const deKey = ValueKey<String>('language-option-de');
    await tester.scrollUntilVisible(
      find.byKey(deKey),
      48,
      scrollable: find.byType(Scrollable).last,
    );
    tester.widget<ListTile>(find.byKey(deKey)).onTap!.call();
    await pumpFrames(tester, count: 8);
    expect(find.byType(AlertDialog), findsNothing);

    expect(localeViewModel.preference, LocalePreference.language('de'));
  });

  test('picker catalog uses native endonyms for ar ja hi', () {
    expect(AppLocaleCatalog.endonymForCode('ar'), 'العربية');
    expect(AppLocaleCatalog.endonymForCode('ja'), '日本語');
    expect(AppLocaleCatalog.endonymForCode('hi'), 'हिन्दी');
  });
}

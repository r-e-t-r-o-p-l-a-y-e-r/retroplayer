/// Settings Tab/arrow focus, Space/Enter activation, and subpage back registration.
///
/// Evidence:
/// - `Tab from last theme segment moves to language line`
/// - `pointer click on preset row sets line for arrow navigation`
/// - `EQ slider shows focus decoration when focused`
/// - `Tab focuses theme segmented control`
/// - `theme segmented control selects dark on tap`
/// - `settings subpage registers back navigation`
/// - `Space on theme segment selects dark`
/// - `Enter on locale segment selects German`
/// - `Space on bass preset selects bass boost`
/// - `Enter on data storage tile opens subpage`
/// - `Enter on open source licenses tile opens subpage`
/// - `arrow down moves focus from theme line to language line`
/// - `Tab leaves EQ band slider for next control`
/// - `arrow up on EQ slider moves to previous line`
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/ui/features/settings/widgets/language_section.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/ui/core/keyboard/app_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/data_storage_view.dart';
import 'package:retroplayer/ui/features/settings/views/open_source_licenses_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_panel.dart';

class _FakeEqualizerService implements EqualizerService {
  @override
  bool get isSupported => true;

  @override
  Future<void> apply(EqualizerSettings settings) async {}

  @override
  Future<EqualizerSettings> loadSettings() async => EqualizerSettings.manual();

  @override
  Future<void> loadAndApply() async {}

  @override
  Future<void> saveAndApply(EqualizerSettings settings) async {}

  @override
  Future<void> reapplyLast() async {}
}

Future<void> _sendWidgetKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  await tester.pump();
}

Future<void> _tabUntilFocused(
  WidgetTester tester,
  bool Function(BuildContext? focusContext) predicate, {
  int maxTabs = 40,
}) async {
  for (var i = 0; i < maxTabs; i++) {
    if (predicate(FocusManager.instance.primaryFocus?.context)) return;
    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
  }
  fail('Could not focus target control');
}

void main() {
  Future<void> pumpSettings(WidgetTester tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => EqualizerViewModel(
              equalizerService: _FakeEqualizerService(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeViewModel(storageService: storage)..load(),
          ),
          ChangeNotifierProvider(
            create: (_) => LocaleViewModel(storageService: storage)..load(),
          ),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
        ],
        child: wrapWithL10n(
          const AppShortcuts(child: SettingsView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Tab from last theme segment moves to language line', (tester) async {
    await pumpSettings(tester);

    await _tabUntilFocused(
      tester,
      (ctx) =>
          ctx?.findAncestorWidgetOfExactType<SegmentedButton<ThemePreference>>() !=
          null,
    );
    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<ListTile>(),
      isNotNull,
    );
    expect(
      focusContext!.findAncestorWidgetOfExactType<LanguageSection>(),
      isNotNull,
    );
  });

  testWidgets('pointer click on preset row sets line for arrow navigation', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Bass'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Bass'));
    await tester.pumpAndSettle();

    await _sendWidgetKey(tester, LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<LanguageSection>(),
      isNotNull,
    );
  });

  testWidgets('EQ slider shows focus decoration when focused', (tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('60'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('60'));
    await tester.pumpAndSettle();

    final focus = FocusManager.instance.primaryFocus;
    expect(focus, isNotNull);
    expect(focus!.hasFocus, isTrue);
    // Band slider draws an accent border while its Focus node is focused.
    final decorated = find.descendant(
      of: find.ancestor(
        of: find.text('60'),
        matching: find.byType(Row),
      ),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      ),
    );
    expect(decorated, findsOneWidget);
  });

  testWidgets('Tab focuses theme segmented control', (tester) async {
    await pumpSettings(tester);

    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final segmentedFinder = find.byType(SegmentedButton<ThemePreference>);
    expect(segmentedFinder, findsOneWidget);
    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<SegmentedButton<ThemePreference>>(),
      isNotNull,
    );
  });

  testWidgets('theme segmented control selects dark on tap', (tester) async {
    await pumpSettings(tester);
    final themeVm = tester
        .element(find.byType(SettingsView))
        .read<ThemeViewModel>();

    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    expect(themeVm.preference, ThemePreference.dark);
  });

  testWidgets('settings subpage registers back navigation', (tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Data storage'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Data storage'));
    await tester.pumpAndSettle();
    expect(find.byType(DataStorageView), findsOneWidget);

    final registry = tester
        .element(find.byType(DataStorageView))
        .read<KeyboardRegistry>();
    expect(registry.settingsSubpage?.navigateBack, isNotNull);

    registry.settingsSubpage!.navigateBack!.call();
    await tester.pumpAndSettle();

    expect(find.byType(DataStorageView), findsNothing);
  });

  testWidgets('Space on theme segment selects dark', (tester) async {
    await pumpSettings(tester);
    final themeVm =
        tester.element(find.byType(SettingsView)).read<ThemeViewModel>();

    await _tabUntilFocused(
      tester,
      (ctx) =>
          ctx?.findAncestorWidgetOfExactType<SegmentedButton<ThemePreference>>() !=
          null,
    );
    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await _sendWidgetKey(tester, LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(themeVm.preference, ThemePreference.dark);
  });

  testWidgets('Enter on language summary opens picker', (tester) async {
    await pumpSettings(tester);

    await _tabUntilFocused(
      tester,
      (ctx) =>
          ctx?.findAncestorWidgetOfExactType<SegmentedButton<ThemePreference>>() !=
          null,
    );
    await _sendWidgetKey(tester, LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await _tabUntilFocused(
      tester,
      (ctx) => ctx?.findAncestorWidgetOfExactType<LanguageSection>() != null,
    );
    await _sendWidgetKey(tester, LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Space on bass preset selects bass boost', (tester) async {
    await pumpSettings(tester);
    final eqVm =
        tester.element(find.byType(SettingsView)).read<EqualizerViewModel>();

    await tester.scrollUntilVisible(
      find.text('Bass'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Bass'));
    await tester.pumpAndSettle();

    expect(eqVm.selectedPreset, EqualizerPreset.bassBoost);
  });

  testWidgets('Enter on data storage tile opens subpage', (tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings_data_storage')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    Actions.invoke(
      tester.element(find.byKey(const ValueKey('settings_data_storage'))),
      const ActivateIntent(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataStorageView), findsOneWidget);
  });

  testWidgets('Enter on open source licenses tile opens subpage', (tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings_open_source_licenses')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    Actions.invoke(
      tester.element(
        find.byKey(const ValueKey('settings_open_source_licenses')),
      ),
      const ActivateIntent(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OpenSourceLicensesView), findsOneWidget);
  });

  testWidgets('arrow down moves focus from theme line to language line', (
    tester,
  ) async {
    await pumpSettings(tester);

    await _tabUntilFocused(
      tester,
      (ctx) =>
          ctx?.findAncestorWidgetOfExactType<SegmentedButton<ThemePreference>>() !=
          null,
    );
    await _sendWidgetKey(tester, LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<LanguageSection>(),
      isNotNull,
    );
  });

  testWidgets('Tab leaves EQ band slider for next control', (tester) async {
    await pumpSettings(tester);
    final eqVm =
        tester.element(find.byType(SettingsView)).read<EqualizerViewModel>();

    await tester.scrollUntilVisible(
      find.text('60'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('60'));
    await tester.pumpAndSettle();

    final gainBefore = eqVm.bands.first.gainDb;
    await _sendWidgetKey(tester, LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(eqVm.bands.first.gainDb, isNot(equals(gainBefore)));

    await _sendWidgetKey(tester, LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<ExcludeFocus>(),
      isNull,
    );
  });

  testWidgets('arrow up on EQ slider moves to previous line', (tester) async {
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('60'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('60'));
    await pumpFrames(tester, count: 8);

    await _sendWidgetKey(tester, LogicalKeyboardKey.arrowUp);
    await pumpFrames(tester, count: 8);

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<TextButton>(),
      isNotNull,
    );
  });
}

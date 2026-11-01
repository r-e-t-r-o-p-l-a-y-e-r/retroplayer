/// UC-16: Settings sections render through the real shell.
///
/// Evidence:
/// - `settings shows appearance, language and equalizer sections`
/// - `data storage subpage opens and back closes it`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/settings/views/data_storage_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';
import 'package:retroplayer/ui/features/settings/widgets/equalizer_section.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';
import '../../../helpers/system_back.dart';

void main() {
  testWidgets('settings shows appearance, language and equalizer sections',
      (tester) async {
    final app = await pumpRealApp(tester);
    app.shellRouter.push(AppRouter.settings);
    await pumpFrames(tester, count: 12);

    final l10n = enL10n(tester);
    expect(find.byType(SettingsView), findsOneWidget);
    expect(find.text(l10n.appearance), findsWidgets);
    expect(find.text(l10n.language), findsWidgets);
    expect(find.byType(EqualizerSection), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(EqualizerSection),
        matching: find.text(l10n.bands),
      ),
      findsOneWidget,
    );
  });

  testWidgets('data storage subpage opens and back closes it', (tester) async {
    final app = await pumpRealApp(tester);
    app.shellRouter.push(AppRouter.settings);
    await pumpFrames(tester, count: 12);

    final l10n = enL10n(tester);
    await tester.scrollUntilVisible(
      find.text(l10n.dataStorage),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(l10n.dataStorage));
    await pumpFrames(tester, count: 12);
    expect(find.byType(DataStorageView), findsOneWidget);
    expect(find.text(l10n.dataStorageLibraryTitle), findsOneWidget);

    await sendSystemBackGesture(tester);
    expect(find.byType(DataStorageView), findsNothing);
    expect(find.byType(SettingsView), findsOneWidget);
  });
}

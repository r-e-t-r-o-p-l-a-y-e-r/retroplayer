/// Desktop shortcut tooltip string formatting.
///
/// Evidence:
/// - `shortcutTooltip formats action and shortcut`
/// - `withDesktopShortcut includes shortcut on desktop hosts`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shortcutTooltip formats action and shortcut', (tester) async {
    await pumpWithL10n(
      tester,
      Builder(
        builder: (context) => Text(
          shortcutTooltip(context, 'Play', shortcut: 'Ctrl+P'),
        ),
      ),
    );

    final l10n = AppLocalizations.of(
      tester.element(find.byType(Text)),
    );
    expect(find.text(l10n.shortcutTooltip('Play', 'Ctrl+P')), findsOneWidget);
  });

  testWidgets('withDesktopShortcut includes shortcut on desktop hosts',
      (tester) async {
    await pumpWithL10n(
      tester,
      Builder(
        builder: (context) {
          final label = withDesktopShortcut(
            context,
            'Settings',
            shortcut: DesktopShortcuts.settings,
          );
          return Text(label);
        },
      ),
    );

    expect(find.textContaining('Ctrl+'), findsWidgets);
  });
}

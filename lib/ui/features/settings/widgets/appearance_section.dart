import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

/// Appearance controls on the Settings screen.
class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  String _label(AppLocalizations l10n, ThemePreference preference) =>
      switch (preference) {
        ThemePreference.light => l10n.themeLight,
        ThemePreference.dark => l10n.themeDark,
        ThemePreference.system => l10n.themeSystem,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<ThemeViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.appearance, style: RetroTypography.trackTitle(context)),
        const SizedBox(height: 8),
        SegmentedButton<ThemePreference>(
          showSelectedIcon: false,
          segments: [
            for (final mode in ThemePreference.values)
              ButtonSegment(
                value: mode,
                label: Text(_label(l10n, mode)),
              ),
          ],
          selected: {vm.preference},
          onSelectionChanged: (selection) => vm.setPreference(selection.first),
        ),
      ],
    );
  }
}

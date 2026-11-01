import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/widgets/language_picker_sheet.dart';

/// Language controls on the Settings screen.
class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  static const summaryTileKey = ValueKey<String>('language-summary-tile');

  String _summaryLabel(AppLocalizations l10n, LocaleViewModel vm) {
    if (vm.preference.isSystem) {
      return l10n.languageSystem;
    }
    return AppLocaleCatalog.endonymForCode(vm.preference.languageCode!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<LocaleViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.language, style: RetroTypography.trackTitle(context)),
        const SizedBox(height: 8),
        ListTile(
          key: summaryTileKey,
          contentPadding: EdgeInsets.zero,
          title: Text(_summaryLabel(l10n, vm)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLanguagePickerSheet(
            context: context,
            selected: vm.preference,
            onSelected: (preference) =>
                context.read<LocaleViewModel>().setPreference(preference),
          ),
        ),
      ],
    );
  }
}

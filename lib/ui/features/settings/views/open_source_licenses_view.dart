import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/features/settings/widgets/settings_subpage_keyboard.dart';

/// Third-party open source licenses for app dependencies.
class OpenSourceLicensesView extends StatefulWidget {
  const OpenSourceLicensesView({super.key});

  @override
  State<OpenSourceLicensesView> createState() => _OpenSourceLicensesViewState();
}

class _OpenSourceLicensesViewState extends State<OpenSourceLicensesView>
    with SettingsSubpageKeyboard {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LicensePage(
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationLegalese: l10n.openSourceLegalese,
    );
  }
}

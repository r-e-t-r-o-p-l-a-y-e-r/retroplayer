import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/data_storage_view.dart';
import 'package:retroplayer/ui/features/settings/views/open_source_licenses_view.dart';
import 'package:retroplayer/ui/features/settings/widgets/about_section.dart';
import 'package:retroplayer/ui/features/settings/widgets/appearance_section.dart';
import 'package:retroplayer/ui/features/settings/widgets/equalizer_section.dart';
import 'package:retroplayer/ui/features/settings/widgets/language_section.dart';
import 'package:retroplayer/ui/features/settings/widgets/settings_focus.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _openSubpage(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _confirmResetDatabase(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final removeFolders = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetDatabaseTitle),
        content: Text(l10n.resetDatabaseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.resetDatabaseKeepFolders),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.resetDatabaseClearEverything),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (removeFolders == null || !context.mounted) return;
    await context.read<PlayerViewModel>().stopAndClearPlayback();
    await context.read<LibraryRepository>().resetDatabase(
      removeLibraryFolders: removeFolders,
    );
    if (!context.mounted) return;
    await context.read<ThemeViewModel>().load();
    await context.read<LocaleViewModel>().load();
    await context.read<EqualizerViewModel>().reloadFromStorage();
    await context.read<LibraryViewModel>().reloadAfterDatabaseReset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bandCount = context.watch<EqualizerViewModel>().bands.length;
    const firstBandLine = 4;
    final dataStorageLine = firstBandLine + bandCount;
    final licensesLine = dataStorageLine + 1;
    final resetLine = licensesLine + 1;
    final aboutLine = resetLine + 1;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<LibraryViewModel>().markSettingsOverlayClosed();
          unawaited(
            context.read<LibraryRepository>().saveSettingsOverlayOpen(false),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SettingsFocusScope(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SettingsFocusLine(lineIndex: 0, child: AppearanceSection()),
            const SizedBox(height: 24),
            const SettingsFocusLine(lineIndex: 1, child: LanguageSection()),
            const Divider(height: 32),
            Text(l10n.equalizer, style: RetroTypography.trackTitle(context)),
            const SizedBox(height: 8),
            const EqualizerSection(
              presetLineIndex: 2,
              resetLineIndex: 3,
              firstBandLineIndex: firstBandLine,
            ),
            const Divider(height: 32),
            SettingsFocusLine(
              lineIndex: dataStorageLine,
              child: _SettingsNavigationTile(
                tileKey: const ValueKey('settings_data_storage'),
                title: Text(l10n.dataStorage),
                onActivate: () =>
                    _openSubpage(context, const DataStorageView()),
              ),
            ),
            SettingsFocusLine(
              lineIndex: licensesLine,
              child: _SettingsNavigationTile(
                tileKey: const ValueKey('settings_open_source_licenses'),
                title: Text(l10n.openSourceLicenses),
                onActivate: () =>
                    _openSubpage(context, const OpenSourceLicensesView()),
              ),
            ),
            SettingsFocusLine(
              lineIndex: resetLine,
              child: _SettingsNavigationTile(
                tileKey: const ValueKey('settings_reset_database'),
                title: Text(l10n.resetDatabase),
                showChevron: false,
                onActivate: () => _confirmResetDatabase(context),
              ),
            ),
            const Divider(height: 32),
            Text(l10n.about, style: RetroTypography.trackTitle(context)),
            const SizedBox(height: 4),
            SettingsFocusLine(
              lineIndex: aboutLine,
              child: const AboutSection(),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SettingsNavigationTile extends StatelessWidget {
  const _SettingsNavigationTile({
    required this.tileKey,
    required this.title,
    required this.onActivate,
    this.showChevron = true,
  });

  final Key tileKey;
  final Widget title;
  final VoidCallback onActivate;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onActivate();
            return null;
          },
        ),
      },
      child: InkWell(
        key: tileKey,
        onTap: onActivate,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: title,
          trailing: showChevron ? const Icon(Icons.chevron_right) : null,
        ),
      ),
    );
  }
}

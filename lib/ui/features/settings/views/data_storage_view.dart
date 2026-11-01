import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retroplayer/app_branding.dart';
import 'package:retroplayer/data/services/app_data_paths.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/settings/widgets/settings_subpage_keyboard.dart';

/// Explains where Retro Player stores app data and user library files.
class DataStorageView extends StatefulWidget {
  const DataStorageView({super.key});

  @override
  State<DataStorageView> createState() => _DataStorageViewState();
}

class _DataStorageViewState extends State<DataStorageView>
    with SettingsSubpageKeyboard {
  List<Widget> _platformSections(AppLocalizations l10n) {
    if (kIsWeb) {
      return _spacedSections([
        _Section(
          title: l10n.dataStoragePlatformTitle('Web'),
          body: l10n.dataStoragePlatformBodyWeb,
        ),
      ]);
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.linux => _spacedSections([
        _Section(
          title: l10n.dataStorageLinuxDataTitle,
          body: l10n.dataStorageLinuxDataBody,
        ),
        _Section(
          title: l10n.dataStorageLinuxTaskbarTitle,
          body: l10n.dataStorageLinuxTaskbarBody,
        ),
      ]),
      TargetPlatform.android => _spacedSections([
        _Section(
          title: l10n.dataStorageAndroidPermissionsTitle,
          body: l10n.dataStorageAndroidPermissionsBody,
        ),
        _Section(
          title: l10n.dataStorageAndroidPlaybackTitle,
          body: l10n.dataStorageAndroidPlaybackBody,
        ),
      ]),
      TargetPlatform.iOS => _spacedSections([
        _Section(
          title: l10n.dataStorageIOSAccessTitle,
          body: l10n.dataStorageIOSAccessBody,
        ),
        _Section(
          title: l10n.dataStorageIOSPlaybackTitle,
          body: l10n.dataStorageIOSPlaybackBody,
        ),
      ]),
      TargetPlatform.macOS => _spacedSections([
        _Section(
          title: l10n.dataStoragePlatformTitle('macOS'),
          body: l10n.dataStoragePlatformBodyMacOS,
        ),
      ]),
      TargetPlatform.windows => _spacedSections([
        _Section(
          title: l10n.dataStoragePlatformTitle('Windows'),
          body: l10n.dataStoragePlatformBodyWindows,
        ),
      ]),
      _ => const <Widget>[],
    };
  }

  List<Widget> _spacedSections(List<_Section> sections) {
    return [
      for (final section in sections) ...[
        const SizedBox(height: 16),
        section,
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const DesktopSubpageBackLeading(),
        title: Text(l10n.dataStorage),
      ),
      body: FutureBuilder<String>(
        future: AppDataPaths.databaseFile(),
        builder: (context, snapshot) {
          final dbPath = snapshot.data ?? l10n.loading;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(l10n.dataStorageIntro, style: RetroTypography.trackTitle(context)),
              const SizedBox(height: 12),
              _Section(
                title: l10n.dataStorageAppDataTitle,
                body: l10n.dataStorageAppDataBody(
                  AppBranding.databaseFileName,
                  dbPath,
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: l10n.dataStorageLibraryTitle,
                body: l10n.dataStorageLibraryBody,
              ),
              const SizedBox(height: 16),
              _Section(
                title: l10n.dataStoragePlaylistsTitle,
                body: l10n.dataStoragePlaylistsBody,
              ),
              ..._platformSections(l10n),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RetroTypography.sectionHeader(context)),
        const SizedBox(height: 4),
        Text(body),
      ],
    );
  }
}

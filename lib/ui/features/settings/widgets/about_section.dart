import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retroplayer/app_branding.dart';
import 'package:retroplayer/build_info.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';

/// App name, tagline, version, and build stamp for Settings → About.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Fixed pattern so date and time are always visible (not locale-dependent).
    final buildTimeLabel =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(BuildInfo.buildTime.toLocal());
    final muted = RetroPalette.of(context).textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppBranding.displayName,
          style: RetroTypography.trackTitle(context),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aboutSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 12),
        _AboutMetaRow(
          label: l10n.aboutVersion,
          value: BuildInfo.versionLabel,
        ),
        const SizedBox(height: 4),
        _AboutMetaRow(
          label: l10n.aboutBuildDate,
          value: buildTimeLabel,
        ),
        const SizedBox(height: 4),
        _AboutMetaRow(
          label: l10n.aboutGitBranch,
          value: BuildInfo.gitBranch,
        ),
        const SizedBox(height: 4),
        _AboutMetaRow(
          label: l10n.aboutGitCommit,
          value: BuildInfo.gitHash,
        ),
      ],
    );
  }
}

class _AboutMetaRow extends StatelessWidget {
  const _AboutMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = RetroPalette.of(context).textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: RetroTypography.timeLabel(context).copyWith(color: muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

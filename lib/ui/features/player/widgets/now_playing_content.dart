import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_jumps.dart';
import 'package:retroplayer/ui/features/player/widgets/player_controls.dart';

/// Full now-playing body: album art, metadata, transport, and speed control.
class NowPlayingContent extends StatelessWidget {
  const NowPlayingContent({super.key, required this.viewModel});

  final PlayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!viewModel.hasSession) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(RetroSpacing.screenPadding),
          child: Text(
            AppLocalizations.of(context).selectToPlay,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        RetroSpacing.screenPadding,
        16,
        RetroSpacing.screenPadding,
        RetroSpacing.screenPadding,
      ),
      child: Column(
        children: [
          AlbumArtWithJumps(
            viewModel: viewModel,
            artSize: RetroSpacing.albumArtSize,
          ),
          const SizedBox(height: 24),
          Text(
            viewModel.title,
            style: RetroTypography.trackTitle(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (viewModel.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              viewModel.subtitle,
              style: RetroTypography.trackSubtitle(context),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 32),
          PlayerControls(viewModel: viewModel),
          const SizedBox(height: 20),
          _SpeedControl(viewModel: viewModel),
        ],
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  const _SpeedControl({required this.viewModel});

  final PlayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    return Row(
      children: [
        Icon(Icons.speed, size: 18, color: palette.textMuted),
        const SizedBox(width: 4),
        Text(
          AppLocalizations.of(context).speed,
          style: RetroTypography.timeLabel(context),
        ),
        Expanded(
          child: Slider(
            value: viewModel.speed,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            label: '${viewModel.speed}x',
            onChanged: viewModel.setSpeed,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${viewModel.speed}x',
            style: RetroTypography.timeLabel(context),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

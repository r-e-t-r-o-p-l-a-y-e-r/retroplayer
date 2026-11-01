import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/playback_progress_bar.dart';

/// Circular tactile transport controls with optional seek bar.
class RetroTransportControls extends StatelessWidget {
  const RetroTransportControls({
    super.key,
    required this.viewModel,
    this.compact = false,
    this.showSeekBar = true,
    this.embedInParentTraversal = false,
    this.seekOrder = const NumericFocusOrder(1),
    this.prevOrder = const NumericFocusOrder(2),
    this.playOrder = const NumericFocusOrder(3),
    this.nextOrder = const NumericFocusOrder(4),
  });

  final PlayerViewModel viewModel;
  final bool compact;
  final bool showSeekBar;
  final bool embedInParentTraversal;
  final NumericFocusOrder seekOrder;
  final NumericFocusOrder prevOrder;
  final NumericFocusOrder playOrder;
  final NumericFocusOrder nextOrder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _buildControls(context),
    );
  }

  Widget _buildControls(BuildContext context) {
    if (!viewModel.hasSession) return const SizedBox.shrink();

    final ready = viewModel.hasTrack;

    final playSize = compact
        ? RetroSpacing.transportCompactPlay
        : RetroSpacing.transportPlaySize;
    final skipSize = compact
        ? RetroSpacing.transportCompactSkip
        : RetroSpacing.transportSkipSize;

    final l10n = AppLocalizations.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSeekBar)
          FocusTraversalOrder(
            order: seekOrder,
            child: RetroProgressBar(viewModel: viewModel, compact: compact),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FocusTraversalOrder(
              order: prevOrder,
              child: _TransportButton(
                size: skipSize,
                icon: Icons.skip_previous_rounded,
                tooltip: withDesktopShortcut(
                  context,
                  l10n.previous,
                  shortcut: DesktopShortcuts.previous,
                ),
                enabled: ready && viewModel.hasPrevious,
                onPressed: viewModel.skipPrevious,
              ),
            ),
            SizedBox(width: compact ? 8 : 16),
            FocusTraversalOrder(
              order: playOrder,
              child: _TransportButton(
                size: playSize,
                icon: viewModel.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                tooltip: withDesktopShortcut(
                  context,
                  viewModel.isPlaying ? l10n.pause : l10n.play,
                  shortcut: DesktopShortcuts.playPause,
                ),
                enabled: ready,
                primary: true,
                onPressed: viewModel.togglePlayPause,
              ),
            ),
            SizedBox(width: compact ? 8 : 16),
            FocusTraversalOrder(
              order: nextOrder,
              child: _TransportButton(
                size: skipSize,
                icon: Icons.skip_next_rounded,
                tooltip: withDesktopShortcut(
                  context,
                  l10n.next,
                  shortcut: DesktopShortcuts.next,
                ),
                enabled: ready && viewModel.hasNext,
                onPressed: viewModel.skipNext,
              ),
            ),
          ],
        ),
      ],
    );

    if (embedInParentTraversal) return content;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: content,
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
    this.primary = false,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final iconSize = primary ? size * 0.55 : size * 0.5;

    return Focus(
      canRequestFocus: enabled,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: primary
              ? palette.accent
              : palette.iconChip.withValues(alpha: enabled ? 1 : 0.5),
          shape: const CircleBorder(),
          elevation: primary ? 2 : 0,
          shadowColor: palette.accent.withValues(alpha: 0.35),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                size: iconSize,
                color: primary
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? palette.textPrimary
                          : Colors.white)
                    : (enabled ? palette.textPrimary : palette.textMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible alias.
typedef PlayerControls = RetroTransportControls;

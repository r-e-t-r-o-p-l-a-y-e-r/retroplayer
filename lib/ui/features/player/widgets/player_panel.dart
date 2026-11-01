import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_jumps.dart';
import 'package:retroplayer/ui/features/player/widgets/player_controls.dart';
import 'package:retroplayer/ui/features/player/widgets/player_focus.dart';

/// Fixed-height mini player for routes that do not host the swipe sheet.
///
/// Expand is intentionally disabled here (e.g. Settings): those routes have no
/// continuous sheet, so swipe/tap expand would jump via a binary navigation.
class PlayerCollapsedBar extends StatelessWidget {
  const PlayerCollapsedBar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final coverArtPath = context.select<PlayerViewModel, String?>(
      (vm) => vm.coverArtPath,
    );
    final title = context.select<PlayerViewModel, String>((vm) => vm.title);
    final subtitle = context.select<PlayerViewModel, String>(
      (vm) => vm.subtitle,
    );
    final playerVm = context.read<PlayerViewModel>();

    return Material(
      color: palette.screenElevated,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.divider, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => locateNowPlaying(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                  child: Row(
                    children: [
                      AlbumArtFrame(compact: true, imagePath: coverArtPath),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RetroTypography.trackTitle(
                                context,
                              ).copyWith(fontSize: 15),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RetroTypography.trackSubtitle(
                                  context,
                                ).copyWith(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
                child: PlayerControls(
                  viewModel: playerVm,
                  compact: true,
                  showSeekBar: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expanded player chrome (art, title, transport, speed) without a drag handle.
class PlayerExpandedContent extends StatelessWidget {
  const PlayerExpandedContent({super.key, this.focusOrderOffset = 1});

  /// First [NumericFocusOrder] value for art, title, seek, transport, speed.
  final int focusOrderOffset;

  @override
  Widget build(BuildContext context) {
    final title = context.select<PlayerViewModel, String>((vm) => vm.title);
    final subtitle = context.select<PlayerViewModel, String>(
      (vm) => vm.subtitle,
    );
    final playerVm = context.read<PlayerViewModel>();

    final hasSession = context.select<PlayerViewModel, bool>(
      (vm) => vm.hasSession,
    );
    if (!hasSession) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // Sheet drag briefly lays this out in a short viewport; keep a minimum
        // art size that still fits after FittedBox scale-down.
        final artSize = (height * 0.36).clamp(72.0, RetroSpacing.albumArtSize);
        final gap = height < 520 ? 8.0 : 16.0;
        final artOrder = NumericFocusOrder(focusOrderOffset.toDouble());
        final titleOrder = NumericFocusOrder((focusOrderOffset + 1).toDouble());
        final seekOrder = NumericFocusOrder((focusOrderOffset + 2).toDouble());
        final prevOrder = NumericFocusOrder((focusOrderOffset + 3).toDouble());
        final playOrder = NumericFocusOrder((focusOrderOffset + 4).toDouble());
        final nextOrder = NumericFocusOrder((focusOrderOffset + 5).toDouble());
        final speedOrder = NumericFocusOrder((focusOrderOffset + 6).toDouble());

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RetroSpacing.screenPadding,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlbumArtWithJumps(
                    viewModel: playerVm,
                    artSize: artSize,
                    artOrder: artOrder,
                    onArtTap: () => locateNowPlaying(context),
                  ),
                  SizedBox(height: gap),
                  PlayerFocusChrome(
                    order: titleOrder,
                    onActivate: () => locateNowPlaying(context),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: RetroTypography.trackTitle(context),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: RetroTypography.trackSubtitle(context),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: gap),
                  PlayerControls(
                    viewModel: playerVm,
                    embedInParentTraversal: true,
                    seekOrder: seekOrder,
                    prevOrder: prevOrder,
                    playOrder: playOrder,
                    nextOrder: nextOrder,
                  ),
                  SizedBox(height: gap * 0.75),
                  FocusTraversalOrder(
                    order: speedOrder,
                    child: _SpeedControl(viewModel: playerVm),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Expanded player filling the body below the app bar (no internal scroll).
///
/// Prefer [PlayerLibrarySheet] on the library shell; this remains for tests and
/// non-sheet embeddings.
class PlayerExpandedBody extends StatelessWidget {
  const PlayerExpandedBody({super.key, this.focusOrderOffset = 1});

  final int focusOrderOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerDragHandle(onToggle: () => collapsePlayerPanel(context)),
        Expanded(
          child: PlayerExpandedContent(focusOrderOffset: focusOrderOffset),
        ),
      ],
    );
  }
}

/// Grabber that toggles expand/collapse on tap when [onToggle] is set.
class PlayerDragHandle extends StatelessWidget {
  const PlayerDragHandle({super.key, this.onToggle});

  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final bar = Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: palette.textMuted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
    if (onToggle == null) return bar;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: bar,
    );
  }
}

class _SpeedControl extends StatefulWidget {
  const _SpeedControl({required this.viewModel});

  final PlayerViewModel viewModel;

  @override
  State<_SpeedControl> createState() => _SpeedControlState();
}

class _SpeedControlState extends State<_SpeedControl> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => () {
        widget.viewModel.setSpeed(
          (widget.viewModel.speed - 0.25).clamp(0.5, 2.0),
        );
        return KeyEventResult.handled;
      }(),
      LogicalKeyboardKey.arrowRight => () {
        widget.viewModel.setSpeed(
          (widget.viewModel.speed + 0.25).clamp(0.5, 2.0),
        );
        return KeyEventResult.handled;
      }(),
      _ => KeyEventResult.ignored,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => _buildSlider(context),
    );
  }

  Widget _buildSlider(BuildContext context) {
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
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKey,
            child: Builder(
              builder: (context) {
                final focused = Focus.of(context).hasFocus;
                return Listener(
                  onPointerDown: (_) => _focusNode.requestFocus(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: focused
                          ? Border.all(color: palette.accent, width: 2)
                          : null,
                    ),
                    child: ExcludeFocus(
                      child: Slider(
                        value: widget.viewModel.speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 6,
                        label: '${widget.viewModel.speed}x',
                        onChanged: widget.viewModel.setSpeed,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${widget.viewModel.speed}x',
            style: RetroTypography.timeLabel(context),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Expands the player panel after starting playback.
///
/// No-op on routes that do not host a swipe sheet (e.g. Settings): expanding
/// there would require a binary navigate-then-expand jump.
Future<void> expandPlayerPanel(BuildContext context) async {
  final location = AppLocation.shellOf(context);
  if (location != null && !location.hostsPlayerSheet) return;
  await context.read<PlayerPanelViewModel>().expand();
}

/// Collapses the player sheet.
Future<void> collapsePlayerPanel(BuildContext context) =>
    context.read<PlayerPanelViewModel>().collapse();

/// Collapses the player and navigates library to the now-playing track.
Future<void> locateNowPlaying(BuildContext context) =>
    LibraryNavigator.of(context).jumpToNowPlaying();

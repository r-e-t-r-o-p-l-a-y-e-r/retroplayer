import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/player_controls.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_gesture.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';

/// Continuous swipeable player sheet for the library shell.
///
/// Collapsed and expanded chrome crossfade with sheet extent so drag is not a
/// binary IndexedStack swap. Uses [scrollController] from
/// [DraggableScrollableSheet] so swipe-down collapses reliably.
class PlayerLibrarySheet extends StatefulWidget {
  const PlayerLibrarySheet({
    super.key,
    required this.scrollController,
    required this.minChildSize,
    required this.bodyHeight,
    this.focusOrderOffset = 1,
  });

  final ScrollController scrollController;
  final double minChildSize;
  final double bodyHeight;
  final int focusOrderOffset;

  static const double handleExtent = 16;

  @override
  State<PlayerLibrarySheet> createState() => _PlayerLibrarySheetState();
}

class _PlayerLibrarySheetState extends State<PlayerLibrarySheet> {
  /// While false, the sheet scroll view ignores drags (bottom nav slop only).
  bool _sheetScrollEligible = true;

  void _onSheetPointerDown(PointerDownEvent event) {
    final panelExpanded = context.read<PlayerPanelViewModel>().isExpanded;
    if (panelExpanded) {
      if (!_sheetScrollEligible) setState(() => _sheetScrollEligible = true);
      return;
    }
    final box = context.findRenderObject();
    final global = box is RenderBox
        ? box.localToGlobal(event.localPosition)
        : event.position;
    final eligible = isPlayerSheetVerticalDragEligible(context, global);
    if (eligible != _sheetScrollEligible) {
      setState(() => _sheetScrollEligible = eligible);
    }
  }

  void _onSheetPointerUp(PointerEvent event) {
    if (!_sheetScrollEligible) {
      setState(() => _sheetScrollEligible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final hasSession = context.select<PlayerViewModel, bool>(
      (vm) => vm.hasSession,
    );
    final panelExpanded = context.select<PlayerPanelViewModel, bool>(
      (vm) => vm.isExpanded,
    );
    final fullyExpanded = context.select<PlayerPanelViewModel, bool>(
      (vm) => vm.isExpanded && vm.sheetExtent >= 0.99,
    );
    final allowSheetScroll = panelExpanded || _sheetScrollEligible;

    return Material(
      color: palette.screenElevated,
      elevation: 8,
      shadowColor: Colors.black45,
      clipBehavior: Clip.hardEdge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.divider, width: 0.5)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final extent = widget.bodyHeight > 0
                ? (constraints.maxHeight / widget.bodyHeight).clamp(0.0, 1.0)
                : widget.minChildSize;
            final t = sheetBlendT(
              extent: extent,
              minChildSize: widget.minChildSize,
            );
            final sheetHeight = constraints.maxHeight;

            return Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _onSheetPointerDown,
              onPointerUp: _onSheetPointerUp,
              onPointerCancel: _onSheetPointerUp,
              child: CustomScrollView(
                controller: widget.scrollController,
                physics: allowSheetScroll
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: sheetHeight,
                      child: Column(
                        children: [
                          PlayerDragHandle(
                            onToggle: () {
                              if (panelExpanded) {
                                collapsePlayerPanel(context);
                              } else {
                                expandPlayerPanel(context);
                              }
                            },
                          ),
                          Expanded(
                            child: !hasSession
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        RetroSpacing.screenPadding,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).selectToPlay,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : fullyExpanded
                                ? PlayerExpandedContent(
                                    focusOrderOffset: widget.focusOrderOffset,
                                  )
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (t < 0.85)
                                        IgnorePointer(
                                          ignoring: t > 0.25,
                                          child: Opacity(
                                            opacity: (1.0 - t / 0.25).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            child: panelExpanded
                                                ? const _CollapsedSheetBody()
                                                : const _CollapsedSheetBodyDragBlocker(
                                                    child: _CollapsedSheetBody(),
                                                  ),
                                          ),
                                        ),
                                      if (t > 0.2)
                                        IgnorePointer(
                                          ignoring: t < 0.75,
                                          child: Opacity(
                                            opacity: ((t - 0.25) / 0.75)
                                                .clamp(
                                                  0.0,
                                                  1.0,
                                                ),
                                            child: PlayerExpandedContent(
                                              focusOrderOffset:
                                                  widget.focusOrderOffset,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Swallows vertical drags on the mini player body so only the handle expands.
class _CollapsedSheetBodyDragBlocker extends StatelessWidget {
  const _CollapsedSheetBodyDragBlocker({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          VerticalDragGestureRecognizer.new,
          (VerticalDragGestureRecognizer instance) {
            instance.onUpdate = (_) {};
          },
        ),
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

class _CollapsedSheetBody extends StatelessWidget {
  const _CollapsedSheetBody();

  @override
  Widget build(BuildContext context) {
    final coverArtPath = context.select<PlayerViewModel, String?>(
      (vm) => vm.coverArtPath,
    );
    final title = context.select<PlayerViewModel, String>((vm) => vm.title);
    final subtitle = context.select<PlayerViewModel, String>(
      (vm) => vm.subtitle,
    );
    final playerVm = context.read<PlayerViewModel>();
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => locateNowPlaying(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 8, 4),
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
    );
  }
}

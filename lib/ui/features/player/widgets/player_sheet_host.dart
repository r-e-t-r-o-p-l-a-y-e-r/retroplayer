import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_expanded_pop_scope.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';

/// Wraps [child] with the continuous swipeable player sheet when a track plays.
///
/// Used on the library shell, album detail, and playlist detail so expand is a
/// smooth sheet drag rather than a binary mini-bar → full-screen swap.
///
/// One host per route, not a single sheet in [PlayerDockShell]: the sheet
/// fills the Scaffold *body* under that page's AppBar (library "Now Playing"
/// vs the album title). A hoisted host would cover those bars.
///
/// Set [active] false when this host's route is covered by another sheet host
/// (e.g. library under a pushed album) so only one controller stays bound.
class PlayerSheetHost extends StatefulWidget {
  const PlayerSheetHost({
    super.key,
    required this.child,
    this.focusOrderOffset = 1,
    this.sheetKey,
    this.active = true,
  });

  final Widget child;
  final int focusOrderOffset;

  /// Optional key for the [DraggableScrollableSheet] (tests).
  final Key? sheetKey;

  /// When false, only [child] is shown (no sheet / no controller bind).
  final bool active;

  @override
  State<PlayerSheetHost> createState() => _PlayerSheetHostState();
}

class _PlayerSheetHostState extends State<PlayerSheetHost> {
  final _sheetController = DraggableScrollableController();
  PlayerPanelViewModel? _boundPanelVm;
  double _minChildSize = 0.2;

  /// Frozen after first layout so collapse does not rebuild
  /// [DraggableScrollableSheet.initialChildSize] (that jumps the sheet
  /// while [animateTo] is already running — the swipe-back twitch).
  double? _openedInitialSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBinding();
  }

  @override
  void didUpdateWidget(PlayerSheetHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncBinding();
  }

  @override
  void dispose() {
    _boundPanelVm?.unbindSheet(_sheetController);
    _boundPanelVm = null;
    _sheetController.dispose();
    super.dispose();
  }

  void _syncBinding() {
    final panelVm = context.read<PlayerPanelViewModel>();
    final hasSession = context.read<PlayerViewModel>().hasSession;
    if (widget.active && hasSession) {
      _bindSheet(panelVm);
    } else {
      _unbindSheet();
    }
  }

  void _bindSheet(PlayerPanelViewModel panelVm) {
    if (identical(_boundPanelVm, panelVm)) {
      panelVm.bindSheet(_sheetController, minChildSize: _minChildSize);
      return;
    }
    _boundPanelVm?.unbindSheet(_sheetController);
    _boundPanelVm = panelVm;
    panelVm.bindSheet(_sheetController, minChildSize: _minChildSize);
  }

  void _unbindSheet() {
    if (_boundPanelVm == null) return;
    _boundPanelVm!.unbindSheet(_sheetController);
    _boundPanelVm = null;
  }

  void _updateMinSize(double minSize) {
    if (_minChildSize == minSize) return;
    _minChildSize = minSize;
    final panel = _boundPanelVm;
    if (panel != null) {
      panel.bindSheet(_sheetController, minChildSize: minSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = context.select<PlayerViewModel, bool>(
      (vm) => vm.hasSession,
    );
    final playerExpanded = context.select<PlayerPanelViewModel, bool>(
      (vm) => vm.isExpanded,
    );
    final showSheet = widget.active && hasSession;

    return LayoutBuilder(
      builder: (context, constraints) {
        final collapsedPx = playerCollapsedExtent(context);
        final body = ExcludeFocus(
          excluding: playerExpanded,
          child: Padding(
            padding: EdgeInsets.only(bottom: hasSession ? collapsedPx : 0),
            child: widget.child,
          ),
        );

        if (!showSheet) {
          _openedInitialSize = null;
          if (_boundPanelVm != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _unbindSheet();
            });
          }
          return body;
        }

        final minSize = (collapsedPx / constraints.maxHeight).clamp(0.08, 0.4);
        final panelVm = context.read<PlayerPanelViewModel>();
        final startExpanded =
            playerExpanded || panelVm.sheetExtent >= 1.0 - 0.02;
        _openedInitialSize ??= startExpanded ? 1.0 : minSize;
        if (minSize != _minChildSize || _boundPanelVm != panelVm) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _updateMinSize(minSize);
            if (widget.active && context.read<PlayerViewModel>().hasSession) {
              _bindSheet(context.read<PlayerPanelViewModel>());
            } else {
              _unbindSheet();
            }
          });
        }

        return PlayerExpandedPopScope(
          child: Stack(
            children: [
              body,
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  context.read<PlayerPanelViewModel>().syncFromExtent(
                    notification.extent,
                  );
                  return false;
                },
                child: DraggableScrollableSheet(
                  key: widget.sheetKey ?? const ValueKey('player_sheet'),
                  controller: _sheetController,
                  initialChildSize: _openedInitialSize!,
                  minChildSize: minSize,
                  maxChildSize: 1.0,
                  snap: true,
                  shouldCloseOnMinExtent: false,
                  builder: (context, scrollController) {
                    return PlayerLibrarySheet(
                      scrollController: scrollController,
                      minChildSize: minSize,
                      bodyHeight: constraints.maxHeight,
                      focusOrderOffset: widget.focusOrderOffset,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

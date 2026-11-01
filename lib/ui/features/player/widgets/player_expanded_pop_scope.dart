import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

/// Owns Android predictive back while the player sheet is expanded.
///
/// Vetoes this route's pop so the swipe cannot peek the page underneath
/// (that peek-then-snap is the twitch before collapse). The gesture is
/// committed by collapsing the sheet instead.
class PlayerExpandedPopScope extends StatefulWidget {
  const PlayerExpandedPopScope({super.key, required this.child});

  final Widget child;

  @override
  State<PlayerExpandedPopScope> createState() => _PlayerExpandedPopScopeState();
}

class _PlayerExpandedPopScopeState extends State<PlayerExpandedPopScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  PlayerPanelViewModel get _panel => context.read<PlayerPanelViewModel>();

  bool get _expanded => _panel.isExpanded;

  /// Settings and other root overlays use [BackPolicy] / route pop instead.
  bool get _rootOverlayBlocksPredictiveBack {
    final state = BackPolicy.read(context);
    return state.location is SettingsLocation || state.pagelessRouteOnTop;
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (!mounted || !_expanded) return false;
    // Button / Escape still go through [AppBackGuard].
    if (backEvent.isButtonEvent) return false;
    if (_rootOverlayBlocksPredictiveBack) return false;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (!mounted || _rootOverlayBlocksPredictiveBack) return;
    _panel.scrubSheet(backEvent.progress);
  }

  @override
  void handleCommitBackGesture() {
    if (!mounted || _rootOverlayBlocksPredictiveBack) return;
    unawaited(collapsePlayerPanel(context));
  }

  @override
  void handleCancelBackGesture() {
    if (!mounted || _rootOverlayBlocksPredictiveBack) return;
    unawaited(_panel.expand());
  }

  @override
  Widget build(BuildContext context) {
    final expanded = context.select<PlayerPanelViewModel, bool>(
      (vm) => vm.isExpanded,
    );
    return PopScope(canPop: !expanded, child: widget.child);
  }
}

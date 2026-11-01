import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';

/// Controls whether the bottom player is collapsed (mini bar) or expanded.
class PlayerPanelViewModel extends ChangeNotifier {
  PlayerPanelViewModel({
    this._animator = const AnimatedSheetAnimator(),
    this._onPersistExpanded,
    this._canPersistExpanded,
    bool coldStartExpanded = false,
  })  : _isExpanded = coldStartExpanded,
        _sheetExtent = coldStartExpanded ? 1.0 : 0.2;

  final SheetAnimator _animator;
  Future<void> Function(bool expanded)? _onPersistExpanded;
  bool Function()? _canPersistExpanded;

  bool _isExpanded;
  DraggableScrollableController? _sheet;
  double _minChildSize = 0.2;
  double _sheetExtent;

  /// Predictive-back scrub jumps the sheet; ignore those extent ticks so the
  /// AppBar / library path do not swap mid-swipe.
  bool _suppressExtentSync = false;

  bool get isExpanded => _isExpanded;

  double get sheetExtent => _sheetExtent;

  double get chromeBlendT => sheetBlendT(
    extent: _sheetExtent,
    minChildSize: _minChildSize,
  );

  /// AppBar crossfade follows extent except during predictive-back scrub.
  double get appBarChromeT =>
      _suppressExtentSync ? (_isExpanded ? 1.0 : 0.0) : chromeBlendT;

  static const Duration sheetAnimationDuration = Duration(milliseconds: 280);

  void attachPersistence({
    required Future<void> Function(bool expanded) onPersistExpanded,
    required bool Function() canPersistExpanded,
  }) {
    _onPersistExpanded = onPersistExpanded;
    _canPersistExpanded = canPersistExpanded;
  }

  /// Bind the library-shell [DraggableScrollableSheet] controller.
  void bindSheet(
    DraggableScrollableController? controller, {
    double? minChildSize,
  }) {
    _sheet = controller;
    if (minChildSize != null) {
      _minChildSize = minChildSize;
    }
    if (_isExpanded && _sheetExtent >= 1.0 - 0.01) {
      _jumpSheetToExpandedIfAttached();
    }
  }

  /// Unbind [controller] only if it is still the bound sheet.
  ///
  /// Library and album/playlist detail each host a sheet; the covered host
  /// unbinds after the covering one has already bound its own controller.
  void unbindSheet(DraggableScrollableController controller) {
    if (identical(_sheet, controller)) _sheet = null;
  }

  /// Keep [isExpanded] in sync while the user drags the sheet.
  ///
  /// While a sheet is attached, its extent is the source of truth.
  void syncFromExtent(double extent) {
    _sheetExtent = extent;
    if (!_suppressExtentSync) {
      final mid = (_minChildSize + 1.0) / 2;
      _updateExpanded(extent >= mid);
    } else {
      notifyListeners();
    }
  }

  Future<void> expand() => _command(expanded: true, snapChrome: false);

  Future<void> collapse({bool snapChrome = false}) =>
      _command(expanded: false, snapChrome: snapChrome);

  /// When the saved pref is expanded but the panel was not primed (tests / legacy).
  void restoreExpandedFromSavedSession() {
    _suppressExtentSync = false;
    _isExpanded = true;
    _sheetExtent = 1.0;
    _jumpSheetToExpandedIfAttached();
    notifyListeners();
    unawaited(_persistExpandedIfNeeded(true));
  }

  /// Follow a predictive-back swipe: [progress] 0 is expanded, 1 is collapsed.
  ///
  /// Does not flip [isExpanded] so the AppBar does not twitch mid-gesture.
  void scrubSheet(double progress) {
    _suppressExtentSync = true;
    final sheet = _sheet;
    if (sheet == null || !sheet.isAttached) return;
    final size = (1.0 - progress.clamp(0.0, 1.0) * (1.0 - _minChildSize)).clamp(
      _minChildSize,
      1.0,
    );
    sheet.jumpTo(size);
  }

  Future<void> toggle() => _isExpanded ? collapse() : expand();

  /// Collapsed flag and chrome for navigation before sheet animation finishes.
  void snapCollapsedForNavigation() {
    if (!_isExpanded && _sheetExtent <= _minChildSize + 0.01) return;
    _isExpanded = false;
    _sheetExtent = _minChildSize;
    notifyListeners();
    unawaited(_persistExpandedIfNeeded(false));
  }

  Future<void> _command({
    required bool expanded,
    required bool snapChrome,
  }) async {
    _suppressExtentSync = false;
    final sheet = _sheet;
    if (sheet != null && sheet.isAttached) {
      if (!expanded && snapChrome) {
        snapCollapsedForNavigation();
      }
      _animator.move(sheet, expanded ? 1.0 : _minChildSize);
      return;
    }
    _updateExpanded(expanded);
  }

  void _updateExpanded(bool expanded) {
    if (expanded == _isExpanded) return;
    _isExpanded = expanded;
    final sheet = _sheet;
    if (sheet == null || !sheet.isAttached) {
      _sheetExtent = expanded ? 1.0 : _minChildSize;
    }
    notifyListeners();
    unawaited(_persistExpandedIfNeeded(expanded));
  }

  void _jumpSheetToExpandedIfAttached() {
    final sheet = _sheet;
    if (sheet == null || !sheet.isAttached) return;
    sheet.jumpTo(1.0);
    _sheetExtent = 1.0;
  }

  Future<void> _persistExpandedIfNeeded(bool expanded) async {
    final persist = _onPersistExpanded;
    if (persist == null) return;
    if (expanded) {
      final can = _canPersistExpanded;
      if (can != null && !can()) return;
    }
    await persist(expanded);
  }
}

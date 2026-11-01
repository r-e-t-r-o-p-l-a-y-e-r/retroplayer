import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

/// What one back press (system back, edge swipe or Escape) does.
enum BackAction {
  /// Let the navigator pop its top route (dialog, menu, subpage, Settings or
  /// a detail page).
  popRoute,
  collapsePlayer,
  browseUp,

  /// Consume the press and do nothing: at the library root back must not
  /// finish the activity, which would stop background playback.
  absorb,
}

/// The inputs back depends on.
class BackState {
  const BackState({
    required this.location,
    this.pagelessRouteOnTop = false,
    this.playerExpanded = false,
    this.canPop = false,
    this.canBrowseUp = false,
    this.suppressExpandedBackAfterSettingsClose = false,
  });

  /// Topmost page ([SettingsLocation] while Settings is open).
  final AppLocation? location;

  /// A dialog, popup menu or pushed page sits above the go_router pages.
  final bool pagelessRouteOnTop;
  final bool playerExpanded;
  final bool canPop;
  final bool canBrowseUp;

  /// One-shot after Settings closes (duplicate back dispatch).
  final bool suppressExpandedBackAfterSettingsClose;
}

/// The back rules of UC-14, in order.
abstract final class BackPolicy {
  static BackAction resolve(BackState state) {
    if (state.pagelessRouteOnTop) return BackAction.popRoute;
    if (state.location is SettingsLocation) return BackAction.popRoute;
    if (state.playerExpanded && state.suppressExpandedBackAfterSettingsClose) {
      return BackAction.absorb;
    }
    // Album and playlist detail host the player too: collapse it before
    // popping the page underneath.
    if (state.playerExpanded) return BackAction.collapsePlayer;
    if ((state.location?.isDetail ?? false) && state.canPop) {
      return BackAction.popRoute;
    }
    if (state.canBrowseUp) return BackAction.browseUp;
    return BackAction.absorb;
  }

  /// Reads [BackState] from the providers and router above [context].
  static BackState read(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    return BackState(
      location: AppLocation.topOf(context),
      pagelessRouteOnTop:
          router != null &&
          (AppRouter.routeStackOf(router)?.pagelessRouteOnTop ?? false),
      playerExpanded:
          _maybeRead<PlayerPanelViewModel>(context)?.isExpanded ?? false,
      // Only consulted on detail pages: after Settings closes, canPop can stay
      // true on the library and must not swallow browse-up.
      canPop: router?.canPop() ?? false,
      canBrowseUp: _maybeRead<LibraryViewModel>(context)?.canGoUp ?? false,
      suppressExpandedBackAfterSettingsClose:
          _maybeRead<LibraryViewModel>(
            context,
          )?.takeSuppressPlayerBackAfterSettingsClose() ??
          false,
    );
  }

  /// Playlist multi-select (and similar) can swallow back before the route pops.
  static bool consumeLocalBack(BuildContext context, BackState state) {
    if (state.pagelessRouteOnTop || state.playerExpanded) return false;
    return _maybeRead<KeyboardRegistry>(
          context,
        )?.playlist?.consumeBack?.call() ??
        false;
  }

  /// Runs [action]. Returns false for [BackAction.popRoute], leaving the pop
  /// to the caller.
  static bool perform(BuildContext context, BackAction action) {
    switch (action) {
      case BackAction.popRoute:
        return false;
      case BackAction.collapsePlayer:
        unawaited(collapsePlayerPanel(context));
      case BackAction.browseUp:
        unawaited(context.read<LibraryViewModel>().navigateToParentFolder());
      case BackAction.absorb:
        break;
    }
    return true;
  }

  /// System back ([AppBackGuard]) and in-app back (Escape, AppBar leading).
  ///
  /// Returns whether the event was handled (including route pop).
  static Future<bool> handleSystemBack(BuildContext context) async {
    final state = read(context);
    if (consumeLocalBack(context, state)) return true;
    final action = resolve(state);
    if (perform(context, action)) return true;
    await GoRouter.of(context).routerDelegate.popRoute();
    return true;
  }

  /// Escape and other in-app back: resolve, perform, and pop when needed.
  static Future<void> handleInAppBack(BuildContext context) async {
    await handleSystemBack(context);
  }
}

T? _maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } on ProviderNotFoundException {
    return null;
  }
}

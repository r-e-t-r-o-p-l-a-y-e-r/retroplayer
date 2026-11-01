import 'package:flutter/widgets.dart';

/// Tracks the route stacks of the app's navigators.
///
/// go_router only reports its own pages. Dialogs, popup menus, Settings
/// subpages and the track picker are pageless routes pushed on a navigator;
/// back must pop those before it acts on the page underneath.
class RouteStackTracker {
  final _observers = <_StackObserver>[];

  /// A fresh observer for one navigator (an observer can only be attached to
  /// a single navigator).
  NavigatorObserver observer() {
    final observer = _StackObserver();
    _observers.add(observer);
    return observer;
  }

  /// True when the top of a navigator is a route that is not a go_router page.
  bool get pagelessRouteOnTop => _observers.any(
    (observer) =>
        observer.stack.isNotEmpty && observer.stack.last.settings is! Page,
  );
}

class _StackObserver extends NavigatorObserver {
  final stack = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : stack.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      stack[index] = newRoute;
    } else if (newRoute != null) {
      stack.add(newRoute);
    }
  }
}

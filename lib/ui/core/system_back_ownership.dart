import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Tells Android that Flutter always handles back (edge swipe / back button).
///
/// Flutter's default `onNavigationNotification` forwards whatever the last
/// navigator reported. Popping a root overlay (Settings) makes the root
/// navigator report "cannot pop", which hands back to Android and turns the
/// next edge swipe into the system "leave app" animation — at any browse depth,
/// because folder browsing is in-app state, not a route stack.
///
/// Back never exits this app (exit is Recents swipe-away), so the framework
/// owns back unconditionally and [AppBackGuard] decides what it does.
bool claimSystemBack(NavigationNotification notification) {
  reassertSystemBackOwnership();
  return true;
}

/// Re-sends ownership, e.g. after the activity resumes or is recreated.
void reassertSystemBackOwnership() {
  SystemNavigator.setFrameworkHandlesBack(true);
}

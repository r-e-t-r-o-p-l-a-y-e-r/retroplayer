import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_actions.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_bindings.dart';

/// Scoped list navigation shortcuts (library browse, playlist detail).
class ListNavigationShortcuts extends StatelessWidget {
  const ListNavigationShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDesktopHost()) return child;

    return Shortcuts(
      shortcuts: listNavigationShortcutBindings(),
      child: Actions(
        actions: ListNavigationActions(() => context).build(),
        child: child,
      ),
    );
  }
}

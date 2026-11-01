import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_actions.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_bindings.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Wraps the app shell with desktop keyboard shortcuts when on a desktop host.
class AppShortcuts extends StatefulWidget {
  const AppShortcuts({super.key, required this.child});

  final Widget child;

  @override
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  final _focusNode = FocusNode();
  late final DesktopShortcutActions _actions = DesktopShortcutActions(
    () => context,
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopHost()) {
      return widget.child;
    }

    return Shortcuts(
      shortcuts: globalDesktopShortcutBindings(),
      child: Actions(
        actions: _actions.build(),
        child: Focus(
          key: const Key('desktop_shortcut_focus'),
          focusNode: _focusNode,
          onFocusChange: (_) => _maybeRequestShortcutFocus(),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeRequestShortcutFocus();
    });
  }

  void _maybeRequestShortcutFocus() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && !identical(primary, _focusNode)) {
      return;
    }

    try {
      final libraryVm = context.read<LibraryViewModel>();
      if (libraryVm.keyboardSelectedIndex != null) {
        return;
      }
    } on ProviderNotFoundException {
      // Routes without a library view model (e.g. Settings-only tests).
    }

    if (primary == null || identical(primary, _focusNode)) {
      _focusNode.requestFocus();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/keyboard/settings_focus_registry.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_actions.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_bindings.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';

/// Settings screen: vertical ↑/↓ line hop; Tab handles horizontal traversal.
class SettingsFocusScope extends StatefulWidget {
  const SettingsFocusScope({super.key, required this.child});

  final Widget child;

  @override
  State<SettingsFocusScope> createState() => _SettingsFocusScopeState();
}

class _SettingsFocusScopeState extends State<SettingsFocusScope> {
  late final SettingsFocusRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = SettingsFocusRegistry();
    FocusManager.instance.addListener(_syncLineFromPrimaryFocus);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_syncLineFromPrimaryFocus);
    _registry.dispose();
    super.dispose();
  }

  void _syncLineFromPrimaryFocus() {
    if (!mounted) return;
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return;
    final line = context.findAncestorWidgetOfExactType<SettingsFocusLine>();
    if (line != null) {
      _registry.noteLineFocused(line.lineIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopHost()) {
      return SettingsFocusRegistryProvider(
        registry: _registry,
        child: widget.child,
      );
    }

    return SettingsFocusRegistryProvider(
      registry: _registry,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Shortcuts(
          shortcuts: settingsVerticalShortcutBindings(),
          child: Actions(
            actions: buildSettingsVerticalActions(_registry),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class SettingsFocusRegistryProvider extends InheritedWidget {
  const SettingsFocusRegistryProvider({
    super.key,
    required this.registry,
    required super.child,
  });

  final SettingsFocusRegistry registry;

  static SettingsFocusRegistry of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SettingsFocusRegistryProvider>();
    assert(provider != null, 'SettingsFocusRegistryProvider not found');
    return provider!.registry;
  }

  void moveLine(int delta) => registry.moveLine(delta);

  @override
  bool updateShouldNotify(SettingsFocusRegistryProvider oldWidget) =>
      registry != oldWidget.registry;
}

/// One focus line on Settings (theme row, slider row, subpage link, etc.).
class SettingsFocusLine extends StatefulWidget {
  const SettingsFocusLine({
    super.key,
    required this.lineIndex,
    required this.child,
  });

  final int lineIndex;
  final Widget child;

  @override
  State<SettingsFocusLine> createState() => _SettingsFocusLineState();
}

class _SettingsFocusLineState extends State<SettingsFocusLine> {
  final _lineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _register());
  }

  @override
  void didUpdateWidget(SettingsFocusLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lineIndex != widget.lineIndex) {
      _unregister(oldWidget.lineIndex);
      _register();
    }
  }

  void _register() {
    if (!mounted) return;
    SettingsFocusRegistryProvider.of(context).registerLine(
      widget.lineIndex,
      _focusLine,
    );
  }

  void _unregister(int lineIndex) {
    SettingsFocusRegistryProvider.of(context).unregisterLine(lineIndex);
  }

  void _focusLine() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lineElement = _lineKey.currentContext as Element?;
      if (lineElement == null) return;
      _findFirstFocusableInLine(lineElement)?.requestFocus();
    });
  }

  FocusNode? _findFirstFocusableInLine(Element lineElement) {
    FocusNode? result;
    void walk(FocusNode node) {
      if (result != null) return;
      final context = node.context;
      if (context is Element &&
          _isDescendantOf(context, lineElement) &&
          !node.skipTraversal) {
        result ??= node;
        return;
      }
      for (final child in node.children) {
        walk(child);
      }
    }

    walk(FocusManager.instance.rootScope);
    return result;
  }

  bool _isDescendantOf(Element target, Element ancestor) {
    var found = false;
    target.visitAncestorElements((element) {
      if (identical(element, ancestor)) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  void _onPointerDown() {
    SettingsFocusRegistryProvider.of(context)
        .noteLineFocused(widget.lineIndex);
    _focusLine();
  }

  @override
  void dispose() {
    if (mounted) {
      try {
        _unregister(widget.lineIndex);
      } on Object {
        // Provider may already be unmounted.
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = SettingsFocusRegistryProvider.of(context);

    // Listen for line hops so focus targets stay registered. No accent wash —
    // the tint looked odd on touch; native control focus is enough.
    return ListenableBuilder(
      listenable: registry,
      builder: (context, _) {
        return FocusTraversalGroup(
          key: _lineKey,
          policy: OrderedTraversalPolicy(),
          child: Listener(
            onPointerDown: (_) => _onPointerDown(),
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';

/// Registers Alt+← / Backspace to pop a Settings subpage route.
mixin SettingsSubpageKeyboard<T extends StatefulWidget> on State<T> {
  KeyboardRegistry? _keyboardRegistry;
  late final SettingsSubpageKeyboardActions _actions =
      SettingsSubpageKeyboardActions()..navigateBack = _popSubpage;
  bool _registered = false;

  void _popSubpage() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_registered) return;
    _keyboardRegistry = context.read<KeyboardRegistry>();
    _keyboardRegistry!.registerSettingsSubpage(_actions);
    _registered = true;
  }

  @override
  void dispose() {
    _keyboardRegistry?.unregisterSettingsSubpage(_actions);
    super.dispose();
  }
}

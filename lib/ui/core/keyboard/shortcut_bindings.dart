import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_intents.dart';

/// Transport, shell, and navigation shortcuts (no list Enter/Space/arrows).
Map<ShortcutActivator, Intent> globalDesktopShortcutBindings() {
  return {
    const SingleActivator(LogicalKeyboardKey.keyP, control: true):
        const TogglePlayPauseIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
        const SkipPreviousIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
        const SkipNextIntent(),
    const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      control: true,
      shift: true,
    ): const SeekBackwardIntent(),
    const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      control: true,
      shift: true,
    ): const SeekForwardIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowUp, control: true):
        const ExpandPlayerIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowDown, control: true):
        const CollapsePlayerIntent(),
    // Ctrl+O adds tracks on an open playlist and a library folder elsewhere.
    const SingleActivator(LogicalKeyboardKey.keyO, control: true):
        const AddFolderIntent(),
    const SingleActivator(LogicalKeyboardKey.keyN, control: true):
        const CreatePlaylistIntent(),
    const SingleActivator(LogicalKeyboardKey.comma, control: true):
        const OpenSettingsIntent(),
    const SingleActivator(LogicalKeyboardKey.escape):
        const EscapeNavigationIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
        const NavigateParentIntent(),
    const SingleActivator(LogicalKeyboardKey.backspace):
        const NavigateParentIntent(),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true):
        const SavePlaylistIntent(),
  };
}

/// List row navigation: arrows, Enter, Space, Home, End, Delete.
Map<ShortcutActivator, Intent> listNavigationShortcutBindings() {
  return {
    const SingleActivator(LogicalKeyboardKey.arrowUp):
        const MoveSelectionIntent(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
        const MoveSelectionIntent(1),
    const SingleActivator(LogicalKeyboardKey.enter):
        const ActivateSelectionIntent(),
    const SingleActivator(LogicalKeyboardKey.space):
        const PlaySelectionIntent(),
    const SingleActivator(LogicalKeyboardKey.home): const SelectFirstIntent(),
    const SingleActivator(LogicalKeyboardKey.end): const SelectLastIntent(),
    const SingleActivator(LogicalKeyboardKey.delete):
        const DeleteSelectionIntent(),
  };
}

/// Settings vertical line hop (↑/↓ between lines).
Map<ShortcutActivator, Intent> settingsVerticalShortcutBindings() {
  return {
    const SingleActivator(LogicalKeyboardKey.arrowUp):
        const MoveSettingsLineIntent(-1),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
        const MoveSettingsLineIntent(1),
  };
}

import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';

/// Standard Ctrl-based shortcut labels for tooltips.
abstract final class DesktopShortcuts {
  static const playPause = 'Ctrl+P';
  static const previous = 'Ctrl+←';
  static const next = 'Ctrl+→';
  static const seekBack = 'Ctrl+Shift+←';
  static const seekForward = 'Ctrl+Shift+→';
  static const expandPlayer = 'Ctrl+↑';
  static const showLibrary = 'Ctrl+↓';
  static const addFolder = 'Ctrl+O';
  static const createPlaylist = 'Ctrl+N';
  static const settings = 'Ctrl+,';
  static const savePlaylist = 'Ctrl+S';
  static const addTracks = 'Ctrl+O';
  static const parentFolder = 'Alt+← / Backspace';
  static const deleteRow = 'Delete';
}

String shortcutTooltip(
  BuildContext context,
  String action, {
  required String shortcut,
}) {
  final l10n = AppLocalizations.of(context);
  return l10n.shortcutTooltip(action, shortcut);
}

String? desktopShortcutTooltip(
  BuildContext context,
  String action, {
  required String shortcut,
}) {
  if (!isDesktopHost()) return null;
  return shortcutTooltip(context, action, shortcut: shortcut);
}

String withDesktopShortcut(
  BuildContext context,
  String action, {
  required String shortcut,
}) {
  final hint = desktopShortcutTooltip(context, action, shortcut: shortcut);
  return hint ?? action;
}

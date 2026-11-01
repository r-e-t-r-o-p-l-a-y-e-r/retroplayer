import 'package:flutter/foundation.dart';

/// Shell-level actions registered by [MainShellView].
class ShellKeyboardActions {
  VoidCallback? addFolder;
  VoidCallback? createPlaylist;
  VoidCallback? openSettings;
}

/// Playlist-detail actions registered while [PlaylistDetailView] is mounted.
class PlaylistKeyboardActions {
  void Function(int delta)? moveSelection;
  VoidCallback? selectFirst;
  VoidCallback? selectLast;
  VoidCallback? activateSelection;
  VoidCallback? playSelection;
  VoidCallback? deleteSelection;
  VoidCallback? save;
  VoidCallback? addTracks;

  /// Consume back (system / Escape) instead of leaving the playlist.
  ///
  /// Used to exit multi-select. Returns true when back was handled.
  bool Function()? consumeBack;
}

/// Back navigation for Settings subpages pushed on the root navigator.
class SettingsSubpageKeyboardActions {
  VoidCallback? navigateBack;
}

/// Holds optional route-specific keyboard handlers for desktop shortcuts.
class KeyboardRegistry extends ChangeNotifier {
  final ShellKeyboardActions shell = ShellKeyboardActions();
  PlaylistKeyboardActions? playlist;
  SettingsSubpageKeyboardActions? settingsSubpage;

  void registerPlaylist(PlaylistKeyboardActions actions) {
    playlist = actions;
  }

  void unregisterPlaylist(PlaylistKeyboardActions actions) {
    if (identical(playlist, actions)) playlist = null;
  }

  void registerSettingsSubpage(SettingsSubpageKeyboardActions actions) {
    settingsSubpage = actions;
  }

  void unregisterSettingsSubpage(SettingsSubpageKeyboardActions actions) {
    if (identical(settingsSubpage, actions)) settingsSubpage = null;
  }
}

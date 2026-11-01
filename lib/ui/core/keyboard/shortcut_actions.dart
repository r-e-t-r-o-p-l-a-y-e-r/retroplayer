import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/keyboard/settings_focus_registry.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_intents.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

bool isEditableFocused() {
  final focus = FocusManager.instance.primaryFocus;
  final context = focus?.context;
  if (context == null) return false;
  final widget = context.widget;
  return widget is EditableText ||
      widget is TextField ||
      widget is TextFormField;
}

bool _onSettings(BuildContext context) =>
    AppLocation.topOf(context) is SettingsLocation;

/// Desktop shortcut actions bound to the [BuildContext] of [AppShortcuts].
class DesktopShortcutActions {
  DesktopShortcutActions(this._contextOf);

  final BuildContext Function() _contextOf;

  void _withContext(void Function(BuildContext context) fn) {
    final context = _contextOf();
    if (!context.mounted) return;
    fn(context);
  }

  Map<Type, Action<Intent>> build() => _desktopActions();

  Map<Type, Action<Intent>> _desktopActions() {
    return {
      TogglePlayPauseIntent: CallbackAction<TogglePlayPauseIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            if (!playerVm.hasTrack) return;
            await playerVm.togglePlayPause();
          });
          return null;
        },
      ),
      SkipPreviousIntent: CallbackAction<SkipPreviousIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            if (!playerVm.hasTrack || !playerVm.hasPrevious) return;
            await playerVm.skipPrevious();
          });
          return null;
        },
      ),
      SkipNextIntent: CallbackAction<SkipNextIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            if (!playerVm.hasTrack || !playerVm.hasNext) return;
            await playerVm.skipNext();
          });
          return null;
        },
      ),
      SeekBackwardIntent: CallbackAction<SeekBackwardIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            if (!playerVm.hasTrack) return;
            await playerVm.jumpBy(-playbackJumpStep);
          });
          return null;
        },
      ),
      SeekForwardIntent: CallbackAction<SeekForwardIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            if (!playerVm.hasTrack) return;
            await playerVm.jumpBy(playbackJumpStep);
          });
          return null;
        },
      ),
      ExpandPlayerIntent: CallbackAction<ExpandPlayerIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final playerVm = context.read<PlayerViewModel>();
            final panelVm = context.read<PlayerPanelViewModel>();
            if (!playerVm.hasTrack || panelVm.isExpanded) return;
            await expandPlayerPanel(context);
          });
          return null;
        },
      ),
      CollapsePlayerIntent: CallbackAction<CollapsePlayerIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final panelVm = context.read<PlayerPanelViewModel>();
            if (!panelVm.isExpanded) return;
            await collapsePlayerPanel(context);
          });
          return null;
        },
      ),
      AddFolderIntent: CallbackAction<AddFolderIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            final registry = context.read<KeyboardRegistry>();
            final addTracks = registry.playlist?.addTracks;
            if (addTracks != null) {
              addTracks();
              return;
            }
            final panelVm = context.read<PlayerPanelViewModel>();
            if (panelVm.isExpanded) return;
            registry.shell.addFolder?.call();
          });
          return null;
        },
      ),
      CreatePlaylistIntent: CallbackAction<CreatePlaylistIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            final panelVm = context.read<PlayerPanelViewModel>();
            if (panelVm.isExpanded) return;
            context.read<KeyboardRegistry>().shell.createPlaylist?.call();
          });
          return null;
        },
      ),
      OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            context.read<KeyboardRegistry>().shell.openSettings?.call();
          });
          return null;
        },
      ),
      EscapeNavigationIntent: CallbackAction<EscapeNavigationIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            await BackPolicy.handleInAppBack(context);
          });
          return null;
        },
      ),
      NavigateParentIntent: CallbackAction<NavigateParentIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            final registry = context.read<KeyboardRegistry>();

            if (registry.settingsSubpage?.navigateBack != null) {
              registry.settingsSubpage!.navigateBack!.call();
              return;
            }

            final router = GoRouter.of(context);
            final location = AppLocation.topOf(context);
            if ((location is PlaylistDetailLocation ||
                    location is QueueLocation ||
                    location is SettingsLocation) &&
                router.canPop()) {
              context.pop();
              return;
            }
            final panelVm = context.read<PlayerPanelViewModel>();
            if (panelVm.isExpanded) return;
            await context.read<LibraryViewModel>().navigateToParentFolder();
          });
          return null;
        },
      ),
      SavePlaylistIntent: CallbackAction<SavePlaylistIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            context.read<KeyboardRegistry>().playlist?.save?.call();
          });
          return null;
        },
      ),
    };
  }
}

/// List navigation actions mounted on library / playlist surfaces only.
class ListNavigationActions {
  ListNavigationActions(this._contextOf);

  final BuildContext Function() _contextOf;

  void _withContext(void Function(BuildContext context) fn) {
    final context = _contextOf();
    if (!context.mounted) return;
    fn(context);
  }

  Map<Type, Action<Intent>> build() => _listActions();

  Map<Type, Action<Intent>> _listActions() {
    return {
      MoveSelectionIntent: CallbackAction<MoveSelectionIntent>(
        onInvoke: (intent) {
          _withContext((context) {
            if (isEditableFocused()) return;
            _dispatchListNavigation(
              context,
              onPlaylist: (registry) =>
                  registry.playlist?.moveSelection?.call(intent.delta),
              onLibrary: (libraryVm) =>
                  libraryVm.moveKeyboardSelection(intent.delta),
            );
          });
          return null;
        },
      ),
      SelectFirstIntent: CallbackAction<SelectFirstIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            _dispatchListNavigation(
              context,
              onPlaylist: (registry) => registry.playlist?.selectFirst?.call(),
              onLibrary: (libraryVm) => libraryVm.selectFirstKeyboardRow(),
            );
          });
          return null;
        },
      ),
      SelectLastIntent: CallbackAction<SelectLastIntent>(
        onInvoke: (_) {
          _withContext((context) {
            if (isEditableFocused()) return;
            _dispatchListNavigation(
              context,
              onPlaylist: (registry) => registry.playlist?.selectLast?.call(),
              onLibrary: (libraryVm) => libraryVm.selectLastKeyboardRow(),
            );
          });
          return null;
        },
      ),
      ActivateSelectionIntent: CallbackAction<ActivateSelectionIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            await _dispatchListNavigationAsync(
              context,
              onPlaylist: (registry) =>
                  registry.playlist?.activateSelection?.call(),
              onLibrary: (libraryVm) => libraryVm
                  .activateKeyboardSelection()
                  .then(LibraryNavigator.of(context).run),
            );
          });
          return null;
        },
      ),
      PlaySelectionIntent: CallbackAction<PlaySelectionIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            await _dispatchListNavigationAsync(
              context,
              onPlaylist: (registry) =>
                  registry.playlist?.playSelection?.call(),
              onLibrary: (libraryVm) => libraryVm.playKeyboardSelection().then(
                LibraryNavigator.of(context).run,
              ),
            );
          });
          return null;
        },
      ),
      DeleteSelectionIntent: CallbackAction<DeleteSelectionIntent>(
        onInvoke: (_) {
          _withContext((context) async {
            if (isEditableFocused()) return;
            await _dispatchListNavigationAsync(
              context,
              onPlaylist: (registry) =>
                  registry.playlist?.deleteSelection?.call(),
              onLibrary: (libraryVm) => LibraryNavigator.of(
                context,
              ).run(libraryVm.deleteKeyboardSelection()),
            );
          });
          return null;
        },
      ),
    };
  }
}

Map<Type, Action<Intent>> buildSettingsVerticalActions(
  SettingsFocusRegistry registry,
) {
  return {
    MoveSettingsLineIntent: CallbackAction<MoveSettingsLineIntent>(
      onInvoke: (intent) {
        if (isEditableFocused()) return null;
        registry.moveLine(intent.delta);
        return null;
      },
    ),
  };
}

void _dispatchListNavigation(
  BuildContext context, {
  required void Function(KeyboardRegistry registry) onPlaylist,
  required void Function(LibraryViewModel libraryVm) onLibrary,
}) {
  final panelVm = context.read<PlayerPanelViewModel>();
  if (panelVm.isExpanded) return;

  if (_onSettings(context)) return;

  final registry = context.read<KeyboardRegistry>();
  if (registry.settingsSubpage != null) return;
  if (registry.playlist != null) {
    onPlaylist(registry);
    return;
  }
  final libraryVm = _maybeLibraryViewModel(context);
  if (libraryVm == null) return;
  onLibrary(libraryVm);
}

Future<void> _dispatchListNavigationAsync(
  BuildContext context, {
  required void Function(KeyboardRegistry registry) onPlaylist,
  required Future<void> Function(LibraryViewModel libraryVm) onLibrary,
}) async {
  final panelVm = context.read<PlayerPanelViewModel>();
  if (panelVm.isExpanded) return;

  if (_onSettings(context)) return;

  final registry = context.read<KeyboardRegistry>();
  if (registry.settingsSubpage != null) return;
  if (registry.playlist != null) {
    onPlaylist(registry);
    return;
  }
  final libraryVm = _maybeLibraryViewModel(context);
  if (libraryVm == null) return;
  await onLibrary(libraryVm);
}

LibraryViewModel? _maybeLibraryViewModel(BuildContext context) {
  try {
    return context.read<LibraryViewModel>();
  } on ProviderNotFoundException {
    return null;
  }
}

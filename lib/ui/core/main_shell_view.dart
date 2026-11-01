import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/add_library_folder.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/navigation/open_settings_overlay.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';

/// Single main screen: library browse + draggable player panel (no bottom tabs).
class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  bool _shellKeyboardRegistered = false;
  KeyboardRegistry? _keyboardRegistry;
  final _panelToggleFocusNode = FocusNode();

  @override
  void dispose() {
    final shell = _keyboardRegistry?.shell;
    if (shell != null) {
      shell
        ..addFolder = null
        ..createPlaylist = null
        ..openSettings = null;
    }
    _panelToggleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _togglePlayerPanel() async {
    final libraryVm = context.read<LibraryViewModel>();
    final panelVm = context.read<PlayerPanelViewModel>();
    final wasExpanded = panelVm.isExpanded;
    if (wasExpanded) {
      await collapsePlayerPanel(context);
    } else {
      await expandPlayerPanel(context);
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!wasExpanded) {
        _panelToggleFocusNode.requestFocus();
        return;
      }
      final rowIndex = libraryVm.keyboardSelectedIndex;
      if (rowIndex != null) {
        libraryVm.rowFocusRegistry?.focusRow(rowIndex);
      } else {
        _panelToggleFocusNode.requestFocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!context.read<PlayerViewModel>().hasSession) return;
      await _restoreShellNavigation();
    });
  }

  Future<void> _restoreShellNavigation() async {
    await context.read<LibraryViewModel>().ensureLoaded();
    if (!mounted) return;
    await LibraryNavigator.of(context).restoreAlbumDetail();
    if (!mounted) return;
    if (await context.read<LibraryViewModel>().getSavedSettingsOverlayOpen()) {
      if (mounted) context.push(AppRouter.settings);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shellKeyboardRegistered) return;
    _shellKeyboardRegistered = true;
    final registry = context.read<KeyboardRegistry>();
    _keyboardRegistry = registry;
    registry.shell.addFolder = _pickFolder;
    registry.shell.createPlaylist = _openQueue;
    registry.shell.openSettings = _openSettings;
  }

  void _openSettings() => openSettingsOverlay(context);

  Future<void> _pickFolder() => addLibraryFolder(context);

  void _openQueue() {
    LibraryNavigator.of(context).openQueue();
  }

  Future<void> _onPlaybackBreadcrumbTap(String? path) =>
      LibraryNavigator.of(context).jumpToPlaybackBreadcrumb(path);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final libraryVm = context.watch<LibraryViewModel>();
    final playerHasSession = context.select<PlayerViewModel, bool>(
      (vm) => vm.hasSession,
    );
    final currentTrack = context.select<PlayerViewModel, AudioTrack?>(
      (vm) => vm.currentTrack,
    );
    final currentItemId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentItemId,
    );
    final panelVm = context.watch<PlayerPanelViewModel>();
    final playerExpanded = panelVm.isExpanded;
    final chromeT = panelVm.appBarChromeT;
    final libraryChromeOpacity = (1.0 - chromeT).clamp(0.0, 1.0);
    final nowPlayingChromeOpacity = chromeT.clamp(0.0, 1.0);

    final palette = RetroPalette.of(context);
    final playbackBreadcrumbs = libraryVm.breadcrumbsForPlayback(
      track: currentTrack,
      playingItemId: currentItemId,
    );
    final playerBodyOrderStart = playerExpanded
        ? playbackBreadcrumbs.length + 1
        : 1;
    // Library sheet only while this shell is the leaf (not under album/playlist).
    // ModalRoute (unlike the router location) rebuilds us when they pop.
    final sheetActive = ModalRoute.isCurrentOf(context) ?? true;

    final shell = Scaffold(
      backgroundColor: palette.screen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBarBackLeading(),
        title: Text(chromeT >= 0.5 ? l10n.nowPlaying : l10n.library),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: chromeT >= 0.5
              ? LibraryPathSummary(
                  breadcrumbs: playbackBreadcrumbs,
                  tapCurrentSegment: playerHasSession,
                  onNavigate: _onPlaybackBreadcrumbTap,
                  focusOrderStart: 1,
                )
              : LibraryPathSummary(
                  breadcrumbs: libraryVm.browseBreadcrumbs,
                  onNavigate: libraryVm.navigateToBrowsePath,
                ),
        ),
        actions: [
          Opacity(
            opacity: libraryChromeOpacity,
            child: IgnorePointer(
              ignoring: libraryChromeOpacity < 0.5,
              child: IconButton(
                icon: const Icon(Icons.queue_music),
                tooltip: withDesktopShortcut(
                  context,
                  l10n.queue,
                  shortcut: DesktopShortcuts.createPlaylist,
                ),
                onPressed: _openQueue,
              ),
            ),
          ),
          if (playerHasSession)
            IconButton(
              focusNode: _panelToggleFocusNode,
              icon: Icon(
                playerExpanded ? Icons.expand_more : Icons.expand_less,
              ),
              tooltip: withDesktopShortcut(
                context,
                playerExpanded ? l10n.showLibrary : l10n.expandPlayer,
                shortcut: playerExpanded
                    ? DesktopShortcuts.showLibrary
                    : DesktopShortcuts.expandPlayer,
              ),
              onPressed: _togglePlayerPanel,
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: withDesktopShortcut(
              context,
              l10n.settings,
              shortcut: DesktopShortcuts.settings,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      floatingActionButton: libraryChromeOpacity > 0.5 && libraryVm.showAddFolderFab
          ? Padding(
              // Sit above the collapsed player sheet (body padding alone does
              // not lift Scaffold FABs).
              padding: EdgeInsets.only(
                bottom: playerHasSession ? playerCollapsedExtent(context) : 0,
              ),
              child: Tooltip(
                message: withDesktopShortcut(
                  context,
                  l10n.addFolder,
                  shortcut: DesktopShortcuts.addFolder,
                ),
                child: FloatingActionButton.extended(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.addFolder),
                ),
              ),
            )
          : null,
      body: PlayerSheetHost(
        sheetKey: const ValueKey('library_player_sheet'),
        focusOrderOffset: playerBodyOrderStart,
        active: sheetActive,
        child: const LibraryView(
          autoLoad: false,
          embeddedInShell: true,
          restoreSessionOnMount: false,
        ),
      ),
    );

    // Always wrap so expand/collapse does not remount the scaffold (that would
    // re-attach DraggableScrollableController while the old sheet still lives).
    return FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: shell);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/add_library_folder.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/library_row_focus.dart';
import 'package:retroplayer/ui/core/keyboard/list_navigation_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_alphabet_index_bar.dart'
    show LibraryAlphabetIndexBar, libraryAlphabetIndexBarWidth;
import 'package:retroplayer/ui/features/library/widgets/library_item_tile.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';
import 'package:retroplayer/ui/features/library/widgets/library_remove_confirmation.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({
    super.key,
    this.autoLoad = true,
    this.embeddedInShell = false,
    this.restoreSessionOnMount = true,
  });

  /// When false, only refreshes browse display (for widget tests with seeded data).
  final bool autoLoad;

  /// When true, renders only the browse body (AppBar/FAB owned by [MainShellView]).
  final bool embeddedInShell;

  /// When false, skips album-detail session restore on mount (widget tests).
  final bool restoreSessionOnMount;

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final _scrollController = RestoringScrollController();
  final _listScroller = LibraryListScroller();
  bool _listOverflows = false;
  GoRouter? _router;
  bool _settingsCovering = false;

  @override
  void initState() {
    super.initState();
    _listScroller.controller = _scrollController;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<LibraryViewModel>();
      if (widget.autoLoad) {
        await vm.ensureLoaded();
      } else {
        await vm.refreshDisplay();
      }
      if (mounted && widget.restoreSessionOnMount) {
        await LibraryNavigator.of(context).restoreAlbumDetail();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attach every time dependencies resolve so A–Z jumps always have a live
    // scroller (post-frame-only attach was easy to miss after shell rebuilds).
    context.read<LibraryViewModel>().attachListScroller(_listScroller);

    GoRouter? router;
    try {
      router = GoRouter.of(context);
    } on Object {
      router = null;
    }
    if (router != _router) {
      _router?.routerDelegate.removeListener(_onRouterChange);
      _router = router;
      _router?.routerDelegate.addListener(_onRouterChange);
      _settingsCovering =
          router != null && AppLocation.topOf(context) is SettingsLocation;
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouterChange);
    _scrollController.removeListener(_onScroll);
    try {
      context.read<LibraryViewModel>().attachListScroller(null);
    } on Object {
      // Provider may be gone during teardown.
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateOverflowFlag();
    if (!_scrollController.hasClients) return;
    // Keep the current path's offset fresh so Settings / rebuilds can restore.
    context.read<LibraryViewModel>().rememberBrowseScrollOffset();
  }

  void _onRouterChange() {
    if (!mounted) return;
    final settings = AppLocation.topOf(context) is SettingsLocation;
    final vm = context.read<LibraryViewModel>();
    if (settings && !_settingsCovering) {
      vm.rememberBrowseScrollOffset();
    } else if (!settings && _settingsCovering) {
      vm.restoreBrowseScrollOffsetAfterLayout();
    }
    _settingsCovering = settings;
  }

  void _onAlphabetSelect(String indexChar) {
    final vm = context.read<LibraryViewModel>();
    _listScroller.updateCounts(
      folders: vm.folders.length,
      playlists: vm.playlistItems.length,
      audio: vm.audioItems.length,
    );
    final index = vm.indexForLibraryIndexChar(indexChar);
    if (index == null) return;
    // Scroll with this State's controller first (never null here), then sync VM.
    _listScroller.jumpToRow(index);
    vm.jumpToSelectableRow(index);
  }

  void _updateOverflowFlag() {
    if (!_scrollController.hasClients) return;
    final overflows = _scrollController.position.maxScrollExtent > 0;
    if (overflows == _listOverflows) return;
    setState(() => _listOverflows = overflows);
  }

  Widget _folderRow(
    BuildContext context, {
    required FolderEntry folder,
    required int rowIndex,
    bool starred = false,
  }) {
    final vm = context.read<LibraryViewModel>();
    final l10n = AppLocalizations.of(context);
    final palette = RetroPalette.of(context);
    return LibraryRowFocusGroup(
      rowIndex: rowIndex,
      playTooltip: l10n.playFolder,
      onPlayPressed: () => _playFolder(context, folder.path),
      body: RetroListTile(
        selected: vm.isKeyboardSelectedFolder(folder.path),
        leading: Stack(
          children: [
            const SizedBox(
              width: RetroSpacing.iconChipSize,
              height: RetroSpacing.iconChipSize,
              child: RetroIconChip(icon: Icons.folder_outlined),
            ),
            if (starred)
              Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.star, size: 16, color: palette.accent),
              ),
          ],
        ),
        title: Text(folder.name),
        subtitle: Text(
          folder.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: RetroTypography.timeLabel(context, compact: true),
        ),
        onTap: () => vm.browseInto(folder.path),
      ),
    );
  }

  Future<void> _playFolder(BuildContext context, String folderPath) async {
    final libraryVm = context.read<LibraryViewModel>();
    final playerVm = context.read<PlayerViewModel>();
    final tracks = await libraryVm.tracksForFolder(folderPath);
    await playerVm.playFolder(folderPath, tracks);
    if (context.mounted) {
      unawaited(expandPlayerPanel(context));
    }
  }

  Future<void> _pickFolder() => addLibraryFolder(context);

  Future<void> _removeLibraryRoot(String path) async {
    await context.read<PlayerViewModel>().stopAndClearIfUnderLibraryRoot(path);
    if (!mounted) return;
    await context.read<LibraryViewModel>().removeLibraryRoot(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<LibraryViewModel>();

    if (widget.embeddedInShell) {
      return _buildBody(vm, l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.library),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: LibraryPathSummary(
            breadcrumbs: vm.browseBreadcrumbs,
            onNavigate: vm.navigateToBrowsePath,
          ),
        ),
      ),
      floatingActionButton: vm.showAddFolderFab
          ? Tooltip(
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
            )
          : null,
      body: _buildBody(vm, l10n),
    );
  }

  Widget _buildBody(LibraryViewModel vm, AppLocalizations l10n) {
    Widget body;
    if (vm.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null) {
      body = Center(child: Text(l10n.errorMessage(vm.error!)));
    } else if (vm.folders.isEmpty &&
        (vm.browsePath != null || vm.favoriteFolders.isEmpty) &&
        vm.playlistItems.isEmpty &&
        vm.audioItems.isEmpty) {
      if (vm.isLoadingDirectoryItems) {
        body = const Center(child: CircularProgressIndicator());
      } else {
        body = Center(
          child: Text(
            vm.browsePath == null ? l10n.noFoldersAdded : l10n.folderEmpty,
          ),
        );
      }
    } else {
      final atRoot = vm.browsePath == null;
      final favorites = atRoot ? vm.favoriteFolders : const <FolderEntry>[];
      _listScroller.updateCounts(
        folders: favorites.length + vm.folders.length,
        playlists: vm.playlistItems.length,
        audio: vm.audioItems.length,
      );

      final indexLabels = vm.libraryIndexLabels;
      final showIndexBar = _listOverflows && indexLabels.length > 1;

      body = NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          final overflows = notification.metrics.maxScrollExtent > 0;
          if (overflows != _listOverflows) {
            setState(() => _listOverflows = overflows);
          }
          return false;
        },
        child: Stack(
          children: [
            Padding(
              padding: showIndexBar
                  ? const EdgeInsets.only(right: libraryAlphabetIndexBarWidth)
                  : EdgeInsets.zero,
              child: CustomScrollView(
                key: ValueKey('library-browse:${vm.browsePath ?? ''}'),
                controller: _scrollController,
                slivers: [
                  if (vm.folders.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          atRoot ? l10n.librarySources : l10n.folders,
                          style: RetroTypography.sectionHeader(context),
                        ),
                      ),
                    ),
                  if (atRoot)
                    SliverReorderableList(
                      itemCount: vm.folders.length,
                      onReorderItem: vm.reorderLibraryRoot,
                      itemBuilder: (context, index) {
                        final folder = vm.folders[index];
                        final row = _folderRow(
                          context,
                          folder: folder,
                          rowIndex: index,
                          starred: vm.isFavorite(folder.path),
                        );
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(folder.path),
                          index: index,
                          child: LibraryRootDismissible(
                            path: folder.path,
                            displayName: folder.name,
                            onRemove: () => _removeLibraryRoot(folder.path),
                            child: row,
                          ),
                        );
                      },
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final folder = vm.folders[index];
                        final row = _folderRow(
                          context,
                          folder: folder,
                          rowIndex: index,
                          starred: vm.isFavorite(folder.path),
                        );
                        return FolderFavoriteDismissible(
                          path: folder.path,
                          isFavorite: vm.isFavorite(folder.path),
                          onToggle: () => vm.toggleFavorite(folder.path),
                          child: row,
                        );
                      }, childCount: vm.folders.length),
                    ),
                  if (favorites.isNotEmpty) ...[
                    if (vm.folders.isNotEmpty)
                      const SliverToBoxAdapter(child: Divider()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          l10n.favorites,
                          style: RetroTypography.sectionHeader(context),
                        ),
                      ),
                    ),
                    SliverReorderableList(
                      itemCount: favorites.length,
                      onReorderItem: vm.reorderFavorite,
                      itemBuilder: (context, index) {
                        final folder = favorites[index];
                        // The drag listener has to wrap [Dismissible]. Inside
                        // it, the swipe recognizer keeps the arena open and
                        // the long-press reorder never starts.
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(folder.path),
                          index: index,
                          child: FolderFavoriteDismissible(
                            path: folder.path,
                            isFavorite: true,
                            onToggle: () => vm.toggleFavorite(folder.path),
                            child: _folderRow(
                              context,
                              folder: folder,
                              rowIndex: vm.folders.length + index,
                              starred: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (vm.playlistItems.isNotEmpty &&
                      (favorites.isNotEmpty || vm.folders.isNotEmpty))
                    const SliverToBoxAdapter(child: Divider()),
                  if (vm.playlistItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          l10n.playlists,
                          style: RetroTypography.sectionHeader(context),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = vm.playlistItems[index];
                      return LibraryItemTile(
                        key: ValueKey(item.id),
                        item: item,
                        rowIndex: vm.folders.length + favorites.length + index,
                        keyboardSelected: vm.isKeyboardSelectedItem(item),
                      );
                    }, childCount: vm.playlistItems.length),
                  ),
                  if (vm.audioItems.isNotEmpty &&
                      (favorites.isNotEmpty ||
                          vm.folders.isNotEmpty ||
                          vm.playlistItems.isNotEmpty))
                    const SliverToBoxAdapter(child: Divider()),
                  if (vm.audioItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          l10n.audio,
                          style: RetroTypography.sectionHeader(context),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = vm.audioItems[index];
                      return LibraryItemTile(
                        key: ValueKey(item.id),
                        item: item,
                        rowIndex:
                            vm.folders.length +
                            favorites.length +
                            vm.playlistItems.length +
                            index,
                        keyboardSelected: vm.isKeyboardSelectedItem(item),
                      );
                    }, childCount: vm.audioItems.length),
                  ),
                ],
              ),
            ),
            if (showIndexBar)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: LibraryAlphabetIndexBar(
                  labels: indexLabels,
                  onSelect: _onAlphabetSelect,
                ),
              ),
          ],
        ),
      );
    }

    return LibraryRowFocusScope(child: ListNavigationShortcuts(child: body));
  }
}

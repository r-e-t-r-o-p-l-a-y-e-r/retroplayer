import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/playlist_entry_validation.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_list_controller.dart';
import 'package:retroplayer/ui/core/keyboard/list_navigation_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';
import 'package:retroplayer/ui/features/playlist/views/library_track_picker_page.dart';

class PlaylistDetailView extends StatefulWidget {
  const PlaylistDetailView({super.key, required this.playlist});

  final PlaylistFile playlist;

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
  late List<String> _entryPaths;
  bool _saving = false;
  Set<String> _missingPaths = const {};
  List<AudioTrack>? _resolvedTracks;
  final _selection = SelectableListController();
  bool _selectMode = false;
  final _checkedIndices = <int>{};
  late final PlaylistKeyboardActions _keyboardActions;
  KeyboardRegistry? _keyboardRegistry;
  bool _keyboardRegistered = false;
  final _entryFocusNodes = <String, FocusNode>{};

  PlaylistFile get _playlist =>
      PlaylistFile(filePath: widget.playlist.filePath, entryPaths: _entryPaths);

  /// Playlists found on disk are read-only; only app-created ones are edited.
  bool get _editable => context.read<LibraryViewModel>().isAppCreatedPlaylist(
    widget.playlist.filePath,
  );

  String get _playlistDirectory =>
      normalizeLibraryPath(p.dirname(widget.playlist.filePath));

  @override
  void initState() {
    super.initState();
    _entryPaths = List<String>.from(widget.playlist.entryPaths);
    _keyboardActions = PlaylistKeyboardActions()
      ..moveSelection = _moveKeyboardSelection
      ..selectFirst = _selectFirstEntry
      ..selectLast = _selectLastEntry
      ..activateSelection = _activateKeyboardSelection
      ..playSelection = _activateKeyboardSelection
      ..deleteSelection = _deleteKeyboardSelection
      ..save = _save
      ..addTracks = _addTracks
      ..consumeBack = _consumeBack;
    _refreshMissingPaths();
    _refreshResolvedTracks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_keyboardRegistered) return;
    _keyboardRegistry = context.read<KeyboardRegistry>();
    _keyboardRegistry!.registerPlaylist(_keyboardActions);
    _keyboardRegistered = true;
  }

  @override
  void dispose() {
    _keyboardRegistry?.unregisterPlaylist(_keyboardActions);
    for (final node in _entryFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _focusNodeFor(String path) =>
      _entryFocusNodes.putIfAbsent(path, FocusNode.new);

  void _pruneFocusNodes() {
    final live = _entryPaths.toSet();
    final stale = [
      for (final path in _entryFocusNodes.keys)
        if (!live.contains(path)) path,
    ];
    for (final path in stale) {
      _entryFocusNodes.remove(path)?.dispose();
    }
  }

  void _selectEntryFromPointer(int index) {
    _selection.setLength(_entryPaths.length);
    if (_selection.selectedIndex == index) return;
    setState(() => _selection.selectAt(index));
    _syncKeyboardFocus();
  }

  void _enterSelectMode() {
    if (!_editable || _entryPaths.isEmpty) return;
    setState(() {
      _selectMode = true;
      _checkedIndices
        ..clear()
        ..addAll({
          if (_selection.selectedIndex != null) _selection.selectedIndex!,
        });
    });
  }

  void _exitSelectMode() {
    if (!_selectMode) return;
    setState(() {
      _selectMode = false;
      _checkedIndices.clear();
    });
  }

  bool _consumeBack() {
    if (!_selectMode) return false;
    _exitSelectMode();
    return true;
  }

  void _setChecked(int index, bool checked) {
    setState(() {
      if (checked) {
        _checkedIndices.add(index);
      } else {
        _checkedIndices.remove(index);
      }
    });
  }

  void _toggleChecked(int index) {
    _setChecked(index, !_checkedIndices.contains(index));
  }

  void _selectAllEntries() {
    final allChecked =
        _entryPaths.isNotEmpty && _checkedIndices.length == _entryPaths.length;
    setState(() {
      _checkedIndices.clear();
      if (allChecked) return;
      for (var i = 0; i < _entryPaths.length; i++) {
        _checkedIndices.add(i);
      }
    });
  }

  void _syncKeyboardFocus() {
    final index = _selection.selectedIndex;
    if (index == null) return;
    final node = _focusNodeFor(_entryPaths[index]);
    node.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = node.context;
      if (context == null || !context.mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: Duration.zero,
      );
    });
  }

  void _moveKeyboardSelection(int delta) {
    setState(() {
      _selection.setLength(_entryPaths.length);
      _selection.move(delta);
    });
    _syncKeyboardFocus();
  }

  void _selectFirstEntry() {
    setState(() {
      _selection.setLength(_entryPaths.length);
      _selection.selectFirst();
    });
    _syncKeyboardFocus();
  }

  void _selectLastEntry() {
    setState(() {
      _selection.setLength(_entryPaths.length);
      _selection.selectLast();
    });
    _syncKeyboardFocus();
  }

  void _activateKeyboardSelection() {
    final index = _selection.selectedIndex;
    if (index == null) return;
    if (_selectMode) {
      _toggleChecked(index);
      return;
    }
    unawaited(_playFromEntry(index));
  }

  Future<void> _deleteKeyboardSelection() async {
    if (!_editable) return;
    if (_selectMode) {
      await _removeCheckedTracks();
      return;
    }
    final index = _selection.selectedIndex;
    if (index == null || index >= _entryPaths.length) return;
    final confirmed = await _confirmRemoveTracks(1);
    if (!confirmed || !mounted) return;
    setState(() {
      _entryPaths.removeAt(index);
      _pruneFocusNodes();
      _clampKeyboardSelection();
    });
    await _refreshMissingPaths();
    await _refreshResolvedTracks();
  }

  Future<void> _removeCheckedTracks() async {
    if (!_editable || _checkedIndices.isEmpty) return;
    final count = _checkedIndices.length;
    final confirmed = await _confirmRemoveTracks(count);
    if (!confirmed || !mounted) return;
    final ordered = _checkedIndices.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final index in ordered) {
        if (index >= 0 && index < _entryPaths.length) {
          _entryPaths.removeAt(index);
        }
      }
      _selectMode = false;
      _checkedIndices.clear();
      _pruneFocusNodes();
      _clampKeyboardSelection();
    });
    await _refreshMissingPaths();
    await _refreshResolvedTracks();
  }

  void _clampKeyboardSelection() {
    _selection.setLength(_entryPaths.length);
  }

  Future<void> _refreshResolvedTracks() async {
    final tracks = await context.read<LibraryViewModel>().tracksForPlaylist(
      _playlist,
    );
    if (mounted) {
      setState(() => _resolvedTracks = tracks);
    }
  }

  Future<void> _refreshMissingPaths() async {
    final missing = <String>{};
    for (final path in _entryPaths) {
      if (!await File(path).exists()) {
        missing.add(path);
      }
    }
    if (mounted) {
      setState(() => _missingPaths = missing);
    }
  }

  bool get _hasPendingChanges {
    final saved = widget.playlist.entryPaths;
    if (saved.length != _entryPaths.length) return true;
    for (var i = 0; i < saved.length; i++) {
      if (saved[i] != _entryPaths[i]) return true;
    }
    return false;
  }

  Future<void> _save() async {
    if (!_editable || !_hasPendingChanges || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<LibraryViewModel>().savePlaylistEntries(
        playlistPath: widget.playlist.filePath,
        absoluteEntryPaths: _entryPaths,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addTracks() async {
    if (!_editable) return;
    final libraryVm = context.read<LibraryViewModel>();
    final roots = libraryVm.libraryRoots;
    if (roots.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).libraryEmptyNoRoots),
          duration: const Duration(seconds: 8),
        ),
      );
      return;
    }

    final initial =
        libraryVm.browsePath != null &&
            isPathWithinLibraryRoots(libraryVm.browsePath!, roots)
        ? libraryVm.browsePath
        : (isPathWithinLibraryRoots(_playlistDirectory, roots)
              ? _playlistDirectory
              : null);

    final paths = await LibraryTrackPickerPage.open(
      context,
      libraryRoots: roots,
      initialPath: initial,
      alreadySelected: _entryPaths.toSet(),
    );
    if (!mounted || paths == null || paths.isEmpty) return;

    final added = filterNewPlaylistEntries(
      paths: paths,
      libraryRoots: roots,
      existingPaths: _entryPaths.toSet(),
    );
    if (!mounted) return;
    if (added.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).addTracksNothingAdded),
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _entryPaths.addAll(added));
    await _refreshMissingPaths();
    await _refreshResolvedTracks();
  }

  void _showNothingToPlaySnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).playlistNothingToPlay),
      ),
    );
  }

  Future<void> _playFromEntry(int index) async {
    if (index >= _entryPaths.length) return;
    final library = context.read<LibraryViewModel>();
    final path = normalizeLibraryPath(_entryPaths[index]);
    final tracks =
        _resolvedTracks ?? library.previewTracksForPlaylist(_playlist);
    if (!mounted) return;
    final trackIndex = tracks.indexWhere(
      (t) => normalizeLibraryPath(t.filePath) == path,
    );
    if (trackIndex < 0) {
      _showNothingToPlaySnackBar();
      return;
    }
    final player = context.read<PlayerViewModel>();
    await player.playPlaylistTrack(
      _playlist,
      tracks,
      tracks[trackIndex],
    );
    if (_resolvedTracks == null) {
      unawaited(_adoptPlaylistTags(player));
    }
  }

  Future<void> _adoptPlaylistTags(PlayerViewModel player) async {
    final library = context.read<LibraryViewModel>();
    final entryKey = _entryPaths.join('\n');
    final tracks = await library.tracksForPlaylist(_playlist);
    if (!mounted || _entryPaths.join('\n') != entryKey) return;
    if (tracks.isNotEmpty) {
      setState(() => _resolvedTracks = tracks);
    }
    player.adoptResolvedTracks(_playlist.id, tracks);
  }

  Future<bool> _confirmRemoveTracks(int count) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removePlaylistTrackTitle(count)),
        content: Text(l10n.removePlaylistTrackBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Widget _buildEntry(
    BuildContext context,
    int index, {
    required AppLocalizations l10n,
    required PlayerViewModel playerVm,
    required String? highlightId,
    required bool isPlaylistActive,
    required bool editable,
  }) {
    final path = _entryPaths[index];
    final missing = _missingPaths.contains(path);
    final resolved = _resolvedTracks;
    final track = resolved != null && index < resolved.length
        ? resolved[index]
        : null;
    final isPlaying =
        track != null &&
        isPlaylistActive &&
        playerVm.currentTrack?.id == track.id &&
        playerVm.isPlaying;
    final isHighlighted = track != null && highlightId == track.id;
    final isKeyboardSelected = _selection.selectedIndex == index;
    final isChecked = _checkedIndices.contains(index);
    final artist = track?.metadata.artist;

    final Widget leading = _selectMode
        ? IgnorePointer(
            child: Checkbox(
              value: isChecked,
              onChanged: (_) {},
              visualDensity: VisualDensity.compact,
            ),
          )
        : SizedBox(
            width: 32,
            child: Center(
              child: isPlaying
                  ? Icon(
                      Icons.volume_up_rounded,
                      color: RetroPalette.of(context).accent,
                    )
                  : RetroIconChip(
                      icon: editable
                          ? Icons.drag_handle
                          : Icons.music_note_rounded,
                    ),
            ),
          );

    return Focus(
      key: editable && !_selectMode ? null : ValueKey(path),
      focusNode: _focusNodeFor(path),
      onFocusChange: (focused) {
        if (!focused) return;
        final focusedIndex = _entryPaths.indexOf(path);
        if (focusedIndex < 0) return;
        setState(() {
          _selection.setLength(_entryPaths.length);
          _selection.selectAt(focusedIndex);
        });
      },
      child: RetroListTile(
        selected: _selectMode
            ? isChecked
            : isKeyboardSelected || isPlaying || isHighlighted,
        leading: leading,
        title: Text(track?.displayTitle ?? p.basename(path)),
        subtitle: missing
            ? Text(l10n.missingTrack)
            : artist != null
            ? Text(artist)
            : null,
        onTap: () {
          if (_selectMode) {
            // Use the value from this build. A second handler on the same
            // tap then sets the same checked state instead of undoing it.
            _setChecked(index, !isChecked);
            return;
          }
          _selectEntryFromPointer(index);
          unawaited(_playFromEntry(index));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playingTrackId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentTrack?.id,
    );
    final currentItemId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentItemId,
    );
    final hasTrack = context.select<PlayerViewModel, bool>((vm) => vm.hasTrack);
    final playerVm = context.read<PlayerViewModel>();
    final libraryVm = context.watch<LibraryViewModel>();
    final highlightId = libraryVm.effectiveHighlightedTrackId(playingTrackId);
    final isPlaylistActive = currentItemId == widget.playlist.id;
    final editable = libraryVm.isAppCreatedPlaylist(widget.playlist.filePath);

    return PopScope(
      canPop: !_selectMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _consumeBack();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _selectMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.cancel,
                  onPressed: _exitSelectMode,
                )
              : const AppBarBackLeading(),
          title: Text(
            _selectMode
                ? l10n.playlistSelectedCount(_checkedIndices.length)
                : l10n.playlist,
          ),
          actions: [
            if (_selectMode) ...[
              IconButton(
                icon: const Icon(Icons.select_all),
                tooltip:
                    _entryPaths.isNotEmpty &&
                        _checkedIndices.length == _entryPaths.length
                    ? l10n.playlistDeselectAll
                    : l10n.playlistSelectAll,
                onPressed: _entryPaths.isEmpty ? null : _selectAllEntries,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.remove,
                onPressed: _checkedIndices.isEmpty
                    ? null
                    : _removeCheckedTracks,
              ),
            ] else ...[
              if (!editable)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      l10n.playlistReadOnly,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              if (editable && _entryPaths.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.checklist),
                  tooltip: l10n.playlistSelect,
                  onPressed: _enterSelectMode,
                ),
              if (editable)
                TextButton(
                  onPressed: _hasPendingChanges && !_saving ? _save : null,
                  style: TextButton.styleFrom(
                    foregroundColor: RetroPalette.of(context).accent,
                    disabledForegroundColor: RetroPalette.of(context).textMuted,
                  ),
                  child: Text(
                    withDesktopShortcut(
                      context,
                      l10n.save,
                      shortcut: DesktopShortcuts.savePlaylist,
                    ),
                  ),
                ),
            ],
          ],
        ),
        body: PlayerSheetHost(
          sheetKey: const ValueKey('playlist_player_sheet'),
          child: ListNavigationShortcuts(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    widget.playlist.displayName,
                    style: RetroTypography.trackTitle(
                      context,
                    ).copyWith(fontSize: 17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _entryPaths.isEmpty
                      ? Center(child: Text(l10n.playlistEmpty))
                      : _selectMode
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _entryPaths.length,
                          itemBuilder: (context, index) => _buildEntry(
                            context,
                            index,
                            l10n: l10n,
                            playerVm: playerVm,
                            highlightId: highlightId,
                            isPlaylistActive: isPlaylistActive,
                            editable: true,
                          ),
                        )
                      : editable
                      ? ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _entryPaths.length,
                          onReorderStart: (index) {
                            // Select without setState — rebuilding here cancels the
                            // long-press drag that just started.
                            _selection.setLength(_entryPaths.length);
                            _selection.selectAt(index);
                          },
                          onReorderItem: (oldIndex, newIndex) {
                            setState(() {
                              final entry = _entryPaths.removeAt(oldIndex);
                              _entryPaths.insert(newIndex, entry);
                              _selection.setLength(_entryPaths.length);
                              _selection.selectAt(newIndex);
                            });
                            // Focus after rebuild so a stale row closure cannot
                            // re-select the drag-start index.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _syncKeyboardFocus();
                            });
                            _refreshResolvedTracks();
                          },
                          itemBuilder: (context, index) {
                            final path = _entryPaths[index];
                            // The drag listener has to wrap [Dismissible]. Inside it,
                            // the swipe recognizer keeps the arena open and the
                            // long-press reorder never starts.
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(path),
                              index: index,
                              child: Dismissible(
                                key: ValueKey('dismiss-$path'),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmRemoveTracks(1),
                                onDismissed: (_) {
                                  setState(() {
                                    _entryPaths.removeAt(index);
                                    _pruneFocusNodes();
                                    _clampKeyboardSelection();
                                  });
                                  _refreshResolvedTracks();
                                },
                                background: const _RemoveDismissBackground(),
                                child: _buildEntry(
                                  context,
                                  index,
                                  l10n: l10n,
                                  playerVm: playerVm,
                                  highlightId: highlightId,
                                  isPlaylistActive: isPlaylistActive,
                                  editable: true,
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _entryPaths.length,
                          itemBuilder: (context, index) => _buildEntry(
                            context,
                            index,
                            l10n: l10n,
                            playerVm: playerVm,
                            highlightId: highlightId,
                            isPlaylistActive: isPlaylistActive,
                            editable: false,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: !editable || _selectMode
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: hasTrack ? playerCollapsedExtent(context) : 0,
                ),
                child: Tooltip(
                  message: withDesktopShortcut(
                    context,
                    l10n.addTracks,
                    shortcut: DesktopShortcuts.addTracks,
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: _addTracks,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addTracks),
                  ),
                ),
              ),
      ),
    );
  }
}

class _RemoveDismissBackground extends StatelessWidget {
  const _RemoveDismissBackground();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.remove,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

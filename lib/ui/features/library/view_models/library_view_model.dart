import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/ui/core/keyboard/library_row_focus_registry.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_library_row.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_list_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:retroplayer/ui/features/library/library_index_labels.dart';
import 'package:retroplayer/ui/features/library/view_models/library_effects.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required LibraryRepository libraryRepository,
    BrowseLibrary? browseLibrary,
  }) : _libraryRepository = libraryRepository,
       _browseLibrary = browseLibrary ?? BrowseLibrary();

  final LibraryRepository _libraryRepository;
  final BrowseLibrary _browseLibrary;

  List<LibraryItem> _items = [];
  List<FolderEntry> _folders = [];
  bool _isLoading = false;
  bool _isLoadingDirectoryItems = false;
  String? _error;
  String? _browsePath;
  String? _browseParentPath;
  bool _canGoUp = false;
  bool _loaded = false;
  bool _albumDetailRestored = false;
  List<String> _libraryRoots = [];
  List<String> _queuePaths = [];
  int _queueIndex = 0;
  List<String> _favoritePaths = [];
  String? _highlightedTrackId;
  final _selection = SelectableListController();
  List<SelectableLibraryRow> _selectableRows = const [];
  Set<String> _appCreatedPlaylistPaths = const {};
  int _refreshGeneration = 0;
  LibraryRowFocusRegistry? rowFocusRegistry;
  LibraryListScroller? listScroller;
  int _albumCoverEnrichGeneration = 0;
  int _directoryItemsLoadGeneration = 0;
  StreamSubscription<DirectoryListingUpdate>? _directoryWatch;

  /// Folder to re-select after a deferred directory scan (edge-back / browse up).
  String? _folderSelectionToRestore;

  /// Scroll offsets per browse path (`''` = library roots) for parent restore.
  final Map<String, double> _scrollOffsetByBrowseKey = {};

  List<String> get libraryRoots => List.unmodifiable(_libraryRoots);

  int? get keyboardSelectedIndex => _selection.selectedIndex;
  List<SelectableLibraryRow> get selectableRows => _selectableRows;

  /// Display titles for each selectable row (folder / playlist / audio).
  List<String> get selectableRowTitles => [
    for (final row in _selectableRows)
      switch (row.kind) {
        SelectableRowKind.folder => row.folderName ?? '',
        SelectableRowKind.libraryItem => row.item?.title ?? '',
      },
  ];

  /// Content-driven index labels (`#`, letters, `•`) for the current list.
  List<String> get libraryIndexLabels =>
      libraryIndexLabelsFor(selectableRowTitles);

  void attachRowFocusRegistry(LibraryRowFocusRegistry? registry) {
    rowFocusRegistry = registry;
  }

  void attachListScroller(LibraryListScroller? scroller) {
    listScroller = scroller;
  }

  void _syncKeyboardFocus() {
    final index = _selection.selectedIndex;
    if (index == null) return;
    rowFocusRegistry?.focusRow(
      index,
      ensureBuilt: () => listScroller?.jumpToRow(index),
    );
  }

  void _syncKeyboardFocusAfterLayout() {
    try {
      final binding = WidgetsBinding.instance;
      binding.addPostFrameCallback((_) {
        _syncKeyboardFocus();
        binding.addPostFrameCallback((_) {
          _syncKeyboardFocus();
        });
      });
    } on Object {
      _syncKeyboardFocus();
    }
  }

  /// Index of the first selectable row matching [indexChar], or null.
  int? indexForLibraryIndexChar(String indexChar) =>
      firstLibraryIndexMatching(selectableRowTitles, indexChar);

  /// Select [rowIndex] and scroll/focus it into view (A–Z scrubber / restore).
  void jumpToSelectableRow(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _selectableRows.length) return;
    // Always assign so a second scrub to the same letter still re-scrolls.
    _selection.selectedIndex = rowIndex;
    notifyListeners();
    listScroller?.jumpToRow(rowIndex);
    _syncKeyboardFocusAfterLayout();
  }

  /// Jump the list to the first row matching [indexChar] and select it.
  void jumpToLibraryIndexChar(String indexChar) {
    final index = indexForLibraryIndexChar(indexChar);
    if (index == null) return;
    jumpToSelectableRow(index);
  }

  List<LibraryItem> get items => _items;
  List<LibraryItem> get playlistItems => [
    for (final item in _items)
      if (item case LibraryPlaylistItem()) item,
  ];
  List<LibraryItem> get audioItems => [
    for (final item in _items)
      if (item case LibraryAlbumItem() || LibraryTrackItem()) item,
  ];
  List<FolderEntry> get folders => _folders;

  /// Favorite folder links, in the saved order.
  List<FolderEntry> get favoriteFolders => [
    for (final path in _favoritePaths)
      FolderEntry(path: path, name: p.basename(path)),
  ];

  bool isFavorite(String path) =>
      _favoritePaths.contains(normalizeLibraryPath(path));

  /// Marks [path] as a favorite, or clears it when it is already marked.
  ///
  /// Library roots are ignored. A path outside the current roots is ignored.
  Future<void> toggleFavorite(String path) async {
    final normalized = normalizeLibraryPath(path);
    final roots = _libraryRoots.map(normalizeLibraryPath).toSet();
    if (roots.contains(normalized)) return;
    if (!isPathWithinLibraryRoots(normalized, _libraryRoots)) return;
    final next = [..._favoritePaths];
    if (!next.remove(normalized)) next.add(normalized);
    _favoritePaths = next;
    await _libraryRepository.setFavoriteFolders(next);
    _rebuildSelectableRows();
    notifyListeners();
  }

  /// Moves the favorite at [oldIndex] to [newIndex].
  ///
  /// [newIndex] is the insert index after removal ([ReorderableListView.onReorderItem]).
  Future<void> reorderFavorite(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _favoritePaths.length) return;
    if (newIndex < 0 || newIndex >= _favoritePaths.length) return;
    if (oldIndex == newIndex) return;
    final next = [..._favoritePaths];
    final path = next.removeAt(oldIndex);
    next.insert(newIndex, path);
    _favoritePaths = next;
    _rebuildSelectableRows();
    notifyListeners();
    await _libraryRepository.setFavoriteFolders(next);
  }

  /// Moves a library source folder at [oldIndex] to [newIndex] (root only).
  Future<void> reorderLibraryRoot(int oldIndex, int newIndex) async {
    if (_browsePath != null) return;
    if (oldIndex < 0 || oldIndex >= _libraryRoots.length) return;
    if (newIndex < 0 || newIndex >= _libraryRoots.length) return;
    if (oldIndex == newIndex) return;
    final next = [..._libraryRoots];
    final path = next.removeAt(oldIndex);
    next.insert(newIndex, path);
    _libraryRoots = next;
    final browse = _browseLibrary(
      currentPath: null,
      libraryRoots: _libraryRoots,
      directoryItems: const [],
      childFolders: const [],
    );
    _folders = browse.folders;
    _rebuildSelectableRows();
    notifyListeners();
    await _libraryRepository.reorderLibraryRoots(oldIndex, newIndex);
  }


  bool get isLoading => _isLoading;

  /// True while audio tags for the open folder are still being scanned.
  bool get isLoadingDirectoryItems => _isLoadingDirectoryItems;
  String? get error => _error;

  bool get canGoUp => _canGoUp;
  String? get browsePath => _browsePath;
  bool get showAddFolderFab => _browsePath == null;
  String? get highlightedTrackId => _highlightedTrackId;

  /// Jump-to-playing highlight, only while [playingTrackId] still matches.
  String? effectiveHighlightedTrackId(String? playingTrackId) {
    final id = _highlightedTrackId;
    if (id == null || playingTrackId == null) return null;
    return id == playingTrackId ? id : null;
  }

  LibraryRepository get libraryRepository => _libraryRepository;

  bool isAppCreatedPlaylist(String path) =>
      _appCreatedPlaylistPaths.contains(normalizeLibraryPath(path));

  void clearHighlightedTrack() {
    if (_highlightedTrackId == null) return;
    _highlightedTrackId = null;
    notifyListeners();
  }

  List<BrowseBreadcrumb> get browseBreadcrumbs => libraryBrowseBreadcrumbs(
    browsePath: _browsePath,
    libraryRoots: _libraryRoots,
  );

  List<BrowseBreadcrumb> breadcrumbsForPlayback({
    AudioTrack? track,
    String? playingItemId,
  }) => playbackBreadcrumbs(
    track: track,
    libraryRoots: _libraryRoots,
    playingItemId: playingItemId,
  );

  List<BrowseBreadcrumb> breadcrumbsForTrack(AudioTrack? track) =>
      breadcrumbsForPlayback(track: track);

  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _restoreBrowsePath();
      await _restoreQueue();
      await refreshDisplay();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _restoreBrowsePath() async {
    final saved = await _libraryRepository.getSavedBrowsePath();
    if (saved == null) return;

    final roots = await _libraryRepository.getLibraryRoots();
    if (!isPathWithinLibraryRoots(saved, roots)) {
      await _libraryRepository.saveBrowsePath(null);
      return;
    }
    _browsePath = saved;
  }

  Future<void> _persistBrowsePath() =>
      _libraryRepository.saveBrowsePath(_browsePath);

  /// Composed queue paths, including tracks that have already played.
  List<String> get queuePaths => List.unmodifiable(_queuePaths);

  /// Index of the current queue track. Earlier tracks stay in [queuePaths].
  int get queueIndex => _queueIndex;

  Future<void> _restoreQueue() async {
    final stored = await _libraryRepository.getPlaybackQueue();
    _queuePaths = stored.paths;
    _queueIndex = stored.index;
  }

  Future<void> reloadQueue() async {
    await _restoreQueue();
    notifyListeners();
  }

  Future<void> _persistQueue() => _libraryRepository.setPlaybackQueue(
    paths: _queuePaths,
    index: _queueIndex,
  );

  Future<void> addQueuePaths(List<String> paths) async {
    final next = [..._queuePaths];
    for (final path in paths) {
      final normalized = normalizeLibraryPath(path);
      if (!next.contains(normalized)) next.add(normalized);
    }
    if (next.length == _queuePaths.length) return;
    _queuePaths = next;
    await _persistQueue();
    notifyListeners();
  }

  /// [newIndex] is the insert index after removal ([ReorderableListView.onReorderItem]).
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queuePaths.length) return;
    if (newIndex < 0 || newIndex >= _queuePaths.length) return;
    if (oldIndex == newIndex) return;
    final next = [..._queuePaths];
    final path = next.removeAt(oldIndex);
    next.insert(newIndex, path);
    _queuePaths = next;
    _queueIndex = _indexAfterReorder(_queueIndex, oldIndex, newIndex);
    await _persistQueue();
    notifyListeners();
  }

  Future<void> removeQueueAt(int index) async {
    if (index < 0 || index >= _queuePaths.length) return;
    final next = [..._queuePaths]..removeAt(index);
    _queuePaths = next;
    if (next.isEmpty) {
      _queueIndex = 0;
    } else if (index < _queueIndex) {
      _queueIndex -= 1;
    } else if (_queueIndex >= next.length) {
      _queueIndex = next.length - 1;
    }
    await _persistQueue();
    notifyListeners();
  }

  /// Drops every queued path. Saved playlists and audio files stay.
  Future<void> clearQueue() async {
    if (_queuePaths.isEmpty && _queueIndex == 0) return;
    _queuePaths = const [];
    _queueIndex = 0;
    await _persistQueue();
    notifyListeners();
  }

  /// Remembers which queue track is current without dropping earlier tracks.
  Future<void> noteQueueIndex(int index) async {
    if (_queuePaths.isEmpty) return;
    final clamped = index.clamp(0, _queuePaths.length - 1);
    if (clamped == _queueIndex) return;
    _queueIndex = clamped;
    await _persistQueue();
    notifyListeners();
  }

  Future<List<AudioTrack>> tracksForQueue() =>
      _libraryRepository.tracksForPaths(_queuePaths);

  /// Queue tracks that can start playback before tags are read.
  List<AudioTrack> previewTracksForQueue() =>
      _libraryRepository.previewTracksForPaths(_queuePaths);

  List<AudioTrack> previewTracksForPlaylist(PlaylistFile playlist) =>
      _libraryRepository.previewTracksForPaths(playlist.entryPaths);

  /// Writes the queue into [directory]. The virtual library root is refused.
  ///
  /// The stored queue is left in place.
  Future<PlaylistFile> saveQueueAsPlaylist({
    required String? directory,
    required String name,
  }) async {
    if (directory == null || directory.trim().isEmpty) {
      throw StateError('Choose a folder inside the library');
    }
    final normalized = normalizeLibraryPath(directory);
    if (!isPathWithinLibraryRoots(normalized, _libraryRoots)) {
      throw StateError('Choose a folder inside the library');
    }
    final playlist = await _libraryRepository.createPlaylist(
      directory: normalized,
      name: name,
    );
    if (_queuePaths.isEmpty) return playlist;
    return savePlaylistEntries(
      playlistPath: playlist.filePath,
      absoluteEntryPaths: _queuePaths,
    );
  }

  static int _indexAfterReorder(int current, int from, int to) {
    if (current == from) return to;
    if (from < current && to >= current) return current - 1;
    if (from > current && to <= current) return current + 1;
    return current;
  }

  /// Drops favorites that are a library root or no longer under one, and
  /// writes the list back when it changed.
  Future<List<String>> _pruneFavorites(
    List<String> stored,
    List<String> roots,
  ) async {
    final rootSet = roots.map(normalizeLibraryPath).toSet();
    final kept = <String>[];
    for (final path in stored) {
      final normalized = normalizeLibraryPath(path);
      if (rootSet.contains(normalized)) continue;
      if (!isPathWithinLibraryRoots(normalized, roots)) continue;
      if (kept.contains(normalized)) continue;
      kept.add(normalized);
    }
    if (kept.length != stored.length) {
      await _libraryRepository.setFavoriteFolders(kept);
    }
    return kept;
  }

  Future<void> refreshDisplay() async {
    // Overlapping refreshes (browse, then delete, …) must not let an older
    // one write back state it read before the newer change.
    final generation = ++_refreshGeneration;
    final libraryRoots = await _libraryRepository.getLibraryRoots();
    final appCreatedPlaylistPaths = await _libraryRepository
        .getAppCreatedPlaylistPaths();
    final storedFavorites = await _libraryRepository.getFavoriteFolders();
    if (generation != _refreshGeneration) return;
    _libraryRoots = libraryRoots;
    _appCreatedPlaylistPaths = appCreatedPlaylistPaths;
    _favoritePaths = await _pruneFavorites(storedFavorites, libraryRoots);

    if (_browsePath == null) {
      final browse = _browseLibrary(
        currentPath: null,
        libraryRoots: _libraryRoots,
        directoryItems: const [],
        childFolders: const [],
      );
      _folders = browse.folders;
      _items = const [];
      _browseParentPath = browse.parentPath;
      _canGoUp = browse.canGoUp;
      _isLoadingDirectoryItems = false;
      await _cancelDirectoryScan();
    } else {
      final path = normalizeLibraryPath(_browsePath!);
      final childFolders = await _libraryRepository.listChildFolders(path);
      if (generation != _refreshGeneration) return;
      // Paint folders (and any cached tracks) immediately — do not wait for
      // tag reads on every audio file before navigation feels complete.
      final cachedItems = _libraryRepository.cachedDirectoryItems(path);
      final cached = cachedItems ?? const [];
      final browse = _browseLibrary(
        currentPath: path,
        libraryRoots: _libraryRoots,
        directoryItems: cached,
        childFolders: childFolders,
      );
      _folders = browse.folders;
      _items = browse.items;
      _browseParentPath = browse.parentPath;
      _canGoUp = browse.canGoUp;
      // Spinner instead of "empty" until the first scan of this folder finishes.
      _isLoadingDirectoryItems = cachedItems == null;
      _rebuildSelectableRows();
      notifyListeners();

      // Only scan when cold — a warm cache must not start an unawaited Drift
      // sort that never completes under the widget-test binding (deadlock).
      if (cachedItems == null) {
        unawaited(_loadDirectoryItemsForBrowsePath(path));
      }
      return;
    }
    _rebuildSelectableRows();
    notifyListeners();
  }

  /// Scans/sorts audio in [path] after the folder list is already on screen.
  Future<void> _loadDirectoryItemsForBrowsePath(String path) async {
    await _cancelDirectoryScan();
    final generation = ++_directoryItemsLoadGeneration;
    _directoryWatch = _libraryRepository.watchDirectory(path).listen((update) {
      if (generation != _directoryItemsLoadGeneration || _browsePath != path) {
        return;
      }
      _applyDirectoryListingUpdate(path, update);
    }, onError: (_, _) {});
  }

  void _applyDirectoryListingUpdate(
    String path,
    DirectoryListingUpdate update,
  ) {
    final offset = listScroller?.currentOffset;
    _items = update.items;
    _isLoadingDirectoryItems = !update.isComplete && _items.isEmpty;
    _rebuildSelectableRows();
    if (_folderSelectionToRestore != null) {
      _restoreFolderSelection();
      if (_keyboardSelectedRow?.folderPath == _folderSelectionToRestore) {
        _folderSelectionToRestore = null;
      }
    } else {
      notifyListeners();
    }
    if (offset != null) {
      listScroller?.jumpToOffset(offset);
    }
    if (update.isComplete) {
      unawaited(_enrichAlbumCoversForBrowsePath(path));
    }
  }

  Future<void> _cancelDirectoryScan() async {
    _directoryItemsLoadGeneration++;
    final subscription = _directoryWatch;
    _directoryWatch = null;
    await subscription?.cancel();
  }

  /// Resolves covers for albums in the open folder after the list is shown.
  Future<void> _enrichAlbumCoversForBrowsePath(String path) async {
    final generation = ++_albumCoverEnrichGeneration;
    final enriched = await _libraryRepository.enrichAlbumCovers(
      _items,
      shouldContinue: () =>
          generation == _albumCoverEnrichGeneration && _browsePath == path,
    );
    if (identical(enriched, _items)) return;
    if (generation != _albumCoverEnrichGeneration || _browsePath != path) {
      return;
    }
    _items = enriched;
    _libraryRepository.replaceDirectoryItems(path, enriched);
    _rebuildSelectableRows();
    notifyListeners();
  }

  void _rebuildSelectableRows() {
    final previous = _keyboardSelectedRow;
    final atLibraryRoot = _browsePath == null;
    _selectableRows = buildFolderSelectableRows(
      folders: _folders,
      favoriteFolders: atLibraryRoot ? favoriteFolders : const [],
      playlistItems: playlistItems,
      audioItems: audioItems,
      atLibraryRoot: atLibraryRoot,
      deletablePlaylistPaths: _appCreatedPlaylistPaths,
    );
    listScroller?.updateCounts(
      folders: (atLibraryRoot ? _favoritePaths.length : 0) + _folders.length,
      playlists: playlistItems.length,
      audio: audioItems.length,
    );
    if (previous != null) {
      final index = _indexOfSelection(previous);
      if (index != null) {
        _selection.selectedIndex = index;
      } else {
        _selection.clamp();
      }
    } else {
      _clampKeyboardSelection();
    }
  }

  int? _indexOfSelection(SelectableLibraryRow previous) {
    for (var i = 0; i < _selectableRows.length; i++) {
      if (_sameSelectableRow(_selectableRows[i], previous)) return i;
    }
    final trackId = switch (previous.item) {
      LibraryTrackItem(:final track) => track.id,
      _ => null,
    };
    if (trackId == null) return null;
    for (var i = 0; i < _selectableRows.length; i++) {
      final item = _selectableRows[i].item;
      if (item is LibraryAlbumItem &&
          item.album.tracks.any((track) => track.id == trackId)) {
        return i;
      }
    }
    return null;
  }

  bool _sameSelectableRow(SelectableLibraryRow a, SelectableLibraryRow b) {
    if (a.kind != b.kind) return false;
    if (a.folderPath != null && a.folderPath == b.folderPath) return true;
    return a.item?.id != null && a.item?.id == b.item?.id;
  }

  void _clampKeyboardSelection() {
    _selection.setLength(_selectableRows.length);
  }

  void clearKeyboardSelection() {
    if (_selection.selectedIndex == null) return;
    _selection.clear();
    notifyListeners();
  }

  SelectableLibraryRow? get _keyboardSelectedRow {
    final index = _selection.selectedIndex;
    if (index == null || index < 0 || index >= _selectableRows.length) {
      return null;
    }
    return _selectableRows[index];
  }

  bool isKeyboardSelectedFolder(String path) {
    final row = _keyboardSelectedRow;
    if (row == null) return false;
    return row.kind == SelectableRowKind.folder &&
        row.folderPath == normalizeLibraryPath(path);
  }

  bool isKeyboardSelectedItem(LibraryItem item) {
    final row = _keyboardSelectedRow;
    return row?.item?.id == item.id;
  }

  void moveKeyboardSelection(int delta) {
    _selection.setLength(_selectableRows.length);
    _selection.move(delta);
    notifyListeners();
    _syncKeyboardFocus();
  }

  void selectKeyboardRowAt(int index) {
    _selection.setLength(_selectableRows.length);
    if (!_selection.selectAt(index)) return;
    notifyListeners();
  }

  /// Mouse/touch row pick: update highlight and move focus to the row body.
  ///
  /// Does not scroll the row into view — the pointer already landed on it.
  /// Scrolling here made touch-drag feel like forced selection jumps.
  void selectKeyboardRowFromPointer(int index) {
    _selection.setLength(_selectableRows.length);
    if (!_selection.selectAt(index)) return;
    notifyListeners();
    rowFocusRegistry?.focusRow(index, scrollIntoView: false);
  }

  void selectFirstKeyboardRow() {
    _selection.setLength(_selectableRows.length);
    _selection.selectFirst();
    notifyListeners();
    _syncKeyboardFocus();
  }

  void selectLastKeyboardRow() {
    _selection.setLength(_selectableRows.length);
    _selection.selectLast();
    notifyListeners();
    _syncKeyboardFocus();
  }

  /// Enter on the selected row: folders open in place; albums and playlists
  /// return a detail to open; tracks play.
  Future<LibraryEffect?> activateKeyboardSelection() async {
    final row = _keyboardSelectedRow;
    if (row == null) return null;
    switch (row.kind) {
      case SelectableRowKind.folder:
        final path = row.folderPath;
        if (path == null) return null;
        await browseInto(path);
        clearKeyboardSelection();
        return null;
      case SelectableRowKind.libraryItem:
        return switch (row.item) {
          null => null,
          LibraryAlbumItem(:final album) => OpenAlbumDetail(album),
          LibraryPlaylistItem(:final playlist) => OpenPlaylistDetail(playlist),
          LibraryTrackItem() => playKeyboardSelection(),
        };
    }
  }

  /// Space on the selected row: what to play.
  Future<LibraryEffect?> playKeyboardSelection() async {
    final row = _keyboardSelectedRow;
    if (row == null) return null;
    switch (row.kind) {
      case SelectableRowKind.folder:
        final path = row.folderPath;
        if (path == null) return null;
        final tracks = await tracksForFolder(path);
        return tracks.isEmpty ? null : PlayFolder(path, tracks);
      case SelectableRowKind.libraryItem:
        final item = row.item;
        if (item == null) return null;
        if (item case LibraryPlaylistItem(:final playlist)) {
          final tracks = await tracksForPlaylist(playlist);
          if (tracks.isEmpty) return const ShowNothingToPlay();
          return PlayLibraryItem(item, playlistTracks: tracks);
        }
        return PlayLibraryItem(item);
    }
  }

  /// Delete on the selected row: which confirmation to ask for.
  LibraryEffect? deleteKeyboardSelection() {
    final row = _keyboardSelectedRow;
    if (row == null) return null;
    switch (row.deleteAction) {
      case KeyboardDeleteAction.none:
        return null;
      case KeyboardDeleteAction.removeLibraryRoot:
        final path = row.folderPath;
        if (path == null) return null;
        return ConfirmRemoveRoot(path, displayName: row.folderName);
      case KeyboardDeleteAction.deletePlaylist:
        return switch (row.item) {
          LibraryPlaylistItem(:final playlist) => ConfirmDeletePlaylist(
            playlist,
          ),
          _ => null,
        };
    }
  }

  Future<void> navigateToParentFolder() async {
    if (!_canGoUp) return;
    final returningFromPath = _browsePath;
    final parentOffset =
        _scrollOffsetByBrowseKey[_browseScrollKey(_browseParentPath)];
    if (parentOffset != null) {
      // Apply before the parent list attaches so the first paint is already
      // at this offset (no visible scrub from the top).
      listScroller?.prepareRestore(parentOffset);
    }
    await browseUp();
    if (returningFromPath != null) {
      // Keep until the deferred parent scan finishes — a late items rebuild
      // otherwise leaves the list scrolled at the top.
      _folderSelectionToRestore = returningFromPath;
      _restoreFolderSelection();
    }
  }

  String _browseScrollKey([String? path]) {
    final value = path ?? _browsePath;
    return value == null ? '' : normalizeLibraryPath(value);
  }

  void _captureBrowseScrollOffset() {
    final offset = listScroller?.currentOffset;
    if (offset == null) return;
    _scrollOffsetByBrowseKey[_browseScrollKey()] = offset;
  }

  void _restoreBrowseScrollOffset() {
    final offset = _scrollOffsetByBrowseKey[_browseScrollKey()];
    if (offset == null) return;
    listScroller?.jumpToOffset(offset);
  }

  /// Remember the current list offset for this browse path (scroll / Settings).
  void rememberBrowseScrollOffset() => _captureBrowseScrollOffset();

  /// Re-apply a remembered offset after overlays or list rebuilds.
  void restoreBrowseScrollOffsetAfterLayout() {
    _restoreBrowseScrollOffset();
    try {
      final binding = WidgetsBinding.instance;
      binding.addPostFrameCallback((_) {
        _restoreBrowseScrollOffset();
        binding.addPostFrameCallback((_) {
          _restoreBrowseScrollOffset();
        });
      });
    } on Object {
      // Tests without a binding still get the synchronous restore above.
    }
  }

  void _restoreFolderSelection() {
    final path = _folderSelectionToRestore;
    if (path == null) return;
    // Select without jumpToRow — restore the exact prior scroll offset instead.
    _selectKeyboardRowForFolder(path, scrollList: false);
    restoreBrowseScrollOffsetAfterLayout();
  }

  void _selectKeyboardRowForFolder(String path, {bool scrollList = true}) {
    final normalized = normalizeLibraryPath(path);
    final index = _selectableRows.indexWhere(
      (row) =>
          row.kind == SelectableRowKind.folder && row.folderPath == normalized,
    );
    if (index < 0) return;
    // Force index even when unchanged so listeners/focus run after a rebuild.
    _selection.selectedIndex = index;
    notifyListeners();
    if (scrollList) {
      listScroller?.jumpToRow(index);
      _syncKeyboardFocusAfterLayout();
      return;
    }
    // Parent restore: focus the row without scrolling (offset owns the view).
    try {
      final binding = WidgetsBinding.instance;
      binding.addPostFrameCallback((_) {
        rowFocusRegistry?.focusRow(index, scrollIntoView: false);
        binding.addPostFrameCallback((_) {
          rowFocusRegistry?.focusRow(index, scrollIntoView: false);
        });
      });
    } on Object {
      rowFocusRegistry?.focusRow(index, scrollIntoView: false);
    }
  }

  Future<void> browseInto(String path) async {
    rememberBrowseScrollOffset();
    clearHighlightedTrack();
    clearKeyboardSelection();
    _folderSelectionToRestore = null;
    _browsePath = normalizeLibraryPath(path);
    await _persistBrowsePath();
    await refreshDisplay();
  }

  Future<void> navigateToBrowsePath(
    String? path, {
    bool clearHighlight = true,
  }) async {
    if (clearHighlight) clearHighlightedTrack();
    _folderSelectionToRestore = null;
    _browsePath = path == null ? null : normalizeLibraryPath(path);
    await _persistBrowsePath();
    await refreshDisplay();
  }

  /// Browses to where a playback breadcrumb segment lives. Returns the detail
  /// page to open when the segment is the playing track or playlist.
  Future<LibraryEffect?> locatePlaybackBreadcrumb({
    required String? breadcrumbPath,
    required AudioTrack? playingTrack,
    required String? playingItemId,
  }) async {
    if (breadcrumbPath == null) {
      await navigateToBrowsePath(null);
      return null;
    }
    final playlistPath = _playlistPathFromItemId(playingItemId);
    final isTrackSegment =
        playingTrack != null && breadcrumbPath == playingTrack.filePath;
    final isPlaylistSegment =
        playlistPath != null && breadcrumbPath == playlistPath;

    if (playlistPath != null && (isPlaylistSegment || isTrackSegment)) {
      return _locatePlaylistPlayback(
        playlistPath,
        highlightTrack: playingTrack,
      );
    }
    if (!isTrackSegment) {
      await navigateToBrowsePath(breadcrumbPath);
      return null;
    }
    return locateNowPlaying(track: playingTrack, playingItemId: playingItemId);
  }

  /// Browses to the folder of the playing [track] and highlights it. Returns
  /// the album or playlist detail that contains it, if any.
  Future<LibraryEffect?> locateNowPlaying({
    required AudioTrack track,
    required String? playingItemId,
  }) async {
    final playlistPath = _playlistPathFromItemId(playingItemId);
    if (playlistPath != null) {
      return _locatePlaylistPlayback(playlistPath, highlightTrack: track);
    }

    await navigateToBrowsePath(track.directoryPath, clearHighlight: false);
    _highlightedTrackId = track.id;
    notifyListeners();
    final item = await _resolveLibraryItemForPlayback(
      playingItemId: playingItemId,
      track: track,
    );
    return switch (item) {
      LibraryAlbumItem(:final album) => OpenAlbumDetail(album),
      _ => null,
    };
  }

  String? _playlistPathFromItemId(String? playingItemId) {
    if (playingItemId == null) return null;
    return PlaylistFile.playlistPathFromItemId(playingItemId);
  }

  Future<LibraryEffect?> _locatePlaylistPlayback(
    String playlistPath, {
    AudioTrack? highlightTrack,
  }) async {
    await navigateToBrowsePath(
      normalizeLibraryPath(p.dirname(playlistPath)),
      clearHighlight: false,
    );
    if (highlightTrack != null) {
      _highlightedTrackId = highlightTrack.id;
      notifyListeners();
    }
    final playlist = await _libraryRepository.findPlaylistByPath(playlistPath);
    return playlist == null ? null : OpenPlaylistDetail(playlist);
  }

  Future<LibraryItem?> _resolveLibraryItemForPlayback({
    required String? playingItemId,
    required AudioTrack track,
  }) async {
    if (playingItemId != null && !playingItemId.startsWith('folder:')) {
      final item = await _libraryRepository.findByIdAsync(playingItemId);
      if (item != null) return item;
    }
    return _findLibraryItemContainingTrack(track);
  }

  Future<LibraryItem?> _findLibraryItemContainingTrack(AudioTrack track) async {
    await _libraryRepository.loadDirectory(track.directoryPath);
    for (final item in _libraryRepository.items) {
      switch (item) {
        case LibraryAlbumItem(:final album):
          if (album.tracks.any((t) => _tracksMatch(t, track))) return item;
        case LibraryTrackItem(track: final itemTrack):
          if (_tracksMatch(itemTrack, track)) return item;
        case LibraryPlaylistItem():
          continue;
      }
    }
    return null;
  }

  bool _tracksMatch(AudioTrack a, AudioTrack b) {
    if (a.id == b.id) return true;
    return normalizeLibraryPath(a.filePath) == normalizeLibraryPath(b.filePath);
  }

  /// Persists which album detail is open so a cold start can reopen it.
  Future<void> rememberAlbumDetail(String? albumId) =>
      _libraryRepository.saveAlbumDetailId(albumId);

  Future<void> saveSettingsOverlayOpen(bool open) =>
      _libraryRepository.saveSettingsOverlayOpen(open);

  Future<bool> getSavedSettingsOverlayOpen() =>
      _libraryRepository.getSavedSettingsOverlayOpen();

  /// After the Settings overlay pops, one stray shell back must not collapse
  /// an expanded player (AppBar back can dispatch twice on some platforms).
  bool _suppressPlayerBackAfterSettingsClose = false;

  void markSettingsOverlayClosed() {
    _suppressPlayerBackAfterSettingsClose = true;
  }

  /// Returns true once after [markSettingsOverlayClosed].
  bool takeSuppressPlayerBackAfterSettingsClose() {
    if (!_suppressPlayerBackAfterSettingsClose) return false;
    _suppressPlayerBackAfterSettingsClose = false;
    return true;
  }

  /// The album detail that was open when the app last closed, once per
  /// session. Browses to its folder so back lands next to it.
  Future<AudioAlbum?> takeAlbumDetailToRestore() async {
    if (_albumDetailRestored || !_loaded) return null;
    _albumDetailRestored = true;

    final albumId = await _libraryRepository.getSavedAlbumDetailId();
    if (albumId == null) return null;

    final item = await _libraryRepository.findByIdAsync(albumId);
    if (item case LibraryAlbumItem(:final album)) {
      await _syncBrowsePathForAlbum(album);
      return album;
    }
    await _libraryRepository.saveAlbumDetailId(null);
    return null;
  }

  Future<void> _syncBrowsePathForAlbum(AudioAlbum album) async {
    if (album.tracks.isEmpty) return;
    final dir = normalizeLibraryPath(album.tracks.first.directoryPath);
    if (_browsePath == dir) return;
    _browsePath = dir;
    await _persistBrowsePath();
    await refreshDisplay();
  }

  Future<void> browseUp() async {
    if (!_canGoUp) return;
    clearHighlightedTrack();
    _browsePath = _browseParentPath;
    await _persistBrowsePath();
    await refreshDisplay();
  }

  Future<void> addLibraryRoot(String path) async {
    clearHighlightedTrack();
    final normalized = normalizeLibraryPath(path);
    await _libraryRepository.addLibraryRoot(normalized);
    await browseInto(normalized);
  }

  Future<void> removeLibraryRoot(String path) async {
    clearHighlightedTrack();
    final normalized = normalizeLibraryPath(path);
    await _libraryRepository.removeLibraryRoot(path);
    _browsePath = null;
    _scrollOffsetByBrowseKey.remove(normalized);
    _scrollOffsetByBrowseKey.remove('');
    await _persistBrowsePath();
    await refreshDisplay();
  }

  /// Clears in-memory browse state after the database was reset, then reloads.
  Future<void> reloadAfterDatabaseReset() async {
    clearHighlightedTrack();
    clearKeyboardSelection();
    _browsePath = null;
    _folderSelectionToRestore = null;
    _scrollOffsetByBrowseKey.clear();
    _items = const [];
    _folders = const [];
    _queuePaths = const [];
    _queueIndex = 0;
    await refreshDisplay();
  }

  Future<List<AudioTrack>> tracksForFolder(String folderPath) =>
      _libraryRepository.tracksUnderFolder(folderPath);

  Future<List<AudioTrack>> tracksForPlaylist(PlaylistFile playlist) =>
      _libraryRepository.resolvePlaylistTracks(playlist);

  Future<PlaylistFile> createPlaylistInCurrentFolder(String name) async {
    final directory = _browsePath;
    if (directory == null) {
      throw StateError('Select a library folder before creating a playlist');
    }
    final playlist = await _libraryRepository.createPlaylist(
      directory: directory,
      name: name,
    );
    await refreshDisplay();
    return playlist;
  }

  Future<PlaylistFile> savePlaylistEntries({
    required String playlistPath,
    required List<String> absoluteEntryPaths,
  }) async {
    final playlist = await _libraryRepository.savePlaylistEntries(
      playlistPath: playlistPath,
      absoluteEntryPaths: absoluteEntryPaths,
    );
    await refreshDisplay();
    return playlist;
  }

  Future<void> deletePlaylist(String playlistPath) async {
    if (!isAppCreatedPlaylist(playlistPath)) return;
    await _libraryRepository.deletePlaylist(playlistPath);
    await refreshDisplay();
  }

  Future<LibraryItem?> findById(String id) =>
      _libraryRepository.findByIdAsync(id);

  @override
  @override
  void dispose() {
    // Invalidate deferred folder scans / cover enrich so they stop touching
    // storage after the view model is gone.
    unawaited(_cancelDirectoryScan());
    _albumCoverEnrichGeneration++;
    _isLoadingDirectoryItems = false;
    super.dispose();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';

/// In-app multi-select browser limited to [libraryRoots].
///
/// Pops with a [List<String>] of selected absolute paths, or null if canceled.
class LibraryTrackPickerPage extends StatefulWidget {
  const LibraryTrackPickerPage({
    super.key,
    required this.libraryRoots,
    this.initialPath,
    this.alreadySelected = const {},
  });

  final List<String> libraryRoots;
  final String? initialPath;
  final Set<String> alreadySelected;

  static Future<List<String>?> open(
    BuildContext context, {
    required List<String> libraryRoots,
    String? initialPath,
    Set<String> alreadySelected = const {},
  }) {
    return Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => LibraryTrackPickerPage(
          libraryRoots: libraryRoots,
          initialPath: initialPath,
          alreadySelected: alreadySelected,
        ),
      ),
    );
  }

  @override
  State<LibraryTrackPickerPage> createState() => _LibraryTrackPickerPageState();
}

class _LibraryTrackPickerPageState extends State<LibraryTrackPickerPage> {
  final _selected = <String>{};

  /// null = library roots list; otherwise a folder under a root.
  String? _currentPath;
  List<String> _folders = const [];
  List<String> _files = const [];

  @override
  void initState() {
    super.initState();
    _currentPath = _resolveInitialPath();
    _loadSync();
  }

  String? _resolveInitialPath() {
    final roots = [
      for (final root in widget.libraryRoots) normalizeLibraryPath(root),
    ];
    if (roots.isEmpty) return null;

    final initial = widget.initialPath;
    if (initial != null && isPathWithinLibraryRoots(initial, roots)) {
      final normalized = normalizeLibraryPath(initial);
      if (Directory(normalized).existsSync()) return normalized;
    }
    return null;
  }

  void _loadSync() {
    final roots = [
      for (final root in widget.libraryRoots) normalizeLibraryPath(root),
    ];

    if (_currentPath == null) {
      _folders = roots;
      _files = const [];
      return;
    }

    final path = normalizeLibraryPath(_currentPath!);
    final dir = Directory(path);
    if (!dir.existsSync()) {
      _folders = const [];
      _files = const [];
      return;
    }

    final folders = <String>[];
    final files = <String>[];
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is Directory) {
        folders.add(normalizeLibraryPath(entity.path));
      } else if (entity is File && SupportedFormats.isSupported(entity.path)) {
        files.add(normalizeLibraryPath(entity.path));
      }
    }
    folders.sort(
      (a, b) =>
          p.basename(a).toLowerCase().compareTo(p.basename(b).toLowerCase()),
    );
    files.sort();
    _folders = folders;
    _files = files;
  }

  void _openFolder(String path) {
    setState(() {
      _currentPath = normalizeLibraryPath(path);
      _loadSync();
    });
  }

  void _goUp() {
    final current = _currentPath;
    if (current == null) return;
    final roots = [
      for (final root in widget.libraryRoots) normalizeLibraryPath(root),
    ];
    final normalized = normalizeLibraryPath(current);
    setState(() {
      if (roots.contains(normalized)) {
        _currentPath = null;
      } else {
        final parent = normalizeLibraryPath(p.dirname(normalized));
        _currentPath = isPathWithinLibraryRoots(parent, roots) ? parent : null;
      }
      _loadSync();
    });
  }

  List<String> get _selectableFiles => [
    for (final file in _files)
      if (!widget.alreadySelected.contains(file)) file,
  ];

  void _setFileChecked(String path, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(path);
      } else {
        _selected.remove(path);
      }
    });
  }

  void _toggleSelectAllInFolder() {
    final selectable = _selectableFiles;
    if (selectable.isEmpty) return;
    final allSelected = selectable.every(_selected.contains);
    setState(() {
      if (allSelected) {
        _selected.removeAll(selectable);
      } else {
        _selected.addAll(selectable);
      }
    });
  }

  void _confirm() {
    final added = [
      for (final path in _selected)
        if (!widget.alreadySelected.contains(path)) path,
    ];
    Navigator.of(context).pop(added);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = RetroPalette.of(context);
    final roots = widget.libraryRoots;

    if (roots.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addTracksFromLibrary)),
        body: Center(child: Text(l10n.libraryEmptyNoRoots)),
      );
    }

    final title = _currentPath == null
        ? l10n.library
        : p.basename(_currentPath!);

    return PopScope(
      canPop: _currentPath == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goUp();
      },
      child: Scaffold(
        backgroundColor: palette.screen,
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_selectableFiles.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.select_all),
                tooltip: _selectableFiles.every(_selected.contains)
                    ? l10n.playlistDeselectAll
                    : l10n.playlistSelectAll,
                onPressed: _toggleSelectAllInFolder,
              ),
            if (_currentPath != null)
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                tooltip: l10n.library,
                onPressed: _goUp,
              ),
          ],
        ),
        body: ListView(
          children: [
            if (_currentPath == null)
              for (final root in _folders)
                RetroListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(p.basename(root)),
                  subtitle: Text(root),
                  onTap: () => _openFolder(root),
                )
            else ...[
              for (final folder in _folders)
                RetroListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(p.basename(folder)),
                  onTap: () => _openFolder(folder),
                ),
              for (final file in _files)
                CheckboxListTile(
                  value:
                      _selected.contains(file) ||
                      widget.alreadySelected.contains(file),
                  onChanged: widget.alreadySelected.contains(file)
                      ? null
                      : (checked) => _setFileChecked(file, checked ?? false),
                  secondary: const Icon(Icons.audiotrack),
                  title: Text(p.basename(file)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              if (_folders.isEmpty && _files.isEmpty)
                ListTile(title: Text(l10n.folderEmpty)),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _confirm,
              child: Text(
                _selected.isEmpty
                    ? l10n.addTracksNothingSelected
                    : l10n.addTracksConfirm(_selected.length),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

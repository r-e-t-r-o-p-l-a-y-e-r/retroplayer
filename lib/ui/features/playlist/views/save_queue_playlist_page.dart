import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Picks a real library folder and writes the queue there as an `.m3u`.
///
/// Opens on the library sources. That virtual root is not a directory, so
/// Save stays off until a library source or a folder inside one is open.
class SaveQueuePlaylistPage extends StatefulWidget {
  const SaveQueuePlaylistPage({super.key});

  @override
  State<SaveQueuePlaylistPage> createState() => _SaveQueuePlaylistPageState();
}

class _SaveQueuePlaylistPageState extends State<SaveQueuePlaylistPage> {
  final _name = TextEditingController();

  /// null is the virtual library root.
  String? _currentPath;
  List<String> _folders = const [];
  var _saving = false;
  var _foldersReady = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_foldersReady) return;
    _foldersReady = true;
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  List<String> get _roots {
    final library = context.read<LibraryViewModel>();
    return [
      for (final root in library.libraryRoots) normalizeLibraryPath(root),
    ];
  }

  void _load() {
    final roots = _roots;
    if (_currentPath == null) {
      _folders = roots;
      return;
    }
    final dir = Directory(normalizeLibraryPath(_currentPath!));
    if (!dir.existsSync()) {
      _folders = const [];
      return;
    }
    final folders = <String>[];
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is Directory) {
        folders.add(normalizeLibraryPath(entity.path));
      }
    }
    folders.sort(
      (a, b) =>
          p.basename(a).toLowerCase().compareTo(p.basename(b).toLowerCase()),
    );
    _folders = folders;
  }

  void _open(String path) {
    setState(() {
      _currentPath = normalizeLibraryPath(path);
      _load();
    });
  }

  void _goUp() {
    final current = _currentPath;
    if (current == null) return;
    final roots = _roots;
    final normalized = normalizeLibraryPath(current);
    setState(() {
      if (roots.contains(normalized)) {
        _currentPath = null;
      } else {
        final parent = normalizeLibraryPath(p.dirname(normalized));
        _currentPath = isPathWithinLibraryRoots(parent, roots) ? parent : null;
      }
      _load();
    });
  }

  Future<void> _save() async {
    final directory = _currentPath;
    final name = _name.text.trim();
    if (directory == null || name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<LibraryViewModel>().saveQueueAsPlaylist(
        directory: directory,
        name: name,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = RetroPalette.of(context);
    final atRoot = _currentPath == null;
    final canSave = !atRoot && _name.text.trim().isNotEmpty && !_saving;
    final title = atRoot ? l10n.library : p.basename(_currentPath!);

    return PopScope(
      canPop: atRoot,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goUp();
      },
      child: Scaffold(
        backgroundColor: palette.screen,
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: Icon(atRoot ? Icons.close : Icons.arrow_back),
            onPressed: atRoot ? () => Navigator.of(context).pop() : _goUp,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                l10n.saveAsPlaylist,
                style: RetroTypography.trackTitle(
                  context,
                ).copyWith(fontSize: 17),
              ),
            ),
            if (atRoot)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l10n.choosePlaylistFolder),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.newPlaylistName),
                onSubmitted: canSave ? (_) => _save() : null,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final folder in _folders)
                    RetroListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(p.basename(folder)),
                      subtitle: atRoot ? Text(folder) : null,
                      onTap: () => _open(folder),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: canSave ? _save : null,
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

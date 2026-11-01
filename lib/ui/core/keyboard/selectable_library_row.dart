import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';

enum KeyboardDeleteAction { none, removeLibraryRoot, deletePlaylist }

enum SelectableRowKind { folder, libraryItem }

/// One keyboard-focusable row in the library folder list.
class SelectableLibraryRow {
  const SelectableLibraryRow({
    required this.kind,
    this.folderPath,
    this.folderName,
    this.item,
    this.deleteAction = KeyboardDeleteAction.none,
  });

  final SelectableRowKind kind;
  final String? folderPath;
  final String? folderName;
  final LibraryItem? item;
  final KeyboardDeleteAction deleteAction;
}

List<SelectableLibraryRow> buildFolderSelectableRows({
  required List<FolderEntry> folders,
  List<FolderEntry> favoriteFolders = const [],
  required List<LibraryItem> playlistItems,
  required List<LibraryItem> audioItems,
  required bool atLibraryRoot,
  required Set<String> deletablePlaylistPaths,
}) {
  final rows = <SelectableLibraryRow>[];
  for (final folder in folders) {
    rows.add(
      SelectableLibraryRow(
        kind: SelectableRowKind.folder,
        folderPath: folder.path,
        folderName: folder.name,
        deleteAction: atLibraryRoot
            ? KeyboardDeleteAction.removeLibraryRoot
            : KeyboardDeleteAction.none,
      ),
    );
  }
  if (atLibraryRoot) {
    for (final folder in favoriteFolders) {
      rows.add(
        SelectableLibraryRow(
          kind: SelectableRowKind.folder,
          folderPath: folder.path,
          folderName: folder.name,
        ),
      );
    }
  }
  for (final item in playlistItems) {
    final playlistPath = switch (item) {
      LibraryPlaylistItem(:final playlist) => normalizeLibraryPath(
        playlist.filePath,
      ),
      _ => null,
    };
    rows.add(
      SelectableLibraryRow(
        kind: SelectableRowKind.libraryItem,
        item: item,
        deleteAction:
            playlistPath != null &&
                deletablePlaylistPaths.contains(playlistPath)
            ? KeyboardDeleteAction.deletePlaylist
            : KeyboardDeleteAction.none,
      ),
    );
  }
  for (final item in audioItems) {
    rows.add(
      SelectableLibraryRow(kind: SelectableRowKind.libraryItem, item: item),
    );
  }
  return rows;
}

import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/library_item.dart';

/// A subfolder shown while browsing the library tree.
class FolderEntry {
  const FolderEntry({
    required this.path,
    required this.name,
    this.coverArtPath,
  });

  final String path;
  final String name;

  /// Sidecar (or later resolved) cover for this folder, if known.
  final String? coverArtPath;

  FolderEntry withCoverArtPath(String? coverArtPath) {
    return FolderEntry(
      path: path,
      name: name,
      coverArtPath: coverArtPath,
    );
  }
}

/// Contents of one level in the library folder browser.
class BrowseResult {
  const BrowseResult({
    required this.folders,
    required this.items,
    this.title,
    this.parentPath,
    this.currentPath,
  });

  final List<FolderEntry> folders;
  final List<LibraryItem> items;
  /// Folder name; null at the roots level, where the UI shows its own label.
  final String? title;
  final String? parentPath;
  final String? currentPath;

  bool get canGoUp => parentPath != null || currentPath != null;
}

/// Builds folder navigation views from the current directory listing.
class BrowseLibrary {
  BrowseResult call({
    required String? currentPath,
    required List<String> libraryRoots,
    required List<LibraryItem> directoryItems,
    required List<FolderEntry> childFolders,
  }) {
    final normalizedRoots =
        libraryRoots.map(normalizeLibraryPath).toList();

    if (currentPath == null) {
      return BrowseResult(
        currentPath: null,
        parentPath: null,
        folders: [
          for (final root in normalizedRoots)
            FolderEntry(path: root, name: p.basename(root)),
        ],
        items: const [],
      );
    }

    final current = normalizeLibraryPath(currentPath);

    return BrowseResult(
      title: p.basename(current),
      currentPath: current,
      parentPath: _parentPath(current, normalizedRoots),
      folders: childFolders,
      items: directoryItems,
    );
  }

  String? _parentPath(String current, List<String> roots) {
    final normalized = normalizeLibraryPath(current);
    for (final root in roots) {
      if (normalized == root) return null;
      if (_isUnder(root, normalized)) {
        final parent = normalizeLibraryPath(p.dirname(normalized));
        if (parent == normalized) return null;
        return parent;
      }
    }
    return null;
  }

  bool _isUnder(String root, String path) {
    final r = normalizeLibraryPath(root);
    final candidate = normalizeLibraryPath(path);
    return candidate == r || p.isWithin(r, candidate);
  }
}

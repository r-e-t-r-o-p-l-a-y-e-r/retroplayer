import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/album_art_files.dart';
import 'package:retroplayer/domain/library_paths.dart';

/// Finds artwork in [directoryPath]: preferred names first, then any image.
class FindAlbumArt {
  const FindAlbumArt();

  String? call(String directoryPath) {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) return null;

    // Fast path: exact preferred names (cover.jpg, folder.png, …).
    for (final name in albumArtCandidateNames) {
      final file = File(p.join(directoryPath, name));
      if (file.existsSync()) {
        return normalizeLibraryPath(file.path);
      }
    }

    // One directory listing: case-insensitive preferred names, then any image.
    final lowerToPath = <String, String>{};
    final otherImages = <String>[];
    try {
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final base = p.basename(entity.path);
        final lower = base.toLowerCase();
        lowerToPath.putIfAbsent(lower, () => entity.path);
        if (isAlbumArtImageFileName(base) &&
            !albumArtCandidateNamesLower.contains(lower)) {
          otherImages.add(entity.path);
        }
      }
    } on FileSystemException {
      return null;
    }

    for (final name in albumArtCandidateNames) {
      final path = lowerToPath[name.toLowerCase()];
      if (path != null) return normalizeLibraryPath(path);
    }

    if (otherImages.isEmpty) return null;

    // Prefer common still formats, then stable path order for determinism.
    otherImages.sort((a, b) {
      final aRank = _extensionRank(a);
      final bRank = _extensionRank(b);
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return normalizeLibraryPath(otherImages.first);
  }

  static int _extensionRank(String path) {
    final ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 0,
      '.png' => 1,
      '.webp' => 2,
      '.gif' => 3,
      _ => 9,
    };
  }
}

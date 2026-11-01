import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Persists extracted embedded cover bytes under [rootDirectory].
class AlbumArtCache {
  AlbumArtCache(this.rootDirectory);

  final Directory rootDirectory;

  File _fileForKey(String key, {required String extension}) {
    // Stable, filesystem-safe name derived from the logical cache key.
    final digest = key.codeUnits.fold<int>(0, (hash, unit) {
      return 0x1fffffff & (hash + unit + ((0x1fffffff & hash) << 10));
    });
    final name = '${digest.toRadixString(16)}_${key.length}$extension';
    return File(p.join(rootDirectory.path, name));
  }

  static String extensionForBytes(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    return '.img';
  }

  /// Returns a previously cached path for [key], if present.
  String? existingPath(String key) {
    for (final extension in const ['.jpg', '.png', '.img']) {
      final file = _fileForKey(key, extension: extension);
      if (file.existsSync()) return file.path;
    }
    return null;
  }

  /// Writes [bytes] for [key] and returns the absolute file path.
  String put(String key, Uint8List bytes) {
    if (!rootDirectory.existsSync()) {
      rootDirectory.createSync(recursive: true);
    }
    final file = _fileForKey(
      key,
      extension: extensionForBytes(bytes),
    );
    file.writeAsBytesSync(bytes, flush: true);
    return file.path;
  }
}

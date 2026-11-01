import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';

/// A playlist stored as an `.m3u` / `.m3u8` file on disk.
class PlaylistFile {
  const PlaylistFile({
    required this.filePath,
    required this.entryPaths,
  });

  final String filePath;
  final List<String> entryPaths;

  String get id => playlistItemId(filePath);

  String get displayName => p.basenameWithoutExtension(filePath);

  static String playlistItemId(String playlistPath) =>
      'playlist:${normalizeLibraryPath(playlistPath)}';

  static String? playlistPathFromItemId(String itemId) {
    if (!itemId.startsWith('playlist:')) return null;
    return normalizeLibraryPath(itemId.substring('playlist:'.length));
  }
}

import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/local_path_policy.dart';

/// Resolves playlist entry paths relative to the playlist file location.
class ResolvePlaylistPaths {
  const ResolvePlaylistPaths();

  /// Resolves [rawEntry] to a local filesystem path, or `null` if remote/non-local.
  String? resolveEntry({
    required String playlistPath,
    required String rawEntry,
  }) {
    final trimmed = rawEntry.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!isLocalFilesystemPath(trimmed)) return null;

    if (p.isAbsolute(trimmed)) {
      return normalizeLibraryPath(trimmed);
    }

    final baseDir = normalizeLibraryPath(p.dirname(playlistPath));
    return normalizeLibraryPath(p.normalize(p.join(baseDir, trimmed)));
  }

  String toRelativeEntry({
    required String playlistPath,
    required String absolutePath,
  }) {
    final baseDir = normalizeLibraryPath(p.dirname(playlistPath));
    final normalized = normalizeLibraryPath(absolutePath);
    if (p.isWithin(baseDir, normalized) || normalized == baseDir) {
      return p.relative(normalized, from: baseDir);
    }
    return normalized;
  }
}

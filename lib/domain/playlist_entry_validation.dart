import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/local_path_policy.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';

/// Filters candidate audio paths for playlist membership.
List<String> filterNewPlaylistEntries({
  required Iterable<String> paths,
  required List<String> libraryRoots,
  required Set<String> existingPaths,
}) {
  final added = <String>[];
  final seen = <String>{...existingPaths};
  for (final path in paths) {
    if (!isLocalFilesystemPath(path)) continue;
    final normalized = normalizeLibraryPath(path);
    if (!SupportedFormats.isSupported(normalized)) continue;
    if (!isPathWithinLibraryRoots(normalized, libraryRoots)) continue;
    if (!seen.add(normalized)) continue;
    added.add(normalized);
  }
  return added;
}

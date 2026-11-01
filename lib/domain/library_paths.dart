import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';

/// One segment in the library folder breadcrumb trail.
class BrowseBreadcrumb {
  const BrowseBreadcrumb({
    required this.label,
    this.path,
    this.isLibraryRoot = false,
  });

  /// Display name for this level (folder basename). Empty when [isLibraryRoot].
  final String label;

  /// Absolute folder path to navigate to, or null for the library root.
  final String? path;

  /// When true, UI should show the localized library root label.
  final bool isLibraryRoot;
}

/// Normalizes filesystem paths for consistent library browse and persistence keys.
String normalizeLibraryPath(String path) {
  try {
    return p.normalize(p.absolute(path));
  } on Object {
    return p.normalize(path);
  }
}

/// Stable track identifier derived from the audio file location.
String stableTrackId(String filePath) => normalizeLibraryPath(filePath);

/// The id matches a later metadata read, so playback can start immediately
/// and titles can replace these without reloading the audio.
AudioTrack trackWithoutMetadata(String filePath) {
  final id = stableTrackId(filePath);
  return AudioTrack(
    id: id,
    filePath: id,
    directoryPath: normalizeLibraryPath(p.dirname(id)),
    metadata: TrackMetadata(title: p.basenameWithoutExtension(id)),
    dateAdded: DateTime.utc(1970),
  );
}

/// Whether [path] is a library root or nested folder under one of [roots].
bool isPathWithinLibraryRoots(String path, List<String> roots) {
  final normalized = normalizeLibraryPath(path);
  for (final root in roots) {
    if (isPathUnderRoot(normalized, root)) {
      return true;
    }
  }
  return false;
}

/// Whether [path] is [root] itself or nested under [root].
bool isPathUnderRoot(String path, String root) {
  final normalized = normalizeLibraryPath(path);
  final normalizedRoot = normalizeLibraryPath(root);
  return normalized == normalizedRoot ||
      p.isWithin(normalizedRoot, normalized);
}

/// Builds breadcrumb segments from [browsePath] under [libraryRoots].
List<BrowseBreadcrumb> libraryBrowseBreadcrumbs({
  required String? browsePath,
  required List<String> libraryRoots,
}) {
  const root = BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true);
  if (browsePath == null) return const [root];

  final current = normalizeLibraryPath(browsePath);
  for (final rootPath in libraryRoots) {
    final normalizedRoot = normalizeLibraryPath(rootPath);
    if (current != normalizedRoot && !p.isWithin(normalizedRoot, current)) {
      continue;
    }

    final segments = <BrowseBreadcrumb>[root];
    var accumulated = normalizedRoot;
    segments.add(BrowseBreadcrumb(
      label: p.basename(normalizedRoot),
      path: normalizedRoot,
    ));

    if (current != normalizedRoot) {
      final relative = p.split(p.relative(current, from: normalizedRoot));
      for (final part in relative) {
        accumulated = normalizeLibraryPath(p.join(accumulated, part));
        segments.add(BrowseBreadcrumb(label: part, path: accumulated));
      }
    }
    return segments;
  }

  return [
    root,
    BrowseBreadcrumb(label: p.basename(current), path: null),
  ];
}

/// Breadcrumb trail for now playing, with playlist context when applicable.
List<BrowseBreadcrumb> playbackBreadcrumbs({
  required AudioTrack? track,
  required List<String> libraryRoots,
  String? playingItemId,
}) {
  if (track == null) {
    return const [BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true)];
  }

  final playlistPath = playingItemId != null
      ? PlaylistFile.playlistPathFromItemId(playingItemId)
      : null;
  if (playlistPath != null) {
    final playlistDir = normalizeLibraryPath(p.dirname(playlistPath));
    final folderCrumbs = libraryBrowseBreadcrumbs(
      browsePath: playlistDir,
      libraryRoots: libraryRoots,
    );
    return [
      ...folderCrumbs,
      BrowseBreadcrumb(
        label: p.basenameWithoutExtension(playlistPath),
        path: playlistPath,
      ),
      BrowseBreadcrumb(label: track.displayTitle, path: track.filePath),
    ];
  }

  return playbackFileBreadcrumbs(track: track, libraryRoots: libraryRoots);
}

/// Breadcrumb trail for the folder path and file name of [track].
List<BrowseBreadcrumb> playbackFileBreadcrumbs({
  required AudioTrack? track,
  required List<String> libraryRoots,
}) {
  if (track == null) {
    return const [BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true)];
  }

  if (!isPathWithinLibraryRoots(track.directoryPath, libraryRoots)) {
    return [
      const BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true),
      BrowseBreadcrumb(label: track.displayTitle, path: track.filePath),
    ];
  }

  final folderCrumbs = libraryBrowseBreadcrumbs(
    browsePath: track.directoryPath,
    libraryRoots: libraryRoots,
  );
  return [
    ...folderCrumbs,
    BrowseBreadcrumb(label: track.displayTitle, path: track.filePath),
  ];
}

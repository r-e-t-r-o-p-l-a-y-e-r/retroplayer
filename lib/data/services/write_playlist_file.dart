import 'dart:io';

import 'package:retroplayer/domain/use_cases/resolve_playlist_paths.dart';

/// Writes playlist entries to an on-disk M3U file using relative paths.
class WritePlaylistFile {
  const WritePlaylistFile({ResolvePlaylistPaths? resolver})
      : _resolver = resolver ?? const ResolvePlaylistPaths();

  final ResolvePlaylistPaths _resolver;

  Future<void> call(String playlistPath, List<String> absoluteEntryPaths) async {
    final file = File(playlistPath);
    await file.parent.create(recursive: true);

    final lines = <String>['#EXTM3U'];
    for (final entry in absoluteEntryPaths) {
      lines.add(
        _resolver.toRelativeEntry(
          playlistPath: playlistPath,
          absolutePath: entry,
        ),
      );
    }

    await file.writeAsString('${lines.join('\n')}\n');
  }
}

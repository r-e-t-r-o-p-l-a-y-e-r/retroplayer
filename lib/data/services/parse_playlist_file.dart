import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:retroplayer/domain/use_cases/resolve_playlist_paths.dart';

/// Reads playlist entries from an on-disk M3U file.
class ParsePlaylistFile {
  const ParsePlaylistFile({ResolvePlaylistPaths? resolver})
      : _resolver = resolver ?? const ResolvePlaylistPaths();

  final ResolvePlaylistPaths _resolver;

  Future<List<String>> call(String playlistPath) async {
    final file = File(playlistPath);
    if (!await file.exists()) return const [];

    final content = await _readPlaylistText(file);
    final entries = <String>[];
    for (final line in const LineSplitter().convert(content)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final resolved = _resolver.resolveEntry(
        playlistPath: playlistPath,
        rawEntry: trimmed,
      );
      if (resolved == null || resolved.isEmpty) continue;
      entries.add(resolved);
    }
    return entries;
  }

  /// Prefer UTF-8 (incl. BOM); fall back to Windows-1250 for legacy playlists.
  Future<String> _readPlaylistText(File file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return '';

    // Strip UTF-8 BOM when present.
    final start =
        bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF
        ? 3
        : 0;
    final payload = start == 0 ? bytes : bytes.sublist(start);

    try {
      return utf8.decode(payload);
    } on FormatException {
      try {
        return windows1250.decode(payload);
      } on Object {
        return latin1.decode(payload, allowInvalid: true);
      }
    }
  }
}

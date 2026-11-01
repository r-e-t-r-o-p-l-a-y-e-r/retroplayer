/// Playlist resolve/parse/filter drop remote http(s) entries.
///
/// Evidence:
/// - `resolveEntry returns null for remote URLs`
/// - `ParsePlaylistFile skips remote M3U lines`
/// - `filterNewPlaylistEntries rejects remote URLs`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/playlist_entry_validation.dart';
import 'package:retroplayer/data/services/parse_playlist_file.dart';
import 'package:retroplayer/domain/use_cases/resolve_playlist_paths.dart';

void main() {
  const resolver = ResolvePlaylistPaths();

  test('resolveEntry returns null for remote URLs', () {
    expect(
      resolver.resolveEntry(
        playlistPath: '/music/list.m3u',
        rawEntry: 'https://cdn.example/track.mp3',
      ),
      isNull,
    );
    expect(
      resolver.resolveEntry(
        playlistPath: '/music/list.m3u',
        rawEntry: 'http://cdn.example/track.mp3',
      ),
      isNull,
    );
  });

  test('ParsePlaylistFile skips remote M3U lines', () async {
    final dir = await Directory.systemTemp.createTemp('rpc-privacy-m3u-');
    addTearDown(() => dir.delete(recursive: true));
    final playlist = File(p.join(dir.path, 'mix.m3u'));
    await playlist.writeAsString('''
#EXTM3U
https://evil.example/a.mp3
local.mp3
http://evil.example/b.mp3
''');

    final entries = await const ParsePlaylistFile().call(playlist.path);
    expect(entries, [p.join(dir.path, 'local.mp3')]);
  });

  test('filterNewPlaylistEntries rejects remote URLs', () {
    final added = filterNewPlaylistEntries(
      paths: [
        'https://cdn.example/a.mp3',
        '/music/ok.mp3',
      ],
      libraryRoots: ['/music'],
      existingPaths: {},
    );
    expect(added, ['/music/ok.mp3']);
  });
}

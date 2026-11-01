/// ResolvePlaylistPaths local path resolution (remote URLs rejected).
///
/// Evidence:
/// - `resolves relative entry from playlist directory`
/// - `writes relative entry when track is under playlist folder`
/// - `keeps absolute path when track is outside playlist folder`
/// - `returns null for remote URL entries`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/use_cases/resolve_playlist_paths.dart';

void main() {
  const resolver = ResolvePlaylistPaths();

  group('ResolvePlaylistPaths', () {
    test('resolves relative entry from playlist directory', () {
      expect(
        resolver.resolveEntry(
          playlistPath: '/music/playlists/road.m3u',
          rawEntry: 'sub/track.mp3',
        ),
        '/music/playlists/sub/track.mp3',
      );
    });

    test('writes relative entry when track is under playlist folder', () {
      expect(
        resolver.toRelativeEntry(
          playlistPath: '/music/playlists/road.m3u',
          absolutePath: '/music/playlists/sub/track.mp3',
        ),
        'sub/track.mp3',
      );
    });

    test('keeps absolute path when track is outside playlist folder', () {
      expect(
        resolver.toRelativeEntry(
          playlistPath: '/music/playlists/road.m3u',
          absolutePath: '/other/track.mp3',
        ),
        '/other/track.mp3',
      );
    });

    test('returns null for remote URL entries', () {
      expect(
        resolver.resolveEntry(
          playlistPath: '/music/playlists/road.m3u',
          rawEntry: 'https://example.com/a.mp3',
        ),
        isNull,
      );
    });
  });
}

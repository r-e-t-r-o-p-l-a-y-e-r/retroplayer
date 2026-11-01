/// filterNewPlaylistEntries root, format, and duplicate rules.
///
/// Evidence:
/// - `accepts tracks in playlist subfolders`
/// - `rejects tracks outside library roots`
/// - `skips duplicates and existing entries`
/// - `rejects unsupported formats`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/playlist_entry_validation.dart';

void main() {
  group('filterNewPlaylistEntries', () {
    test('accepts tracks in playlist subfolders', () {
      final added = filterNewPlaylistEntries(
        paths: ['/music/album/disc1/track01.mp3'],
        libraryRoots: ['/music'],
        existingPaths: {},
      );

      expect(added, [normalizeLibraryPath('/music/album/disc1/track01.mp3')]);
    });

    test('rejects tracks outside library roots', () {
      final added = filterNewPlaylistEntries(
        paths: ['/other/track01.mp3'],
        libraryRoots: ['/music'],
        existingPaths: {},
      );

      expect(added, isEmpty);
    });

    test('skips duplicates and existing entries', () {
      final existing = {normalizeLibraryPath('/music/track01.mp3')};
      final added = filterNewPlaylistEntries(
        paths: [
          '/music/track01.mp3',
          '/music/track02.mp3',
          '/music/track02.mp3',
        ],
        libraryRoots: ['/music'],
        existingPaths: existing,
      );

      expect(added, [normalizeLibraryPath('/music/track02.mp3')]);
    });

    test('rejects unsupported formats', () {
      final added = filterNewPlaylistEntries(
        paths: ['/music/readme.txt'],
        libraryRoots: ['/music'],
        existingPaths: {},
      );

      expect(added, isEmpty);
    });
  });
}

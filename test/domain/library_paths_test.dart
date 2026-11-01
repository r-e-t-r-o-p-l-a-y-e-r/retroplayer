/// Library root containment and browse/playback breadcrumb builders.
///
/// Evidence:
/// - `accepts a library root path`
/// - `accepts nested folders under a root`
/// - `rejects paths outside all roots`
/// - `returns library root when browse path is null`
/// - `builds nested folder trail under a library root`
/// - `includes library root folder when browsing it directly`
/// - `uses folder basename when path is outside library roots`
/// - `returns library root when no track is playing`
/// - `appends track title after folder trail`
/// - `shows library and track title when folder is outside roots`
/// - `shows playlist name before track when playing a playlist`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

const _libraryRoot = BrowseBreadcrumb(label: '', path: null, isLibraryRoot: true);

void main() {
  group('isPathWithinLibraryRoots', () {
    test('accepts a library root path', () {
      expect(
        isPathWithinLibraryRoots('/music', ['/music', '/podcasts']),
        isTrue,
      );
    });

    test('accepts nested folders under a root', () {
      expect(
        isPathWithinLibraryRoots('/music/Author/Book', ['/music']),
        isTrue,
      );
    });

    test('rejects paths outside all roots', () {
      expect(
        isPathWithinLibraryRoots('/other/path', ['/music']),
        isFalse,
      );
    });
  });

  group('libraryBrowseBreadcrumbs', () {
    test('returns library root when browse path is null', () {
      expect(
        libraryBrowseBreadcrumbs(browsePath: null, libraryRoots: ['/music']),
        [_libraryRoot],
      );
    });

    test('builds nested folder trail under a library root', () {
      final crumbs = libraryBrowseBreadcrumbs(
        browsePath: '/music/Author/Book1',
        libraryRoots: ['/music'],
      );

      expect(crumbs.map((c) => c.label).toList(), ['', 'music', 'Author', 'Book1']);
      expect(crumbs.first.isLibraryRoot, isTrue);
      expect(crumbs.map((c) => c.path).toList(), [
        null,
        '/music',
        '/music/Author',
        '/music/Author/Book1',
      ]);
    });

    test('includes library root folder when browsing it directly', () {
      final crumbs = libraryBrowseBreadcrumbs(
        browsePath: '/music',
        libraryRoots: ['/music'],
      );

      expect(crumbs.map((c) => c.label).toList(), ['', 'music']);
      expect(crumbs.last.path, '/music');
    });

    test('uses folder basename when path is outside library roots', () {
      final crumbs = libraryBrowseBreadcrumbs(
        browsePath: '/music/Author/Book1',
        libraryRoots: ['/podcasts'],
      );

      expect(crumbs.map((c) => c.label).toList(), ['', 'Book1']);
      expect(crumbs.last.path, isNull);
    });
  });

  group('playbackFileBreadcrumbs', () {
    test('returns library root when no track is playing', () {
      expect(
        playbackFileBreadcrumbs(track: null, libraryRoots: ['/music']),
        [_libraryRoot],
      );
    });

    test('appends track title after folder trail', () {
      final track = AudioTrack(
        id: '/music/Author/Book1/ch02.mp3',
        filePath: '/music/Author/Book1/ch02.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(title: 'Chapter 2'),
        dateAdded: DateTime(2024),
      );

      final crumbs = playbackFileBreadcrumbs(
        track: track,
        libraryRoots: ['/music'],
      );

      expect(crumbs.map((c) => c.label).toList(), [
        '',
        'music',
        'Author',
        'Book1',
        'Chapter 2',
      ]);
      expect(crumbs.last.path, '/music/Author/Book1/ch02.mp3');
    });

    test('shows library and track title when folder is outside roots', () {
      final track = AudioTrack(
        id: '/music/Author/Book1/ch02.mp3',
        filePath: '/music/Author/Book1/ch02.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(title: 'Chapter 2'),
        dateAdded: DateTime(2024),
      );

      final crumbs = playbackFileBreadcrumbs(
        track: track,
        libraryRoots: const [],
      );

      expect(crumbs.map((c) => c.label).toList(), ['', 'Chapter 2']);
      expect(crumbs.last.path, '/music/Author/Book1/ch02.mp3');
    });
  });

  group('playbackBreadcrumbs', () {
    test('shows playlist name before track when playing a playlist', () {
      final track = AudioTrack(
        id: '/music/Author/Book1/ch02.mp3',
        filePath: '/music/Author/Book1/ch02.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(title: 'Chapter 2'),
        dateAdded: DateTime(2024),
      );

      final crumbs = playbackBreadcrumbs(
        track: track,
        libraryRoots: ['/music'],
        playingItemId: 'playlist:/music/my-list.m3u',
      );

      expect(crumbs.map((c) => c.label).toList(), [
        '',
        'music',
        'my-list',
        'Chapter 2',
      ]);
      expect(crumbs[2].path, '/music/my-list.m3u');
      expect(crumbs.last.path, '/music/Author/Book1/ch02.mp3');
    });
  });
}

/// GroupTracksIntoAlbums tag and directory grouping heuristics.
///
/// Evidence:
/// - `groups tracks with same album tag into one album`
/// - `merges album tags that differ only by case in the same directory`
/// - `groups untagged files in same directory by directory name`
/// - `leaves single loose file as standalone track`
/// - `groups series subdirectories under parent author folder`
/// - `leaves coverArtPath unset during grouping even when cover.jpg exists`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import '../../helpers/track_factory.dart';

void main() {
  late GroupTracksIntoAlbums useCase;

  setUp(() {
    useCase = const GroupTracksIntoAlbums();
  });

  group('GroupTracksIntoAlbums', () {
    test('groups tracks with same album tag into one album', () {
      final tracks = [
        testTrack(
          id: '1',
          filePath: '/music/book/ch01.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(album: 'Test Book', trackNumber: 1),
        ),
        testTrack(
          id: '2',
          filePath: '/music/book/ch02.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(album: 'Test Book', trackNumber: 2),
        ),
      ];

      final items = useCase(tracks);

      expect(items, hasLength(1));
      final item = items.single;
      expect(item, isA<LibraryAlbumItem>());
      switch (item) {
        case LibraryAlbumItem(:final album):
          expect(album.title, 'Test Book');
          expect(album.tracks, hasLength(2));
          expect(album.tracks.first.trackNumber, 1);
          expect(album.tracks.last.trackNumber, 2);
        case LibraryTrackItem():
          fail('Expected album item');
        case LibraryPlaylistItem():
          fail('Expected album item');
      }
    });

    test('merges album tags that differ only by case in the same directory', () {
      final tracks = [
        testTrack(
          id: '1',
          filePath: '/music/book/ch01.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(album: 'Test Book', trackNumber: 1),
        ),
        testTrack(
          id: '2',
          filePath: '/music/book/ch02.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(album: 'test book', trackNumber: 2),
        ),
      ];

      final items = useCase(tracks);

      expect(items, hasLength(1));
      switch (items.single) {
        case LibraryAlbumItem(:final album):
          expect(album.title, 'Test Book');
          expect(album.tracks, hasLength(2));
        case LibraryTrackItem():
          fail('Expected album item');
        case LibraryPlaylistItem():
          fail('Expected album item');
      }
    });

    test('groups untagged files in same directory by directory name', () {
      final tracks = [
        testTrack(
          id: '1',
          filePath: '/audiobooks/Author/Book Title/01-intro.mp3',
          directoryPath: '/audiobooks/Author/Book Title',
          metadata: const TrackMetadata(),
        ),
        testTrack(
          id: '2',
          filePath: '/audiobooks/Author/Book Title/02-body.mp3',
          directoryPath: '/audiobooks/Author/Book Title',
          metadata: const TrackMetadata(),
        ),
      ];

      final items = useCase(tracks);

      expect(items, hasLength(1));
      switch (items.single) {
        case LibraryAlbumItem(:final album):
          expect(album.title, 'Book Title');
          expect(album.artist, 'Author');
          expect(album.tracks, hasLength(2));
        case LibraryTrackItem():
          fail('Expected album item');
        case LibraryPlaylistItem():
          fail('Expected album item');
      }
    });

    test('leaves single loose file as standalone track', () {
      final tracks = [
        testTrack(
          id: '1',
          filePath: '/music/single.mp3',
          directoryPath: '/music',
          metadata: const TrackMetadata(title: 'Single Song'),
        ),
      ];

      final items = useCase(tracks);

      expect(items, hasLength(1));
      expect(items.single, isA<LibraryTrackItem>());
    });

    test('groups series subdirectories under parent author folder', () {
      final tracks = [
        testTrack(
          id: '1',
          filePath: '/Author/Book1/ch01.mp3',
          directoryPath: '/Author/Book1',
          metadata: const TrackMetadata(),
        ),
        testTrack(
          id: '2',
          filePath: '/Author/Book1/ch02.mp3',
          directoryPath: '/Author/Book1',
          metadata: const TrackMetadata(),
        ),
        testTrack(
          id: '3',
          filePath: '/Author/Book2/ch01.mp3',
          directoryPath: '/Author/Book2',
          metadata: const TrackMetadata(),
        ),
        testTrack(
          id: '4',
          filePath: '/Author/Book2/ch02.mp3',
          directoryPath: '/Author/Book2',
          metadata: const TrackMetadata(),
        ),
      ];

      final items = useCase(tracks);

      expect(items, hasLength(2));
      final titles = items.map((i) {
        return switch (i) {
          LibraryAlbumItem(:final album) => album.title,
          LibraryTrackItem() => '',
          LibraryPlaylistItem() => '',
        };
      }).toSet();
      expect(titles, containsAll(['Book1', 'Book2']));
    });

    test('splits same album tag in one folder by disc number', () {
      final dir = '/music/Unplugged';
      final tracks = [
        testTrack(
          id: 'd1t1',
          filePath: '$dir/01.mp3',
          directoryPath: dir,
          metadata: const TrackMetadata(
            album: 'Unplugged',
            trackNumber: 1,
            discNumber: 1,
          ),
        ),
        testTrack(
          id: 'd1t2',
          filePath: '$dir/02.mp3',
          directoryPath: dir,
          metadata: const TrackMetadata(
            album: 'Unplugged',
            trackNumber: 2,
            discNumber: 1,
          ),
        ),
        testTrack(
          id: 'd2t1',
          filePath: '$dir/03.mp3',
          directoryPath: dir,
          metadata: const TrackMetadata(
            album: 'Unplugged',
            trackNumber: 1,
            discNumber: 2,
          ),
        ),
        testTrack(
          id: 'd2t2',
          filePath: '$dir/04.mp3',
          directoryPath: dir,
          metadata: const TrackMetadata(
            album: 'Unplugged',
            trackNumber: 2,
            discNumber: 2,
          ),
        ),
      ];

      final items = useCase(tracks);

      expect(items.whereType<LibraryAlbumItem>(), hasLength(2));
      for (final item in items) {
        switch (item) {
          case LibraryAlbumItem(:final album):
            expect(album.tracks, hasLength(2));
            final discs = album.tracks.map((t) => t.metadata.discNumber).toSet();
            expect(discs, hasLength(1));
            expect(album.tracks.first.trackNumber, 1);
            expect(album.tracks.last.trackNumber, 2);
          default:
            fail('Expected album items only');
        }
      }
    });

    test('leaves coverArtPath unset during grouping even when cover.jpg exists',
        () async {
      final dir = await Directory.systemTemp.createTemp('group_no_cover_');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });
      await File('${dir.path}/cover.jpg').writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);
      final tracks = [
        testTrack(
          id: '1',
          filePath: '${dir.path}/ch01.mp3',
          directoryPath: dir.path,
          metadata: const TrackMetadata(album: 'Test Book', trackNumber: 1),
        ),
        testTrack(
          id: '2',
          filePath: '${dir.path}/ch02.mp3',
          directoryPath: dir.path,
          metadata: const TrackMetadata(album: 'Test Book', trackNumber: 2),
        ),
      ];

      final items = useCase(tracks);

      switch (items.single) {
        case LibraryAlbumItem(:final album):
          expect(album.coverArtPath, isNull);
        default:
          fail('Expected album item');
      }
    });
  });
}

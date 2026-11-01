/// Album playback copies library names onto tracks that have no tags.
///
/// Evidence:
/// - `fills missing artist and album from the album and keeps tags`
/// - `replaces blank artist and album tags with the album labels`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

import '../../helpers/track_factory.dart';

void main() {
  test('fills missing artist and album from the album and keeps tags', () {
    final bare = testTrack(
      filePath: '/books/Author/Book/02.mp3',
      directoryPath: '/books/Author/Book',
      metadata: const TrackMetadata(trackNumber: 2),
    );
    final tagged = testTrack(
      filePath: '/books/Author/Book/01.mp3',
      directoryPath: '/books/Author/Book',
      metadata: const TrackMetadata(
        title: 'Opening',
        artist: 'Tagged Author',
        album: 'Tagged Book',
        trackNumber: 1,
      ),
    );
    final album = AudioAlbum(
      id: 'dir',
      title: 'Book',
      artist: 'Author',
      tracks: [bare, tagged],
      source: AlbumSource.directory,
      groupingKey: 'dir',
    );

    final playback = AlbumPlayback(album);

    expect(playback.tracks.map((track) => track.filePath), [
      tagged.filePath,
      bare.filePath,
    ]);
    expect(playback.tracks[0].metadata.artist, 'Tagged Author');
    expect(playback.tracks[0].metadata.album, 'Tagged Book');
    expect(playback.tracks[1].metadata.artist, 'Author');
    expect(playback.tracks[1].metadata.album, 'Book');
    expect(playback.tracks[1].metadata.trackNumber, 2);
    expect(bare.metadata.artist, isNull);
    expect(bare.metadata.album, isNull);
  });

  test('replaces blank artist and album tags with the album labels', () {
    final track = testTrack(
      filePath: '/books/Author/Book/01.mp3',
      directoryPath: '/books/Author/Book',
      metadata: const TrackMetadata(artist: '  ', album: ' '),
    );
    final album = AudioAlbum(
      id: 'dir',
      title: ' Book ',
      artist: ' Author ',
      tracks: [track],
      source: AlbumSource.directory,
      groupingKey: 'dir',
    );

    final playback = AlbumPlayback(album);

    expect(playback.tracks.single.metadata.artist, 'Author');
    expect(playback.tracks.single.metadata.album, 'Book');
    expect(track.metadata.artist, '  ');
    expect(track.metadata.album, ' ');
  });
}

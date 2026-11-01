/// AudioAlbum.sortedTracks orders by disc then track number.
///
/// Evidence:
/// - `sorts by disc number before track number`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

import '../../helpers/track_factory.dart';

void main() {
  test('sorts by disc number before track number', () {
    const album = AudioAlbum(
      id: 'tag:test',
      title: 'Unplugged',
      tracks: [],
      source: AlbumSource.tag,
      groupingKey: 'tag:test',
    );
    final unsorted = album.copyWith(
      tracks: [
        testTrack(
          id: 'd2t1',
          filePath: '/m/03.mp3',
          directoryPath: '/m',
          metadata: const TrackMetadata(trackNumber: 1, discNumber: 2),
        ),
        testTrack(
          id: 'd1t2',
          filePath: '/m/02.mp3',
          directoryPath: '/m',
          metadata: const TrackMetadata(trackNumber: 2, discNumber: 1),
        ),
        testTrack(
          id: 'd1t1',
          filePath: '/m/01.mp3',
          directoryPath: '/m',
          metadata: const TrackMetadata(trackNumber: 1, discNumber: 1),
        ),
      ],
    );

    final sorted = unsorted.sortedTracks();

    expect(sorted.tracks.map((t) => t.id).toList(), ['d1t1', 'd1t2', 'd2t1']);
  });
}

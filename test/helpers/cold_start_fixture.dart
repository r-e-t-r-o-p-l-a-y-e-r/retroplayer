import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

import 'track_factory.dart';

/// Folder album with [count] tracks for cold-start / restore perf tests.
({AudioAlbum album, List<AudioTrack> tracks, String albumId, String directoryPath})
albumTracksFixture({
  int count = 23,
  String directoryPath = '/music/book',
}) {
  final albumId = 'dir:$directoryPath';
  final tracks = [
    for (var i = 1; i <= count; i++)
      testTrack(
        filePath: '$directoryPath/ch${i.toString().padLeft(2, '0')}.mp3',
        directoryPath: directoryPath,
        metadata: TrackMetadata(
          trackNumber: i,
          title: 'Chapter $i',
        ),
        durationMs: 180000,
      ),
  ];
  final album = AudioAlbum(
    id: albumId,
    title: 'Book',
    tracks: tracks,
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
  return (
    album: album,
    tracks: tracks,
    albumId: albumId,
    directoryPath: directoryPath,
  );
}

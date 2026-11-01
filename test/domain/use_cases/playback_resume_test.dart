/// PlaybackResume index/position resolution from saved state.
///
/// Evidence:
/// - `resolveAlbumResume uses saved track index and position`
/// - `indexOfTrack finds saved track by normalized file path`
/// - `resolveAlbumResume starts at beginning when nothing is saved`
/// - `resumePosition ignores zero millisecond positions`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';
import '../../helpers/track_factory.dart';

void main() {
  group('PlaybackResume', () {
    const albumId = 'dir:/music/book';
    final tracks = [
      testTrack(
        filePath: '/music/book/ch01.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 1),
      ),
      testTrack(
        filePath: '/music/book/ch02.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 2),
      ),
    ];

    final album = AudioAlbum(
      id: albumId,
      title: 'Book',
      tracks: tracks,
      source: AlbumSource.directory,
      groupingKey: albumId,
    );

    test('resolveAlbumResume uses saved track index and position', () {
      final plan = PlaybackResume.resolveAlbumResume(
        album: album,
        saved: (
          trackId: '/music/book/ch02.mp3',
          positionMs: 45000,
          speed: 1.25,
          displayTitle: null,
          subtitle: null,
          durationMs: null,
        ),
      );

      expect(plan.startIndex, 1);
      expect(plan.initialPosition, const Duration(seconds: 45));
      expect(plan.speed, 1.25);
      expect(plan.trackId, '/music/book/ch02.mp3');
    });

    test('indexOfTrack finds saved track by normalized file path', () {
      expect(
        PlaybackResume.indexOfTrack(tracks, '/music/book/ch02.mp3'),
        1,
      );
    });

    test('resolveAlbumResume starts at beginning when nothing is saved', () {
      final plan = PlaybackResume.resolveAlbumResume(album: album);

      expect(plan.startIndex, 0);
      expect(plan.initialPosition, isNull);
      expect(plan.speed, 1.0);
      expect(plan.trackId, '/music/book/ch01.mp3');
    });

    test('resumePosition ignores zero millisecond positions', () {
      expect(PlaybackResume.resumePosition(Duration.zero), isNull);
      expect(
        PlaybackResume.resumePosition(const Duration(seconds: 5)),
        const Duration(seconds: 5),
      );
    });
  });
}

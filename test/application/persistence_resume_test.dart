/// Resume after library rescan with stable album ids and track file keys.
///
/// Evidence:
/// - `GroupTracksIntoAlbums uses stable album id from groupingKey`
/// - `resume survives rescan with same file paths`
/// - `saveProgress stores file path as track key`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/application/play_queue.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:just_audio/just_audio.dart';
import '../helpers/track_factory.dart';

void main() {
  group('Persistence resume after rescan', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late _RecordingPlayback playback;
    late PlayQueue playQueue;

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

    setUp(() {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      playback = _RecordingPlayback();
      playQueue = PlayQueue(engine: playback, store: storage);
    });

    tearDown(() async {
      await db.close();
    });

    test('GroupTracksIntoAlbums uses stable album id from groupingKey', () {
      final grouped = GroupTracksIntoAlbums()(tracks);
      expect(grouped, hasLength(1));
      switch (grouped.single) {
        case LibraryAlbumItem(:final album):
          expect(album.id, 'dir:/music/book');
        case LibraryTrackItem():
          fail('expected album');
        case LibraryPlaylistItem():
          fail('expected album');
      }
    });

    test('resume survives rescan with same file paths', () async {
      await storage.savePlaybackState(
        itemId: albumId,
        trackId: '/music/book/ch02.mp3',
        positionMs: 45000,
        speed: 1.25,
      );

      await playQueue.start(AlbumPlayback(album));

      expect(playback.lastStartIndex, 1);
      expect(playback.lastInitialPosition, const Duration(seconds: 45));
      expect(playback.lastSpeed, 1.25);
    });

    test('saveProgress stores file path as track key', () async {
      playback.currentTrackOverride = tracks.first;
      playback.positionOverride = const Duration(seconds: 12);

      await playQueue.saveProgress(albumId);

      final saved = await storage.getPlaybackState(albumId);
      expect(saved?.trackId, '/music/book/ch01.mp3');
      expect(saved?.positionMs, 12000);
    });
  });
}

class _RecordingPlayback implements AudioPlaybackService {
  List<AudioTrack>? lastQueue;
  int lastStartIndex = 0;
  Duration? lastInitialPosition;
  double lastSpeed = 1.0;
  AudioTrack? currentTrackOverride;
  Duration positionOverride = Duration.zero;

  @override
  AudioTrack? get currentTrack => currentTrackOverride;

  @override
  Duration get position => positionOverride;

  @override
  Duration? get duration => null;

  @override
  Stream<AudioTrack?> get currentTrackStream => const Stream.empty();

  @override
  List<AudioTrack> get queue => lastQueue ?? const [];

  @override
  bool get hasNext => false;

  @override
  bool get hasPrevious => false;

  @override
  int? get currentQueueIndex => null;

  @override
  double get speed => lastSpeed;

  @override
  int? get androidAudioSessionId => null;

  @override
  Stream<int?> get androidAudioSessionIdStream => const Stream.empty();


  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  Stream<Duration?> get durationStream => const Stream.empty();

  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();

  @override
  Stream<bool> get playingStream => const Stream.empty();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}


  @override
  Future<void> seekToQueueIndex(int index) async {}

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    lastQueue = tracks;
    lastStartIndex = startIndex;
    lastInitialPosition = initialPosition;
  }

  @override
  Future<void> setSpeed(double speed) async => lastSpeed = speed;


  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  void replaceQueueTracks(List<AudioTrack> tracks) {}

  @override
  Future<void> stop() async {}
}

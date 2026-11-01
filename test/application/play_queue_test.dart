/// PlayQueue: one start/resume path for albums, folders, playlists and tracks.
///
/// Runs against in-memory ports (no Drift, no audio).
///
/// Evidence:
/// - `album queues tracks in track-number order`
/// - `album restores saved track, position and speed`
/// - `album without saved state resets speed to 1.0`
/// - `autoPlay false loads resume without starting playback`
/// - `replaying the current queue does not rebuild or re-seek`
/// - `startAt seeks within the current queue`
/// - `startAt on already playing track does not seek to zero`
/// - `startAt rebuilds the queue on first play`
/// - `startAt matches the track by file path when ids differ`
/// - `folder queue orders by path and resumes its saved track`
/// - `folder and playlist keep the current speed without saved state`
/// - `folderId is stable and normalized`
/// - `track resumes its saved position`
/// - `saveProgress stores the file path as the track key`
/// - `each album and folder resumes where it was left`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/application/play_queue.dart';
import 'package:retroplayer/application/ports/playback_engine.dart';
import 'package:retroplayer/application/ports/playback_state_store.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

import '../helpers/track_factory.dart';

void main() {
  late _FakeEngine engine;
  late _MemoryStore store;
  late PlayQueue queue;

  setUp(() {
    engine = _FakeEngine();
    store = _MemoryStore();
    queue = PlayQueue(engine: engine, store: store);
  });

  AudioTrack track(String name, {int? number, String dir = '/music/book'}) =>
      testTrack(
        filePath: '$dir/$name.mp3',
        directoryPath: dir,
        metadata: TrackMetadata(trackNumber: number, title: name),
      );

  AudioAlbum album(List<AudioTrack> tracks) => AudioAlbum(
    id: 'dir:/music/book',
    title: 'Book',
    tracks: tracks,
    source: AlbumSource.directory,
    groupingKey: 'dir',
  );

  group('album', () {
    test('album queues tracks in track-number order', () async {
      final ch1 = track('ch01', number: 1);
      final ch2 = track('ch02', number: 2);

      await queue.start(AlbumPlayback(album([ch2, ch1])));

      expect(engine.queue.map((track) => track.filePath), [
        ch1.filePath,
        ch2.filePath,
      ]);
      expect(engine.playCalls, 1);
    });

    test('album restores saved track, position and speed', () async {
      final ch1 = track('ch01', number: 1);
      final ch2 = track('ch02', number: 2);
      store.save('dir:/music/book', ch2.filePath, 30000, 1.5);

      await queue.start(AlbumPlayback(album([ch1, ch2])));

      expect(engine.lastStartIndex, 1);
      expect(engine.lastInitialPosition, const Duration(seconds: 30));
      expect(engine.speed, 1.5);
    });

    test('album without saved state resets speed to 1.0', () async {
      engine.speed = 1.75;

      await queue.start(AlbumPlayback(album([track('ch01', number: 1)])));

      expect(engine.speed, 1.0);
    });

    test('autoPlay false loads resume without starting playback', () async {
      final ch1 = track('ch01', number: 1);
      final ch2 = track('ch02', number: 2);
      store.save('dir:/music/book', ch2.filePath, 30000, 1.5);

      await queue.start(AlbumPlayback(album([ch1, ch2])), autoPlay: false);

      expect(engine.playCalls, 0);
      expect(engine.lastStartIndex, 1);
      expect(engine.lastInitialPosition, const Duration(seconds: 30));
    });

    test('replaying the current queue does not rebuild or re-seek', () async {
      final item = AlbumPlayback(
        album([track('ch01', number: 1), track('ch02', number: 2)]),
      );
      await queue.start(item);
      engine.currentQueueIndex = 1;

      await queue.start(item);

      expect(engine.setQueueCalls, 1);
      expect(engine.seekToQueueIndexCalls, isEmpty);
      expect(engine.currentQueueIndex, 1);
      expect(engine.playCalls, 2);
    });
  });

  group('startAt', () {
    test('startAt seeks within the current queue', () async {
      final ch1 = track('ch01', number: 1);
      final ch2 = track('ch02', number: 2);
      final item = AlbumPlayback(album([ch1, ch2]));
      await queue.startAt(item, ch1);

      await queue.startAt(item, ch2);

      expect(engine.setQueueCalls, 1);
      expect(engine.seekToQueueIndexCalls, [1]);
      expect(engine.playCalls, 2);
    });

    test('startAt on already playing track does not seek to zero', () async {
      final ch1 = track('ch01', number: 1);
      final item = AlbumPlayback(album([ch1, track('ch02', number: 2)]));
      await queue.startAt(item, ch1);
      engine.seeks.clear();

      await queue.startAt(item, ch1);

      expect(engine.seekToQueueIndexCalls, isEmpty);
      expect(engine.seeks, isEmpty);
    });

    test('startAt rebuilds the queue on first play', () async {
      final a = track('a', dir: '/music');
      final b = track('b', dir: '/music');
      final playlist = PlaylistFile(
        filePath: '/music/list.m3u',
        entryPaths: [a.filePath, b.filePath],
      );

      await queue.startAt(PlaylistPlayback(playlist, [a, b]), b);

      expect(engine.queue, [a, b]);
      expect(engine.lastStartIndex, 1);
      expect(engine.seekToQueueIndexCalls, isEmpty);
      expect(engine.playCalls, 1);
    });

    test('startAt matches the track by file path when ids differ', () async {
      final a = track('a', dir: '/music');
      final b = track('b', dir: '/music');
      final playlist = PlaylistFile(
        filePath: '/music/list.m3u',
        entryPaths: [a.filePath, b.filePath],
      );
      final sameFile = AudioTrack(
        id: 'other-id',
        filePath: b.filePath,
        directoryPath: b.directoryPath,
        metadata: b.metadata,
        dateAdded: b.dateAdded,
      );

      await queue.startAt(PlaylistPlayback(playlist, [a, b]), sameFile);

      expect(engine.lastStartIndex, 1);
    });
  });

  group('folder, playlist and track', () {
    test('folder queue orders by path and resumes its saved track', () async {
      final a2 = track('ch02', number: 2, dir: '/music/Author/BookA');
      final a1 = track('ch01', number: 1, dir: '/music/Author/BookA');
      final loose = track('loose', dir: '/music/Author');
      store.save(
        PlaybackItem.folderId('/music/Author'),
        a2.filePath,
        120000,
        1.25,
      );

      await queue.start(FolderPlayback('/music/Author', [loose, a2, a1]));

      expect(engine.queue, [a1, a2, loose]);
      expect(engine.lastStartIndex, 1);
      expect(engine.lastInitialPosition, const Duration(minutes: 2));
      expect(engine.speed, 1.25);
    });

    test(
      'folder and playlist keep the current speed without saved state',
      () async {
        engine.speed = 1.5;
        final a = track('a', dir: '/music');

        await queue.start(FolderPlayback('/music', [a]));
        expect(engine.speed, 1.5);

        await queue.start(
          PlaylistPlayback(
            PlaylistFile(filePath: '/music/l.m3u', entryPaths: [a.filePath]),
            [a],
          ),
        );
        expect(engine.speed, 1.5);
      },
    );

    test('folderId is stable and normalized', () {
      expect(PlaybackItem.folderId('/music/Author/'), 'folder:/music/Author');
      expect(
        PlaybackItem.folderPathFromId('folder:/music/Author'),
        '/music/Author',
      );
      expect(PlaybackItem.folderPathFromId('dir:/music'), isNull);
    });

    test('track resumes its saved position', () async {
      final single = track('single', dir: '/music');
      store.save(single.id, single.filePath, 5000, 1.1);

      await queue.start(TrackPlayback(single));

      expect(engine.queue, [single]);
      expect(engine.lastInitialPosition, const Duration(seconds: 5));
      expect(engine.speed, 1.1);
    });
  });

  test('each album and folder resumes where it was left', () async {
    AudioAlbum book(String id, String dir) => AudioAlbum(
      id: id,
      title: 'Book',
      artist: 'Author',
      tracks: [
        track('ch01', number: 1, dir: dir),
        track('ch02', number: 2, dir: dir),
      ],
      source: AlbumSource.directory,
      groupingKey: id,
    );

    final bookA = AlbumPlayback(book('dir:/books/a', '/books/a'));
    final bookB = AlbumPlayback(book('dir:/books/b', '/books/b'));
    final folder = FolderPlayback('/books/c', [
      track('one', number: 1, dir: '/books/c'),
      track('two', number: 2, dir: '/books/c'),
    ]);

    Future<void> leaveAt(
      PlaybackItem item,
      int chapter,
      Duration position,
    ) async {
      await queue.start(item);
      engine.currentQueueIndex = chapter;
      engine.position = position;
      await queue.saveProgress(item.id);
    }

    await leaveAt(bookA, 1, const Duration(seconds: 12));
    await leaveAt(bookB, 0, const Duration(seconds: 45));
    await leaveAt(folder, 1, const Duration(minutes: 3));

    await queue.start(bookA);
    expect(engine.lastStartIndex, 1);
    expect(engine.lastInitialPosition, const Duration(seconds: 12));
    expect(engine.currentTrack?.filePath, '/books/a/ch02.mp3');

    await queue.start(bookB);
    expect(engine.lastStartIndex, 0);
    expect(engine.lastInitialPosition, const Duration(seconds: 45));
    expect(engine.currentTrack?.filePath, '/books/b/ch01.mp3');

    await queue.start(folder);
    expect(engine.lastStartIndex, 1);
    expect(engine.lastInitialPosition, const Duration(minutes: 3));
    expect(engine.currentTrack?.filePath, '/books/c/two.mp3');
  });

  test('saveProgress stores the file path as the track key', () async {
    final ch1 = track('ch01', number: 1);
    await queue.start(AlbumPlayback(album([ch1])));
    engine.position = const Duration(seconds: 42);

    await queue.saveProgress('dir:/music/book');

    final saved = await store.getPlaybackState('dir:/music/book');
    expect(saved?.trackId, ch1.filePath);
    expect(saved?.positionMs, 42000);
  });

  test('saveProgress stores engine duration when tags lack length', () async {
    final ch1 = testTrack(
      filePath: '/music/book/lesson.mp3',
      directoryPath: '/music/book',
      durationMs: null,
    );
    const itemId = 'dir:/music/book';
    engine.duration = const Duration(minutes: 7);
    engine.position = const Duration(seconds: 10);
    await queue.start(AlbumPlayback(album([ch1])));

    await queue.saveProgress(itemId);

    final saved = await store.getPlaybackState(itemId);
    expect(saved?.durationMs, const Duration(minutes: 7).inMilliseconds);
  });
}

class _MemoryStore implements PlaybackStateStore {
  final _rows = <String, SavedPlaybackState>{};

  void save(
    String itemId,
    String trackId,
    int positionMs,
    double speed, {
    String? displayTitle,
    String? subtitle,
    int? durationMs,
  }) =>
      _rows[itemId] = (
        trackId: trackId,
        positionMs: positionMs,
        speed: speed,
        displayTitle: displayTitle,
        subtitle: subtitle,
        durationMs: durationMs,
      );

  @override
  Future<SavedPlaybackState?> getPlaybackState(String itemId) async =>
      _rows[itemId];

  @override
  Future<void> savePlaybackState({
    required String itemId,
    required String trackId,
    required int positionMs,
    required double speed,
    String? displayTitle,
    String? subtitle,
    int? durationMs,
  }) async => save(
    itemId,
    trackId,
    positionMs,
    speed,
    displayTitle: displayTitle,
    subtitle: subtitle,
    durationMs: durationMs,
  );
}

class _FakeEngine implements PlaybackEngine {
  @override
  List<AudioTrack> queue = const [];

  @override
  int? currentQueueIndex;

  @override
  Duration position = Duration.zero;

  @override
  Duration? duration;

  @override
  double speed = 1.0;

  int setQueueCalls = 0;
  int playCalls = 0;
  int? lastStartIndex;
  Duration? lastInitialPosition;
  final seekToQueueIndexCalls = <int>[];
  final seeks = <Duration>[];

  @override
  AudioTrack? get currentTrack {
    final index = currentQueueIndex;
    if (index == null || index < 0 || index >= queue.length) return null;
    return queue[index];
  }

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    setQueueCalls++;
    queue = tracks;
    currentQueueIndex = startIndex;
    lastStartIndex = startIndex;
    lastInitialPosition = initialPosition;
  }

  @override
  Future<void> play() async => playCalls++;

  @override
  Future<void> seek(Duration position) async => seeks.add(position);

  @override
  Future<void> seekToQueueIndex(int index) async {
    seekToQueueIndexCalls.add(index);
    currentQueueIndex = index;
  }

  @override
  Future<void> setSpeed(double speed) async => this.speed = speed;
}

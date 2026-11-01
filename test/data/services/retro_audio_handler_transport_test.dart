/// UC-17: the media session mirrors in-app playback both ways.
///
/// Evidence:
/// - `notification transport drives the player`
/// - `player state is published to the media session`
/// - `current track is published as media item`
/// - `missing tags fall back to file name and folder name`
/// - `blank artist falls back to album artist`
/// - `does not publish Unknown Album when the file has no folder`
/// - `session queue carries artist and album for every track`
/// - `position ticks update the session position`
/// - `engine duration fills media item when tags lack length`
/// - `handler publishes initial playback state when engine already has queue`
/// - `refreshSessionState republishes controls after resume hook`
/// - `idle engine state with loaded track keeps session ready`
library;

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

import '../../helpers/recording_playback.dart';
import '../../helpers/track_factory.dart';

void main() {
  late RecordingPlayback playback;
  late RetroAudioHandler handler;

  setUp(() {
    playback = RecordingPlayback();
    handler = RetroAudioHandler(playback);
  });

  test('notification transport drives the player', () async {
    await handler.play();
    expect(playback.playForMediaTransportCalled, isTrue);
    expect(playback.playCalled, isTrue);
    await handler.pause();
    expect(playback.pauseCalled, isTrue);
    await handler.seek(const Duration(seconds: 42));
    expect(playback.position, const Duration(seconds: 42));
    await handler.skipToNext();
    await handler.skipToPrevious();
    expect(playback.skipNextCalls, 1);
    expect(playback.skipPreviousCalls, 1);
  });

  test('skip next control omitted on last queue track', () async {
    final tracks = [
      testTrack(filePath: '/m/01.mp3', directoryPath: '/m'),
      testTrack(filePath: '/m/02.mp3', directoryPath: '/m'),
      testTrack(filePath: '/m/03.mp3', directoryPath: '/m'),
    ];
    await playback.setQueue(tracks, startIndex: 2);
    playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);

    final controls = handler.playbackState.value.controls;
    expect(controls, contains(MediaControl.skipToPrevious));
    expect(controls, isNot(contains(MediaControl.skipToNext)));
  });

  test('skip previous omitted on first queue track', () async {
    final tracks = [
      testTrack(filePath: '/m/01.mp3', directoryPath: '/m'),
      testTrack(filePath: '/m/02.mp3', directoryPath: '/m'),
    ];
    await playback.setQueue(tracks, startIndex: 0);
    playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);

    final controls = handler.playbackState.value.controls;
    expect(controls, contains(MediaControl.skipToNext));
    expect(controls, isNot(contains(MediaControl.skipToPrevious)));
  });

  test('player state is published to the media session', () async {
    playback.emitPlayerState(PlayerState(true, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);

    final state = handler.playbackState.value;
    expect(state.playing, isTrue);
    expect(state.processingState, AudioProcessingState.ready);
    expect(state.controls, contains(MediaControl.pause));

    playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);
    expect(handler.playbackState.value.controls, contains(MediaControl.play));
  });

  test('current track is published as media item', () async {
    final track = testTrack(
      filePath: '/music/a/01.mp3',
      directoryPath: '/music/a',
      metadata: const TrackMetadata(
        title: 'Chapter 1',
        artist: 'Author',
        album: 'Book',
      ),
      durationMs: 61000,
    );
    playback.emitTrack(track);
    await Future<void>.delayed(Duration.zero);

    final item = handler.mediaItem.value!;
    expect(item.id, track.id);
    expect(item.title, 'Chapter 1');
    expect(item.displayTitle, 'Chapter 1');
    expect(item.artist, 'Author');
    expect(item.displaySubtitle, 'Author');
    expect(item.album, 'Book');
    expect(item.displayDescription, 'Book');
    expect(item.duration, const Duration(seconds: 61));

    playback.emitTrack(null);
    await Future<void>.delayed(Duration.zero);
    expect(handler.mediaItem.value, isNull);
    expect(handler.queue.value, isEmpty);
  });

  test('missing tags fall back to file name and folder name', () async {
    final track = testTrack(
      filePath: '/music/Book/01 Chapter.mp3',
      directoryPath: '/music/Book',
      metadata: const TrackMetadata(artist: '  ', album: ' '),
    );
    playback.emitTrack(track);
    await Future<void>.delayed(Duration.zero);

    final item = handler.mediaItem.value!;
    expect(item.title, '01 Chapter');
    expect(item.displayTitle, '01 Chapter');
    expect(item.album, 'Book');
    expect(item.displayDescription, 'Book');
    expect(item.artist, isNull);
    expect(item.displaySubtitle, isNull);
  });

  test('blank artist falls back to album artist', () async {
    final track = testTrack(
      filePath: '/music/Book/01.mp3',
      directoryPath: '/music/Book',
      metadata: const TrackMetadata(
        title: 'Chapter',
        artist: ' ',
        albumArtist: ' Narrator ',
        album: ' Book ',
      ),
    );
    playback.emitTrack(track);
    await Future<void>.delayed(Duration.zero);

    final item = handler.mediaItem.value!;
    expect(item.artist, 'Narrator');
    expect(item.displaySubtitle, 'Narrator');
    expect(item.album, 'Book');
    expect(item.displayDescription, 'Book');
  });

  test('does not publish Unknown Album when the file has no folder', () async {
    final track = testTrack(
      filePath: '01.mp3',
      directoryPath: '',
      metadata: const TrackMetadata(),
    );
    playback.emitTrack(track);
    await Future<void>.delayed(Duration.zero);

    final item = handler.mediaItem.value!;
    expect(item.title, '01');
    expect(item.album, isNull);
    expect(item.displayDescription, isNull);
  });

  test('session queue carries artist and album for every track', () async {
    final first = testTrack(
      filePath: '/music/Book/01.mp3',
      directoryPath: '/music/Book',
      metadata: const TrackMetadata(
        title: 'One',
        artist: 'Author',
        album: 'Book',
      ),
    );
    final second = testTrack(
      filePath: '/music/Book/02 Side.mp3',
      directoryPath: '/music/Book',
    );
    playback.lastQueue = [first, second];
    playback.emitTrack(first);
    await Future<void>.delayed(Duration.zero);

    final items = handler.queue.value;
    expect(items, hasLength(2));
    expect(items[0].title, 'One');
    expect(items[0].artist, 'Author');
    expect(items[0].album, 'Book');
    expect(items[1].title, '02 Side');
    expect(items[1].artist, isNull);
    expect(items[1].album, 'Book');
    expect(items[1].displayDescription, 'Book');
  });

  test('engine duration fills media item when tags lack length', () async {
    const engineDuration = Duration(minutes: 11, seconds: 22);
    final track = testTrack(
      filePath: '/course/lesson.mp3',
      directoryPath: '/course',
      metadata: const TrackMetadata(title: 'Lesson'),
      durationMs: null,
    );
    playback.emitTrack(track);
    await Future<void>.delayed(Duration.zero);

    expect(handler.mediaItem.value!.duration, isNull);

    playback.durationOverride = engineDuration;
    playback.emitDuration(engineDuration);
    await Future<void>.delayed(Duration.zero);

    expect(handler.mediaItem.value!.duration, engineDuration);
  });

  test('handler publishes initial playback state when engine already has queue',
      () async {
    final tracks = [
      testTrack(filePath: '/m/01.mp3', directoryPath: '/m'),
      testTrack(filePath: '/m/02.mp3', directoryPath: '/m'),
    ];
    await playback.setQueue(tracks, startIndex: 0);
    handler = RetroAudioHandler(playback);

    expect(handler.mediaItem.value, isNotNull);
    expect(handler.queue.value, hasLength(2));

    playback.emitPlayerState(PlayerState(true, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);
    expect(handler.playbackState.value.playing, isTrue);
    expect(handler.playbackState.value.controls, contains(MediaControl.pause));
  });

  test('refreshSessionState republishes controls after resume hook', () async {
    final tracks = [
      testTrack(filePath: '/m/01.mp3', directoryPath: '/m'),
    ];
    await playback.setQueue(tracks);
    playback.emitPlayerState(PlayerState(false, ProcessingState.ready));
    handler = RetroAudioHandler(playback);
    await Future<void>.delayed(Duration.zero);
    expect(handler.playbackState.value.controls, contains(MediaControl.play));

    playback.emitPlayerState(PlayerState(true, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);
    handler.refreshSessionState();

    expect(handler.playbackState.value.playing, isTrue);
    expect(handler.playbackState.value.controls, contains(MediaControl.pause));
  });

  test('idle engine state with loaded track keeps session ready', () async {
    final track = testTrack(filePath: '/m/01.mp3', directoryPath: '/m');
    await playback.setQueue([track]);
    playback.emitPlayerState(PlayerState(false, ProcessingState.idle));
    await Future<void>.delayed(Duration.zero);

    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.ready,
    );
  });

  test('position ticks update the session position', () async {
    playback.emitPlayerState(PlayerState(true, ProcessingState.ready));
    await Future<void>.delayed(Duration.zero);
    playback.emitPosition(const Duration(seconds: 7));
    await Future<void>.delayed(Duration.zero);

    expect(
      handler.playbackState.value.updatePosition,
      const Duration(seconds: 7),
    );
  });
}

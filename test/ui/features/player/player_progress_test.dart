/// Playback progress keeps updating when the player reports position.
///
/// Evidence:
/// - `durationStream null does not clear known duration`
/// - `playAlbumTrack seeds duration from track metadata`
/// - `positionStream updates PlayerViewModel.position`
/// - `progress bar elapsed label advances with positionStream`
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/playback_progress_bar.dart';

import '../../../helpers/track_factory.dart';

class _StreamPlayback implements AudioPlaybackService {
  final positionController = StreamController<Duration>.broadcast();
  final durationController = StreamController<Duration?>.broadcast();
  final playingController = StreamController<bool>.broadcast();
  final trackController = StreamController<AudioTrack?>.broadcast();

  List<AudioTrack> _queue = [];
  AudioTrack? _current;
  Duration _position = Duration.zero;

  @override
  AudioTrack? get currentTrack => _current;

  @override
  List<AudioTrack> get queue => List.unmodifiable(_queue);

  @override
  Duration get position => _position;

  @override
  Duration? get duration => _reportedDuration;

  Duration? _reportedDuration;

  @override
  double get speed => 1.0;

  @override
  bool get hasNext => false;

  @override
  bool get hasPrevious => false;

  @override
  int? get currentQueueIndex => _current == null ? null : 0;

  @override
  int? get androidAudioSessionId => null;

  @override
  Stream<int?> get androidAudioSessionIdStream => const Stream.empty();

  @override
  Stream<Duration> get positionStream => positionController.stream;

  @override
  Stream<Duration?> get durationStream => durationController.stream;

  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();

  @override
  Stream<bool> get playingStream => playingController.stream;

  @override
  Stream<AudioTrack?> get currentTrackStream => trackController.stream;

  void emitPosition(Duration position) {
    _position = position;
    positionController.add(position);
  }

  void emitDuration(Duration? duration) {
    _reportedDuration = duration;
    durationController.add(duration);
  }

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {
    _queue = tracks;
    _current = tracks.isEmpty
        ? null
        : tracks[startIndex.clamp(0, tracks.length - 1)];
    _position = initialPosition ?? Duration.zero;
    trackController.add(_current);
  }

  @override
  Future<void> play() async => playingController.add(true);

  @override
  Future<void> pause() async => playingController.add(false);

  @override
  void replaceQueueTracks(List<AudioTrack> tracks) {}

  @override
  Future<void> stop() async {
    _current = null;
    trackController.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    positionController.add(position);
  }

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> seekToQueueIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _current = _queue[index];
    _position = Duration.zero;
    trackController.add(_current);
  }

  @override
  Future<void> dispose() async {
    await positionController.close();
    await durationController.close();
    await playingController.close();
    await trackController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerViewModel progress timing', () {
    late AppDatabase db;
    late _StreamPlayback playback;
    late PlayerViewModel viewModel;

    final track = testTrack(
      filePath: '/music/book/ch01.mp3',
      directoryPath: '/music/book',
      metadata: const TrackMetadata(title: 'Chapter 1', trackNumber: 1),
      durationMs: 180000,
    );

    final album = AudioAlbum(
      id: 'dir:/music/book',
      title: 'Book',
      tracks: [track],
      source: AlbumSource.directory,
      groupingKey: 'dir:/music/book',
    );

    setUp(() {
      db = AppDatabase.inMemory();
      playback = _StreamPlayback();
      viewModel = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: playback,
          storageService: LibraryStorageService(db),
        ),
      );
    });

    tearDown(() async {
      await viewModel.stopAndClearPlayback();
      viewModel.dispose();
      await playback.dispose();
      await db.close();
    });

    test('playAlbumTrack seeds duration from track metadata', () async {
      await viewModel.playAlbumTrack(album, track);
      expect(viewModel.duration, const Duration(milliseconds: 180000));
    });

    test('durationStream null does not clear known duration', () async {
      await viewModel.playAlbumTrack(album, track);
      expect(viewModel.duration, const Duration(milliseconds: 180000));

      playback.emitDuration(null);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.duration, const Duration(milliseconds: 180000));

      playback.emitDuration(const Duration(milliseconds: 181000));
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.duration, const Duration(milliseconds: 181000));
    });

    test('positionStream updates PlayerViewModel.position', () async {
      await viewModel.playAlbumTrack(album, track);
      playback.emitPosition(const Duration(seconds: 12));
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.position, const Duration(seconds: 12));

      playback.emitDuration(null);
      playback.emitPosition(const Duration(seconds: 25));
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.position, const Duration(seconds: 25));
      expect(viewModel.duration, const Duration(milliseconds: 180000));
    });

    test('position ticks do not notifyListeners', () async {
      var notifies = 0;
      viewModel.addListener(() => notifies++);
      await viewModel.playAlbumTrack(album, track);
      final afterPlay = notifies;

      playback.emitPosition(const Duration(seconds: 12));
      await Future<void>.delayed(Duration.zero);
      expect(notifies, afterPlay);
      expect(viewModel.position, const Duration(seconds: 12));
      expect(viewModel.positionListenable.value, const Duration(seconds: 12));
    });
  });

  testWidgets('progress bar elapsed label advances with positionStream', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    final playback = _StreamPlayback();
    final viewModel = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: LibraryStorageService(db),
      ),
    );
    addTearDown(() async {
      await viewModel.stopAndClearPlayback();
      viewModel.dispose();
      await playback.dispose();
      await db.close();
    });

    final track = testTrack(
      filePath: '/music/book/ch01.mp3',
      directoryPath: '/music/book',
      metadata: const TrackMetadata(title: 'Chapter 1'),
      durationMs: 180000,
    );
    final album = AudioAlbum(
      id: 'dir:/music/book',
      title: 'Book',
      tracks: [track],
      source: AlbumSource.directory,
      groupingKey: 'dir:/music/book',
    );
    await viewModel.playAlbumTrack(album, track);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RetroProgressBar(viewModel: viewModel)),
      ),
    );
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);

    playback.emitPosition(const Duration(seconds: 12));
    // Stream listeners run as microtasks under the test binding.
    await tester.idle();
    await tester.pump();
    expect(viewModel.position, const Duration(seconds: 12));
    expect(find.text('00:12'), findsOneWidget);

    // Loading null duration must not freeze elapsed display at 0.
    playback.emitDuration(null);
    playback.emitPosition(const Duration(seconds: 25));
    await tester.idle();
    await tester.pump();
    expect(find.text('00:25'), findsOneWidget);
    expect(find.text('03:00'), findsOneWidget);

    // Stop the periodic progress-save timer before the test binding checks
    // for pending timers.
    await viewModel.togglePlayPause();
    await tester.idle();
  });
}

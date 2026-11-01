/// Touch: mini player bar, seek-bar drag, album-detail track list.
///
/// Evidence:
/// - `PlayerCollapsedBar has no drag handle and does not expand`
/// - `seek bar drag calls PlayerViewModel.seek`
/// - `album detail lists tracks in tag order without reorder handles`
library;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/playback_progress_bar.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

class _GesturePlayback implements AudioPlaybackService {
  _GesturePlayback({
    required this.track,
    this.duration = const Duration(minutes: 5),
  });

  final AudioTrack track;
  final Duration duration;
  Duration lastSeek = Duration.zero;

  @override
  AudioTrack? get currentTrack => track;

  @override
  Stream<AudioTrack?> get currentTrackStream => Stream.value(track);

  @override
  List<AudioTrack> get queue => [track];

  @override
  bool get hasNext => false;

  @override
  bool get hasPrevious => false;

  @override
  int? get currentQueueIndex => 0;

  @override
  double get speed => 1.0;

  @override
  int? get androidAudioSessionId => null;

  @override
  Stream<int?> get androidAudioSessionIdStream => const Stream.empty();

  @override
  Duration get position => Duration.zero;

  @override
  Stream<Duration> get positionStream => const Stream.empty();

  @override
  Stream<Duration?> get durationStream => Stream.value(duration);

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
  Future<void> seek(Duration position) async {
    lastSeek = position;
  }

  @override
  Future<void> seekToQueueIndex(int index) async {}

  @override
  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
  }) async {}

  @override
  Future<void> setSpeed(double speed) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  void replaceQueueTracks(List<AudioTrack> tracks) {}

  @override
  Future<void> stop() async {}
}

AudioAlbum _detailAlbum() {
  const albumId = 'dir:/music/book';
  return AudioAlbum(
    id: albumId,
    title: 'Detail Test',
    tracks: [
      testTrack(
        id: 't2',
        filePath: '/music/book/02.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 2, title: 'Two'),
      ),
      testTrack(
        id: 't1',
        filePath: '/music/book/01.mp3',
        directoryPath: '/music/book',
        metadata: const TrackMetadata(trackNumber: 1, title: 'One'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('PlayerCollapsedBar has no drag handle and does not expand',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final track = testTrack(filePath: '/music/a.mp3', directoryPath: '/music');
    final playback = _GesturePlayback(track: track);
    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );
    final panelVm = testPanelVm();

    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithL10n(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: playerVm),
            ChangeNotifierProvider.value(value: panelVm),
          ],
          child: const Material(child: PlayerCollapsedBar()),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.byType(PlayerDragHandle), findsNothing);
    expect(panelVm.isExpanded, isFalse);

    await tester.drag(find.byType(PlayerCollapsedBar), const Offset(0, -200));
    await pumpFrames(tester);
    expect(panelVm.isExpanded, isFalse);
  });

  testWidgets('seek bar drag calls PlayerViewModel.seek', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final track = testTrack(filePath: '/music/a.mp3', directoryPath: '/music');
    final playback = _GesturePlayback(
      track: track,
      duration: const Duration(seconds: 100),
    );
    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );

    await tester.pumpWidget(
      wrapWithL10n(
        ChangeNotifierProvider.value(
          value: playerVm,
          child: Material(
            child: PlaybackProgressBar(viewModel: playerVm, compact: true),
          ),
        ),
      ),
    );
    await pumpFrames(tester);

    final slider = find.byType(Slider);
    expect(slider, findsOneWidget);

    final center = tester.getCenter(slider);
    await tester.dragFrom(center, const Offset(80, 0));
    await pumpFrames(tester);

    expect(playback.lastSeek.inSeconds, greaterThan(10));
  });

  testWidgets('album detail lists tracks in tag order without reorder handles',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final album = _detailAlbum();
    final libraryRepository = testLibraryRepository(storage);
    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);

    await tester.pumpWidget(
      wrapWithL10n(
        MultiProvider(
          providers: [
            Provider.value(value: libraryRepository),
            ChangeNotifierProvider.value(value: libraryVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
            ChangeNotifierProvider(
              create: (_) => PlayerViewModel(
                playbackRepository: PlaybackRepository(
                  playbackService: _GesturePlayback(track: album.tracks.first),
                  storageService: storage,
                ),
              ),
            ),
          ],
          child: AlbumDetailView(album: album),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.byType(ReorderableDragStartListener), findsNothing);
    final rowTitles = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(RetroListTile),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .toList();
    expect(rowTitles.indexOf('One'), lessThan(rowTitles.indexOf('Two')));
  });
}

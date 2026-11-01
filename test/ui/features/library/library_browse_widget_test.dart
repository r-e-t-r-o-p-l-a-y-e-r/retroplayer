/// LibraryView browse UI from sources into folders; album titles line up with folder titles.
///
/// Evidence:
/// - `LibraryView shows sources at root and files after browse`
/// - `album play button starts playback without opening detail`
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
import 'package:go_router/go_router.dart';
import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import '../../../helpers/test_panel.dart';

final _testRootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _browseTestRouter() {
  return GoRouter(
    navigatorKey: _testRootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const LibraryView(autoLoad: false, restoreSessionOnMount: false),
        routes: [
          GoRoute(
            path: 'album-detail',
            builder: (context, state) {
              final album = state.extra as AudioAlbum?;
              if (album == null) {
                return const Scaffold(
                  body: Center(child: Text('Album not found')),
                );
              }
              return AlbumDetailView(album: album);
            },
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('LibraryView shows sources at root and files after browse', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    final libraryRepository = testLibraryRepository(storage);

    await storage.addLibraryRoot('/music');

    seedAuthorBook1Hierarchy(libraryRepository);

    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    await libraryVm.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: _NoOpPlayback(),
                storageService: storage,
              ),
            ),
          ),
        ],
        child: wrapRouterWithL10n(router: _browseTestRouter()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Library sources'), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
    expect(find.text('music'), findsOneWidget);
    expect(find.text('Book One'), findsNothing);

    await libraryVm.browseInto('/music');
    await tester.pump();

    expect(
      tester.widget<AppBar>(find.byType(AppBar)).title,
      isA<Text>().having((text) => text.data, 'data', 'Library'),
    );
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('music'), findsWidgets);
    expect(find.text('Author'), findsWidgets);
    expect(find.text('Book One'), findsNothing);
    final folderNameLeft = tester.getTopLeft(find.text('Author')).dx;

    await libraryVm.browseInto('/music/Author');
    await tester.pump();

    expect(find.text('Book1'), findsOneWidget);
    expect(find.text('Author'), findsWidgets);
    expect(find.text('Book1'), findsWidgets);
    expect(find.text('Book One'), findsNothing);

    await libraryVm.browseInto('/music/Author/Book1');
    await tester.pump();

    expect(find.text('Book One'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Book One')).dx, folderNameLeft);

    await tester.tap(find.text('Book One'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ch01'), findsOneWidget);
    expect(find.text('ch02'), findsOneWidget);

    await db.close();
  });

  testWidgets('album play button starts playback without opening detail', (
    tester,
  ) async {
    final db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    final playback = _RecordingPlayback();
    final libraryRepository = testLibraryRepository(storage);

    await storage.addLibraryRoot('/music');
    final album = AudioAlbum(
      id: 'dir:/music/book',
      title: 'My Book',
      tracks: [
        testTrack(
          filePath: '/music/MyBook/ch01.mp3',
          directoryPath: '/music/MyBook',
        ),
      ],
      source: AlbumSource.directory,
      groupingKey: 'dir:/music/book',
    );
    seedMyBookDirectory(libraryRepository, album);

    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    await libraryVm.browseInto('/music/MyBook');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: playback,
                storageService: storage,
              ),
            ),
          ),
        ],
        child: wrapRouterWithL10n(router: _browseTestRouter()),
      ),
    );

    await pumpFrames(tester);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await pumpFrames(tester);

    expect(playback.playItemCalled, isTrue);
    expect(find.text('ch01'), findsNothing);

    await db.close();
  });
}

class _RecordingPlayback implements AudioPlaybackService {
  bool playItemCalled = false;

  @override
  AudioTrack? get currentTrack => null;

  @override
  Duration get position => Duration.zero;

  @override
  Duration? get duration => null;

  @override
  Stream<AudioTrack?> get currentTrackStream => const Stream.empty();

  @override
  List<AudioTrack> get queue => const [];

  @override
  bool get hasNext => false;

  @override
  bool get hasPrevious => false;

  @override
  int? get currentQueueIndex => null;

  @override
  double get speed => 1.0;

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
  Future<void> play() async {
    playItemCalled = true;
  }

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
    playItemCalled = true;
  }

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

class _NoOpPlayback implements AudioPlaybackService {
  @override
  AudioTrack? get currentTrack => null;

  @override
  Duration get position => Duration.zero;

  @override
  Duration? get duration => null;

  @override
  Stream<AudioTrack?> get currentTrackStream => const Stream.empty();

  @override
  List<AudioTrack> get queue => const [];

  @override
  bool get hasNext => false;

  @override
  bool get hasPrevious => false;

  @override
  int? get currentQueueIndex => null;

  @override
  double get speed => 1.0;

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

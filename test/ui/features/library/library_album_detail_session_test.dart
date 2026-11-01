/// Album detail session id persistence and restore after restart.
///
/// Evidence:
/// - `opening album detail persists album id until back`
/// - `restoreAlbumDetail reopens saved album track list`
/// - `LibraryView startup restores album detail after restart`
/// - `restoreAlbumDetail clears stale album id`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:just_audio/just_audio.dart';
import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

final _sessionTestNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _sessionTestRouter({bool autoLoad = false}) {
  return GoRouter(
    navigatorKey: _sessionTestNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            LibraryView(autoLoad: autoLoad, restoreSessionOnMount: autoLoad),
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

AudioAlbum _testAlbum() {
  const albumId = 'dir:/music/mybook';
  return AudioAlbum(
    id: albumId,
    title: 'My Book',
    tracks: [
      testTrack(
        filePath: '/music/MyBook/ch01.mp3',
        directoryPath: '/music/MyBook',
        metadata: const TrackMetadata(trackNumber: 1, title: 'Chapter 1'),
      ),
      testTrack(
        filePath: '/music/MyBook/ch02.mp3',
        directoryPath: '/music/MyBook',
        metadata: const TrackMetadata(trackNumber: 2, title: 'Chapter 2'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
}

void main() {
  group('Library album detail session restore', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late LibraryRepository libraryRepository;
    late LibraryViewModel libraryVm;

    late AudioAlbum album;

    setUp(() async {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      album = _testAlbum();
      libraryRepository = testLibraryRepository(storage);

      await storage.addLibraryRoot('/music');
      seedMyBookDirectory(libraryRepository, album);

      libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
      await libraryVm.load();
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> pumpLibraryApp(WidgetTester tester) async {
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
          child: wrapRouterWithL10n(router: _sessionTestRouter()),
        ),
      );
      await pumpFrames(tester);
    }

    testWidgets('opening album detail persists album id until back', (
      tester,
    ) async {
      await pumpLibraryApp(tester);

      await libraryVm.browseInto('/music/MyBook');
      await pumpFrames(tester);

      expect(find.text('My Book'), findsOneWidget);

      await tester.tap(find.text('My Book'));
      await pumpFrames(tester, count: 5);

      expect(await storage.getLibraryAlbumDetailId(), 'dir:/music/mybook');
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);

      GoRouter.of(tester.element(find.byType(AlbumDetailView))).pop();
      await pumpFrames(tester, count: 5);

      expect(await storage.getLibraryAlbumDetailId(), isNull);
      expect(find.text('Chapter 1'), findsNothing);
    });

    testWidgets('restoreAlbumDetail reopens saved album track list', (
      tester,
    ) async {
      const albumId = 'dir:/music/mybook';
      await storage.setLibraryBrowsePath('/music');
      await storage.setLibraryAlbumDetailId(albumId);

      await libraryVm.load();
      await pumpLibraryApp(tester);

      await LibraryNavigator.of(
        tester.element(find.byType(LibraryView)),
      ).restoreAlbumDetail();
      await pumpFrames(tester);

      expect(libraryVm.browsePath, '/music/MyBook');
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);
    });

    testWidgets('LibraryView startup restores album detail after restart', (
      tester,
    ) async {
      const albumId = 'dir:/music/mybook';
      await storage.setLibraryBrowsePath('/music');
      await storage.setLibraryAlbumDetailId(albumId);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: libraryRepository),
            ChangeNotifierProvider(
              create: (_) =>
                  LibraryViewModel(libraryRepository: libraryRepository),
            ),
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
          child: wrapRouterWithL10n(router: _sessionTestRouter(autoLoad: true)),
        ),
      );
      await pumpFrames(tester, count: 5);

      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);

      final vm = Provider.of<LibraryViewModel>(
        tester.element(find.text('Chapter 1')),
        listen: false,
      );
      expect(vm.browsePath, '/music/MyBook');
    });

    testWidgets('restoreAlbumDetail clears stale album id', (tester) async {
      await storage.setLibraryAlbumDetailId('dir:/music/missing');

      await libraryVm.load();
      await pumpLibraryApp(tester);

      await LibraryNavigator.of(
        tester.element(find.byType(LibraryView)),
      ).restoreAlbumDetail();
      await pumpFrames(tester);

      expect(await storage.getLibraryAlbumDetailId(), isNull);
      expect(find.text('Chapter 1'), findsNothing);
    });
  });
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
  Future<void> playForMediaTransport() => play();

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

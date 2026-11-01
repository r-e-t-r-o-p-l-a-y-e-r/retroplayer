/// E2E: library shell smoke and playback resume after relaunch.
///
/// Evidence:
/// - `app shell shows library screen`
/// - `playback resume restores saved position after relaunch`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/application/play_queue.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/mobile_layout.dart';
import 'package:retroplayer/ui/core/theme.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shell shows library screen', (tester) async {
    final db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    final libraryRepository = createLibraryRepository(storage);
    final playbackService = JustAudioPlaybackService();
    final equalizerService = EqualizerService(
      storage,
      playbackService: playbackService,
    );
    final playbackRepository = PlaybackRepository(
      playbackService: playbackService,
      storageService: storage,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          Provider.value(value: playbackRepository),
          Provider.value(value: equalizerService),
          ChangeNotifierProvider(
            create: (_) =>
                LibraryViewModel(libraryRepository: libraryRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => PlayerPanelViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                PlayerViewModel(playbackRepository: playbackRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => EqualizerViewModel(
              equalizerService: equalizerService,
            ),
          ),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.create(),
          builder: (context, child) {
            return MobileLayout(child: child ?? const SizedBox.shrink());
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // App bar title plus empty-state breadcrumb both say "Library".
    expect(find.text('Library'), findsAtLeastNWidgets(1));
    expect(
      find.text('No folders added. Tap "Add folder" to get started.'),
      findsOneWidget,
    );

    await db.close();
  });

  testWidgets('playback resume restores saved position after relaunch',
      (tester) async {
    final db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    final playback = _RecordingPlayback();
    final playQueue = PlayQueue(engine: playback, store: storage);

    const albumId = 'dir:/music/book';
    final album = AudioAlbum(
      id: albumId,
      title: 'Book',
      tracks: [
        AudioTrack(
          id: '/music/book/ch01.mp3',
          filePath: '/music/book/ch01.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(trackNumber: 1),
          dateAdded: DateTime.now(),
        ),
        AudioTrack(
          id: '/music/book/ch02.mp3',
          filePath: '/music/book/ch02.mp3',
          directoryPath: '/music/book',
          metadata: const TrackMetadata(trackNumber: 2),
          dateAdded: DateTime.now(),
        ),
      ],
      source: AlbumSource.directory,
      groupingKey: albumId,
    );

    await storage.savePlaybackState(
      itemId: albumId,
      trackId: '/music/book/ch02.mp3',
      positionMs: 120000,
      speed: 1.0,
    );

    await playQueue.start(AlbumPlayback(album));

    expect(playback.lastStartIndex, 1);
    expect(playback.lastInitialPosition, const Duration(minutes: 2));

    await db.close();
  });
}

class _RecordingPlayback implements AudioPlaybackService {
  int lastStartIndex = 0;
  Duration? lastInitialPosition;

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
  }) async {
    lastStartIndex = startIndex;
    lastInitialPosition = initialPosition;
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

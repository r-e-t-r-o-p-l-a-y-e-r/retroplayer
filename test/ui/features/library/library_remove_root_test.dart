/// Swipe-dismiss library root with confirm; nested folders not dismissible.
///
/// Evidence:
/// - `swipe remove library root shows confirmation and removes on confirm`
/// - `subfolder swipe left does not remove the folder`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/library/widgets/folder_favorite_swipe.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

void main() {
  testWidgets(
    'swipe remove library root shows confirmation and removes on confirm',
    (tester) async {
      final harness = await _pumpLibraryHarness(tester);
      addTearDown(harness.dispose);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(LibraryView)),
      );

      expect(find.text('music'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);

      await tester.drag(find.text('music'), const Offset(-400, 0));
      await pumpFrames(tester);

      expect(find.text(l10n.removeLibraryFolderTitle), findsOneWidget);
      expect(
        find.textContaining('Your audio files on disk are not deleted'),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.cancel));
      await pumpFrames(tester);

      expect(find.text('music'), findsOneWidget);

      await tester.drag(find.text('music'), const Offset(-400, 0));
      await pumpFrames(tester);

      await tester.tap(find.widgetWithText(FilledButton, l10n.remove));
      await pumpFrames(tester, count: 5);

      expect(find.text(l10n.noFoldersAdded), findsOneWidget);
      expect(find.byType(Dismissible), findsNothing);
    },
  );

  testWidgets('subfolder swipe left does not remove the folder', (
    tester,
  ) async {
    final harness = await _pumpLibraryHarness(tester);
    addTearDown(harness.dispose);

    final l10n = AppLocalizations.of(tester.element(find.byType(LibraryView)));

    await harness.libraryVm.browseInto('/music');
    await pumpFrames(tester);

    expect(find.text('Author'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);
    expect(find.byType(FolderFavoriteSwipe), findsOneWidget);

    await tester.drag(find.text('Author'), const Offset(-400, 0));
    await pumpFrames(tester);

    expect(find.text(l10n.removeLibraryFolderTitle), findsNothing);
    expect(find.text('Author'), findsOneWidget);
  });
}

Future<_Harness> _pumpLibraryHarness(WidgetTester tester) async {
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
      child: wrapWithL10n(
        const LibraryView(autoLoad: false, restoreSessionOnMount: false),
      ),
    ),
  );

  await pumpFrames(tester);

  return _Harness(db: db, libraryVm: libraryVm);
}

class _Harness {
  _Harness({required this.db, required this.libraryVm});

  final AppDatabase db;
  final LibraryViewModel libraryVm;

  Future<void> dispose() => db.close();
}

class _NoOpPlayback implements AudioPlaybackService {
  @override
  AudioTrack? get currentTrack => null;

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
  Duration get position => Duration.zero;

  @override
  Duration? get duration => null;

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

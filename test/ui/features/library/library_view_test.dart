/// LibraryView empty state.
///
/// Evidence:
/// - `LibraryView shows empty state`
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
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

void main() {
  testWidgets('LibraryView shows empty state', (tester) async {
    final db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    final libraryRepository = testLibraryRepository(storage);
    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    await libraryVm.load();

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
                  playbackService: _NoOpPlayback(),
                  storageService: storage,
                ),
              ),
            ),
          ],
          child: const LibraryView(autoLoad: false),
        ),
      ),
    );

    await pumpFrames(tester);

    final l10n = AppLocalizations.of(tester.element(find.byType(LibraryView)));
    expect(find.text(l10n.noFoldersAdded), findsOneWidget);

    await db.close();
  });
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

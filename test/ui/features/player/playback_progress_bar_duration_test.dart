/// RetroProgressBar stays visible when a track is loaded.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/playback_progress_bar.dart';

import '../../../helpers/recording_playback.dart';

void main() {
  testWidgets('progress bar visible when hasTrack and engine duration known',
      (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(() async => db.close());

    final playback = RecordingPlayback();
    final viewModel = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: LibraryStorageService(db),
      ),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RetroProgressBar(viewModel: viewModel),
        ),
      ),
    );

    expect(find.byType(Slider), findsNothing);

    playback.emitTrack(
      AudioTrack(
        id: '/x/a.mp3',
        filePath: '/x/a.mp3',
        directoryPath: '/x',
        metadata: const TrackMetadata(title: 'A'),
        dateAdded: DateTime(2024),
        durationMs: null,
      ),
    );
    playback.emitDuration(const Duration(minutes: 3));
    await tester.pump();

    expect(find.byType(Slider), findsOneWidget);
  });
}

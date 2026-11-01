/// 15-second jumps from the buttons, the album art, and the view model.
///
/// Evidence:
/// - `jumpBy moves 15 seconds and stops at the ends`
/// - `side buttons and art double-tap jump 15 seconds`
library;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_jumps.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late RecordingPlayback playback;
  late PlayerViewModel viewModel;

  final track = testTrack(
    filePath: '/books/a/ch01.mp3',
    directoryPath: '/books/a',
    metadata: const TrackMetadata(title: 'Chapter 1'),
  );

  setUp(() {
    db = AppDatabase.inMemory();
    playback = RecordingPlayback();
    viewModel = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: LibraryStorageService(db),
      ),
    );
    playback.emitTrack(track);
  });

  tearDown(() async {
    viewModel.dispose();
    await db.close();
  });

  Future<void> at(Duration position, {Duration? length}) async {
    playback.emitPosition(position);
    if (length != null) playback.emitDuration(length);
    // Broadcast streams deliver on a microtask. A zero Duration timer never
    // fires inside a widget test, so wait on an already-completed future.
    await Future<void>.value();
  }

  test('jumpBy moves 15 seconds and stops at the ends', () async {
    await at(const Duration(minutes: 1), length: const Duration(minutes: 3));

    await viewModel.jumpBy(-playbackJumpStep);
    expect(playback.position, const Duration(seconds: 45));

    await at(const Duration(minutes: 1));
    await viewModel.jumpBy(playbackJumpStep);
    expect(playback.position, const Duration(seconds: 75));

    await at(const Duration(seconds: 5));
    await viewModel.jumpBy(-playbackJumpStep);
    expect(playback.position, Duration.zero);

    await at(const Duration(minutes: 2, seconds: 50));
    await viewModel.jumpBy(playbackJumpStep);
    expect(playback.position, const Duration(minutes: 3));
  });

  testWidgets('side buttons and art double-tap jump 15 seconds', (
    tester,
  ) async {
    await at(const Duration(minutes: 1), length: const Duration(minutes: 3));

    await tester.pumpWidget(
      wrapWithL10n(
        ChangeNotifierProvider<PlayerViewModel>.value(
          value: viewModel,
          child: AlbumArtWithJumps(viewModel: viewModel, artSize: 200),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('-15'), findsOneWidget);
    expect(find.text('+15'), findsOneWidget);

    await tester.tap(find.text('-15'));
    await tester.pump();
    expect(playback.position, const Duration(seconds: 45));

    await at(const Duration(minutes: 1));
    await tester.tap(find.text('+15'));
    await tester.pump();
    expect(playback.position, const Duration(seconds: 75));

    Future<void> doubleTapAt(Offset point) async {
      final first = await tester.startGesture(point);
      await first.up();
      await tester.pump(kDoubleTapMinTime);
      final second = await tester.startGesture(point);
      await second.up();
      await tester.pump(const Duration(milliseconds: 50));
    }

    final art = tester.getRect(find.byType(AlbumArtFrame));
    await at(const Duration(minutes: 1));
    await doubleTapAt(art.centerLeft + const Offset(24, 0));
    expect(playback.position, const Duration(seconds: 45));

    await at(const Duration(minutes: 1));
    await doubleTapAt(art.centerRight - const Offset(24, 0));
    expect(playback.position, const Duration(seconds: 75));
  });

  testWidgets('art single tap callback runs without waiting for double-tap window', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      wrapWithL10n(
        ChangeNotifierProvider<PlayerViewModel>.value(
          value: viewModel,
          child: AlbumArtWithJumps(
            viewModel: viewModel,
            artSize: 200,
            onArtTap: () => tapCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(AlbumArtFrame));
    await tester.pump();

    expect(tapCount, 1);
  });
}

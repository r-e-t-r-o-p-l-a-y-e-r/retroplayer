/// Library source folders at the root can be reordered like favorites.
///
/// Evidence:
/// - `reordering two roots persists and reloads in that order`
/// - `long-press drag swaps library source rows`
library;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;
  late LibraryRepository libraryRepository;
  late LibraryViewModel viewModel;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
    libraryRepository = testLibraryRepository(storage);
    viewModel = LibraryViewModel(libraryRepository: libraryRepository);
  });

  tearDown(() async {
    viewModel.dispose();
    await db.close();
  });

  test('reordering two roots persists and reloads in that order', () async {
    await storage.addLibraryRoot('/music');
    await storage.addLibraryRoot('/audiobooks');
    await viewModel.load();

    expect(viewModel.folders.map((f) => f.name), ['music', 'audiobooks']);

    await viewModel.reorderLibraryRoot(0, 1);

    expect(viewModel.folders.map((f) => f.name), ['audiobooks', 'music']);
    expect(await storage.getLibraryRoots(), [
      normalizeLibraryPath('/audiobooks'),
      normalizeLibraryPath('/music'),
    ]);

    final again = LibraryViewModel(libraryRepository: libraryRepository);
    await again.load();
    expect(again.folders.map((f) => f.name), ['audiobooks', 'music']);
    again.dispose();
  });

  testWidgets('long-press drag swaps library source rows', (tester) async {
    await storage.addLibraryRoot('/music');
    await storage.addLibraryRoot('/audiobooks');
    await viewModel.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: viewModel),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: RecordingPlayback(),
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

    expect(
      tester.getTopLeft(find.text('music')).dy,
      lessThan(tester.getTopLeft(find.text('audiobooks')).dy),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('music')),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    final audiobooks = tester.getCenter(find.text('audiobooks'));
    await gesture.moveTo(audiobooks + const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await pumpFrames(tester, count: 12);

    expect(
      tester.getTopLeft(find.text('audiobooks')).dy,
      lessThan(tester.getTopLeft(find.text('music')).dy),
    );
    expect(await storage.getLibraryRoots(), [
      normalizeLibraryPath('/audiobooks'),
      normalizeLibraryPath('/music'),
    ]);
  });
}

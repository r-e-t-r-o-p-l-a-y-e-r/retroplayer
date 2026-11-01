/// Folder favorite swipe must not activate for drags starting at the back edge.
///
/// Evidence:
/// - `edge-started horizontal drag does not toggle favorite`
/// - `center-started swipe right still toggles favorite`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/library/widgets/folder_favorite_swipe.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/library_test_seed.dart';
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

  Future<void> pumpAuthorFolder(WidgetTester tester) async {
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(libraryRepository);
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

    await viewModel.browseInto('/music');
    await pumpFrames(tester);
  }

  testWidgets('edge-started horizontal drag does not toggle favorite', (
    tester,
  ) async {
    await pumpAuthorFolder(tester);

    expect(viewModel.isFavorite('/music/Author'), isFalse);

    final row = find.text('Author');
    final topLeft = tester.getTopLeft(row);
    final height = tester.getSize(row).height;

    final gesture = await tester.startGesture(
      topLeft + Offset(kFolderFavoriteBackEdgeSlop / 2, height / 2),
    );
    await gesture.moveBy(const Offset(280, 0));
    await gesture.up();
    await pumpFrames(tester, count: 8);

    expect(viewModel.isFavorite('/music/Author'), isFalse);
    expect(find.byIcon(Icons.star), findsNothing);
  });

  testWidgets('center-started swipe right still toggles favorite', (
    tester,
  ) async {
    await pumpAuthorFolder(tester);

    await tester.drag(find.text('Author'), const Offset(500, 0));
    await pumpFrames(tester, count: 8);

    expect(viewModel.isFavorite('/music/Author'), isTrue);
    expect(find.byIcon(Icons.star), findsWidgets);
  });
}

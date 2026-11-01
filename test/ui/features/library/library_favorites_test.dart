/// Favorite folders persist and show up as starred links at the library root.
///
/// Evidence:
/// - `toggle stores a folder and a second toggle clears it`
/// - `favorite links survive refresh and follow library roots`
/// - `paths outside the library are dropped`
/// - `reordering two paths persists and reloads in that order`
/// - `long-press drag swaps favorite links`
/// - `swipe right marks a folder and the root link clears it`
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_library_row.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
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

  test('toggle stores a folder and a second toggle clears it', () async {
    await storage.addLibraryRoot('/music');
    await viewModel.load();

    await viewModel.toggleFavorite('/music/Author');
    expect(viewModel.isFavorite('/music/Author'), isTrue);
    expect(viewModel.favoriteFolders.single.name, 'Author');
    expect(await storage.getFavoriteFolders(), [
      normalizeLibraryPath('/music/Author'),
    ]);

    await viewModel.toggleFavorite('/music');
    expect(viewModel.isFavorite('/music'), isFalse);

    await viewModel.toggleFavorite('/music/Author');
    expect(viewModel.favoriteFolders, isEmpty);
    expect(await storage.getFavoriteFolders(), isEmpty);
  });

  test('favorite links survive refresh and follow library roots', () async {
    await storage.addLibraryRoot('/music');
    await viewModel.load();
    await viewModel.toggleFavorite('/music/Author');

    await viewModel.refreshDisplay();
    expect(
      viewModel.favoriteFolders.single.path,
      normalizeLibraryPath('/music/Author'),
    );

    final again = LibraryViewModel(libraryRepository: libraryRepository);
    await again.load();
    expect(again.isFavorite('/music/Author'), isTrue);
    expect(
      again.selectableRows.first.deleteAction,
      KeyboardDeleteAction.removeLibraryRoot,
    );
    expect(again.selectableRows[1].folderName, 'Author');
    expect(again.selectableRows[1].deleteAction, KeyboardDeleteAction.none);
    again.dispose();
  });

  test('paths outside the library are dropped', () async {
    await storage.addLibraryRoot('/music');
    await libraryRepository.setFavoriteFolders(['/gone/book', '/music/Author']);

    await viewModel.load();

    expect(viewModel.favoriteFolders, hasLength(1));
    expect(viewModel.isFavorite('/music/Author'), isTrue);
    expect(await storage.getFavoriteFolders(), [
      normalizeLibraryPath('/music/Author'),
    ]);
  });

  test('reordering two paths persists and reloads in that order', () async {
    await storage.addLibraryRoot('/music');
    await libraryRepository.setFavoriteFolders(['/music/Alpha', '/music/Beta']);
    await viewModel.load();

    await viewModel.reorderFavorite(0, 1);

    expect(viewModel.favoriteFolders.map((folder) => folder.name), [
      'Beta',
      'Alpha',
    ]);
    expect(await storage.getFavoriteFolders(), [
      normalizeLibraryPath('/music/Beta'),
      normalizeLibraryPath('/music/Alpha'),
    ]);

    final again = LibraryViewModel(libraryRepository: libraryRepository);
    await again.load();
    expect(again.favoriteFolders.map((folder) => folder.name), [
      'Beta',
      'Alpha',
    ]);
    again.dispose();
  });

  testWidgets('long-press drag swaps favorite links', (tester) async {
    await storage.addLibraryRoot('/music');
    await libraryRepository.setFavoriteFolders(['/music/Alpha', '/music/Beta']);
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
      tester.getTopLeft(find.text('Alpha')).dy,
      lessThan(tester.getTopLeft(find.text('Beta')).dy),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Alpha')),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    final beta = tester.getCenter(find.text('Beta'));
    await gesture.moveTo(beta + const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await pumpFrames(tester, count: 12);

    expect(
      tester.getTopLeft(find.text('Beta')).dy,
      lessThan(tester.getTopLeft(find.text('Alpha')).dy),
    );
    expect(await storage.getFavoriteFolders(), [
      normalizeLibraryPath('/music/Beta'),
      normalizeLibraryPath('/music/Alpha'),
    ]);
  });

  testWidgets('swipe right marks a folder and the root link clears it', (
    tester,
  ) async {
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

    final l10n = AppLocalizations.of(tester.element(find.byType(LibraryView)));

    await viewModel.browseInto('/music');
    await pumpFrames(tester);

    await tester.drag(find.text('Author'), const Offset(500, 0));
    await pumpFrames(tester, count: 8);

    expect(find.byIcon(Icons.star), findsWidgets);

    await viewModel.browseUp();
    await pumpFrames(tester);

    expect(find.text(l10n.favorites), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsWidgets);

    await tester.drag(find.text('Author'), const Offset(500, 0));
    await pumpFrames(tester, count: 8);

    expect(find.text(l10n.favorites), findsNothing);
    expect(find.text('Author'), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(find.text('music'), findsOneWidget);
  });
}

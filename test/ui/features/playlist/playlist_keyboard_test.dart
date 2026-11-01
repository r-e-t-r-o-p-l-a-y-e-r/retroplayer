/// Playlist detail keyboard play and Escape closes the route.
///
/// Evidence:
/// - `arrow down and enter plays second playlist entry`
/// - `EscapeNavigationIntent closes playlist detail route`
/// - `escape closes playlist detail route`
/// - `disk playlist is read-only: no save, add, reorder or swipe remove`
/// - `app-created playlist offers save, add and reorder`
/// - `app-created playlist rows use delayed drag on the whole tile`
/// - `long-press drag reorders playlist rows`
/// - `save stays grey until the playlist has unsaved edits`
/// - `swipe to remove still confirms`
/// - `reordering keeps the dragged item selected`
/// - `app-created playlist can multi-select and remove tracks`
/// - `playlist select mode toggles a track off`
/// - `playlist select all checks every track and clears them again`
/// - `German disk playlist shows the read-only label`
/// - `German playlist select all switches to deselect all`
/// - `escape leaves playlist select mode without closing the page`
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_intents.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/playlist/views/playlist_detail_view.dart';

import '../../../helpers/keyboard_test_helpers.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_panel.dart';

class _PlaylistTrackScanLibrary extends ScanLibrary {
  _PlaylistTrackScanLibrary({
    required this.tracksByPath,
    required this.itemsByDirectory,
  }) : super(
         fileScanService: FileScanService(),
         metadataService: MetadataService(),
         groupTracksIntoAlbums: GroupTracksIntoAlbums(),
       );

  final Map<String, AudioTrack> tracksByPath;
  final Map<String, List<LibraryItem>> itemsByDirectory;

  @override
  Stream<DirectoryListingUpdate> watchDirectoryShallow(
    String directoryPath,
  ) async* {
    yield DirectoryListingUpdate.complete(
      itemsByDirectory[normalizeLibraryPath(directoryPath)] ?? const [],
    );
  }

  @override
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath) async {
    return itemsByDirectory[normalizeLibraryPath(directoryPath)] ?? const [];
  }

  @override
  Future<AudioTrack> trackFromPath(String filePath) async {
    return tracksByPath[filePath]!;
  }
}

void main() {
  late AudioTrack track1;
  late AudioTrack track2;
  late PlaylistFile playlist;
  late LibraryViewModel libraryVm;
  late PlayerViewModel playerVm;
  late RecordingPlayback playback;
  late LibraryStorageService storage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    track1 = testTrack(
      filePath: '/music/track01.mp3',
      metadata: const TrackMetadata(title: 'Track One'),
    );
    track2 = testTrack(
      filePath: '/music/track02.mp3',
      metadata: const TrackMetadata(title: 'Track Two'),
    );
    playlist = PlaylistFile(
      filePath: '/music/road.m3u',
      entryPaths: [track1.filePath, track2.filePath],
    );

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    storage = LibraryStorageService(db);
    final libraryRepository = LibraryRepository(
      storageService: storage,
      scanLibrary: _PlaylistTrackScanLibrary(
        tracksByPath: {track1.filePath: track1, track2.filePath: track2},
        itemsByDirectory: {
          '/music': [LibraryItem.playlist(playlist: playlist)],
        },
      ),
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
    );
    await storage.addLibraryRoot('/music');
    libraryRepository.seedDirectory('/music', [
      LibraryItem.playlist(playlist: playlist),
    ]);

    playback = RecordingPlayback();
    libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    await libraryVm.load();
    await libraryVm.navigateToBrowsePath('/music');
    playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );
  });

  Future<void> pumpPlaylistDetail(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider.value(value: playerVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapRouterWithL10n(
          router: AppRouter.create(initialLocation: AppRouter.library),
          locale: locale,
        ),
      ),
    );
    await pumpFrames(tester);
    await tester.tap(find.text('road'));
    await pumpFrames(tester);

    final registry = tester
        .element(find.byType(PlaylistDetailView))
        .read<KeyboardRegistry>();
    expect(registry.playlist, isNotNull);
  }

  testWidgets('arrow down and enter plays second playlist entry', (
    tester,
  ) async {
    await pumpPlaylistDetail(tester);

    // Disk playlist: read-only list, but keyboard selection still works.
    expect(find.byType(ReorderableListView), findsNothing);
    final listContext = tester.element(
      find
          .descendant(
            of: find.byType(PlaylistDetailView),
            matching: find.byType(ListView),
          )
          .first,
    );
    Actions.invoke(listContext, const MoveSelectionIntent(1));
    await pumpFrames(tester);
    Actions.invoke(listContext, const MoveSelectionIntent(1));
    await pumpFrames(tester);
    await sendPlainKey(tester, LogicalKeyboardKey.enter);

    expect(playback.playCalled, isTrue);
    expect(playback.lastStartIndex, 1);
  });

  testWidgets('EscapeNavigationIntent closes playlist detail route', (
    tester,
  ) async {
    await pumpPlaylistDetail(tester);
    expect(find.byType(PlaylistDetailView), findsOneWidget);

    final focusElement = tester.element(
      find.byKey(const Key('desktop_shortcut_focus')),
    );
    final router = GoRouter.of(focusElement);
    expect(focusElement.read<KeyboardRegistry>().playlist, isNotNull);
    expect(router.canPop(), isTrue);

    Actions.invoke(focusElement, const EscapeNavigationIntent());
    await pumpFrames(tester);

    expect(router.state.matchedLocation, AppRouter.library);
  });

  testWidgets('escape closes playlist detail route', (tester) async {
    await pumpPlaylistDetail(tester);
    final router = GoRouter.of(
      tester.element(find.byKey(const Key('desktop_shortcut_focus'))),
    );
    expect(router.state.matchedLocation, contains('playlist-detail'));

    await sendPlainKey(tester, LogicalKeyboardKey.escape);
    await pumpFrames(tester);

    expect(router.state.matchedLocation, AppRouter.library);
  });

  testWidgets(
    'disk playlist is read-only: no save, add, reorder or swipe remove',
    (tester) async {
      await pumpPlaylistDetail(tester);

      expect(find.textContaining(enL10n(tester).save), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byIcon(Icons.checklist), findsNothing);
      expect(find.byType(ReorderableListView), findsNothing);
      expect(_inDetail(Dismissible), findsNothing);
      expect(_inDetail(ReorderableDelayedDragStartListener), findsNothing);
      expect(find.text('Track One'), findsOneWidget);
      expect(find.text(enL10n(tester).playlistReadOnly), findsWidgets);
    },
  );

  testWidgets('app-created playlist offers save, add and reorder', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    expect(find.textContaining(enL10n(tester).save), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(_inDetail(Dismissible), findsNWidgets(2));
    expect(_inDetail(ReorderableDelayedDragStartListener), findsNWidgets(2));
  });

  testWidgets('long-press drag reorders playlist rows', (tester) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    Finder title(String label) => find.descendant(
      of: find.byType(PlaylistDetailView),
      matching: find.text(label),
    );

    expect(
      tester.getTopLeft(title('Track One')).dy,
      lessThan(tester.getTopLeft(title('Track Two')).dy),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(title('Track One')),
    );
    await tester.pump(kLongPressTimeout + kPressTimeout);
    final trackTwo = tester.getCenter(title('Track Two'));
    await gesture.moveTo(trackTwo + const Offset(0, 120));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(title('Track Two')).dy,
      lessThan(tester.getTopLeft(title('Track One')).dy),
    );
  });

  testWidgets('save stays grey until the playlist has unsaved edits', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    TextButton saveButton() {
      return tester.widget<TextButton>(
        find.ancestor(
          of: find.descendant(
            of: find.byType(PlaylistDetailView),
            matching: find.textContaining(enL10n(tester).save),
          ),
          matching: find.byType(TextButton),
        ),
      );
    }

    Color? saveColor(Set<WidgetState> states) {
      return saveButton().style?.foregroundColor?.resolve(states);
    }

    expect(saveButton().onPressed, isNull);
    expect(
      saveColor({WidgetState.disabled}),
      RetroPalette.of(
        tester.element(find.byType(PlaylistDetailView)),
      ).textMuted,
    );

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem?.call(0, 1);
    await tester.pump();

    expect(saveButton().onPressed, isNotNull);
    expect(
      saveColor({}),
      RetroPalette.of(tester.element(find.byType(PlaylistDetailView))).accent,
    );
  });

  testWidgets('swipe to remove still confirms', (tester) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    await tester.drag(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.text('Track One'),
      ),
      const Offset(-500, 0),
    );
    await pumpFrames(tester, count: 12);

    expect(
      find.text(enL10n(tester).removePlaylistTrackTitle(1)),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, enL10n(tester).remove));
    await pumpFrames(tester);

    expect(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.text('Track One'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.text('Track Two'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reordering keeps the dragged item selected', (tester) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderStart?.call(0);
    await tester.pump();
    final latest = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    latest.onReorderItem?.call(0, 1);
    await tester.pump();
    await tester.pump();

    RetroListTile tileFor(String title) {
      return tester.widget<RetroListTile>(
        find.ancestor(
          of: find.descendant(
            of: find.byType(PlaylistDetailView),
            matching: find.text(title),
          ),
          matching: find.byType(RetroListTile),
        ),
      );
    }

    expect(tileFor('Track One').selected, isTrue);
    expect(tileFor('Track Two').selected, isFalse);
  });

  testWidgets('app-created playlist can multi-select and remove tracks', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    await tester.tap(find.byIcon(Icons.checklist));
    await pumpFrames(tester);

    expect(find.text(enL10n(tester).playlistSelectedCount(0)), findsOneWidget);
    expect(find.byType(ReorderableListView), findsNothing);
    expect(find.byType(Checkbox), findsNWidgets(2));

    await tester.tap(find.text('Track One'));
    await pumpFrames(tester);
    await tester.tap(find.text('Track Two'));
    await pumpFrames(tester);

    expect(playback.playCalled, isFalse);
    expect(find.text(enL10n(tester).playlistSelectedCount(2)), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await pumpFrames(tester);
    await tester.tap(find.widgetWithText(FilledButton, enL10n(tester).remove));
    await pumpFrames(tester);

    expect(find.text('Track One'), findsNothing);
    expect(find.text('Track Two'), findsNothing);
    expect(find.text(enL10n(tester).playlistEmpty), findsOneWidget);
  });

  testWidgets('playlist select mode toggles a track off', (tester) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    await tester.tap(find.byIcon(Icons.checklist));
    await pumpFrames(tester);

    Checkbox checkboxFor(String title) {
      return tester.widget<Checkbox>(
        find.descendant(
          of: find.ancestor(
            of: find.descendant(
              of: find.byType(PlaylistDetailView),
              matching: find.text(title),
            ),
            matching: find.byType(RetroListTile),
          ),
          matching: find.byType(Checkbox),
        ),
      );
    }

    await tester.tap(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.text('Track One'),
      ),
    );
    await pumpFrames(tester);
    expect(checkboxFor('Track One').value, isTrue);
    expect(find.text(enL10n(tester).playlistSelectedCount(1)), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.text('Track One'),
      ),
    );
    await pumpFrames(tester);
    expect(checkboxFor('Track One').value, isFalse);
    expect(find.text(enL10n(tester).playlistSelectedCount(0)), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(Checkbox).first));
    await pumpFrames(tester);
    expect(checkboxFor('Track One').value, isTrue);

    await tester.tapAt(tester.getCenter(find.byType(Checkbox).first));
    await pumpFrames(tester);
    expect(checkboxFor('Track One').value, isFalse);
    expect(find.text(enL10n(tester).playlistSelectedCount(0)), findsOneWidget);
  });

  testWidgets('playlist select all checks every track and clears them again', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    await tester.tap(find.byIcon(Icons.checklist));
    await pumpFrames(tester);

    expect(find.byTooltip(enL10n(tester).playlistSelectAll), findsOneWidget);
    await tester.tap(find.byTooltip(enL10n(tester).playlistSelectAll));
    await pumpFrames(tester);

    expect(find.text(enL10n(tester).playlistSelectedCount(2)), findsOneWidget);
    expect(find.byTooltip(enL10n(tester).playlistDeselectAll), findsOneWidget);
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .map((box) => box.value),
      everyElement(isTrue),
    );

    await tester.tap(find.byTooltip(enL10n(tester).playlistDeselectAll));
    await pumpFrames(tester);

    expect(find.text(enL10n(tester).playlistSelectedCount(0)), findsOneWidget);
    expect(find.byTooltip(enL10n(tester).playlistSelectAll), findsOneWidget);
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .map((box) => box.value),
      everyElement(isFalse),
    );
  });

  testWidgets('German disk playlist shows the read-only label', (tester) async {
    final de = lookupAppLocalizations(const Locale('de'));
    await pumpPlaylistDetail(tester, locale: const Locale('de'));
    expect(find.textContaining(de.playlistReadOnly), findsWidgets);
  });

  testWidgets('German playlist select all switches to deselect all', (
    tester,
  ) async {
    final de = lookupAppLocalizations(const Locale('de'));
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester, locale: const Locale('de'));

    await tester.tap(find.byIcon(Icons.checklist));
    await pumpFrames(tester);
    expect(find.byTooltip(de.playlistSelectAll), findsOneWidget);

    await tester.tap(find.byTooltip(de.playlistSelectAll));
    await pumpFrames(tester);
    expect(find.text(de.playlistSelectedCount(2)), findsOneWidget);
    expect(find.byTooltip(de.playlistDeselectAll), findsOneWidget);
  });

  testWidgets('escape leaves playlist select mode without closing the page', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await storage.markAppCreatedPlaylist(playlist.filePath);
      await libraryVm.load();
      await libraryVm.navigateToBrowsePath('/music');
    });
    await pumpPlaylistDetail(tester);

    await tester.tap(find.byIcon(Icons.checklist));
    await pumpFrames(tester);
    expect(find.byType(Checkbox), findsWidgets);

    await sendPlainKey(tester, LogicalKeyboardKey.escape);
    await pumpFrames(tester);

    expect(find.byType(PlaylistDetailView), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });
}

Finder _inDetail(Type type) => find.descendant(
  of: find.byType(PlaylistDetailView),
  matching: find.byType(type),
);

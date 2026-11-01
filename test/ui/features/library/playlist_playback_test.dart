/// Playlist row play vs open detail; detail entry play; mini player visibility.
///
/// Evidence:
/// - `playlist row play button starts playback without opening detail`
/// - `playlist row body tap opens detail without starting playback`
/// - `playlist detail app bar has no play button`
/// - `playlist detail entry tap starts playback at that track`
/// - `playlist detail play keeps continuous sheet collapsed`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
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
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_item_tile.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_library_sheet.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';
import 'package:retroplayer/ui/features/playlist/views/playlist_detail_view.dart';

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
    final track = tracksByPath[filePath];
    if (track == null) {
      throw StateError('No seeded track for $filePath');
    }
    return track;
  }
}

void main() {
  late AudioTrack track1;
  late AudioTrack track2;
  late PlaylistFile playlist;
  late LibraryRepository libraryRepository;
  late RecordingPlayback playback;
  late LibraryViewModel libraryVm;
  late PlayerViewModel playerVm;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    track1 = testTrack(
      filePath: '/music/track01.mp3',
      directoryPath: '/music',
      metadata: const TrackMetadata(title: 'Track One'),
    );
    track2 = testTrack(
      filePath: '/music/track02.mp3',
      directoryPath: '/music',
      metadata: const TrackMetadata(title: 'Track Two'),
    );

    playlist = PlaylistFile(
      filePath: '/music/road.m3u',
      entryPaths: [track1.filePath, track2.filePath],
    );

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    libraryRepository = LibraryRepository(
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

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider.value(value: playerVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: wrapRouterWithL10n(
          router: AppRouter.create(initialLocation: AppRouter.library),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  testWidgets(
    'playlist row play button starts playback without opening detail',
    (tester) async {
      await pumpShell(tester);

      final playButtons = find.descendant(
        of: find.byType(LibraryItemTile),
        matching: find.byIcon(Icons.play_arrow_rounded),
      );
      expect(playButtons, findsOneWidget);

      await tester.tap(playButtons);
      await pumpFrames(tester);

      expect(playback.playCalled, isTrue);
      expect(playback.lastQueue, hasLength(2));
      expect(playerVm.currentItemId, playlist.id);
      expect(find.byType(PlaylistDetailView), findsNothing);
    },
  );

  testWidgets('playlist row body tap opens detail without starting playback', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('road'));
    await pumpFrames(tester);

    expect(find.byType(PlaylistDetailView), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Playlist'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PlaylistDetailView),
        matching: find.byIcon(Icons.play_arrow_rounded),
      ),
      findsNothing,
    );
    expect(find.text('road'), findsWidgets);
    expect(playback.playCalled, isFalse);
    expect(playback.lastQueue, isNull);
  });

  testWidgets('playlist detail entry tap starts playback at that track', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('road'));
    await pumpFrames(tester);

    await tester.tap(find.text('Track Two'));
    await pumpFrames(tester);

    expect(playback.playCalled, isTrue);
    expect(playback.lastQueue, hasLength(2));
    expect(playback.lastStartIndex, 1);
    expect(playerVm.currentItemId, playlist.id);
    expect(playerVm.currentTrack?.id, track2.id);
  });

  testWidgets('playlist detail play keeps continuous sheet collapsed', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('road'));
    await pumpFrames(tester);

    await tester.tap(find.text('Track One'));
    await pumpFrames(tester);

    expect(playerVm.currentItemId, playlist.id);
    final detailContext = tester.element(find.byType(PlaylistDetailView));
    final panelVm = detailContext.read<PlayerPanelViewModel>();
    expect(panelVm.isExpanded, isFalse);
    expect(AppLocation.shellOf(detailContext), isA<PlaylistDetailLocation>());
    expect(find.byType(PlayerLibrarySheet), findsOneWidget);
    expect(find.byType(PlayerCollapsedBar), findsNothing);
  });
}

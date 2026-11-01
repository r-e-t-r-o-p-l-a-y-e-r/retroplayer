/// jumpToNowPlaying opens album detail and highlights the playing track.
///
/// Evidence:
/// - `jumpToNowPlaying from folder play opens album detail for first track`
/// - `jumpToNowPlaying scrolls folder audio row into view when highlight is off-screen`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

final _jumpTestNavigatorKey = GlobalKey<NavigatorState>();

GoRouter _jumpTestRouter() {
  return GoRouter(
    navigatorKey: _jumpTestNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const LibraryView(autoLoad: false, restoreSessionOnMount: false),
        routes: [
          GoRoute(
            path: 'album-detail',
            builder: (context, state) {
              final album = state.extra as AudioAlbum?;
              if (album == null) {
                return const Scaffold(
                  body: Center(child: Text('Album not found')),
                );
              }
              return AlbumDetailView(album: album);
            },
          ),
        ],
      ),
    ],
  );
}

AudioAlbum _testAlbum() {
  const albumId = 'dir:/music/mybook';
  return AudioAlbum(
    id: albumId,
    title: 'My Book',
    tracks: [
      testTrack(
        filePath: '/music/MyBook/ch01.mp3',
        directoryPath: '/music/MyBook',
        metadata: const TrackMetadata(trackNumber: 1, title: 'Chapter 1'),
      ),
      testTrack(
        filePath: '/music/MyBook/ch02.mp3',
        directoryPath: '/music/MyBook',
        metadata: const TrackMetadata(trackNumber: 2, title: 'Chapter 2'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
}

void main() {
  testWidgets(
    'jumpToNowPlaying from folder play opens album detail for first track',
    (tester) async {
      final db = AppDatabase.inMemory();
      final storage = LibraryStorageService(db);
      final album = _testAlbum();
      final libraryRepository = testLibraryRepository(storage);
      await storage.addLibraryRoot('/music');
      seedMyBookDirectory(libraryRepository, album);
      libraryRepository.seedTracksUnderFolder('/music', album.tracks);
      final playback = RecordingPlayback();
      final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
      await libraryVm.load();

      final playerVm = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: playback,
          storageService: storage,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: libraryRepository),
            ChangeNotifierProvider.value(value: libraryVm),
            ChangeNotifierProvider(create: (_) => testPanelVm()),
            ChangeNotifierProvider.value(value: playerVm),
          ],
          child: wrapRouterWithL10n(router: _jumpTestRouter()),
        ),
      );
      await pumpFrames(tester);

      await playerVm.playFolder('/music', album.tracks);
      final firstTrack = album.tracks.first;

      expect(playerVm.currentItemId, PlaybackItem.folderId('/music'));
      expect(playerVm.currentTrack?.id, firstTrack.id);

      await LibraryNavigator.of(
        tester.element(find.byType(LibraryView)),
      ).jumpToNowPlaying();
      await pumpFrames(tester);

      final albumDetail = find.byType(AlbumDetailView);
      expect(albumDetail, findsOneWidget);
      expect(
        find.descendant(of: albumDetail, matching: find.text('Chapter 1')),
        findsAtLeast(1),
      );
      expect(
        find.descendant(of: albumDetail, matching: find.text('Chapter 2')),
        findsAtLeast(1),
      );
      expect(libraryVm.highlightedTrackId, firstTrack.id);
      expect(
        libraryVm.effectiveHighlightedTrackId(firstTrack.id),
        firstTrack.id,
      );

      final secondTrack = album.tracks[1];
      expect(libraryVm.effectiveHighlightedTrackId(secondTrack.id), isNull);

      await db.close();
    },
  );
}

/// Playlist row play starts from preview tracks before tags are read.
///
/// Evidence:
/// - `playlist entry play uses preview then adopt without reloading playback`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/application/scan_library.dart';
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
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'playlist entry play uses preview then adopt without reloading playback',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'retroplayer_playlist_tap_',
      );
      addTearDown(() async {
        if (temp.existsSync()) await temp.delete(recursive: true);
      });
      final root = normalizeLibraryPath(temp.path);
      final track1Path = p.join(root, 'track01.mp3');
      final track2Path = p.join(root, 'track02.mp3');

      final track1 = testTrack(
        filePath: track1Path,
        directoryPath: root,
        metadata: const TrackMetadata(title: 'Track One', artist: 'Author'),
      );
      final track2 = testTrack(
        filePath: track2Path,
        directoryPath: root,
        metadata: const TrackMetadata(title: 'Track Two', artist: 'Author'),
      );

      final db = AppDatabase.inMemory();
      addTearDown(db.close);
      final storage = LibraryStorageService(db);
      await storage.addLibraryRoot(root);
      final repository = LibraryRepository(
        storageService: storage,
        scanLibrary: _SlowScanLibrary(
          tracksByPath: {track1.filePath: track1, track2.filePath: track2},
        ),
        sortLibrary: SortLibrary(),
        fileScanService: FileScanService(),
      );
      final library = LibraryViewModel(libraryRepository: repository);
      addTearDown(library.dispose);

      final playlist = PlaylistFile(
        filePath: p.join(root, 'list.m3u'),
        entryPaths: [track1Path, track2Path],
      );

      final engine = RecordingPlayback();
      final player = PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: engine,
          storageService: storage,
        ),
      );
      addTearDown(player.dispose);

      final preview = library.previewTracksForPlaylist(playlist);
      await player.playPlaylistTrack(playlist, preview, preview[1]);

      expect(engine.playCalled, isTrue);
      expect(engine.setQueueCalls, 1);
      expect(engine.lastStartIndex, 1);
      expect(player.currentItemId, playlist.id);
      expect(player.title, 'track02');

      final resolved = await library.tracksForPlaylist(playlist);
      player.adoptResolvedTracks(playlist.id, resolved);

      expect(engine.setQueueCalls, 1);
      expect(player.title, 'Track Two');
      expect(player.subtitle, 'Author');
    },
  );
}

class _SlowScanLibrary extends ScanLibrary {
  _SlowScanLibrary({required this.tracksByPath})
    : super(
        fileScanService: FileScanService(),
        metadataService: MetadataService(),
        groupTracksIntoAlbums: GroupTracksIntoAlbums(),
      );

  final Map<String, AudioTrack> tracksByPath;

  @override
  Stream<DirectoryListingUpdate> watchDirectoryShallow(
    String directoryPath,
  ) async* {
    yield DirectoryListingUpdate.complete(const []);
  }

  @override
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath) async {
    return const [];
  }

  @override
  Future<AudioTrack> trackFromPath(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final track = tracksByPath[normalizeLibraryPath(filePath)];
    if (track == null) {
      throw StateError('No seeded track for $filePath');
    }
    return track;
  }
}

import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';

/// Scanner that serves seeded directories and tracks instead of touching disk.
class SeededScanLibrary extends ScanLibrary {
  SeededScanLibrary({
    this.tracksByPath = const {},
    this.itemsByDirectory = const {},
  }) : super(
         fileScanService: FileScanService(),
         metadataService: MetadataService(),
         groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
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

/// [LibraryRepository] backed by a [SeededScanLibrary].
LibraryRepository seededLibraryRepository(
  LibraryStorageService storage, {
  Map<String, AudioTrack> tracksByPath = const {},
  Map<String, List<LibraryItem>> itemsByDirectory = const {},
}) {
  return LibraryRepository(
    storageService: storage,
    scanLibrary: SeededScanLibrary(
      tracksByPath: tracksByPath,
      itemsByDirectory: itemsByDirectory,
    ),
    sortLibrary: SortLibrary(),
    fileScanService: FileScanService(),
  );
}

/// Covers load only inside a folder (albums) or on play — not for child folders.
///
/// Evidence:
/// - `listChildFolders returns entries without coverArtPath`
/// - `refreshDisplay does not attach covers to child folder rows`
/// - `enrichAlbumCovers still resolves covers for albums in the open folder`
library;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/album_art_cache.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import '../../../helpers/track_factory.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late LibraryRepository repository;
  late LibraryViewModel viewModel;
  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lazy_covers_');
    db = AppDatabase.inMemory();
    final resolve = ResolveCoverArt(
      readEmbeddedArtwork: (_) => jpegBytes,
      cache: AlbumArtCache(Directory('${tempDir.path}/cache')),
    );
    repository = LibraryRepository(
      storageService: LibraryStorageService(db),
      scanLibrary: ScanLibrary(
        fileScanService: FileScanService(),
        metadataService: MetadataService(),
        groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
      ),
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
      resolveCoverArt: resolve,
    );
    viewModel = LibraryViewModel(libraryRepository: repository);
  });

  tearDown(() async {
    viewModel.dispose();
    // Let cancelled deferred scans settle before closing the DB.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('listChildFolders returns entries without coverArtPath', () async {
    final child = Directory('${tempDir.path}/Album');
    await child.create();
    await File('${child.path}/cover.jpg').writeAsBytes(jpegBytes);

    final folders = await repository.listChildFolders(tempDir.path);

    expect(folders, hasLength(1));
    expect(folders.single.coverArtPath, isNull);
  });

  test('refreshDisplay does not attach covers to child folder rows', () async {
    final child = Directory('${tempDir.path}/Album');
    await child.create();
    await File('${child.path}/cover.jpg').writeAsBytes(jpegBytes);
    await repository.addLibraryRoot(tempDir.path);
    // Stay at library root (folder rows only) — no deferred audio scan.
    await viewModel.refreshDisplay();

    expect(viewModel.folders, isNotEmpty);
    for (final folder in viewModel.folders) {
      expect(folder.coverArtPath, isNull);
    }
  });

  test('enrichAlbumCovers still resolves covers for albums in the open folder',
      () async {
    await File('${tempDir.path}/cover.jpg').writeAsBytes(jpegBytes);
    final tracks = [
      testTrack(
        id: '1',
        filePath: '${tempDir.path}/ch01.mp3',
        directoryPath: tempDir.path,
        metadata: const TrackMetadata(album: 'Book', trackNumber: 1),
      ),
    ];
    final items = [
      LibraryItem.album(
        album: AudioAlbum(
          id: 'a',
          title: 'Book',
          tracks: tracks,
          source: AlbumSource.tag,
          groupingKey: 'a',
        ),
      ),
    ];

    final enriched = await repository.enrichAlbumCovers(items);

    switch (enriched.single) {
      case LibraryAlbumItem(:final album):
        expect(album.coverArtPath, isNotNull);
        expect(File(album.coverArtPath!).readAsBytesSync(), jpegBytes);
      default:
        fail('Expected album');
    }
  });
}

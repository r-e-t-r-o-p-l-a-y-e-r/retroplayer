/// Regression: cover.jpg resolves when browsing a folder or playing — not on scan.
///
/// Evidence:
/// - `ResolveCoverArt caches cover.jpg when extractEmbedded is true`
/// - `ResolveCoverArt returns sidecar path without copying when extractEmbedded is false`
/// - `GroupTracksIntoAlbums leaves cover unset even with cover.jpg present`
/// - `enrichAlbumCovers fills cover.jpg when browsing inside the folder`
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
import '../../helpers/track_factory.dart';

void main() {
  late Directory tempDir;
  late Directory cacheDir;
  late File cover;
  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9, 1, 2, 3]);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cover_jpg_regression_');
    cacheDir = Directory('${tempDir.path}/cache');
    cover = File('${tempDir.path}/cover.jpg');
    await cover.writeAsBytes(jpegBytes);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ResolveCoverArt caches cover.jpg when extractEmbedded is true', () {
    var reads = 0;
    final resolve = ResolveCoverArt(
      readEmbeddedArtwork: (_) {
        reads++;
        return null;
      },
      cache: AlbumArtCache(cacheDir),
    );

    final path = resolve(
      directoryPath: tempDir.path,
      trackFilePath: '${tempDir.path}/track.mp3',
    );

    expect(path, isNotNull);
    expect(path!.startsWith(cacheDir.path), isTrue);
    expect(File(path).readAsBytesSync(), jpegBytes);
    expect(reads, 0);
  });

  test(
    'ResolveCoverArt returns sidecar path without copying when extractEmbedded is false',
    () {
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) => null,
        cache: AlbumArtCache(cacheDir),
      );

      final path = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
        extractEmbedded: false,
      );

      expect(path, isNotNull);
      expect(path!.startsWith(cacheDir.path), isFalse);
      expect(File(path).readAsBytesSync(), jpegBytes);
      expect(cacheDir.existsSync() ? cacheDir.listSync() : const [], isEmpty);
    },
  );

  test('GroupTracksIntoAlbums leaves cover unset even with cover.jpg present',
      () {
    final grouped = const GroupTracksIntoAlbums()([
      testTrack(
        id: '1',
        filePath: '${tempDir.path}/ch01.mp3',
        directoryPath: tempDir.path,
        metadata: const TrackMetadata(album: 'Book', trackNumber: 1),
      ),
      testTrack(
        id: '2',
        filePath: '${tempDir.path}/ch02.mp3',
        directoryPath: tempDir.path,
        metadata: const TrackMetadata(album: 'Book', trackNumber: 2),
      ),
    ]);

    expect(grouped, hasLength(1));
    switch (grouped.single) {
      case LibraryAlbumItem(:final album):
        expect(album.coverArtPath, isNull);
      default:
        fail('Expected album');
    }
  });

  test('enrichAlbumCovers fills cover.jpg when browsing inside the folder',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final resolve = ResolveCoverArt(
      readEmbeddedArtwork: (_) => null,
      cache: AlbumArtCache(cacheDir),
    );
    final repository = LibraryRepository(
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

    expect(enriched, hasLength(1));
    switch (enriched.single) {
      case LibraryAlbumItem(:final album):
        expect(album.coverArtPath, isNotNull);
        expect(File(album.coverArtPath!).readAsBytesSync(), jpegBytes);
      default:
        fail('Expected album with cover.jpg');
    }
  });
}

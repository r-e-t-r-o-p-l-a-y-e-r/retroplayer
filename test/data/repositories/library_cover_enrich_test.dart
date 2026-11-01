/// LibraryRepository cover enrichment for albums.
///
/// Evidence:
/// - `enrichAlbumCovers extracts embedded art for albums missing covers`
/// - `enrichAlbumCovers is a no-op when covers already present`
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
  late AppDatabase db;
  late LibraryRepository repository;
  late int reads;

  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cover_enrich_');
    db = AppDatabase.inMemory();
    reads = 0;
    final resolve = ResolveCoverArt(
      readEmbeddedArtwork: (_) {
        reads++;
        return jpegBytes;
      },
      cache: AlbumArtCache(Directory('${tempDir.path}/cache')),
    );
    final metadata = MetadataService();
    repository = LibraryRepository(
      storageService: LibraryStorageService(db),
      scanLibrary: ScanLibrary(
        fileScanService: FileScanService(),
        metadataService: metadata,
        groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
      ),
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
      resolveCoverArt: resolve,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LibraryRepository.enrichAlbumCovers', () {
    test('extracts embedded art for albums missing covers', () async {
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

      expect(reads, 1);
      expect(enriched, hasLength(1));
      switch (enriched.single) {
        case LibraryAlbumItem(:final album):
          expect(album.coverArtPath, isNotNull);
          expect(album.coverArtPath, endsWith('.jpg'));
        default:
          fail('Expected album');
      }
    });

    test('is a no-op when covers already present', () async {
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
            coverArtPath: '${tempDir.path}/cover.jpg',
          ),
        ),
      ];

      final enriched = await repository.enrichAlbumCovers(items);

      expect(identical(enriched, items), isTrue);
      expect(reads, 0);
    });
  });

}

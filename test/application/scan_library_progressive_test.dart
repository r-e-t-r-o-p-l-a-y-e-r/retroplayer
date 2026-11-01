/// ScanLibrary streams placeholders first, then fills tags and albums.
///
/// Evidence:
/// - `first update is filename placeholders with no tag reads`
/// - `later updates replace placeholders and form album rows`
/// - `no duplicate item ids`
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';

class _GatedMetadata implements TrackMetadataReader {
  _GatedMetadata(this.tags);

  final Map<String, TrackMetadata> tags;
  final gate = Completer<void>();
  final started = Completer<void>();
  int reads = 0;

  @override
  Future<TrackMetadata> readMetadata(String filePath) async {
    reads++;
    if (!started.isCompleted) started.complete();
    await gate.future;
    return tags[p.basename(filePath)] ??
        TrackMetadata(title: p.basenameWithoutExtension(filePath));
  }
}

void main() {
  late Directory tempDir;
  late _GatedMetadata metadata;
  late ScanLibrary scanner;
  late String fileA;
  late String fileB;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scan_progressive_');
    fileA = p.join(tempDir.path, 'a.mp3');
    fileB = p.join(tempDir.path, 'b.mp3');
    await File(fileA).writeAsBytes([0, 1, 2]);
    await File(fileB).writeAsBytes([0, 1, 2]);
    metadata = _GatedMetadata({
      'a.mp3': const TrackMetadata(title: 'One', album: 'Book', trackNumber: 1),
      'b.mp3': const TrackMetadata(title: 'Two', album: 'Book', trackNumber: 2),
    });
    scanner = ScanLibrary(
      fileScanService: FileScanService(),
      metadataService: metadata,
      groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
    );
  });

  tearDown(() async {
    if (!metadata.gate.isCompleted) metadata.gate.complete();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('first update is a placeholder album with no tag reads', () async {
    late final StreamSubscription<DirectoryListingUpdate> sub;
    final first = Completer<DirectoryListingUpdate>();
    sub = scanner.watchDirectoryShallow(tempDir.path).listen((update) {
      if (!first.isCompleted) first.complete(update);
      sub.pause();
    });
    addTearDown(sub.cancel);

    final update = await first.future.timeout(const Duration(seconds: 2));
    expect(update.isComplete, isFalse);
    expect(update.scannedFileCount, 0);
    expect(update.totalFileCount, 2);
    expect(update.items, hasLength(1));
    expect(update.items.single, isA<LibraryAlbumItem>());
    final album = (update.items.single as LibraryAlbumItem).album;
    expect(album.tracks, hasLength(2));
    expect(album.tracks.map((track) => track.displayTitle).toSet(), {'a', 'b'});
    expect(metadata.reads, 0);
  });

  test('later updates replace placeholders and form album rows', () async {
    final updates = <DirectoryListingUpdate>[];
    final done = Completer<void>();
    final sub = scanner
        .watchDirectoryShallow(tempDir.path)
        .listen(updates.add, onDone: done.complete);
    addTearDown(sub.cancel);

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(updates, isNotEmpty);
    expect(updates.first.items, hasLength(1));
    expect(updates.first.items.single, isA<LibraryAlbumItem>());

    metadata.gate.complete();
    await done.future.timeout(const Duration(seconds: 2));

    final last = updates.last;
    expect(last.isComplete, isTrue);
    expect(last.scannedFileCount, 2);
    expect(last.items, hasLength(1));
    expect(last.items.single, isA<LibraryAlbumItem>());
    final album = (last.items.single as LibraryAlbumItem).album;
    expect(album.title, 'Book');
    expect(album.tracks, hasLength(2));
    expect(
      last.items.map((item) => item.id).toSet(),
      hasLength(last.items.length),
    );
  });

  test(
    'pending files join the forming album instead of sitting beside it',
    () async {
      late final StreamSubscription<DirectoryListingUpdate> sub;
      final first = Completer<DirectoryListingUpdate>();
      final mid = Completer<DirectoryListingUpdate>();
      sub = scanner.watchDirectoryShallow(tempDir.path).listen((update) {
        if (!first.isCompleted) {
          first.complete(update);
          return;
        }
        if (!mid.isCompleted && !update.isComplete) {
          mid.complete(update);
        }
      });
      addTearDown(sub.cancel);

      await first.future.timeout(const Duration(seconds: 2));
      // Let the 100ms emit interval elapse while the first tag read is gated,
      // so the next yield is the incomplete album (still holding the pending file).
      await Future<void>.delayed(const Duration(milliseconds: 120));
      metadata.gate.complete();

      final update = await mid.future.timeout(const Duration(seconds: 2));
      expect(update.isComplete, isFalse);
      expect(update.items.whereType<LibraryTrackItem>(), isEmpty);
      expect(update.items.whereType<LibraryAlbumItem>(), hasLength(1));
      final album = (update.items.single as LibraryAlbumItem).album;
      expect(album.title, 'Book');
      expect(album.tracks, hasLength(2));
    },
  );
}

/// Progressive directory listing: placeholders, per-file fill-in, cancel.
///
/// Evidence:
/// - `placeholders appear immediately from a fake scanner`
/// - `rows update one by one and albums form without duplicates`
/// - `keyboard selection follows the item across listing updates`
/// - `navigating away cancels the scan`
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/track_factory.dart';

class _ControllableScanner implements LibraryScanner {
  StreamController<DirectoryListingUpdate>? active;
  bool cancelled = false;
  int watchCount = 0;

  @override
  Stream<DirectoryListingUpdate> watchDirectoryShallow(String directoryPath) {
    watchCount++;
    cancelled = false;
    final controller = StreamController<DirectoryListingUpdate>(
      onCancel: () => cancelled = true,
    );
    active = controller;
    return controller.stream;
  }

  @override
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath) async {
    throw UnimplementedError();
  }

  @override
  Future<List<AudioTrack>> scanDirectoryRecursive(String rootPath) async =>
      const [];

  @override
  Future<AudioTrack> trackFromPath(String filePath) async {
    throw UnimplementedError();
  }

  void emit(DirectoryListingUpdate update) => active!.add(update);

  Future<void> close() async {
    await active?.close();
  }
}

AudioTrack _track(String name, {String? title, String? album, int? number}) {
  return testTrack(
    filePath: '/music/$name.mp3',
    directoryPath: '/music',
    metadata: TrackMetadata(
      title: title ?? name,
      album: album,
      trackNumber: number,
    ),
  );
}

void main() {
  late AppDatabase db;
  late _ControllableScanner scanner;
  late LibraryRepository repository;
  late LibraryViewModel viewModel;

  setUp(() async {
    db = AppDatabase.inMemory();
    scanner = _ControllableScanner();
    repository = LibraryRepository(
      storageService: LibraryStorageService(db),
      scanLibrary: scanner,
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
    );
    repository.seedChildFolders('/music', const []);
    await repository.addLibraryRoot('/music');
    viewModel = LibraryViewModel(libraryRepository: repository);
  });

  tearDown(() async {
    await scanner.close();
    viewModel.dispose();
    await db.close();
  });

  Future<void> openFolder() async {
    await viewModel.browseInto('/music');
    await Future<void>.delayed(Duration.zero);
    expect(scanner.active, isNotNull);
  }

  test('placeholders appear immediately from a fake scanner', () async {
    await openFolder();
    expect(viewModel.items, isEmpty);

    final a = _track('a');
    scanner.emit(
      DirectoryListingUpdate(
        items: [LibraryItem.track(track: a)],
        scannedFileCount: 0,
        totalFileCount: 2,
        isComplete: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.items, hasLength(1));
    expect(viewModel.items.single.title, 'a');
    expect(viewModel.isLoadingDirectoryItems, isFalse);
  });

  test('rows update one by one and albums form without duplicates', () async {
    await openFolder();
    final placeholderA = _track('a');
    final placeholderB = _track('b');
    scanner.emit(
      DirectoryListingUpdate(
        items: [
          LibraryItem.track(track: placeholderA),
          LibraryItem.track(track: placeholderB),
        ],
        scannedFileCount: 0,
        totalFileCount: 2,
        isComplete: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.items.map((item) => item.id).toSet(), hasLength(2));

    final taggedA = _track('a', title: 'One', album: 'Book', number: 1);
    scanner.emit(
      DirectoryListingUpdate(
        items: [
          LibraryItem.album(
            album: AudioAlbum(
              id: 'tag:/music::book',
              title: 'Book',
              tracks: [taggedA, placeholderB],
              source: AlbumSource.tag,
              groupingKey: 'tag:/music::book',
            ),
          ),
        ],
        scannedFileCount: 1,
        totalFileCount: 2,
        isComplete: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.items, hasLength(1));
    expect(viewModel.items.single, isA<LibraryAlbumItem>());
    expect(
      (viewModel.items.single as LibraryAlbumItem).album.tracks,
      hasLength(2),
    );

    final taggedB = _track('b', title: 'Two', album: 'Book', number: 2);
    scanner.emit(
      DirectoryListingUpdate(
        items: [
          LibraryItem.album(
            album: AudioAlbum(
              id: 'tag:/music::book',
              title: 'Book',
              tracks: [taggedA, taggedB],
              source: AlbumSource.tag,
              groupingKey: 'tag:/music::book',
            ),
          ),
        ],
        scannedFileCount: 2,
        totalFileCount: 2,
        isComplete: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.items, hasLength(1));
    expect(viewModel.items.single, isA<LibraryAlbumItem>());
    expect(
      (viewModel.items.single as LibraryAlbumItem).album.tracks,
      hasLength(2),
    );
  });

  test('keyboard selection follows the item across listing updates', () async {
    await openFolder();
    final a = _track('a');
    final b = _track('b');
    scanner.emit(
      DirectoryListingUpdate(
        items: [
          LibraryItem.track(track: a),
          LibraryItem.track(track: b),
        ],
        scannedFileCount: 0,
        totalFileCount: 2,
        isComplete: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final bIndex = viewModel.selectableRows.indexWhere(
      (row) => row.item?.id == b.id,
    );
    viewModel.selectKeyboardRowAt(bIndex);
    expect(viewModel.keyboardSelectedIndex, bIndex);

    scanner.emit(
      DirectoryListingUpdate(
        items: [
          LibraryItem.track(track: b),
          LibraryItem.track(track: a),
        ],
        scannedFileCount: 1,
        totalFileCount: 2,
        isComplete: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final selected = viewModel.selectableRows[viewModel.keyboardSelectedIndex!];
    expect(selected.item?.id, b.id);
  });

  test('navigating away cancels the scan', () async {
    await openFolder();
    expect(scanner.watchCount, 1);
    await viewModel.navigateToBrowsePath(null);
    expect(scanner.cancelled, isTrue);
  });
}

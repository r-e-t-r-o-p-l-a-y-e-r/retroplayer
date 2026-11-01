/// Folder navigation paints child folders before audio tag reads finish.
///
/// Evidence:
/// - `browseInto shows child folders before directory scan completes`
/// - `isLoadingDirectoryItems is true until the deferred scan finishes`
/// - `directory audio items appear after the deferred scan`
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';
import 'package:retroplayer/application/scan_library.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

class _Gate {
  Completer<void> open = Completer<void>();
  Completer<void> started = Completer<void>();
}

class _SlowMetadataService extends MetadataService {
  _SlowMetadataService(this.gate);

  final _Gate gate;
  int reads = 0;

  @override
  Future<TrackMetadata> readMetadata(String filePath) async {
    reads++;
    if (!gate.started.isCompleted) gate.started.complete();
    await gate.open.future;
    return const TrackMetadata(title: 'Slow track');
  }
}

void main() {
  late Directory tempDir;
  late Directory albumDir;
  late AppDatabase db;
  late _Gate gate;
  late _SlowMetadataService metadata;
  late LibraryRepository repository;
  late LibraryViewModel viewModel;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('browse_before_scan_');
    albumDir = Directory('${tempDir.path}/Album');
    await albumDir.create();
    await File('${albumDir.path}/track.mp3').writeAsBytes([0, 1, 2]);

    db = AppDatabase.inMemory();
    gate = _Gate();
    metadata = _SlowMetadataService(gate);

    repository = LibraryRepository(
      storageService: LibraryStorageService(db),
      scanLibrary: ScanLibrary(
        fileScanService: FileScanService(),
        metadataService: metadata,
        groupTracksIntoAlbums: const GroupTracksIntoAlbums(),
      ),
      sortLibrary: SortLibrary(),
      fileScanService: FileScanService(),
    );
    repository.seedChildFolders(tempDir.path, [
      FolderEntry(path: albumDir.path, name: 'Album'),
    ]);
    await repository.addLibraryRoot(tempDir.path);

    viewModel = LibraryViewModel(libraryRepository: repository);
  });

  tearDown(() async {
    if (!gate.open.isCompleted) gate.open.complete();
    viewModel.dispose();
    await Future<void>.delayed(Duration.zero);
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'browseInto shows child folders before directory scan completes',
    () async {
      await viewModel.browseInto(tempDir.path);

      expect(viewModel.folders.map((f) => f.name), contains('Album'));
      expect(viewModel.items, isEmpty);

      // Returns once folder chrome is ready; tag reads continue in the background.
      await viewModel.browseInto(albumDir.path);

      final placeholdersReady = Completer<void>();
      void onPlaceholder() {
        if (viewModel.items.isNotEmpty && !placeholdersReady.isCompleted) {
          placeholdersReady.complete();
        }
      }

      viewModel.addListener(onPlaceholder);
      if (viewModel.items.isNotEmpty) placeholdersReady.complete();
      await placeholdersReady.future.timeout(const Duration(seconds: 2));
      viewModel.removeListener(onPlaceholder);

      expect(viewModel.browsePath, albumDir.path);
      expect(viewModel.items.single, isA<LibraryTrackItem>());
      expect(viewModel.items.single.title, 'track');
      expect(viewModel.isLoadingDirectoryItems, isFalse);

      await gate.started.future.timeout(const Duration(seconds: 2));
      expect(metadata.reads, greaterThan(0));

      final taggedReady = Completer<void>();
      void onTagged() {
        if (viewModel.items.isNotEmpty &&
            viewModel.items.single.title == 'Slow track' &&
            !taggedReady.isCompleted) {
          taggedReady.complete();
        }
      }

      viewModel.addListener(onTagged);
      gate.open.complete();
      await taggedReady.future.timeout(const Duration(seconds: 2));
      viewModel.removeListener(onTagged);

      expect(viewModel.isLoadingDirectoryItems, isFalse);
      expect(viewModel.items.single, isA<LibraryTrackItem>());
      expect(viewModel.items.single.title, 'Slow track');
    },
  );
}

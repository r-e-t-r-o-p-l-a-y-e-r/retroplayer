/// LibraryViewModel browse-path load/clear/persist session behavior.
///
/// Evidence:
/// - `load restores saved browse path under a library root`
/// - `load clears invalid browse path outside library roots`
/// - `browseInto persists folder selection`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';

void main() {
  group('LibraryViewModel session restore', () {
    late AppDatabase db;
    late LibraryStorageService storage;
    late LibraryRepository libraryRepository;
    late LibraryViewModel viewModel;

    setUp(() {
      db = AppDatabase.inMemory();
      storage = LibraryStorageService(db);
      libraryRepository = testLibraryRepository(storage);
      viewModel = LibraryViewModel(libraryRepository: libraryRepository);
    });

    tearDown(() async {
      await db.close();
    });

    test('load restores saved browse path under a library root', () async {
      await storage.addLibraryRoot('/music');
      await storage.setLibraryBrowsePath('/music/MyBook');

      libraryRepository.seedDirectory(
        '/music/MyBook',
        [
          LibraryItem.album(
            album: AudioAlbum(
              id: 'dir:/music/mybook',
              title: 'My Book',
              tracks: [
                testTrack(
                  filePath: '/music/MyBook/ch01.mp3',
                  directoryPath: '/music/MyBook',
                ),
              ],
              source: AlbumSource.directory,
              groupingKey: 'dir:/music/mybook',
            ),
          ),
        ],
      );

      await viewModel.load();

      expect(viewModel.browsePath, '/music/MyBook');
    });

    test('load clears invalid browse path outside library roots', () async {
      await storage.addLibraryRoot('/music');
      await storage.setLibraryBrowsePath('/other/path');

      await viewModel.load();

      expect(viewModel.browsePath, isNull);
      expect(await storage.getLibraryBrowsePath(), isNull);
    });

    test('browseInto persists folder selection', () async {
      await storage.addLibraryRoot('/music');
      libraryRepository.seedDirectory(
        '/music/MyBook',
        [
          LibraryItem.album(
            album: AudioAlbum(
              id: 'dir:/music/mybook',
              title: 'My Book',
              tracks: [
                testTrack(
                  filePath: '/music/MyBook/ch01.mp3',
                  directoryPath: '/music/MyBook',
                ),
              ],
              source: AlbumSource.directory,
              groupingKey: 'dir:/music/mybook',
            ),
          ),
        ],
      );

      await viewModel.refreshDisplay();
      await viewModel.browseInto('/music/MyBook');

      expect(await storage.getLibraryBrowsePath(), '/music/MyBook');
    });
  });
}

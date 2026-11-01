/// BrowseLibrary folder listing and parent navigation semantics.
///
/// Evidence:
/// - `root level lists library sources only with no audio items`
/// - `shows child folders supplied for the current path`
/// - `shows directory items at the current path`
/// - `parent at library root goes back to null browse path`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import '../../helpers/track_factory.dart';

void main() {
  late BrowseLibrary browseLibrary;

  setUp(() {
    browseLibrary = BrowseLibrary();
  });

  group('BrowseLibrary', () {
    test('root level lists library sources only with no audio items', () {
      final result = browseLibrary(
        currentPath: null,
        libraryRoots: ['/music', '/audiobooks'],
        directoryItems: const [],
        childFolders: const [],
      );

      expect(result.title, isNull);
      expect(result.canGoUp, isFalse);
      expect(result.folders.map((f) => f.path), ['/music', '/audiobooks']);
      expect(result.items, isEmpty);
    });

    test('shows child folders supplied for the current path', () {
      final atMusic = browseLibrary(
        currentPath: '/music',
        libraryRoots: ['/music'],
        directoryItems: const [],
        childFolders: const [
          FolderEntry(path: '/music/Author', name: 'Author'),
        ],
      );

      expect(atMusic.folders.map((f) => f.name), ['Author']);
      expect(atMusic.items, isEmpty);

      final atAuthor = browseLibrary(
        currentPath: '/music/Author',
        libraryRoots: ['/music'],
        directoryItems: const [],
        childFolders: const [
          FolderEntry(path: '/music/Author/Book1', name: 'Book1'),
        ],
      );

      expect(atAuthor.folders.map((f) => f.name), ['Book1']);
      expect(atAuthor.items, isEmpty);
    });

    test('shows directory items at the current path', () {
      final album = LibraryItem.album(
        album: AudioAlbum(
          id: 'dir:/music/author/book1',
          title: 'Book One',
          tracks: [
            testTrack(
              filePath: '/music/Author/Book1/ch01.mp3',
              directoryPath: '/music/Author/Book1',
            ),
            testTrack(
              filePath: '/music/Author/Book1/ch02.mp3',
              directoryPath: '/music/Author/Book1',
            ),
          ],
          source: AlbumSource.directory,
          groupingKey: 'dir:/music/author/book1',
        ),
      );
      final loose = LibraryItem.track(
        track: testTrack(
          filePath: '/music/Author/loose.mp3',
          directoryPath: '/music/Author',
        ),
      );

      final atBook1 = browseLibrary(
        currentPath: '/music/Author/Book1',
        libraryRoots: ['/music'],
        directoryItems: [album],
        childFolders: const [],
      );

      expect(atBook1.folders, isEmpty);
      expect(atBook1.items, hasLength(1));
      expect(atBook1.items.single, isA<LibraryAlbumItem>());

      final atAuthor = browseLibrary(
        currentPath: '/music/Author',
        libraryRoots: ['/music'],
        directoryItems: [loose],
        childFolders: const [
          FolderEntry(path: '/music/Author/Book1', name: 'Book1'),
        ],
      );

      expect(atAuthor.folders.map((f) => f.name), ['Book1']);
      expect(atAuthor.items, hasLength(1));
      expect(atAuthor.items.single, isA<LibraryTrackItem>());
    });

    test('parent at library root goes back to null browse path', () {
      final result = browseLibrary(
        currentPath: '/music',
        libraryRoots: ['/music'],
        directoryItems: const [],
        childFolders: const [],
      );

      expect(result.parentPath, isNull);
      expect(result.canGoUp, isTrue);
    });
  });
}

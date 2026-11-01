import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';

import 'track_factory.dart';

/// Seeds the Author/Book1 hierarchy used by library browse and tree tests.
void seedAuthorBook1Hierarchy(LibraryRepository repository) {
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

  repository.seedChildFolders('/music', [
    const FolderEntry(path: '/music/Author', name: 'Author'),
  ]);
  repository.seedChildFolders('/music/Author', [
    const FolderEntry(path: '/music/Author/Book1', name: 'Book1'),
  ]);
  repository.seedChildFolders('/music/Author/Book1', const []);
  repository.seedDirectory('/music', const []);
  repository.seedDirectory('/music/Author', const []);
  repository.seedDirectory('/music/Author/Book1', [album]);
}

/// Seeds folder hierarchy for player breadcrumb tests.
void seedPlayerBreadcrumbHierarchy(
  LibraryRepository repository,
  AudioAlbum album,
) {
  repository.seedChildFolders('/music', [
    const FolderEntry(path: '/music/Author', name: 'Author'),
  ]);
  repository.seedChildFolders('/music/Author', [
    const FolderEntry(path: '/music/Author/Book1', name: 'Book1'),
  ]);
  repository.seedChildFolders('/music/Author/Book1', const []);
  repository.seedDirectory('/music', const []);
  repository.seedDirectory('/music/Author', const []);
  repository.seedDirectory('/music/Author/Book1', [
    LibraryItem.album(album: album),
  ]);
}

/// Seeds a single album folder for MyBook-style tests.
void seedMyBookDirectory(LibraryRepository repository, AudioAlbum album) {
  repository.seedChildFolders('/music', [
    const FolderEntry(path: '/music/MyBook', name: 'MyBook'),
  ]);
  repository.seedChildFolders('/music/MyBook', const []);
  repository.seedDirectory('/music', const []);
  repository.seedDirectory('/music/MyBook', [LibraryItem.album(album: album)]);
}

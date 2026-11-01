/// buildFolderSelectableRows delete affordances for roots vs nested folders.
///
/// Evidence:
/// - `buildFolderSelectableRows tags roots and playlists for delete`
/// - `buildFolderSelectableRows disables root delete inside subfolders`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_library_row.dart';

void main() {
  test('buildFolderSelectableRows tags roots and playlists for delete', () {
    final playlist = PlaylistFile(
      filePath: '/music/a.m3u',
      entryPaths: const [],
    );
    final rows = buildFolderSelectableRows(
      folders: const [FolderEntry(path: '/music', name: 'music')],
      playlistItems: [LibraryItem.playlist(playlist: playlist)],
      audioItems: const [],
      atLibraryRoot: true,
      deletablePlaylistPaths: {normalizeLibraryPath('/music/a.m3u')},
    );

    expect(rows, hasLength(2));
    expect(rows[0].deleteAction, KeyboardDeleteAction.removeLibraryRoot);
    expect(rows[1].deleteAction, KeyboardDeleteAction.deletePlaylist);
  });

  test('buildFolderSelectableRows disables root delete inside subfolders', () {
    final rows = buildFolderSelectableRows(
      folders: const [FolderEntry(path: '/music/sub', name: 'sub')],
      playlistItems: const [],
      audioItems: const [],
      atLibraryRoot: false,
      deletablePlaylistPaths: const {},
    );

    expect(rows.single.deleteAction, KeyboardDeleteAction.none);
  });
}

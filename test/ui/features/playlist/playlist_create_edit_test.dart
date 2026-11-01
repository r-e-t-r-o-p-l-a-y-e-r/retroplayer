/// UC-08: create, edit and delete app-created playlists through the library.
///
/// Evidence:
/// - `create in current folder lists it as an app-created playlist`
/// - `saving entries rewrites the m3u file`
/// - `delete removes app-created playlists, disk playlists stay`
/// - `saving a disk playlist is refused and leaves the file untouched`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/test_library_repository.dart';

void main() {
  late Directory temp;
  late String root;
  late AppDatabase db;
  late LibraryViewModel vm;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('retroplayer_playlists_');
    root = normalizeLibraryPath(temp.path);
    db = AppDatabase.inMemory();
    final storage = LibraryStorageService(db);
    await storage.addLibraryRoot(root);
    vm = LibraryViewModel(libraryRepository: testLibraryRepository(storage));
    await vm.load();
    await vm.browseInto(root);
  });

  tearDown(() async {
    vm.dispose();
    await db.close();
    await temp.delete(recursive: true);
  });

  List<String> listedPlaylists() => [
        for (final item in vm.items)
          if (item case LibraryPlaylistItem(:final playlist)) playlist.filePath,
      ];

  test('create in current folder lists it as an app-created playlist',
      () async {
    final playlist = await vm.createPlaylistInCurrentFolder('Road trip');

    expect(p.basename(playlist.filePath), 'Road trip.m3u');
    expect(await File(playlist.filePath).exists(), isTrue);
    expect(listedPlaylists(), contains(playlist.filePath));
    expect(vm.isAppCreatedPlaylist(playlist.filePath), isTrue);
  });

  test('saving entries rewrites the m3u file', () async {
    final playlist = await vm.createPlaylistInCurrentFolder('mix');
    final a = p.join(root, 'a.mp3');
    final b = p.join(root, 'b.mp3');

    final saved = await vm.savePlaylistEntries(
      playlistPath: playlist.filePath,
      absoluteEntryPaths: [b, a],
    );

    expect(saved.entryPaths, [b, a]);
    final content = await File(playlist.filePath).readAsString();
    expect(content.indexOf('b.mp3'), lessThan(content.indexOf('a.mp3')));
  });

  test('delete removes app-created playlists, disk playlists stay', () async {
    final diskPath = p.join(root, 'found.m3u');
    await File(diskPath).writeAsString('#EXTM3U\n');
    final own = await vm.createPlaylistInCurrentFolder('own');

    expect(vm.isAppCreatedPlaylist(diskPath), isFalse);
    await vm.deletePlaylist(diskPath);
    expect(await File(diskPath).exists(), isTrue);

    await vm.deletePlaylist(own.filePath);
    expect(await File(own.filePath).exists(), isFalse);
    expect(vm.isAppCreatedPlaylist(own.filePath), isFalse);
    expect(await File(diskPath).exists(), isTrue);
  });

  test('saving a disk playlist is refused and leaves the file untouched',
      () async {
    final diskPath = p.join(root, 'found.m3u');
    const original = '#EXTM3U\nsong.mp3\n';
    await File(diskPath).writeAsString(original);

    await expectLater(
      vm.savePlaylistEntries(
        playlistPath: diskPath,
        absoluteEntryPaths: [p.join(root, 'other.mp3')],
      ),
      throwsStateError,
    );
    expect(await File(diskPath).readAsString(), original);
  });
}

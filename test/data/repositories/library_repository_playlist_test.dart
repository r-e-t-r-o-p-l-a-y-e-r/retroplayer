/// LibraryRepository create/delete guards for app-created playlists only.
///
/// Evidence:
/// - `deletePlaylist removes only app-created m3u files`
/// - `createPlaylist marks playlist as app-created`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';

import '../../helpers/test_library_repository.dart';

void main() {
  test('deletePlaylist removes only app-created m3u files', () async {
    final temp = await Directory.systemTemp.createTemp('retroplayer_playlist_');
    addTearDown(() => temp.delete(recursive: true));

    final playlistPath = normalizeLibraryPath(p.join(temp.path, 'test.m3u'));
    await File(playlistPath).writeAsString('#EXTM3U\n');

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await repo.addLibraryRoot(temp.path);

    expect(
      () => repo.deletePlaylist(playlistPath),
      throwsA(isA<StateError>()),
    );
    expect(await File(playlistPath).exists(), isTrue);

    await storage.markAppCreatedPlaylist(playlistPath);
    await repo.deletePlaylist(playlistPath);

    expect(await File(playlistPath).exists(), isFalse);
    expect(await storage.isAppCreatedPlaylist(playlistPath), isFalse);
  });

  test('createPlaylist marks playlist as app-created', () async {
    final temp = await Directory.systemTemp.createTemp('retroplayer_playlist_');
    addTearDown(() => temp.delete(recursive: true));

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await repo.addLibraryRoot(temp.path);

    final playlist = await repo.createPlaylist(
      directory: temp.path,
      name: 'road trip',
    );

    expect(await storage.isAppCreatedPlaylist(playlist.filePath), isTrue);
    expect(await File(playlist.filePath).exists(), isTrue);
  });
}

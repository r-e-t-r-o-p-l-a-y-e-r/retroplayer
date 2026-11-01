/// AppDatabase migrations through v3.
///
/// Evidence:
/// - `v1 database with sort_orders and manual sort opens`
/// - `v2 database drops browse mode and sort mode settings`
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('retro_migration_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('v1 database with sort_orders and manual sort opens', () async {
    final file = File('${tempDir.path}/app.sqlite');

    // Create the current tables, then rewind the file to look like v1.
    final fresh = AppDatabase(NativeDatabase(file));
    await LibraryStorageService(fresh).addLibraryRoot('/music');
    await fresh.close();

    final v1 = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          if (raw.userVersion != 3) return;
          raw.execute(
            'CREATE TABLE sort_orders (scope TEXT NOT NULL, item_id TEXT '
            'NOT NULL, position INTEGER NOT NULL, PRIMARY KEY (scope, item_id))',
          );
          raw.execute("INSERT INTO sort_orders VALUES ('library', 'a', 0)");
          raw.execute('CREATE TABLE albums (id TEXT PRIMARY KEY)');
          raw.execute('CREATE TABLE tracks (id TEXT PRIMARY KEY)');
          raw.execute(
            "INSERT INTO app_settings VALUES ('default_sort_mode', 'manual')",
          );
          raw.execute(
            "INSERT INTO app_settings VALUES ('last_main_tab', '/player')",
          );
          raw.execute(
            "INSERT INTO app_settings VALUES ('library_browse_mode', 'tree')",
          );
          raw.userVersion = 1;
        },
      ),
    );
    addTearDown(v1.close);

    final storage = LibraryStorageService(v1);
    expect(await storage.getLibraryRoots(), ['/music']);

    final tables = await v1
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name IN ('sort_orders', 'albums', 'tracks')",
        )
        .get();
    expect(tables, isEmpty);

    final settings = await v1
        .customSelect('SELECT key FROM app_settings')
        .map((row) => row.read<String>('key'))
        .get();
    expect(settings, isNot(contains('last_main_tab')));
    expect(settings, isNot(contains('default_sort_mode')));
    expect(settings, isNot(contains('library_browse_mode')));
  });

  test('v2 database drops browse mode and sort mode settings', () async {
    final file = File('${tempDir.path}/v2.sqlite');

    final fresh = AppDatabase(NativeDatabase(file));
    await LibraryStorageService(fresh).addLibraryRoot('/music');
    await fresh.close();

    final v2 = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          if (raw.userVersion != 3) return;
          raw.execute(
            "INSERT INTO app_settings VALUES ('library_browse_mode', 'tree')",
          );
          raw.execute(
            "INSERT INTO app_settings VALUES ('default_sort_mode', 'artist')",
          );
          raw.userVersion = 2;
        },
      ),
    );
    addTearDown(v2.close);

    final storage = LibraryStorageService(v2);
    expect(await storage.getLibraryRoots(), ['/music']);

    final settings = await v2
        .customSelect('SELECT key FROM app_settings')
        .map((row) => row.read<String>('key'))
        .get();
    expect(settings, isNot(contains('library_browse_mode')));
    expect(settings, isNot(contains('default_sort_mode')));
  });
}

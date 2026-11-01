import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:retroplayer/data/db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LibraryRoots, PlaybackStates, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  static AppDatabase inMemory() => AppDatabase(NativeDatabase.memory());

  /// Opens a file-backed database at [path] (for CLI persistence harness).
  static AppDatabase openAtPath(String path) {
    return AppDatabase(NativeDatabase(File(path)));
  }
}

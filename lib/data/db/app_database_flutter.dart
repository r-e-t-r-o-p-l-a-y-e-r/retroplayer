import 'dart:io';

import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/app_data_paths.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens the app database in the platform app-support directory.
Future<AppDatabase> openAppDatabase() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }
  final path = await AppDataPaths.databaseFile();
  return AppDatabase.openAtPath(path);
}

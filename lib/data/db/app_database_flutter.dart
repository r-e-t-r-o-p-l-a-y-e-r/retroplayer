import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/app_data_paths.dart';

/// Opens the app database in the platform app-support directory.
Future<AppDatabase> openAppDatabase() async {
  final path = await AppDataPaths.databaseFile();
  return AppDatabase.openAtPath(path);
}

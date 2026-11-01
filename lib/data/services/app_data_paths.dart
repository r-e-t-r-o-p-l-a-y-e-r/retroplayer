import 'package:path_provider/path_provider.dart';
import 'package:retroplayer/data/db/database_path.dart';

/// Resolves on-disk locations for app-internal persisted data.
abstract final class AppDataPaths {
  static Future<String> applicationSupportDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  static Future<String> databaseFile() async {
    final dir = await applicationSupportDirectory();
    return databaseFilePathFromDirectory(dir);
  }
}

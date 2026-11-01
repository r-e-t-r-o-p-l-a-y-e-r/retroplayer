import 'package:path/path.dart' as p;
import 'package:retroplayer/app_branding.dart';

/// Resolves the on-disk path for the app SQLite database.
String databaseFilePathFromDirectory(String directoryPath) =>
    databaseFilePath(directoryPath);

/// Resolves the on-disk path for the app SQLite database.
String databaseFilePath(String directoryPath) =>
    p.join(directoryPath, AppBranding.databaseFileName);

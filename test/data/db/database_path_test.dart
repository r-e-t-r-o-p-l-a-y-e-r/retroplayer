/// AppBranding identifiers and SQLite database path joining.
///
/// Evidence:
/// - `uses Retro Player identifiers`
/// - `joins directory with database filename`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/app_branding.dart';
import 'package:retroplayer/data/db/database_path.dart';

void main() {
  group('AppBranding', () {
    test('uses Retro Player identifiers', () {
      expect(AppBranding.displayName, 'Retro Player');
      expect(AppBranding.applicationId, 'app.retroplayer');
      expect(AppBranding.notificationChannelId, 'app.retroplayer');
      expect(AppBranding.databaseFileName, 'retroplayer.db');
    });
  });

  group('databaseFilePath', () {
    test('joins directory with database filename', () {
      expect(
        databaseFilePath('/tmp/app-data'),
        '/tmp/app-data/retroplayer.db',
      );
    });
  });
}

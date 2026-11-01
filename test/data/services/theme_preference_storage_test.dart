/// Theme preference default and persistence.
///
/// Evidence:
/// - `getThemePreference defaults to system`
/// - `setThemePreference persists choice`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getThemePreference defaults to system', () async {
    expect(await storage.getThemePreference(), ThemePreference.system);
  });

  test('setThemePreference persists choice', () async {
    await storage.setThemePreference(ThemePreference.dark);
    expect(await storage.getThemePreference(), ThemePreference.dark);

    await storage.setThemePreference(ThemePreference.light);
    expect(await storage.getThemePreference(), ThemePreference.light);
  });
}

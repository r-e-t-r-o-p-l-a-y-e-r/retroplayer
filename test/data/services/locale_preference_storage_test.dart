/// Locale preference default and persistence.
///
/// Evidence:
/// - `getLocalePreference defaults to system`
/// - `setLocalePreference persists choice`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';

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

  test('getLocalePreference defaults to system', () async {
    expect(await storage.getLocalePreference(), LocalePreference.system);
  });

  test('setLocalePreference persists choice', () async {
    await storage.setLocalePreference(LocalePreference.language('de'));
    expect(
      await storage.getLocalePreference(),
      LocalePreference.language('de'),
    );

    await storage.setLocalePreference(LocalePreference.language('en'));
    expect(
      await storage.getLocalePreference(),
      LocalePreference.language('en'),
    );
  });

  test('setLocalePreference persists language code', () async {
    await storage.setLocalePreference(LocalePreference.language('fr'));
    expect(
      await storage.getLocalePreference(),
      LocalePreference.language('fr'),
    );
  });
}

/// UC-16: theme and language preferences apply immediately and persist.
///
/// Evidence:
/// - `theme preference loads, applies and persists`
/// - `locale preference loads, applies and persists`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/domain/models/theme_preference.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
  });

  tearDown(() => db.close());

  test('theme preference loads, applies and persists', () async {
    final vm = ThemeViewModel(storageService: storage);
    await vm.load();
    expect(vm.preference, ThemePreference.system);
    expect(vm.themeMode, ThemeMode.system);

    var notified = 0;
    vm.addListener(() => notified++);
    await vm.setPreference(ThemePreference.dark);
    expect(vm.themeMode, ThemeMode.dark);
    expect(notified, 1);

    await vm.setPreference(ThemePreference.dark);
    expect(notified, 1, reason: 'same value does not notify');

    final reloaded = ThemeViewModel(storageService: storage);
    await reloaded.load();
    expect(reloaded.preference, ThemePreference.dark);
  });

  test('locale preference loads, applies and persists', () async {
    final vm = LocaleViewModel(storageService: storage);
    await vm.load();
    expect(vm.locale, isNull, reason: 'system locale');

    await vm.setPreference(LocalePreference.language('de'));
    expect(vm.locale, const Locale('de'));

    final reloaded = LocaleViewModel(storageService: storage);
    await reloaded.load();
    expect(reloaded.preference, LocalePreference.language('de'));
  });
}

/// UI session prefs in browse KV storage.
///
/// Evidence:
/// - `playerPanelExpanded defaults false when unset`
/// - `playerPanelExpanded round-trips true and false`
/// - `settingsOverlayOpen defaults false when unset`
/// - `settingsOverlayOpen round-trips true and clear on false`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
  });

  tearDown(() async => db.close());

  test('playerPanelExpanded defaults false when unset', () async {
    expect(await storage.getPlayerPanelExpanded(), isFalse);
  });

  test('playerPanelExpanded round-trips true and false', () async {
    await storage.setPlayerPanelExpanded(true);
    expect(await storage.getPlayerPanelExpanded(), isTrue);
    await storage.setPlayerPanelExpanded(false);
    expect(await storage.getPlayerPanelExpanded(), isFalse);
  });

  test('settingsOverlayOpen defaults false when unset', () async {
    expect(await storage.getSettingsOverlayOpen(), isFalse);
  });

  test('settingsOverlayOpen round-trips true and clear on false', () async {
    await storage.setSettingsOverlayOpen(true);
    expect(await storage.getSettingsOverlayOpen(), isTrue);
    await storage.setSettingsOverlayOpen(false);
    expect(await storage.getSettingsOverlayOpen(), isFalse);
  });
}

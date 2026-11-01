/// EqualizerSettings storage migration and band round-trip.
///
/// Evidence:
/// - `migrates legacy preset-only storage`
/// - `round-trips custom band settings`
/// - `preset mode preserves stored manual bands`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

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

  test('migrates legacy preset-only storage', () async {
    await storage.setEqualizerPreset(EqualizerPreset.bassBoost);
    final settings = await storage.getEqualizerSettings();
    expect(settings.mode, EqualizerMode.preset);
    expect(settings.preset, EqualizerPreset.bassBoost);
    expect(settings.effectiveBands().first.gainDb, greaterThan(0));
  });

  test('round-trips custom band settings', () async {
    final custom = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 3),
      ...EqualizerBand.flat().skip(1),
    ]);
    await storage.setEqualizerSettings(custom);
    final loaded = await storage.getEqualizerSettings();
    expect(loaded.mode, EqualizerMode.custom);
    expect(loaded.effectiveBands().first.gainDb, 3);
  });

  test('preset mode preserves stored manual bands', () async {
    final custom = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 4),
      ...EqualizerBand.flat().skip(1),
    ]);
    await storage.setEqualizerSettings(custom);
    await storage.setEqualizerSettings(
      EqualizerSettings.fromPreset(
        EqualizerPreset.bassBoost,
        manualBands: custom.bands,
      ),
    );

    final loaded = await storage.getEqualizerSettings();
    expect(loaded.mode, EqualizerMode.preset);
    expect(loaded.preset, EqualizerPreset.bassBoost);
    expect(loaded.bands.first.gainDb, 4);
    expect(loaded.effectiveBands().first.gainDb, greaterThan(0));
  });
}

/// EqualizerPreset storage mapping and band gain definitions.
///
/// Evidence:
/// - `fromStorage defaults to manual`
/// - `fromStorage round-trips enum names`
/// - `manual preset has flat band gains`
/// - `non-manual presets define 5 bands`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';

void main() {
  group('EqualizerPreset', () {
    test('fromStorage defaults to manual', () {
      expect(EqualizerPresetStorage.fromStorage(null), EqualizerPreset.manual);
      expect(
        EqualizerPresetStorage.fromStorage('unknown'),
        EqualizerPreset.manual,
      );
    });

    test('fromStorage round-trips enum names', () {
      for (final preset in EqualizerPreset.values) {
        expect(
          EqualizerPresetStorage.fromStorage(preset.name),
          preset,
        );
      }
    });

    test('manual preset has flat band gains', () {
      final bands = EqualizerPreset.manual.bandGains();
      expect(bands.every((b) => b.gainDb == 0), isTrue);
    });

    test('non-manual presets define 5 bands', () {
      for (final preset in EqualizerPreset.values) {
        if (preset == EqualizerPreset.manual) continue;
        expect(preset.bandGains(), hasLength(5));
      }
    });
  });
}

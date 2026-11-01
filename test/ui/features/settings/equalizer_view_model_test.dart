/// EqualizerViewModel preset/manual band restore, reset, and restart.
///
/// Evidence:
/// - `initial settings are available before load`
/// - `switching preset and back restores manual slider values`
/// - `reset returns manual sliders to flat`
/// - `restart restores manual bands while active preset is preserved`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';

class _FakeEqualizerService implements EqualizerService {
  _FakeEqualizerService(this._loaded);

  final EqualizerSettings _loaded;
  EqualizerSettings? lastSaved;

  @override
  bool get isSupported => true;

  @override
  Future<void> apply(EqualizerSettings settings) async {}

  @override
  Future<EqualizerSettings> loadSettings() async => _loaded;

  @override
  Future<void> loadAndApply() async {}

  @override
  Future<void> saveAndApply(EqualizerSettings settings) async {
    lastSaved = settings;
  }

  @override
  Future<void> reapplyLast() async {}
}

void main() {
  test('initial settings are available before load', () {
    final manual = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 5),
      ...EqualizerBand.flat().skip(1),
    ]);
    final vm = EqualizerViewModel(
      equalizerService: _FakeEqualizerService(manual),
      initialSettings: manual,
    );

    expect(vm.bands.first.gainDb, 5);
  });

  test('switching preset and back restores manual slider values', () async {
    final manual = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 5),
      ...EqualizerBand.flat().skip(1),
    ]);
    final vm = EqualizerViewModel(
      equalizerService: _FakeEqualizerService(manual),
    );

    await vm.load();
    expect(vm.bands.first.gainDb, 5);

    await vm.selectPreset(EqualizerPreset.bassBoost);
    expect(vm.selectedPreset, EqualizerPreset.bassBoost);
    expect(vm.bands.first.gainDb, greaterThan(4));

    await vm.selectPreset(EqualizerPreset.manual);
    expect(vm.selectedPreset, EqualizerPreset.manual);
    expect(vm.bands.first.gainDb, 5);
  });

  test('reset returns manual sliders to flat', () async {
    final manual = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 5),
      ...EqualizerBand.flat().skip(1),
    ]);
    final vm = EqualizerViewModel(
      equalizerService: _FakeEqualizerService(manual),
    );

    await vm.load();
    await vm.resetBands();

    expect(vm.bands.every((b) => b.gainDb == 0), isTrue);
  });

  test('restart restores manual bands while active preset is preserved', () async {
    final manual = EqualizerSettings.custom([
      const EqualizerBand(centerHz: 60, gainDb: 5),
      ...EqualizerBand.flat().skip(1),
    ]);
    final vm = EqualizerViewModel(
      equalizerService: _FakeEqualizerService(manual),
    );

    await vm.load();
    await vm.selectPreset(EqualizerPreset.bassBoost);

    final restarted = EqualizerViewModel(
      equalizerService: _FakeEqualizerService(
        EqualizerSettings.fromPreset(
          EqualizerPreset.bassBoost,
          manualBands: manual.bands,
        ),
      ),
    );
    await restarted.load();
    await restarted.selectPreset(EqualizerPreset.manual);

    expect(restarted.bands.first.gainDb, 5);
  });
}

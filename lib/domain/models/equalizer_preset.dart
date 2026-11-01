import 'package:retroplayer/domain/models/equalizer_band.dart';

/// Named equalizer presets stored in app settings.
enum EqualizerPreset {
  manual,
  bassBoost,
  trebleBoost,
  voice,
}

extension EqualizerPresetStorage on EqualizerPreset {
  static EqualizerPreset fromStorage(String? value) {
    if (value == null) return EqualizerPreset.manual;
    return EqualizerPreset.values.firstWhere(
      (p) => p.name == value,
      orElse: () => EqualizerPreset.manual,
    );
  }

  /// 5-band gains (60 / 230 / 910 / 3600 / 14000 Hz) in dB.
  List<EqualizerBand> bandGains() {
    final gains = switch (this) {
      EqualizerPreset.manual => [0.0, 0.0, 0.0, 0.0, 0.0],
      EqualizerPreset.bassBoost => [6.0, 4.0, 1.0, 0.0, 0.0],
      EqualizerPreset.trebleBoost => [0.0, 0.0, 1.0, 4.0, 5.0],
      EqualizerPreset.voice => [-4.0, 5.0, 3.0, 1.0, -2.0],
    };
    return [
      for (var i = 0; i < EqualizerBand.standardFrequencies.length; i++)
        EqualizerBand(
          centerHz: EqualizerBand.standardFrequencies[i],
          gainDb: gains[i],
        ),
    ];
  }
}

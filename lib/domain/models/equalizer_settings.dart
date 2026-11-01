import 'dart:convert';

import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';

enum EqualizerMode { off, preset, custom }

class EqualizerSettings {
  const EqualizerSettings({
    required this.mode,
    this.preset = EqualizerPreset.manual,
    this.bands = const [],
  });

  final EqualizerMode mode;
  final EqualizerPreset preset;
  final List<EqualizerBand> bands;

  factory EqualizerSettings.manual() => EqualizerSettings.custom(
        EqualizerBand.flat(),
      );

  factory EqualizerSettings.fromPreset(
    EqualizerPreset preset, {
    List<EqualizerBand>? manualBands,
  }) {
    final storedManual = manualBands ?? EqualizerBand.flat();
    if (preset == EqualizerPreset.manual) {
      return EqualizerSettings.custom(storedManual);
    }
    return EqualizerSettings(
      mode: EqualizerMode.preset,
      preset: preset,
      bands: storedManual,
    );
  }

  factory EqualizerSettings.custom(List<EqualizerBand> bands) => EqualizerSettings(
        mode: EqualizerMode.custom,
        preset: EqualizerPreset.manual,
        bands: bands,
      );

  List<EqualizerBand> effectiveBands() {
    return switch (mode) {
      EqualizerMode.off => EqualizerBand.flat(),
      EqualizerMode.preset => preset.bandGains(),
      EqualizerMode.custom =>
        bands.isEmpty ? EqualizerBand.flat() : bands,
    };
  }

  bool get isEnabled => mode != EqualizerMode.off;

  EqualizerSettings copyWith({
    EqualizerMode? mode,
    EqualizerPreset? preset,
    List<EqualizerBand>? bands,
  }) {
    return EqualizerSettings(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      bands: bands ?? this.bands,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EqualizerSettings &&
          mode == other.mode &&
          preset == other.preset &&
          _listEquals(bands, other.bands);

  @override
  int get hashCode => Object.hash(mode, preset, Object.hashAll(bands));

  static bool _listEquals(List<EqualizerBand> a, List<EqualizerBand> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

List<EqualizerBand> parseEqualizerBandsJson(String? json) {
  if (json == null || json.isEmpty) return EqualizerBand.flat();
  try {
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((e) => EqualizerBand.fromJson(e as Map<String, dynamic>))
        .toList();
  } on Object {
    return EqualizerBand.flat();
  }
}

String encodeEqualizerBandsJson(List<EqualizerBand> bands) =>
    jsonEncode(bands.map((b) => b.toJson()).toList());

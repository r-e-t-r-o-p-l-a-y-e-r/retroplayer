import 'dart:async';

import 'package:flutter/material.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

class EqualizerViewModel extends ChangeNotifier {
  EqualizerViewModel({
    required this._equalizerService,
    EqualizerSettings? initialSettings,
  }) {
    if (initialSettings != null) {
      _applyLoadedSettings(initialSettings);
      _loaded = true;
    }
  }

  final EqualizerService _equalizerService;
  Timer? _debounce;

  EqualizerSettings _settings = EqualizerSettings.manual();
  List<EqualizerBand> _manualBands = EqualizerBand.flat();
  bool _loaded = false;

  EqualizerSettings get settings => _settings;
  bool get isSupported => _equalizerService.isSupported;
  List<EqualizerBand> get bands => _settings.effectiveBands();

  EqualizerPreset get selectedPreset {
    if (_settings.mode == EqualizerMode.preset) return _settings.preset;
    return EqualizerPreset.manual;
  }

  void _applyLoadedSettings(EqualizerSettings loaded) {
    if (loaded.mode == EqualizerMode.off) {
      _manualBands = EqualizerBand.flat();
      _settings = EqualizerSettings.custom(_manualBands);
    } else {
      _manualBands = loaded.bands.isEmpty ? EqualizerBand.flat() : loaded.bands;
      _settings = loaded;
    }
  }

  Future<void> load() async {
    if (_loaded) return;

    _applyLoadedSettings(await _equalizerService.loadSettings());
    _loaded = true;
    notifyListeners();
  }

  /// Reads settings again after the database was cleared and applies them.
  Future<void> reloadFromStorage() async {
    await _equalizerService.loadAndApply();
    _applyLoadedSettings(await _equalizerService.loadSettings());
    _loaded = true;
    notifyListeners();
  }

  Future<void> selectPreset(EqualizerPreset preset) async {
    if (_settings.mode == EqualizerMode.custom &&
        preset != EqualizerPreset.manual) {
      _manualBands = List<EqualizerBand>.from(_settings.bands);
    }

    _settings = preset == EqualizerPreset.manual
        ? EqualizerSettings.custom(List<EqualizerBand>.from(_manualBands))
        : EqualizerSettings.fromPreset(
            preset,
            manualBands: List<EqualizerBand>.from(_manualBands),
          );

    notifyListeners();
    await _equalizerService.saveAndApply(_settings);
  }

  void setBandGain(int centerHz, double gainDb) {
    final clamped = gainDb.clamp(
      EqualizerBand.minGainDb,
      EqualizerBand.maxGainDb,
    );
    final updated = bands
        .map(
          (b) => b.centerHz == centerHz
              ? EqualizerBand(centerHz: centerHz, gainDb: clamped)
              : b,
        )
        .toList();
    _manualBands = updated;
    _settings = EqualizerSettings.custom(updated);
    notifyListeners();
    _debounceApply();
  }

  Future<void> resetBands() async {
    _manualBands = EqualizerBand.flat();
    _settings = EqualizerSettings.custom(_manualBands);
    notifyListeners();
    await _equalizerService.saveAndApply(_settings);
  }

  void _debounceApply() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      await _equalizerService.saveAndApply(_settings);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

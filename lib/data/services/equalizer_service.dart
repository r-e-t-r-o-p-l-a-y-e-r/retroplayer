import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/equalizer/equalizer_backend.dart';
import 'package:retroplayer/data/services/equalizer/equalizer_backend_factory.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

/// Loads, persists, and applies equalizer settings via a platform backend.
class EqualizerService {
  EqualizerService(
    this._storageService, {
    EqualizerBackend? backend,
    this._playbackService,
  })  : _backend = backend ?? createEqualizerBackend();

  final LibraryStorageService _storageService;
  final EqualizerBackend _backend;
  final AudioPlaybackService? _playbackService;

  bool get isSupported => _backend.isSupported;

  Future<void> apply(EqualizerSettings settings) async {
    await _backend.apply(
      settings,
      androidAudioSessionId: _playbackService?.androidAudioSessionId,
    );
  }

  Future<EqualizerSettings> loadSettings() =>
      _storageService.getEqualizerSettings();

  Future<void> loadAndApply() async {
    final settings = await loadSettings();
    _lastSettings = settings;
    await apply(settings);
  }

  Future<void> saveAndApply(EqualizerSettings settings) async {
    _lastSettings = settings;
    await _storageService.setEqualizerSettings(settings);
    await apply(settings);
  }

  Future<void> reapplyLast() async {
    final settings = _lastSettings ?? await loadSettings();
    _lastSettings = settings;
    await apply(settings);
  }

  EqualizerSettings? _lastSettings;
}

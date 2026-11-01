import 'package:retroplayer/domain/models/equalizer_settings.dart';

/// Applies [EqualizerSettings] to the platform audio pipeline.
abstract class EqualizerBackend {
  bool get isSupported;

  Future<void> apply(EqualizerSettings settings, {int? androidAudioSessionId});
}

import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:retroplayer/data/services/equalizer/equalizer_backend.dart';
import 'package:retroplayer/domain/equalizer/equalizer_filter_builder.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

class MpvEqualizerBackend implements EqualizerBackend {
  MpvEqualizerBackend({EqualizerFilterBuilder? filterBuilder})
      : _filterBuilder = filterBuilder ?? const EqualizerFilterBuilder();

  final EqualizerFilterBuilder _filterBuilder;

  @override
  bool get isSupported => true;

  @override
  Future<void> apply(
    EqualizerSettings settings, {
    int? androidAudioSessionId,
  }) async {
    final filter = _filterBuilder.toMpvAfChain(settings);
    await JustAudioMediaKit.applyAudioFilter(filter);
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:retroplayer/data/services/equalizer/equalizer_backend.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

class AndroidEqualizerBackend implements EqualizerBackend {
  AndroidEqualizerBackend({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('app.retroplayer/equalizer');

  final MethodChannel _channel;

  @override
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  @override
  Future<void> apply(
    EqualizerSettings settings, {
    int? androidAudioSessionId,
  }) async {
    if (!isSupported) return;

    if (!settings.isEnabled) {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': false});
      return;
    }

    if (androidAudioSessionId == null) return;

    final bands = settings.effectiveBands();
    await _channel.invokeMethod<void>('setBands', {
      'sessionId': androidAudioSessionId,
      'enabled': true,
      'bands': bands
          .map(
            (b) => {
              'hz': b.centerHz,
              'gainDb': b.gainDb.clamp(
                EqualizerBand.minGainDb,
                EqualizerBand.maxGainDb,
              ),
            },
          )
          .toList(),
    });
  }
}

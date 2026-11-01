import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:retroplayer/data/services/equalizer/android_equalizer_backend.dart';
import 'package:retroplayer/data/services/equalizer/equalizer_backend.dart';
import 'package:retroplayer/data/services/equalizer/mpv_equalizer_backend.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

EqualizerBackend createEqualizerBackend() {
  if (kIsWeb) return const _NoOpEqualizerBackend();
  if (Platform.isAndroid) return AndroidEqualizerBackend();
  if (Platform.isLinux || Platform.isIOS) return MpvEqualizerBackend();
  return const _NoOpEqualizerBackend();
}

class _NoOpEqualizerBackend implements EqualizerBackend {
  const _NoOpEqualizerBackend();

  @override
  bool get isSupported => false;

  @override
  Future<void> apply(
    EqualizerSettings settings, {
    int? androidAudioSessionId,
  }) async {}
}

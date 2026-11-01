import 'package:audio_session/audio_session.dart';

/// Heuristic for Android Auto / BT car: avoid audible phone speaker blips.
class ExternalPlaybackRoutePolicy {
  const ExternalPlaybackRoutePolicy._();

  static const Duration routeSettlingDuration = Duration(milliseconds: 900);
  static const Duration externalRoutePrimeDelay = Duration(milliseconds: 150);

  static bool hasBuiltInPhoneOutput(Set<AudioDevice> devices) {
    return devices.where((d) => d.isOutput).any(_isBuiltInPhoneOutput);
  }

  static bool hasExternalPlaybackOutput(Set<AudioDevice> devices) {
    return devices.where((d) => d.isOutput).any(_isExternalPlaybackOutput);
  }

  /// After car/BT output appears, Android may still route the first buffers to
  /// the phone for a short window.
  static bool isRouteTransitioning({
    required Set<AudioDevice> devices,
    required DateTime? externalOutputSince,
    DateTime? now,
  }) {
    if (externalOutputSince == null) return false;
    if (!hasExternalPlaybackOutput(devices)) return false;
    final clock = now ?? DateTime.now();
    return clock.difference(externalOutputSince) < routeSettlingDuration;
  }

  /// Reconnecting car/BT: outputs briefly drop to built-in only.
  static bool shouldWaitForExternalReconnect({
    required Set<AudioDevice> devices,
    required bool externalWasConnected,
  }) {
    if (!externalWasConnected) return false;
    if (hasExternalPlaybackOutput(devices)) return false;
    return hasBuiltInPhoneOutput(devices);
  }

  /// Prime audio focus / session before play when output is already external.
  static bool shouldPrimeExternalRoute(Set<AudioDevice> devices) {
    return hasExternalPlaybackOutput(devices);
  }

  static bool _isBuiltInPhoneOutput(AudioDevice device) {
    return device.type == AudioDeviceType.builtInSpeaker ||
        device.type == AudioDeviceType.builtInEarpiece;
  }

  static bool _isExternalPlaybackOutput(AudioDevice device) {
    return switch (device.type) {
      AudioDeviceType.bluetoothA2dp ||
      AudioDeviceType.bluetoothSco ||
      AudioDeviceType.usbAudio ||
      AudioDeviceType.wiredHeadphones ||
      AudioDeviceType.wiredHeadset ||
      AudioDeviceType.hdmi ||
      AudioDeviceType.hdmiArc ||
      AudioDeviceType.dock ||
      AudioDeviceType.auxLine =>
        true,
      _ => false,
    };
  }
}

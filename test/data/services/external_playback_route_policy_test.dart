/// Route policy for car/BT: settle after connect, not whenever both sinks exist.
///
/// Evidence:
/// - `does not treat steady phone plus car device list as defer`
/// - `transitions for a window after external output attaches`
/// - `waits to reconnect when external was connected but dropped`
library;

import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/external_playback_route_policy.dart';

AudioDevice _device({
  required String id,
  required AudioDeviceType type,
  bool isOutput = true,
}) {
  return AudioDevice(
    id: id,
    name: id,
    isInput: false,
    isOutput: isOutput,
    type: type,
  );
}

void main() {
  group('ExternalPlaybackRoutePolicy', () {
    test('does not treat steady phone plus car device list as defer', () {
      final outputs = {
        _device(id: 'speaker', type: AudioDeviceType.builtInSpeaker),
        _device(id: 'car', type: AudioDeviceType.bluetoothA2dp),
      };
      expect(
        ExternalPlaybackRoutePolicy.isRouteTransitioning(
          devices: outputs,
          externalOutputSince: null,
        ),
        isFalse,
      );
    });

    test('transitions for a window after external output attaches', () {
      final outputs = {
        _device(id: 'speaker', type: AudioDeviceType.builtInSpeaker),
        _device(id: 'car', type: AudioDeviceType.bluetoothA2dp),
      };
      final since = DateTime(2020, 1, 1, 12, 0, 0);
      expect(
        ExternalPlaybackRoutePolicy.isRouteTransitioning(
          devices: outputs,
          externalOutputSince: since,
          now: since.add(const Duration(milliseconds: 100)),
        ),
        isTrue,
      );
      expect(
        ExternalPlaybackRoutePolicy.isRouteTransitioning(
          devices: outputs,
          externalOutputSince: since,
          now: since.add(ExternalPlaybackRoutePolicy.routeSettlingDuration),
        ),
        isFalse,
      );
    });

    test('waits to reconnect when external was connected but dropped', () {
      final phoneOnly = {
        _device(id: 'speaker', type: AudioDeviceType.builtInSpeaker),
      };
      expect(
        ExternalPlaybackRoutePolicy.shouldWaitForExternalReconnect(
          devices: phoneOnly,
          externalWasConnected: true,
        ),
        isTrue,
      );
      expect(
        ExternalPlaybackRoutePolicy.shouldWaitForExternalReconnect(
          devices: phoneOnly,
          externalWasConnected: false,
        ),
        isFalse,
      );
    });

    test('primes play when external output is available', () {
      final outputs = {
        _device(id: 'car', type: AudioDeviceType.bluetoothA2dp),
      };
      expect(
        ExternalPlaybackRoutePolicy.shouldPrimeExternalRoute(outputs),
        isTrue,
      );
    });
  });
}

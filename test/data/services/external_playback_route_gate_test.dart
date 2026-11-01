/// ExternalPlaybackRouteGate waits before play during route settle / reconnect.
///
/// Evidence:
/// - `invokes play immediately on steady external route`
/// - `waits for device change before play during reconnect`
/// - `waits through settle window after external attaches`
library;

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/external_playback_route_gate.dart';
import 'package:retroplayer/data/services/external_playback_route_policy.dart';

AudioDevice _speaker() => AudioDevice(
  id: 'speaker',
  name: 'Speaker',
  isInput: false,
  isOutput: true,
  type: AudioDeviceType.builtInSpeaker,
);

AudioDevice _car() => AudioDevice(
  id: 'car',
  name: 'Car',
  isInput: false,
  isOutput: true,
  type: AudioDeviceType.bluetoothA2dp,
);

void main() {
  test('invokes play immediately on steady external route', () async {
    var playCalls = 0;
    var activateCalls = 0;
    final gate = ExternalPlaybackRouteGate(
      getOutputDevices: () async => {_car()},
      devicesChanged: const Stream.empty(),
      activateAudioSession: () async {
        activateCalls += 1;
        return true;
      },
      waitTimeout: const Duration(milliseconds: 50),
    );
    addTearDown(gate.dispose);

    await gate.runPlay(() async => playCalls += 1);

    expect(playCalls, 1);
    expect(activateCalls, 1);
  });

  test('waits for device change before play during reconnect', () async {
    var playCalls = 0;
    final changes = StreamController<AudioDevicesChangedEvent>.broadcast();
    addTearDown(changes.close);

    final gate = ExternalPlaybackRouteGate(
      getOutputDevices: () async => {_speaker()},
      devicesChanged: changes.stream,
      waitTimeout: const Duration(milliseconds: 200),
    );
    addTearDown(gate.dispose);

    // Bootstrap: car was connected before a brief drop to phone-only.
    changes.add(AudioDevicesChangedEvent(devicesAdded: {_car()}));
    changes.add(AudioDevicesChangedEvent(devicesRemoved: {_car()}));

    final pending = gate.runPlay(() async => playCalls += 1);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(playCalls, 0);

    changes.add(AudioDevicesChangedEvent(devicesAdded: {_car()}));
    await pending;
    expect(playCalls, 1);
  });

  test('waits through settle window after external attaches', () async {
    var playCalls = 0;
    final changes = StreamController<AudioDevicesChangedEvent>();
    addTearDown(changes.close);

    final gate = ExternalPlaybackRouteGate(
      getOutputDevices: () async => {_speaker(), _car()},
      devicesChanged: changes.stream,
      activateAudioSession: () async => true,
      waitTimeout: const Duration(milliseconds: 50),
      pollInterval: const Duration(milliseconds: 10),
    );
    addTearDown(gate.dispose);

    changes.add(AudioDevicesChangedEvent(devicesAdded: {_car()}));

    final started = DateTime.now();
    await gate.runPlay(() async => playCalls += 1);
    final elapsed = DateTime.now().difference(started);

    expect(playCalls, 1);
    expect(
      elapsed,
      greaterThanOrEqualTo(
        ExternalPlaybackRoutePolicy.routeSettlingDuration -
            const Duration(milliseconds: 80),
      ),
    );
  });
}

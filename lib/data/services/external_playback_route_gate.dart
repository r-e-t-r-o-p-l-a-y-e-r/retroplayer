import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:retroplayer/data/services/external_playback_route_policy.dart';

/// Optional delay before [play] when car/BT output is connecting or settling.
class ExternalPlaybackRouteGate {
  ExternalPlaybackRouteGate({
    required this._getOutputDevices,
    required this._devicesChanged,
    this._activateAudioSession,
    this._waitTimeout = const Duration(milliseconds: 1200),
    this._pollInterval = const Duration(milliseconds: 50),
  }) {
    _devicesSub = _devicesChanged.listen(_onDevicesChanged);
  }

  final Future<Set<AudioDevice>> Function() _getOutputDevices;
  final Stream<AudioDevicesChangedEvent> _devicesChanged;
  final Future<bool> Function()? _activateAudioSession;
  final Duration _waitTimeout;
  final Duration _pollInterval;

  late final StreamSubscription<AudioDevicesChangedEvent> _devicesSub;
  DateTime? _externalOutputSince;
  bool _externalWasConnected = false;
  bool _bootstrappedDevices = false;
  Completer<Set<AudioDevice>>? _reconnectWaiter;

  void dispose() {
    unawaited(_devicesSub.cancel());
  }

  void _onDevicesChanged(AudioDevicesChangedEvent event) {
    final addedExternal = event.devicesAdded.any(
      (d) => d.isOutput && ExternalPlaybackRoutePolicy.hasExternalPlaybackOutput({d}),
    );
    if (addedExternal) {
      _externalOutputSince = DateTime.now();
      _externalWasConnected = true;
    }

    final removedExternal = event.devicesRemoved.any(
      (d) => d.isOutput && ExternalPlaybackRoutePolicy.hasExternalPlaybackOutput({d}),
    );
    if (removedExternal) {
      _externalOutputSince = null;
    }

    unawaited(_maybeCompleteReconnectWaiter());
  }

  Future<void> _maybeCompleteReconnectWaiter() async {
    final waiter = _reconnectWaiter;
    if (waiter == null || waiter.isCompleted) return;
    final devices = await _getOutputDevices();
    if (ExternalPlaybackRoutePolicy.hasExternalPlaybackOutput(devices)) {
      waiter.complete(devices);
    }
  }

  Future<void> _bootstrapFromDevices(Set<AudioDevice> devices) async {
    if (_bootstrappedDevices) return;
    _bootstrappedDevices = true;
    if (ExternalPlaybackRoutePolicy.hasExternalPlaybackOutput(devices)) {
      _externalWasConnected = true;
    }
  }

  Future<void> runPlay(Future<void> Function() play) async {
    var devices = await _getOutputDevices();
    await _bootstrapFromDevices(devices);

    if (ExternalPlaybackRoutePolicy.shouldWaitForExternalReconnect(
      devices: devices,
      externalWasConnected: _externalWasConnected,
    )) {
      devices = await _waitForExternalOutput(devices);
    }

    if (ExternalPlaybackRoutePolicy.isRouteTransitioning(
      devices: devices,
      externalOutputSince: _externalOutputSince,
    )) {
      await _waitUntilRouteSettled(devices);
    }

    if (ExternalPlaybackRoutePolicy.shouldPrimeExternalRoute(devices)) {
      final activate = _activateAudioSession;
      if (activate != null) {
        await activate();
      }
      await Future<void>.delayed(
        ExternalPlaybackRoutePolicy.externalRoutePrimeDelay,
      );
    }

    await play();
  }

  Future<Set<AudioDevice>> _waitForExternalOutput(Set<AudioDevice> initial) async {
    if (ExternalPlaybackRoutePolicy.hasExternalPlaybackOutput(initial)) {
      return initial;
    }

    _reconnectWaiter = Completer<Set<AudioDevice>>();
    try {
      return await Future.any([
        _reconnectWaiter!.future,
        Future<Set<AudioDevice>>.delayed(_waitTimeout, () => initial),
      ]);
    } finally {
      _reconnectWaiter = null;
    }
  }

  Future<void> _waitUntilRouteSettled(Set<AudioDevice> devices) async {
    final since = _externalOutputSince;
    if (since == null) return;

    final deadline = since.add(ExternalPlaybackRoutePolicy.routeSettlingDuration);
    while (DateTime.now().isBefore(deadline)) {
      final current = await _getOutputDevices();
      if (!ExternalPlaybackRoutePolicy.isRouteTransitioning(
        devices: current,
        externalOutputSince: since,
      )) {
        return;
      }
      await Future<void>.delayed(_pollInterval);
    }
  }
}

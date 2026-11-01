import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/domain/models/audio_track.dart';

/// Bridges [AudioPlaybackService] into the platform media session.
///
/// On Android, swiping the app away from Recents must stop audio — the
/// foreground media service otherwise keeps playing after the UI is gone.
class RetroAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  RetroAudioHandler(
    this._playbackService, {
    this._onRecentsDismiss,
    this._activateAudioSession,
  }) {
    _playbackService.playerStateStream.listen((state) {
      _lastEngineState = state;
      _publishPlaybackState(state);
    });
    _playbackService.currentTrackStream.listen((track) {
      _publishMediaItem(track);
      final engine = _lastEngineState;
      if (engine != null) {
        _publishPlaybackState(engine);
      }
    });
    _playbackService.durationStream.listen((duration) {
      if (duration == null || duration <= Duration.zero) return;
      final track = _playbackService.currentTrack;
      if (track == null) return;
      _publishMediaItem(track);
    });
    _playbackService.positionStream.listen((position) {
      if (!playbackState.hasValue) return;
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });
    _bootstrapSessionFromEngine();
  }

  /// Re-reads engine track/state into the platform session (app resume).
  void refreshSessionState() {
    _publishMediaItem(_playbackService.currentTrack);
    final engine = _lastEngineState;
    if (engine != null) {
      _publishPlaybackState(engine);
    }
  }

  void _bootstrapSessionFromEngine() {
    final track = _playbackService.currentTrack;
    if (track == null) return;
    _publishMediaItem(track);
    _publishPlaybackState(
      _lastEngineState ?? PlayerState(false, ProcessingState.ready),
    );
  }

  final AudioPlaybackService _playbackService;
  final Future<void> Function()? _onRecentsDismiss;
  final Future<bool> Function()? _activateAudioSession;
  PlayerState? _lastEngineState;

  Future<void> _primeAudioSession() async {
    await _activateAudioSession?.call();
  }

  void _publishPlaybackState(PlayerState state) {
    final controls = <MediaControl>[
      if (_playbackService.hasPrevious) MediaControl.skipToPrevious,
      if (state.playing) MediaControl.pause else MediaControl.play,
      if (_playbackService.hasNext) MediaControl.skipToNext,
    ];
    final compactCount = controls.length.clamp(0, 3);
    unawaited(_primeAudioSession());
    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.seek,
        },
        androidCompactActionIndices: [
          for (var i = 0; i < compactCount; i++) i,
        ],
        processingState: _mapProcessingState(
          state.processingState,
          hasLoadedTrack: _playbackService.currentTrack != null,
        ),
        playing: state.playing,
        updatePosition: _playbackService.position,
      ),
    );
  }

  void _publishMediaItem(AudioTrack? track) {
    if (track == null) {
      mediaItem.add(null);
      queue.add(const []);
      return;
    }
    final engineDuration = _playbackService.duration;
    mediaItem.add(
      mediaItemForTrack(track, engineDuration: engineDuration),
    );
    queue.add([
      for (final queued in _playbackService.queue)
        mediaItemForTrack(
          queued,
          engineDuration: queued.id == track.id ? engineDuration : null,
        ),
    ]);
  }

  AudioProcessingState _mapProcessingState(
    ProcessingState state, {
    required bool hasLoadedTrack,
  }) {
    if (state == ProcessingState.idle && hasLoadedTrack) {
      // just_audio may briefly emit idle while a queue is loaded; publishing
      // idle tears down the native AudioService and kills transport callbacks.
      return AudioProcessingState.ready;
    }
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  @override
  Future<void> play() async {
    await _primeAudioSession();
    await _playbackService.playForMediaTransport();
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    await _primeAudioSession();
    switch (button) {
      case MediaButton.media:
        if (playbackState.valueOrNull?.playing ?? false) {
          await pause();
        } else {
          await play();
        }
      case MediaButton.next:
        await skipToNext();
      case MediaButton.previous:
        await skipToPrevious();
    }
  }

  @override
  Future<void> pause() async {
    await _primeAudioSession();
    await _playbackService.pause();
  }

  @override
  Future<void> stop() async {
    await _playbackService.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _playbackService.seek(position);

  @override
  Future<void> skipToNext() async {
    await _primeAudioSession();
    await _playbackService.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _primeAudioSession();
    await _playbackService.skipToPrevious();
  }

  /// Android Recents swipe / task removed — stop audio and tear down session.
  ///
  /// Clears the platform media session without touching [AudioPlaybackService].
  ///
  /// Used after [PlaybackRepository.stopPlaybackForRecentsDismiss] from the
  /// activity lifecycle bridge.
  Future<void> idleMediaSession() async {
    final current = playbackState.valueOrNull;
    if (current == null) {
      playbackState.add(
        PlaybackState(processingState: AudioProcessingState.idle),
      );
    } else {
      playbackState.add(
        current.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
        ),
      );
    }
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle,
    );
  }

  /// Native invokes this without waiting for completion — stop audio first.
  @override
  Future<void> onTaskRemoved() async {
    final dismiss = _onRecentsDismiss;
    if (dismiss != null) {
      try {
        await dismiss();
      } on Object {
        // Fall through to local stop.
        try {
          await _playbackService.stop();
        } on Object {
          // Player may already be stopped.
        }
      }
    } else {
      try {
        await _playbackService.pause();
      } on Object {
        // Player may already be idle.
      }
      try {
        await _playbackService.stop();
      } on Object {
        // Player may already be stopped.
      }
    }

    try {
      await idleMediaSession();
    } on Object {
      // Session may already be idle.
    }
  }

  /// Notification dismiss (when allowed) — same as stop.
  @override
  Future<void> onNotificationDeleted() async {
    await onTaskRemoved();
  }
}

/// Now-playing fields the notification, MPRIS, and car head units read.
///
/// Title falls back to the file name. Album falls back to the folder name.
/// Blank tags are omitted so the car does not show an empty artist line.
MediaItem mediaItemForTrack(
  AudioTrack track, {
  Duration? engineDuration,
}) {
  final title = track.displayTitle;
  final artist =
      _nonEmpty(track.metadata.artist) ?? _nonEmpty(track.metadata.albumArtist);
  final album = _albumName(track);
  final tagMs = track.durationMs;
  final taggedDuration = tagMs != null && tagMs > 0
      ? Duration(milliseconds: tagMs)
      : null;
  final duration = taggedDuration ??
      ((engineDuration != null && engineDuration > Duration.zero)
          ? engineDuration
          : null);
  return MediaItem(
    id: track.id,
    title: title,
    displayTitle: title,
    artist: artist,
    displaySubtitle: artist,
    album: album,
    displayDescription: album,
    duration: duration,
  );
}

String? _albumName(AudioTrack track) {
  final tagged = _nonEmpty(track.metadata.album);
  if (tagged != null) return tagged;
  final folder = track.metadata.displayAlbum(track.directoryPath);
  if (folder == 'Unknown Album') return null;
  return folder;
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';

/// Stops playback and tears down the media session on true app exit.
///
/// Does not stop when the app is only backgrounded or the screen is locked —
/// [PlayerViewModel] saves progress on pause; `audio_service` keeps playing.
///
/// Android Recents swipe is handled by [RetroAudioHandler.onTaskRemoved],
/// [AndroidRecentsPlaybackBridge], and [PlaybackRepository.stopPlaybackForRecentsDismiss],
/// because [onExitRequested] is not reliably delivered on that path.
class PlaybackLifecycle extends StatefulWidget {
  const PlaybackLifecycle({
    super.key,
    required this.playbackRepository,
    required this.storageService,
    this.audioSessionSubscription,
    required this.child,
  });

  final PlaybackRepository playbackRepository;
  final LibraryStorageService storageService;
  final StreamSubscription<int?>? audioSessionSubscription;
  final Widget child;

  @override
  State<PlaybackLifecycle> createState() => _PlaybackLifecycleState();
}

class _PlaybackLifecycleState extends State<PlaybackLifecycle> {
  late final AppLifecycleListener _exitListener;

  @override
  void initState() {
    super.initState();
    _exitListener = AppLifecycleListener(onExitRequested: _onExitRequested);
  }

  Future<AppExitResponse> _onExitRequested() async {
    await widget.audioSessionSubscription?.cancel();
    await widget.playbackRepository.shutdown();
    await widget.storageService.close();
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    unawaited(widget.audioSessionSubscription?.cancel());
    _exitListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

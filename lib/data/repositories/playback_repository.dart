import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/domain/library_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:retroplayer/application/play_queue.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Exposes playback operations to the UI layer.
class PlaybackRepository {
  PlaybackRepository({
    required AudioPlaybackService playbackService,
    required LibraryStorageService storageService,
  })  : _playbackService = playbackService,
        _storageService = storageService,
        _playQueue = PlayQueue(
          engine: playbackService,
          store: storageService,
        );

  final AudioPlaybackService _playbackService;
  final LibraryStorageService _storageService;
  final PlayQueue _playQueue;

  String? _activeItemId;
  bool _isShutdown = false;

  /// Set from [main] after [AudioService.init] for resume resync.
  RetroAudioHandler? mediaSessionHandler;

  /// Reactivates the OS audio session on app resume (Android lockscreen transport).
  Future<bool> Function()? activateAudioSession;

  AudioPlaybackService get service => _playbackService;

  Future<void> resyncMediaSessionOnResume() async {
    await activateAudioSession?.call();
    mediaSessionHandler?.refreshSessionState();
  }

  String? get activeItemId => _activeItemId;

  void setActiveItemId(String? itemId) => _activeItemId = itemId;

  Future<void> play(PlaybackItem item) {
    _activeItemId = item.id;
    return _playQueue.start(item);
  }

  Future<void> playFrom(PlaybackItem item, AudioTrack track) {
    _activeItemId = item.id;
    return _playQueue.startAt(item, track);
  }

  Future<void> playAlbum(AudioAlbum album) => play(AlbumPlayback(album));

  Future<void> playAlbumTrack(AudioAlbum album, AudioTrack track) =>
      playFrom(AlbumPlayback(album), track);

  Future<void> playTrack(AudioTrack track) => play(TrackPlayback(track));

  Future<void> playFolder(String folderPath, List<AudioTrack> tracks) =>
      play(FolderPlayback(folderPath, tracks));

  Future<void> playPlaylist(PlaylistFile playlist, List<AudioTrack> tracks) =>
      play(PlaylistPlayback(playlist, tracks));

  Future<void> playPlaylistTrack(
    PlaylistFile playlist,
    List<AudioTrack> tracks,
    AudioTrack track,
  ) =>
      playFrom(PlaylistPlayback(playlist, tracks), track);

  Future<void> playComposedQueue(
    List<AudioTrack> tracks, {
    required int startIndex,
  }) {
    if (tracks.isEmpty) return Future.value();
    final index = startIndex.clamp(0, tracks.length - 1);
    _activeItemId = PlaybackItem.composedQueueId;
    return playFrom(QueuePlayback(tracks), tracks[index]);
  }

  /// Replaces the playing queue without clearing the stored path list.
  ///
  /// Keeps the current position when [keepPosition] is true.
  Future<void> retargetComposedQueue(
    List<AudioTrack> tracks, {
    required int startIndex,
    bool keepPosition = true,
  }) async {
    if (tracks.isEmpty) return;
    final index = startIndex.clamp(0, tracks.length - 1);
    _activeItemId = PlaybackItem.composedQueueId;
    await _playbackService.setQueue(
      tracks,
      startIndex: index,
      initialPosition: keepPosition ? _playbackService.position : null,
    );
  }

  Future<void> noteComposedQueueIndex(int index) =>
      _storageService.setPlaybackQueueIndex(index);

  Future<void> pause() => _playbackService.pause();

  Future<void> resume() => _playbackService.play();

  Future<void> stop() => _playbackService.stop();

  Future<void> clearPlaybackState(String itemId) =>
      _storageService.clearPlaybackState(itemId);

  Future<void> seek(Duration position) => _playbackService.seek(position);

  Future<void> setSpeed(double speed) => _playbackService.setSpeed(speed);

  Future<void> skipNext() => _playbackService.skipToNext();

  Future<void> skipPrevious() => _playbackService.skipToPrevious();

  Future<void> saveProgress(String itemId) => _playQueue.saveProgress(itemId);

  static const _taskRemovedSaveTimeout = Duration(milliseconds: 500);

  /// Android Recents / task removed — stop playback and persist with a timeout.
  ///
  /// Also used from [RetroAudioHandler.onTaskRemoved] and
  /// [AndroidRecentsPlaybackBridge] when the activity finishes first.
  Future<void> stopPlaybackForRecentsDismiss() async {
    if (_isShutdown) {
      try {
        await _playbackService.stop();
      } on Object {
        // Player may already be stopped.
      }
      return;
    }
    _isShutdown = true;

    final itemId = _activeItemId;
    Future<void>? saveFuture;
    if (itemId != null && _playbackService.currentTrack != null) {
      saveFuture = saveProgress(itemId)
          .timeout(_taskRemovedSaveTimeout)
          .catchError((_) {});
    }

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

    if (saveFuture != null) {
      try {
        await saveFuture;
      } on Object {
        // Best effort under Recents kill race.
      }
    }
  }

  /// Saves progress, then stops native playback and the media notification.
  ///
  /// Safe to call multiple times. Call on true app exit — not when backgrounded.
  Future<void> shutdown() async {
    if (_isShutdown) return;
    _isShutdown = true;

    final itemId = _activeItemId;
    if (itemId != null) {
      await saveProgress(itemId);
    }
    try {
      await _playbackService.stop();
    } on Object {
      // Player may already be stopped.
    }
    await _tearDownPlaybackService();
  }

  Future<void> _tearDownPlaybackService() async {
    try {
      await _playbackService.dispose();
    } on Object {
      // Player may already be disposed.
    }
    try {
      // Stops the foreground media notification / session.
      // ignore: deprecated_member_use
      await AudioService.stop();
    } on Object catch (e, st) {
      debugPrint('AudioService.stop failed: $e\n$st');
    }
  }

  /// Last persisted row for the active item (title/subtitle for cold-start UI).
  Future<({String itemId, SavedPlaybackState state})?>
  lastActivePlaybackSnapshot() async {
    final itemId = await _storageService.getLastActiveItemId();
    if (itemId == null) return null;
    final state = await _storageService.getPlaybackState(itemId);
    if (state == null) return null;
    return (itemId: itemId, state: state);
  }

  /// Loads the last saved queue and position without starting playback.
  Future<bool> restoreLastSession(LibraryRepository library) async {
    final itemId = await _storageService.getLastActiveItemId();
    if (itemId == null) return false;

    _activeItemId = itemId;
    final item = await _findPlaybackItem(library, itemId);
    if (item == null) return false;
    _activeItemId = item.id;
    await _playQueue.start(item, autoPlay: false);
    return _playbackService.currentTrack != null;
  }

  Future<PlaybackItem?> _findPlaybackItem(
    LibraryRepository library,
    String itemId,
  ) async {
    if (itemId == PlaybackItem.composedQueueId) {
      final stored = await _storageService.getPlaybackQueue();
      if (stored.paths.isEmpty) return null;
      final tracks = await library.tracksForPaths(stored.paths);
      return tracks.isEmpty ? null : QueuePlayback(tracks);
    }

    final folderPath = PlaybackItem.folderPathFromId(itemId);
    if (folderPath != null) {
      final tracks = await library.tracksUnderFolder(folderPath);
      return tracks.isEmpty ? null : FolderPlayback(folderPath, tracks);
    }

    final playlistPath = PlaylistFile.playlistPathFromItemId(itemId);
    if (playlistPath != null) {
      final playlist = await library.findPlaylistByPath(playlistPath);
      if (playlist == null) return null;
      final tracks = await library.resolvePlaylistTracks(playlist);
      return tracks.isEmpty ? null : PlaylistPlayback(playlist, tracks);
    }

    await _warmDirectoryForSavedTrack(library, itemId);

    switch (await library.findByIdAsync(itemId)) {
      case LibraryAlbumItem(:final album):
        return AlbumPlayback(album);
      case LibraryTrackItem(:final track):
        return TrackPlayback(track);
      case _:
        break;
    }

    // The album id changed (e.g. regrouped after a rescan): find the album
    // that holds the saved track.
    final saved = await _storageService.getPlaybackState(itemId);
    if (saved == null) return null;
    await _warmDirectoryForSavedTrackPath(library, saved.trackId);
    for (final root in await library.getLibraryRoots()) {
      await library.loadDirectory(root);
      for (final cached in library.items) {
        if (cached case LibraryAlbumItem(:final album)) {
          final idx = PlaybackResume.indexOfTrack(
            album.sortedTracks().tracks,
            saved.trackId,
          );
          if (idx >= 0) return AlbumPlayback(album);
        }
      }
    }
    return null;
  }

  Future<void> _warmDirectoryForSavedTrack(
    LibraryRepository library,
    String itemId,
  ) async {
    final saved = await _storageService.getPlaybackState(itemId);
    if (saved == null) return;
    await _warmDirectoryForSavedTrackPath(library, saved.trackId);
  }

  Future<void> _warmDirectoryForSavedTrackPath(
    LibraryRepository library,
    String trackKey,
  ) async {
    if (!trackKey.contains('/')) return;
    final dir = normalizeLibraryPath(p.dirname(trackKey));
    if (dir.isEmpty || dir == '.') return;
    await library.loadDirectory(dir);
  }

  Future<void> dispose() => _playbackService.dispose();
}

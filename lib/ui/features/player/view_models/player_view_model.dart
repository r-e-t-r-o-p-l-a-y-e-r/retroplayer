import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/application/ports/cover_art_source.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';
import 'package:retroplayer/ui/features/player/view_models/now_playing_info.dart';

/// Persists playback position every [_progressSaveInterval] while playing.
const _progressSaveInterval = Duration(seconds: 10);

/// How far the side buttons, art double-tap, and Ctrl+Shift+arrows jump.
const playbackJumpStep = Duration(seconds: 15);

class PlayerViewModel extends ChangeNotifier with WidgetsBindingObserver {
  PlayerViewModel({
    required PlaybackRepository playbackRepository,
    CoverArtSource? resolveCoverArt,
    ({String itemId, SavedPlaybackState state})? coldStartPlaybackSnapshot,
  }) : _playbackRepository = playbackRepository,
       _resolveCoverArt =
           resolveCoverArt ??
           ResolveCoverArt(
             readEmbeddedArtwork: MetadataService().readEmbeddedArtwork,
           ) {
    if (coldStartPlaybackSnapshot case final snap?) {
      _applyPlaybackSnapshot(snap);
    }
    WidgetsBinding.instance.addObserver(this);
    _subscriptions.add(
      _playbackRepository.service.playingStream.listen((playing) {
        _isPlaying = playing;
        if (playing) {
          _startProgressTimer();
        } else {
          _stopProgressTimer();
        }
        notifyListeners();
      }),
    );
    _subscriptions.add(
      _playbackRepository.service.positionStream.listen(
        (position) => _setPositionFromEngine(position, fromStream: true),
      ),
    );
    _subscriptions.add(
      _playbackRepository.service.durationStream.listen((dur) {
        // just_audio emits null while loading; clearing would freeze the scrubber
        // (it clamps position to 0 when duration is zero).
        if (dur == null) return;
        if (dur == _duration) return;
        _duration = dur;
        if (_awaitingEngineHydrate && _position == Duration.zero) {
          _awaitingEngineHydrate = false;
        }
        notifyListeners();
      }),
    );
    _subscriptions.add(
      _playbackRepository.service.currentTrackStream.listen((track) {
        if (track != null) {
          _title = track.displayTitle;
          _subtitle = track.metadata.artist ?? track.metadata.album ?? '';
          if (_currentItemId != null && track.id != _lastKnownTrackId) {
            if (_lastKnownTrackId != null) {
              unawaited(_saveProgress());
            }
            _lastKnownTrackId = track.id;
            if (_currentItemId == PlaybackItem.composedQueueId) {
              final index = _playbackRepository.service.currentQueueIndex;
              if (index != null) {
                unawaited(_playbackRepository.noteComposedQueueIndex(index));
              }
            }
            _applyDurationFromTrackChange(track);
            _applyEngineDurationIfNeeded();
            _setCoverArt(
              directoryPath: track.directoryPath,
              trackFilePath: track.filePath,
              preferredPath: null,
            );
          } else {
            _seedDurationFromTrack(track);
            _applyEngineDurationIfNeeded();
          }
        }
        notifyListeners();
      }),
    );
  }

  final PlaybackRepository _playbackRepository;
  final CoverArtSource _resolveCoverArt;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Timer? _progressTimer;
  int? _lastSavedPositionMs;
  double? _lastSavedSpeed;

  /// Position ticks go here so the rest of the tree is not rebuilt.
  final ValueNotifier<Duration> positionListenable = ValueNotifier(
    Duration.zero,
  );

  String? _currentItemId;
  String? _lastKnownTrackId;
  bool _sessionRestored = false;
  bool _awaitingEngineHydrate = false;
  String _title = '';
  String _subtitle = '';
  String? _coverArtPath;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;

  String get title => _title;
  String get subtitle => _subtitle;
  String? get coverArtPath => _coverArtPath;

  NowPlayingInfo get nowPlaying => NowPlayingInfo(
    title: _title,
    subtitle: _subtitle,
    coverArtPath: _coverArtPath,
    itemId: _currentItemId,
  );
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  bool get hasTrack => _playbackRepository.service.currentTrack != null;

  /// Mini player dock before the audio engine finishes restoring the queue.
  bool get hasSession => hasTrack || _awaitingEngineHydrate;
  bool get hasNext => _playbackRepository.service.hasNext;
  bool get hasPrevious => _playbackRepository.service.hasPrevious;

  String? get currentItemId => _currentItemId;

  AudioTrack? get currentTrack => _playbackRepository.service.currentTrack;

  int? get currentQueueIndex => _playbackRepository.service.currentQueueIndex;

  Future<void> playComposedQueue(
    List<AudioTrack> tracks, {
    required int startIndex,
  }) async {
    if (tracks.isEmpty) return;
    _awaitingEngineHydrate = false;
    final index = startIndex.clamp(0, tracks.length - 1);
    final track = tracks[index];
    _currentItemId = PlaybackItem.composedQueueId;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? '';
    _setCoverArt(
      directoryPath: track.directoryPath,
      trackFilePath: track.filePath,
      preferredPath: null,
    );
    await _playbackRepository.playComposedQueue(tracks, startIndex: index);
    _lastKnownTrackId = track.id;
    _seedDurationFromTrack(track);
    _syncTimingFromService();
    notifyListeners();
  }

  /// Keeps the composed queue playing after its stored order changes.
  Future<void> retargetComposedQueue(
    List<AudioTrack> tracks, {
    required int startIndex,
  }) async {
    if (_currentItemId != PlaybackItem.composedQueueId || tracks.isEmpty) {
      return;
    }
    final index = startIndex.clamp(0, tracks.length - 1);
    await _playbackRepository.retargetComposedQueue(tracks, startIndex: index);
    final track = tracks[index];
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? '';
    _lastKnownTrackId = track.id;
    _syncTimingFromService();
    notifyListeners();
  }

  /// Replaces titles on the playing queue when tags arrive after playback
  /// started. Leaves the audio sources alone.
  void adoptResolvedTracks(String itemId, List<AudioTrack> tracks) {
    if (_currentItemId != itemId || tracks.isEmpty) return;
    _playbackRepository.service.replaceQueueTracks(tracks);
    final track = _playbackRepository.service.currentTrack;
    if (track == null) return;
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? track.metadata.album ?? '';
    _lastKnownTrackId = track.id;
    _seedDurationFromTrack(track);
    _setCoverArt(
      directoryPath: track.directoryPath,
      trackFilePath: track.filePath,
      preferredPath: null,
    );
    notifyListeners();
  }

  Future<void> playItem(
    LibraryItem item, {
    required List<AudioTrack> playlistTracks,
  }) async {
    _awaitingEngineHydrate = false;
    _currentItemId = item.id;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    switch (item) {
      case LibraryAlbumItem(:final album):
        _title = album.title;
        _subtitle = album.artist ?? '${album.trackCount} tracks';
        _setCoverArt(
          directoryPath: album.tracks.first.directoryPath,
          trackFilePath: album.tracks.first.filePath,
          preferredPath: album.coverArtPath,
        );
        await _playbackRepository.playAlbum(album);
      case LibraryTrackItem(:final track):
        _title = track.displayTitle;
        _subtitle = track.metadata.artist ?? '';
        _setCoverArt(
          directoryPath: track.directoryPath,
          trackFilePath: track.filePath,
          preferredPath: null,
        );
        await _playbackRepository.playTrack(track);
      case LibraryPlaylistItem(:final playlist):
        await playPlaylist(playlist, playlistTracks);
        return;
    }
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> playPlaylist(
    PlaylistFile playlist,
    List<AudioTrack> tracks,
  ) async {
    if (tracks.isEmpty) return;
    _awaitingEngineHydrate = false;

    _currentItemId = playlist.id;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    _title = playlist.displayName;
    _subtitle = '${tracks.length} tracks';
    _setCoverArt(
      directoryPath: p.dirname(playlist.filePath),
      trackFilePath: tracks.first.filePath,
      preferredPath: null,
    );
    await _playbackRepository.playPlaylist(playlist, tracks);
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> playPlaylistTrack(
    PlaylistFile playlist,
    List<AudioTrack> tracks,
    AudioTrack track,
  ) async {
    if (tracks.isEmpty) return;
    _awaitingEngineHydrate = false;

    _currentItemId = playlist.id;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? playlist.displayName;
    _setCoverArt(
      directoryPath: track.directoryPath,
      trackFilePath: track.filePath,
      preferredPath: null,
    );
    await _playbackRepository.playPlaylistTrack(playlist, tracks, track);
    _lastKnownTrackId = track.id;
    _seedDurationFromTrack(track);
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> playAlbum(AudioAlbum album) async {
    _awaitingEngineHydrate = false;
    _currentItemId = album.id;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    _title = album.title;
    _subtitle = album.artist ?? '${album.trackCount} tracks';
    _setCoverArt(
      directoryPath: album.tracks.first.directoryPath,
      trackFilePath: album.tracks.first.filePath,
      preferredPath: album.coverArtPath,
    );
    await _playbackRepository.playAlbum(album);
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> playAlbumTrack(AudioAlbum album, AudioTrack track) async {
    _awaitingEngineHydrate = false;
    _currentItemId = album.id;
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    await _playbackRepository.playAlbumTrack(album, track);
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? album.title;
    _setCoverArt(
      directoryPath: track.directoryPath,
      trackFilePath: track.filePath,
      preferredPath: album.coverArtPath,
    );
    _lastKnownTrackId = track.id;
    _seedDurationFromTrack(track);
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> playFolder(String folderPath, List<AudioTrack> tracks) async {
    final queue = sortFolderTracks(tracks);
    if (queue.isEmpty) return;
    _awaitingEngineHydrate = false;

    _currentItemId = PlaybackItem.folderId(folderPath);
    _playbackRepository.setActiveItemId(_currentItemId);
    _lastKnownTrackId = null;
    _title = p.basename(folderPath);
    _subtitle = '${queue.length} tracks';
    _setCoverArt(
      directoryPath: folderPath,
      trackFilePath: queue.first.filePath,
      preferredPath: null,
    );
    await _playbackRepository.playFolder(folderPath, queue);
    _syncTimingFromService();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _playbackRepository.pause();
      await _saveProgress();
    } else {
      await _playbackRepository.resume();
    }
  }

  Future<void> stop() async {
    await _saveProgress();
    await _playbackRepository.stop();
    _isPlaying = false;
    _setPosition(Duration.zero);
    notifyListeners();
  }

  /// Stops playback and clears persisted progress when it belongs under [removedRoot].
  Future<void> stopAndClearIfUnderLibraryRoot(String removedRoot) async {
    if (!_isPlaybackUnderRoot(removedRoot)) return;
    await stopAndClearPlayback();
  }

  /// Stops playback when [playlistPath] is the current playlist item.
  Future<void> stopAndClearIfPlayingPlaylist(String playlistPath) async {
    final id = PlaylistFile.playlistItemId(playlistPath);
    if (_currentItemId != id) return;
    await stopAndClearPlayback();
  }

  /// Stops playback when the composed queue is current, and drops its saved
  /// position either way. Playback of a folder, album, or playlist continues.
  Future<void> discardComposedQueuePlayback() async {
    if (_currentItemId == PlaybackItem.composedQueueId) {
      await stopAndClearPlayback();
      return;
    }
    await _playbackRepository.clearPlaybackState(PlaybackItem.composedQueueId);
  }

  Future<void> stopAndClearPlayback() async {
    final itemId = _currentItemId;
    await _playbackRepository.stop();
    if (itemId != null) {
      await _playbackRepository.clearPlaybackState(itemId);
    }
    _playbackRepository.setActiveItemId(null);
    _currentItemId = null;
    _lastKnownTrackId = null;
    _title = '';
    _subtitle = '';
    _coverArtPath = null;
    _setPosition(Duration.zero);
    _duration = Duration.zero;
    _isPlaying = false;
    notifyListeners();
  }

  bool _isPlaybackUnderRoot(String root) {
    final track = currentTrack;
    if (track != null && isPathUnderRoot(track.filePath, root)) {
      return true;
    }
    final itemId = _currentItemId;
    if (itemId == null) return false;
    if (itemId.startsWith('folder:')) {
      return isPathUnderRoot(itemId.substring('folder:'.length), root);
    }
    final playlistPath = PlaylistFile.playlistPathFromItemId(itemId);
    if (playlistPath != null) {
      return isPathUnderRoot(playlistPath, root);
    }
    return track != null && isPathUnderRoot(track.filePath, root);
  }

  Future<void> seek(Duration position) async {
    await _playbackRepository.seek(position);
    await _saveProgress();
  }

  /// Seeks by [delta], stopping at the start and, when known, the end.
  Future<void> jumpBy(Duration delta) async {
    if (!hasTrack) return;
    var target = _position + delta;
    if (target.isNegative) target = Duration.zero;
    if (_duration > Duration.zero && target > _duration) target = _duration;
    await seek(target);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _playbackRepository.setSpeed(speed);
    await _saveProgress();
    notifyListeners();
  }

  Future<void> skipNext() async {
    await _playbackRepository.skipNext();
    _syncTimingFromService();
    await _saveProgress();
    notifyListeners();
  }

  Future<void> skipPrevious() async {
    await _playbackRepository.skipPrevious();
    _syncTimingFromService();
    await _saveProgress();
    notifyListeners();
  }

  /// Keeps engine-reported length when scan metadata has no [AudioTrack.durationMs].
  void _applyDurationFromTrackChange(AudioTrack track) {
    final fromTag = _durationFromTrack(track);
    if (fromTag != null) {
      _duration = fromTag;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_saveProgress());
    }
    // Recents swipe often delivers [detached] before the process is killed;
    // stop locally when the handler callback does not finish in time.
    if (!kIsWeb && Platform.isAndroid && state == AppLifecycleState.detached) {
      unawaited(_playbackRepository.service.stop());
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(_progressSaveInterval, (_) {
      if (_isPlaying && _currentItemId != null) {
        unawaited(_saveProgress());
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Tests and helpers when [runApp] cold-start priming is not used.
  void primeFromColdStartSnapshot(
    ({String itemId, SavedPlaybackState state}) snap,
  ) {
    _applyPlaybackSnapshot(snap);
  }

  Future<void> restoreLastSession(LibraryRepository libraryRepository) async {
    if (_sessionRestored) return;

    await _applySavedSessionSnapshot();

    final restored = await _playbackRepository.restoreLastSession(
      libraryRepository,
    );
    _sessionRestored = true;
    if (!restored) return;

    _currentItemId = _playbackRepository.activeItemId;
    final track = _playbackRepository.service.currentTrack;
    if (track == null) return;

    _lastKnownTrackId = track.id;
    _title = track.displayTitle;
    _subtitle = track.metadata.artist ?? track.metadata.album ?? '';
    _coverArtPath = _coverArtForRestoredSession(track);
    _syncTimingFromService();
    _applyDurationFromTrackChange(track);
    _applyEngineDurationIfNeeded();
    _speed = _playbackRepository.service.speed;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> _applySavedSessionSnapshot() async {
    if (_awaitingEngineHydrate && _title.isNotEmpty) return;
    final snap = await _playbackRepository.lastActivePlaybackSnapshot();
    if (snap == null) return;
    _applyPlaybackSnapshot(snap);
    notifyListeners();
  }

  void _applyPlaybackSnapshot(({String itemId, SavedPlaybackState state}) snap) {
    final saved = snap.state;
    final title = saved.displayTitle;
    if (title == null || title.isEmpty) return;

    _currentItemId = snap.itemId;
    _title = title;
    _subtitle = saved.subtitle ?? '';
    if (saved.durationMs != null && saved.durationMs! > 0) {
      _duration = Duration(milliseconds: saved.durationMs!);
    }
    if (saved.positionMs > 0) {
      _setPosition(Duration(milliseconds: saved.positionMs));
    }
    _speed = saved.speed;
    _awaitingEngineHydrate = true;
    _seedCoverArtFromSavedTrack(saved.trackId);
  }

  void _seedCoverArtFromSavedTrack(String trackKey) {
    if (!trackKey.contains('/')) return;
    _setCoverArt(
      directoryPath: p.dirname(trackKey),
      trackFilePath: trackKey,
      preferredPath: null,
    );
  }

  String? _coverArtForRestoredSession(AudioTrack track) => _resolveCoverArt(
    directoryPath: track.directoryPath,
    trackFilePath: track.filePath,
  );

  Duration? _durationFromTrack(AudioTrack track) {
    final ms = track.durationMs;
    if (ms == null || ms <= 0) return null;
    return Duration(milliseconds: ms);
  }

  /// Prefer tagged length until the player reports a real duration.
  void _seedDurationFromTrack(AudioTrack track) {
    if (_duration != Duration.zero) return;
    final seeded = _durationFromTrack(track);
    if (seeded != null) {
      _duration = seeded;
    }
  }

  void _syncTimingFromService() {
    final track = _playbackRepository.service.currentTrack;
    _lastKnownTrackId = track?.id;
    if (track != null) {
      _seedDurationFromTrack(track);
    }
    _setPositionFromEngine(_playbackRepository.service.position);
    _applyEngineDurationIfNeeded();
  }

  /// While cold-starting, just_audio may report zero until seek/duration load.
  void _setPositionFromEngine(Duration position, {bool fromStream = false}) {
    if (_awaitingEngineHydrate &&
        position == Duration.zero &&
        _position > Duration.zero) {
      return;
    }
    _setPosition(position);
    if (fromStream && _awaitingEngineHydrate && position > Duration.zero) {
      _awaitingEngineHydrate = false;
    }
  }

  void _applyEngineDurationIfNeeded() {
    if (_duration > Duration.zero) return;
    final engine = _playbackRepository.service.duration;
    if (engine != null && engine > Duration.zero) {
      _duration = engine;
    }
  }

  void _setPosition(Duration position) {
    _position = position;
    positionListenable.value = position;
  }

  void _setCoverArt({
    required String directoryPath,
    required String? trackFilePath,
    required String? preferredPath,
  }) {
    // Keep preferred path even if the file is missing — AlbumArtFrame shows a
    // placeholder. Avoid File.existsSync here so widget tests can use fake paths
    // without stalling on FileImage decode.
    if (preferredPath != null && preferredPath.isNotEmpty) {
      _coverArtPath = preferredPath;
      return;
    }
    _coverArtPath = _resolveCoverArt(
      directoryPath: directoryPath,
      trackFilePath: trackFilePath,
    );
  }

  Future<void> _saveProgress() async {
    final itemId = _currentItemId;
    if (itemId == null || _playbackRepository.service.currentTrack == null) {
      return;
    }
    final positionMs = _position.inMilliseconds;
    if (positionMs == _lastSavedPositionMs && _speed == _lastSavedSpeed) {
      return;
    }
    _lastSavedPositionMs = positionMs;
    _lastSavedSpeed = _speed;
    await _playbackRepository.saveProgress(itemId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopProgressTimer();
    unawaited(_saveProgress());
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    positionListenable.dispose();
    super.dispose();
  }
}

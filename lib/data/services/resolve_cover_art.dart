import 'dart:io';
import 'dart:typed_data';

import 'package:retroplayer/application/ports/cover_art_source.dart';
import 'package:retroplayer/data/services/album_art_cache.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/data/services/find_album_art.dart';

/// Resolves cover art: folder sidecar first, then embedded art from a track.
class ResolveCoverArt implements CoverArtSource {
  ResolveCoverArt({
    FindAlbumArt findAlbumArt = const FindAlbumArt(),
    required Uint8List? Function(String trackFilePath) readEmbeddedArtwork,
    AlbumArtCache? cache,
  })  : _findAlbumArt = findAlbumArt,
        _readEmbeddedArtwork = readEmbeddedArtwork,
        _cache = cache ??
            AlbumArtCache(
              Directory('${Directory.systemTemp.path}/retroplayer_album_art'),
            );

  final FindAlbumArt _findAlbumArt;
  final Uint8List? Function(String trackFilePath) _readEmbeddedArtwork;
  final AlbumArtCache _cache;

  /// Positive readable (cached) hits only — never cache misses or raw paths.
  final Map<String, String> _sidecarMemo = {};

  /// Returns a filesystem path to cover art, or null when none is available.
  ///
  /// When [extractEmbedded] is true (default), readable sidecars are copied
  /// into [AlbumArtCache] so the UI loads from app-private storage (Android may
  /// discover `cover.jpg` under audio permission but block reading image bytes
  /// without image permission). Unreadable sidecars fall through to embedded.
  ///
  /// When [extractEmbedded] is false (browse / scan), only discovers the
  /// sidecar path — no byte copy and no tag parse — so listing many folders
  /// stays responsive. Prefer a prior cache hit when one exists.
  @override
  String? call({
    required String directoryPath,
    String? trackFilePath,
    bool extractEmbedded = true,
  }) {
    final normalizedDir = normalizeLibraryPath(directoryPath);
    final memoized = _sidecarMemo[normalizedDir];
    if (memoized != null) return memoized;

    final sidecar = _findAlbumArt(normalizedDir);
    if (sidecar != null) {
      final cacheKey = 'sidecar:${normalizeLibraryPath(sidecar)}';
      final existing = _cache.existingPath(cacheKey);
      if (existing != null) {
        _sidecarMemo[normalizedDir] = existing;
        return existing;
      }

      if (!extractEmbedded) {
        // Fast browse path: point at the sidecar without reading it.
        return normalizeLibraryPath(sidecar);
      }

      final cached = _cacheReadableImage(
        cacheKey: cacheKey,
        sourcePath: sidecar,
      );
      if (cached != null) {
        _sidecarMemo[normalizedDir] = cached;
        return cached;
      }
      // Exists but unreadable — fall through to embedded from the audio file.
    }

    final trackPath = trackFilePath;
    if (trackPath == null || trackPath.isEmpty) return null;

    final cacheKey = 'embedded:${normalizeLibraryPath(trackPath)}';
    final hit = _cache.existingPath(cacheKey);
    if (hit != null) return hit;

    if (!extractEmbedded) return null;

    final bytes = _readEmbeddedArtwork(trackPath);
    if (bytes == null || bytes.isEmpty) return null;

    return _cache.put(cacheKey, bytes);
  }

  /// Reads [sourcePath] and stores bytes in the art cache. Null if unreadable.
  String? _cacheReadableImage({
    required String cacheKey,
    required String sourcePath,
  }) {
    final existing = _cache.existingPath(cacheKey);
    if (existing != null) return existing;
    try {
      final bytes = File(sourcePath).readAsBytesSync();
      if (bytes.isEmpty) return null;
      return _cache.put(cacheKey, bytes);
    } on Object {
      return null;
    }
  }
}

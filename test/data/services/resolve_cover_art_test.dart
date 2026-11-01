/// ResolveCoverArt: readable sidecar → app cache; else embedded.
///
/// Evidence:
/// - `caches readable sidecar cover into AlbumArtCache`
/// - `caches embedded bytes when no sidecar`
/// - `reuses cache without calling reader again`
/// - `returns null when neither sidecar nor embedded art exists`
/// - `skips embedded extract when extractEmbedded is false`
/// - `returns sidecar path without byte copy when extractEmbedded is false`
/// - `does not sticky-cache sidecar misses`
/// - `falls through to embedded when sidecar path is unreadable`
library;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/album_art_cache.dart';
import 'package:retroplayer/data/services/find_album_art.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';

class _FixedFindAlbumArt extends FindAlbumArt {
  const _FixedFindAlbumArt(this.path);
  final String? path;
  @override
  String? call(String directoryPath) => path;
}

void main() {
  late Directory tempDir;
  late Directory cacheDir;
  late AlbumArtCache cache;

  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resolve_cover_');
    cacheDir = Directory('${tempDir.path}/cache');
    cache = AlbumArtCache(cacheDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ResolveCoverArt', () {
    test('caches readable sidecar cover into AlbumArtCache', () async {
      final cover = File('${tempDir.path}/cover.jpg');
      await cover.writeAsBytes(jpegBytes);
      var reads = 0;
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) {
          reads++;
          return jpegBytes;
        },
        cache: cache,
      );

      final path = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
      );

      expect(path, isNotNull);
      expect(path, isNot(cover.path));
      expect(path!.startsWith(cacheDir.path), isTrue);
      expect(File(path).readAsBytesSync(), jpegBytes);
      expect(reads, 0);
    });

    test('caches embedded bytes when no sidecar', () {
      var reads = 0;
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) {
          reads++;
          return jpegBytes;
        },
        cache: cache,
      );

      final path = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
      );

      expect(path, isNotNull);
      expect(File(path!).existsSync(), isTrue);
      expect(File(path).readAsBytesSync(), jpegBytes);
      expect(path.endsWith('.jpg'), isTrue);
      expect(reads, 1);
    });

    test('reuses cache without calling reader again', () {
      var reads = 0;
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) {
          reads++;
          return jpegBytes;
        },
        cache: cache,
      );

      final first = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
      );
      final second = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
      );

      expect(first, second);
      expect(reads, 1);
    });

    test('returns null when neither sidecar nor embedded art exists', () {
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) => null,
        cache: cache,
      );

      expect(
        resolve(
          directoryPath: tempDir.path,
          trackFilePath: '${tempDir.path}/track.mp3',
        ),
        isNull,
      );
    });

    test('skips embedded extract when extractEmbedded is false', () {
      var reads = 0;
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) {
          reads++;
          return jpegBytes;
        },
        cache: cache,
      );

      expect(
        resolve(
          directoryPath: tempDir.path,
          trackFilePath: '${tempDir.path}/track.mp3',
          extractEmbedded: false,
        ),
        isNull,
      );
      expect(reads, 0);
    });

    test(
      'returns sidecar path without byte copy when extractEmbedded is false',
      () async {
        final cover = File('${tempDir.path}/cover.jpg');
        await cover.writeAsBytes(jpegBytes);
        final resolve = ResolveCoverArt(
          readEmbeddedArtwork: (_) => jpegBytes,
          cache: cache,
        );

        final path = resolve(
          directoryPath: tempDir.path,
          trackFilePath: '${tempDir.path}/track.mp3',
          extractEmbedded: false,
        );

        expect(path, isNotNull);
        expect(path!.startsWith(cacheDir.path), isFalse);
        expect(File(path).readAsBytesSync(), jpegBytes);
        expect(cacheDir.existsSync() ? cacheDir.listSync() : const [], isEmpty);
      },
    );

    test('does not sticky-cache sidecar misses', () async {
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (_) => null,
        cache: cache,
      );

      expect(
        resolve(
          directoryPath: tempDir.path,
          trackFilePath: '${tempDir.path}/track.mp3',
          extractEmbedded: false,
        ),
        isNull,
      );

      final cover = File('${tempDir.path}/cover.jpg');
      await cover.writeAsBytes(jpegBytes);

      final path = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
        extractEmbedded: false,
      );
      expect(path, isNotNull);
      expect(File(path!).readAsBytesSync(), jpegBytes);
    });

    test('falls through to embedded when sidecar path is unreadable', () {
      var reads = 0;
      final resolve = ResolveCoverArt(
        findAlbumArt: _FixedFindAlbumArt('${tempDir.path}/missing_cover.jpg'),
        readEmbeddedArtwork: (_) {
          reads++;
          return jpegBytes;
        },
        cache: cache,
      );

      final path = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/track.mp3',
      );

      expect(path, isNotNull);
      expect(File(path!).readAsBytesSync(), jpegBytes);
      expect(reads, 1);
    });

    test('uses distinct cache entries per track file', () {
      final resolve = ResolveCoverArt(
        readEmbeddedArtwork: (path) {
          if (path.endsWith('a.mp3')) {
            return jpegBytes;
          }
          return Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]);
        },
        cache: cache,
      );

      final a = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/a.mp3',
      );
      final b = resolve(
        directoryPath: tempDir.path,
        trackFilePath: '${tempDir.path}/b.mp3',
      );

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a, isNot(b));
      expect(a!.endsWith('.jpg'), isTrue);
      expect(b!.endsWith('.png'), isTrue);
    });
  });
}

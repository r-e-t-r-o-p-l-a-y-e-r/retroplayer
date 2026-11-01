/// AlbumArtCache persistence for extracted embedded artwork.
///
/// Evidence:
/// - `put writes bytes and existingPath finds them`
/// - `extensionForBytes sniffs jpeg and png magic`
library;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/album_art_cache.dart';

void main() {
  late Directory tempDir;
  late AlbumArtCache cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('album_art_cache_');
    cache = AlbumArtCache(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AlbumArtCache', () {
    test('put writes bytes and existingPath finds them', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);
      final path = cache.put('embedded:/music/a.mp3', bytes);

      expect(File(path).existsSync(), isTrue);
      expect(cache.existingPath('embedded:/music/a.mp3'), path);
      expect(cache.existingPath('embedded:/music/missing.mp3'), isNull);
    });

    test('extensionForBytes sniffs jpeg and png magic', () {
      expect(
        AlbumArtCache.extensionForBytes(
          Uint8List.fromList([0xFF, 0xD8, 0xFF]),
        ),
        '.jpg',
      );
      expect(
        AlbumArtCache.extensionForBytes(
          Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]),
        ),
        '.png',
      );
      expect(
        AlbumArtCache.extensionForBytes(Uint8List.fromList([1, 2, 3])),
        '.img',
      );
    });
  });
}

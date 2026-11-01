/// loadAlbumArtBytes: cover.jpg must yield bytes (regression for grey squares).
///
/// Evidence:
/// - `returns bytes for cover.jpg on disk`
/// - `returns null for missing path`
/// - `returns null for empty file`
/// - `returns null for empty string path`
library;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_loader.dart';

void main() {
  late Directory tempDir;

  // JPEG SOI + a few payload bytes + EOI (non-empty file).
  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9, 0x01, 0x02]);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('album_art_loader_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('loadAlbumArtBytes', () {
    test('returns bytes for cover.jpg on disk', () async {
      final cover = File('${tempDir.path}/cover.jpg');
      await cover.writeAsBytes(jpegBytes);

      final bytes = await loadAlbumArtBytes(cover.path);

      expect(bytes, isNotNull);
      expect(bytes, jpegBytes);
    });

    test('returns null for missing path', () async {
      expect(
        await loadAlbumArtBytes('${tempDir.path}/missing.jpg'),
        isNull,
      );
    });

    test('returns null for empty file', () async {
      final empty = File('${tempDir.path}/cover.jpg');
      await empty.writeAsBytes(const []);

      expect(await loadAlbumArtBytes(empty.path), isNull);
    });

    test('returns null for empty string path', () async {
      expect(await loadAlbumArtBytes(''), isNull);
    });
  });
}

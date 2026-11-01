/// FindAlbumArt cover filename discovery in album folders.
///
/// Evidence:
/// - `finds cover.jpg case-insensitively`
/// - `prefers cover.jpg over other images in the folder`
/// - `finds folder.jpg before less common names`
/// - `falls back to any image when no preferred name exists`
/// - `returns null when directory has no artwork`
/// - `returns null for missing directory`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/find_album_art.dart';

void main() {
  late Directory tempDir;
  late FindAlbumArt findAlbumArt;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('album_art_test_');
    findAlbumArt = const FindAlbumArt();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FindAlbumArt', () {
    test('finds cover.jpg case-insensitively', () async {
      await File('${tempDir.path}/Cover.JPG').writeAsBytes([0, 1, 2]);

      expect(findAlbumArt(tempDir.path), '${tempDir.path}/Cover.JPG');
    });

    test('prefers cover.jpg over other images in the folder', () async {
      await File('${tempDir.path}/scan0001.jpg').writeAsBytes([0, 1, 2]);
      await File('${tempDir.path}/cover.jpg').writeAsBytes([0, 1, 2]);

      expect(findAlbumArt(tempDir.path), '${tempDir.path}/cover.jpg');
    });

    test('finds folder.jpg before less common names', () async {
      await File('${tempDir.path}/notes.txt').writeAsString('ignore');
      await File('${tempDir.path}/folder.jpg').writeAsBytes([0, 1, 2]);

      expect(findAlbumArt(tempDir.path), '${tempDir.path}/folder.jpg');
    });

    test('falls back to any image when no preferred name exists', () async {
      await File('${tempDir.path}/track.mp3').writeAsBytes([0]);
      await File('${tempDir.path}/Album Art Final.png').writeAsBytes([0, 1, 2]);

      expect(
        findAlbumArt(tempDir.path),
        '${tempDir.path}/Album Art Final.png',
      );
    });

    test('prefers jpg over png when falling back to arbitrary images', () async {
      await File('${tempDir.path}/z-art.png').writeAsBytes([0, 1, 2]);
      await File('${tempDir.path}/a-photo.jpg').writeAsBytes([0, 1, 2]);

      expect(findAlbumArt(tempDir.path), '${tempDir.path}/a-photo.jpg');
    });

    test('returns null when directory has no artwork', () async {
      await File('${tempDir.path}/track.mp3').writeAsBytes([0]);

      expect(findAlbumArt(tempDir.path), isNull);
    });

    test('returns null for missing directory', () {
      expect(findAlbumArt('/does/not/exist'), isNull);
    });
  });
}

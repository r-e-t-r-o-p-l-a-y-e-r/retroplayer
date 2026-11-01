/// WritePlaylistFile + ParsePlaylistFile M3U relative/absolute round-trip.
///
/// Evidence:
/// - `round-trips entries with relative paths`
/// - `parse resolves absolute entries in file`
/// - `parses UTF-8 playlist paths with Slavic characters`
/// - `parses UTF-8 BOM playlist paths with Slavic characters`
/// - `parses Windows-1250 playlist paths with Slavic characters`
library;
import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/data/services/parse_playlist_file.dart';
import 'package:retroplayer/data/services/write_playlist_file.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('retroplayer-playlist-');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('WritePlaylistFile + ParsePlaylistFile', () {
    test('round-trips entries with relative paths', () async {
      final playlistPath = '${tempDir.path}/mixes/road.m3u';
      final trackA = '${tempDir.path}/mixes/track-a.mp3';
      final trackB = '${tempDir.path}/mixes/sub/track-b.flac';

      await const WritePlaylistFile()(
        playlistPath,
        [trackA, trackB],
      );

      final file = File(playlistPath);
      expect(await file.exists(), isTrue);
      final contents = await file.readAsString();
      expect(contents, contains('#EXTM3U'));
      expect(contents, contains('track-a.mp3'));
      expect(contents, contains(p.join('sub', 'track-b.flac')));

      final entries = await const ParsePlaylistFile()(playlistPath);
      expect(entries, [trackA, trackB]);
    });

    test('parse resolves absolute entries in file', () async {
      final playlistPath = '${tempDir.path}/abs.m3u';
      final absolute = '${tempDir.path}/song.mp3';
      await File(playlistPath).writeAsString('#EXTM3U\n$absolute\n');

      final entries = await const ParsePlaylistFile()(playlistPath);
      expect(entries, [absolute]);
    });

    test('parses UTF-8 playlist paths with Slavic characters', () async {
      final playlistPath = '${tempDir.path}/slavic.m3u';
      final absolute = '${tempDir.path}/kuća-šuma.mp3';
      await File(playlistPath).writeAsBytes(
        utf8.encode('#EXTM3U\n$absolute\n'),
      );

      final entries = await const ParsePlaylistFile()(playlistPath);
      expect(entries, [absolute]);
    });

    test('parses UTF-8 BOM playlist paths with Slavic characters', () async {
      final playlistPath = '${tempDir.path}/bom.m3u';
      final absolute = '${tempDir.path}/ćevapčići.mp3';
      await File(playlistPath).writeAsBytes([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode('#EXTM3U\n$absolute\n'),
      ]);

      final entries = await const ParsePlaylistFile()(playlistPath);
      expect(entries, [absolute]);
    });

    test('parses Windows-1250 playlist paths with Slavic characters', () async {
      final playlistPath = '${tempDir.path}/cp1250.m3u';
      final absolute = '${tempDir.path}/Đorđe.mp3';
      await File(playlistPath).writeAsBytes(
        windows1250.encode('#EXTM3U\n$absolute\n'),
      );

      final entries = await const ParsePlaylistFile()(playlistPath);
      expect(entries, [absolute]);
    });
  });
}

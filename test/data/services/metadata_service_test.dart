/// MetadataService local-file title fallback, P0 formats, and encoding repair.
///
/// Evidence:
/// - `returns filename-based title when tags are missing`
/// - `includes mp3 m4a m4b flac wav`
/// - `repairs UTF-8 ID3 text mislabeled as Latin-1 (ćčš)`
/// - `repairs Windows-1250 ID3 text mislabeled as Latin-1`
library;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';

void main() {
  group('MetadataService', () {
    late MetadataService service;
    late Directory tempDir;

    setUp(() async {
      service = MetadataService();
      tempDir = await Directory.systemTemp.createTemp('rpc_meta_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns filename-based title when tags are missing', () async {
      final file = File('${tempDir.path}/untitled.mp3');
      await file.writeAsBytes([0, 1, 2]);

      final metadata = await service.readMetadata(file.path);

      expect(metadata.title, 'untitled');
    });

    test('repairs UTF-8 ID3 text mislabeled as Latin-1 (ćčš)', () async {
      const title = 'Kuća i šuma';
      const artist = 'Đorđe';
      const album = 'Čaj od šumskog voća';
      final file = File('${tempDir.path}/utf8-latin1.mp3');
      await file.writeAsBytes(
        _id3v23ClaimingLatin1(
          titleBytes: utf8.encode(title),
          artistBytes: utf8.encode(artist),
          albumBytes: utf8.encode(album),
        ),
      );

      final metadata = await service.readMetadata(file.path);

      expect(metadata.title, title);
      expect(metadata.artist, artist);
      expect(metadata.album, album);
    });

    test('repairs Windows-1250 ID3 text mislabeled as Latin-1', () async {
      const title = 'ćevapčići';
      const artist = 'Željko';
      const album = 'Šuma';
      final file = File('${tempDir.path}/cp1250-latin1.mp3');
      await file.writeAsBytes(
        _id3v23ClaimingLatin1(
          titleBytes: windows1250.encode(title),
          artistBytes: windows1250.encode(artist),
          albumBytes: windows1250.encode(album),
        ),
      );

      final metadata = await service.readMetadata(file.path);

      expect(metadata.title, title);
      expect(metadata.artist, artist);
      expect(metadata.album, album);
    });
  });

  group('SupportedFormats P0', () {
    test('includes mp3 m4a m4b flac wav', () {
      for (final ext in ['.mp3', '.m4a', '.m4b', '.flac', '.wav']) {
        expect(SupportedFormats.isP0('/music/file$ext'), isTrue);
      }
    });
  });
}

/// Minimal ID3v2.3 tag with text frames that claim ISO-8859-1 (encoding 0)
/// while carrying [titleBytes]/[artistBytes]/[albumBytes] in another charset.
Uint8List _id3v23ClaimingLatin1({
  required List<int> titleBytes,
  required List<int> artistBytes,
  required List<int> albumBytes,
}) {
  List<int> textFrame(String id, List<int> textBytes) {
    final body = <int>[0x00, ...textBytes]; // encoding 0 = ISO-8859-1
    final size = body.length;
    return [
      ...id.codeUnits,
      (size >> 24) & 0xff,
      (size >> 16) & 0xff,
      (size >> 8) & 0xff,
      size & 0xff,
      0x00,
      0x00,
      ...body,
    ];
  }

  final frames = <int>[
    ...textFrame('TIT2', titleBytes),
    ...textFrame('TPE1', artistBytes),
    ...textFrame('TALB', albumBytes),
  ];
  final tagSize = frames.length;

  return Uint8List.fromList([
    ...'ID3'.codeUnits,
    0x03,
    0x00,
    0x00,
    (tagSize >> 21) & 0x7f,
    (tagSize >> 14) & 0x7f,
    (tagSize >> 7) & 0x7f,
    tagSize & 0x7f,
    ...frames,
  ]);
}

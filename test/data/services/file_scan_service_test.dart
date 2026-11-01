/// Recursive audio discovery and SupportedFormats P0 recognition.
///
/// Evidence:
/// - `finds P0 audio files recursively`
/// - `recognizes P0 extensions`
library;
import 'dart:io';

import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileScanService', () {
    late Directory tempDir;
    late FileScanService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('rpc_scan_');
      service = FileScanService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds P0 audio files recursively', () async {
      await File('${tempDir.path}/song.mp3').create();
      await File('${tempDir.path}/nested/book.flac').create(recursive: true);
      await File('${tempDir.path}/readme.txt').create();

      final files = await service.scanDirectory(tempDir.path);

      expect(files, hasLength(2));
      expect(files.any((f) => f.endsWith('song.mp3')), isTrue);
      expect(files.any((f) => f.endsWith('book.flac')), isTrue);
    });
  });

  group('SupportedFormats', () {
    test('recognizes P0 extensions', () {
      expect(SupportedFormats.isP0('/music/track.MP3'), isTrue);
      expect(SupportedFormats.isP0('/music/track.flac'), isTrue);
      expect(SupportedFormats.isP0('/music/track.wav'), isTrue);
      expect(SupportedFormats.isP0('/music/track.ogg'), isFalse);
    });
  });
}

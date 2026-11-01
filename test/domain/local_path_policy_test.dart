/// isLocalFilesystemPath local-only policy (reject remote URI schemes).
///
/// Evidence:
/// - `accepts absolute and relative filesystem paths`
/// - `accepts file URIs`
/// - `rejects remote and streaming schemes`
/// - `rejects empty`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/local_path_policy.dart';

void main() {
  group('isLocalFilesystemPath', () {
    test('accepts absolute and relative filesystem paths', () {
      expect(isLocalFilesystemPath('/music/track.mp3'), isTrue);
      expect(isLocalFilesystemPath('album/track.flac'), isTrue);
      expect(isLocalFilesystemPath(r'C:\Music\track.mp3'), isTrue);
    });

    test('accepts file URIs', () {
      expect(isLocalFilesystemPath('file:///music/track.mp3'), isTrue);
    });

    test('rejects remote and streaming schemes', () {
      expect(isLocalFilesystemPath('https://example.com/a.mp3'), isFalse);
      expect(isLocalFilesystemPath('http://cdn/x.mp3'), isFalse);
      expect(isLocalFilesystemPath('rtsp://cam/stream'), isFalse);
      expect(isLocalFilesystemPath('ftp://host/a.mp3'), isFalse);
    });

    test('rejects empty', () {
      expect(isLocalFilesystemPath(''), isFalse);
      expect(isLocalFilesystemPath('   '), isFalse);
    });
  });
}

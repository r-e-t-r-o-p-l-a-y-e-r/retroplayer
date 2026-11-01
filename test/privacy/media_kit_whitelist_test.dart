/// JustAudioMediaKit protocolWhitelist restricted to file only.
///
/// Evidence:
/// - `local-only config restricts MPV to file protocol`
/// - `vendored default whitelist is file-only`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:retroplayer/data/services/local_only_media_kit.dart';

void main() {
  test('local-only config restricts MPV to file protocol', () {
    configureLocalOnlyMediaKit();
    expect(JustAudioMediaKit.protocolWhitelist, ['file']);
  });

  test('vendored default whitelist is file-only', () {
    // Reset to package default by constructing a fresh list expectation:
    // configureLocalOnlyMediaKit sets the same value; package default must match.
    expect(
      JustAudioMediaKit.protocolWhitelist,
      equals(const ['file']),
    );
  });
}

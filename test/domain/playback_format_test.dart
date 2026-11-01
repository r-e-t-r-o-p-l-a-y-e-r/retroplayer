/// P0 vs supported format classification for scanning/playback.
///
/// Evidence:
/// - `all P0 extensions are recognized for scanning`
/// - `ogg is not P0`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/supported_formats.dart';

void main() {
  group('P0 playback formats', () {
    test('all P0 extensions are recognized for scanning', () {
      const p0 = ['song.mp3', 'track.m4a', 'book.m4b', 'album.flac', 'sample.wav'];
      for (final name in p0) {
        expect(
          SupportedFormats.isP0('/library/$name'),
          isTrue,
          reason: '$name should be P0',
        );
      }
    });

    test('ogg is not P0', () {
      expect(SupportedFormats.isP0('/library/track.ogg'), isFalse);
      expect(SupportedFormats.isSupported('/library/track.ogg'), isTrue);
    });
  });
}

/// SortLibrary orders items by track number, then title.
///
/// Evidence:
/// - `sorts by track number then title`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';

import '../../helpers/track_factory.dart';

void main() {
  test('sorts by track number then title', () {
    final items = [
      LibraryItem.track(
        track: testTrack(
          id: 'b',
          filePath: '/b.mp3',
          metadata: const TrackMetadata(title: 'Beta', trackNumber: 1),
        ),
      ),
      LibraryItem.track(
        track: testTrack(
          id: 'a',
          filePath: '/a.mp3',
          metadata: const TrackMetadata(title: 'Alpha', trackNumber: 1),
        ),
      ),
      LibraryItem.track(
        track: testTrack(
          id: 'c',
          filePath: '/c.mp3',
          metadata: const TrackMetadata(title: 'Gamma', trackNumber: 2),
        ),
      ),
    ];

    final sorted = SortLibrary()(items);
    expect(sorted.map((item) => item.title), ['Alpha', 'Beta', 'Gamma']);
  });
}

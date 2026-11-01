/// Highlighted track scrolls into view after jump-to-playing.
///
/// Evidence:
/// - `scrollHighlightedTrackIntoView scrolls folder audio row for highlight`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/test_library_repository.dart';
import '../../../helpers/track_factory.dart';

class _RecordingScroller extends LibraryListScroller {
  final jumps = <int>[];

  @override
  void jumpToRow(int rowIndex, {double alignment = 0.15}) {
    jumps.add(rowIndex);
  }
}

void main() {
  test('scrollHighlightedTrackIntoView scrolls folder audio row for highlight',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    repo.seedChildFolders('/music', const []);
    final items = <LibraryItem>[
      for (var i = 0; i < 30; i++)
        LibraryItem.track(
          track: testTrack(
            filePath: '/music/track_${i.toString().padLeft(2, '0')}.mp3',
            directoryPath: '/music',
          ),
        ),
    ];
    repo.seedDirectory('/music', items);

    final vm = LibraryViewModel(libraryRepository: repo);
    addTearDown(vm.dispose);
    final scroller = _RecordingScroller();
    vm.attachListScroller(scroller);

    await vm.load();
    await vm.navigateToBrowsePath('/music');

    final lastTrack = switch (items.last) {
      LibraryTrackItem(:final track) => track,
      _ => throw StateError('expected track item'),
    };
    await vm.locateNowPlaying(track: lastTrack, playingItemId: null);

    scroller.jumps.clear();
    vm.scrollHighlightedTrackIntoView();

    expect(scroller.jumps, isNotEmpty);
    expect(scroller.jumps.last, 29);
  });
}

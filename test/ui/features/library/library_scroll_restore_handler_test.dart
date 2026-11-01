/// Browse-up restores scroll on the parent path key, not the active child scroller.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/test_library_repository.dart';

void main() {
  test('navigateToBrowsePathWithRestore targets parent scroll key', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');

    final vm = LibraryViewModel(libraryRepository: repo);
    addTearDown(vm.dispose);

    final childController = RestoringScrollController();
    final parentController = RestoringScrollController();
    final scroller = LibraryListScroller()..controller = childController;
    vm.attachListScroller(scroller);

    String? restoredKey;
    double? restoredOffset;
    vm.scrollRestoreHandler = (key, offset) {
      restoredKey = key;
      restoredOffset = offset;
      if (key == normalizeLibraryPath('/music')) {
        parentController.pendingInitialOffset = offset;
      }
    };

    vm.activeScrollOffsetReader = () => 480.0;

    await vm.load();
    await vm.navigateToBrowsePath('/music');
    vm.rememberBrowseScrollOffset();
    expect(vm.scrollOffsetForBrowseKey('/music'), 480);

    await vm.browseInto('/music/Author');
    expect(childController, isNot(same(parentController)));

    restoredKey = null;
    restoredOffset = null;
    await vm.navigateToBrowsePathWithRestore('/music');

    expect(restoredKey, normalizeLibraryPath('/music'));
    expect(restoredOffset, 480);
    expect(parentController.pendingInitialOffset, 480);
  });
}

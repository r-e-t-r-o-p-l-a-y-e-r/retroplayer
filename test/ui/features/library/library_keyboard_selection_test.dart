/// LibraryViewModel keyboard selection indices and parent-folder scroll restore.
///
/// Evidence:
/// - `moveKeyboardSelection selects rows`
/// - `selectLastKeyboardRow selects final entry`
/// - `selected playlist row is delete-enabled`
/// - `navigateToParentFolder selects the folder that was opened`
/// - `rememberBrowseScrollOffset restores after simulated settings cover`
/// - `navigateToParentFolder restores saved scroll offset not row snap`
/// - `navigateToParentFolder re-applies offset after deferred parent scan`
/// - `navigateToBrowsePathWithRestore to parent restores saved scroll offset`
/// - `deferred directory update does not reset offset while folder selection restore pending`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/ui/core/keyboard/selectable_library_row.dart';
import 'package:retroplayer/ui/features/library/library_list_scroller.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/test_library_repository.dart';

class _RecordingScroller extends LibraryListScroller {
  final jumps = <int>[];
  final offsets = <double>[];
  double? fakeOffset;

  @override
  double? get currentOffset => fakeOffset;

  @override
  void jumpToRow(int rowIndex, {double alignment = 0.15}) {
    jumps.add(rowIndex);
  }

  @override
  void jumpToOffset(double offset) {
    offsets.add(offset);
  }
}

void main() {
  late LibraryViewModel vm;

  setUp(() async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    await storage.markAppCreatedPlaylist('/music/a.m3u');
    repo.seedDirectory('/music', [
      LibraryItem.playlist(
        playlist: PlaylistFile(filePath: '/music/a.m3u', entryPaths: const []),
      ),
    ]);
    vm = LibraryViewModel(libraryRepository: repo);
    await vm.load();
    await vm.navigateToBrowsePath('/music');
  });

  test('moveKeyboardSelection selects rows', () {
    expect(vm.selectableRows, isNotEmpty);
    vm.moveKeyboardSelection(1);
    expect(vm.keyboardSelectedIndex, 0);
  });

  test('selectLastKeyboardRow selects final entry', () {
    vm.selectLastKeyboardRow();
    expect(vm.keyboardSelectedIndex, vm.selectableRows.length - 1);
  });

  test('selected playlist row is delete-enabled', () {
    vm.selectLastKeyboardRow();
    final row = vm.selectableRows[vm.keyboardSelectedIndex!];
    expect(row.deleteAction, KeyboardDeleteAction.deletePlaylist);
  });

  test('navigateToParentFolder selects the folder that was opened', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final nestedVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(nestedVm.dispose);
    await nestedVm.load();
    await nestedVm.navigateToBrowsePath('/music');
    await nestedVm.browseInto('/music/Author');

    expect(nestedVm.keyboardSelectedIndex, isNull);

    await nestedVm.navigateToParentFolder();

    expect(nestedVm.browsePath, '/music');
    expect(nestedVm.keyboardSelectedIndex, isNotNull);
    final row = nestedVm.selectableRows[nestedVm.keyboardSelectedIndex!];
    expect(row.kind, SelectableRowKind.folder);
    expect(row.folderPath, normalizeLibraryPath('/music/Author'));
  });

  test('rememberBrowseScrollOffset restores after simulated settings cover',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final nestedVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(nestedVm.dispose);
    final scroller = _RecordingScroller()..fakeOffset = 510;
    nestedVm.attachListScroller(scroller);

    await nestedVm.load();
    await nestedVm.navigateToBrowsePath('/music');
    nestedVm.rememberBrowseScrollOffset();

    scroller.fakeOffset = 0;
    scroller.offsets.clear();
    scroller.jumps.clear();
    nestedVm.restoreBrowseScrollOffsetAfterLayout();

    expect(scroller.offsets, contains(510));
    expect(scroller.jumps, isEmpty);
  });

  test('navigateToParentFolder restores saved scroll offset not row snap',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final nestedVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(nestedVm.dispose);
    final scroller = _RecordingScroller()..fakeOffset = 420;
    nestedVm.attachListScroller(scroller);

    await nestedVm.load();
    await nestedVm.navigateToBrowsePath('/music');
    await nestedVm.browseInto('/music/Author');

    scroller.jumps.clear();
    scroller.offsets.clear();

    await nestedVm.navigateToParentFolder();

    expect(nestedVm.browsePath, '/music');
    expect(scroller.offsets, contains(420));
    expect(scroller.jumps, isEmpty);
    final authorIndex = nestedVm.keyboardSelectedIndex!;
    expect(
      nestedVm.selectableRows[authorIndex].folderPath,
      normalizeLibraryPath('/music/Author'),
    );
  });

  test('navigateToParentFolder re-applies offset after deferred parent scan',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final nestedVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(nestedVm.dispose);
    final scroller = _RecordingScroller()..fakeOffset = 280;
    nestedVm.attachListScroller(scroller);

    await nestedVm.load();
    await nestedVm.navigateToBrowsePath('/music');
    await nestedVm.browseInto('/music/Author');

    // Force a deferred rescan of the parent after browse-up.
    repo.invalidateDirectory('/music');
    scroller.jumps.clear();
    scroller.offsets.clear();

    await nestedVm.navigateToParentFolder();
    expect(scroller.offsets, isNotEmpty);
    expect(scroller.offsets.first, 280);
    expect(scroller.jumps, isEmpty);
    final authorIndex = nestedVm.keyboardSelectedIndex!;
    expect(
      nestedVm.selectableRows[authorIndex].folderPath,
      normalizeLibraryPath('/music/Author'),
    );

    // Deferred scan rebuilds the list; offset restore must run again.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(scroller.offsets.length, greaterThanOrEqualTo(2));
    expect(scroller.offsets.last, 280);
    expect(scroller.jumps, isEmpty);
    expect(nestedVm.keyboardSelectedIndex, authorIndex);
  });

  test('navigateToBrowsePathWithRestore to parent restores saved scroll offset',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final vm = LibraryViewModel(libraryRepository: repo);
    addTearDown(vm.dispose);
    final scroller = _RecordingScroller()..fakeOffset = 420;
    vm.attachListScroller(scroller);

    await vm.load();
    await vm.navigateToBrowsePath('/music');
    await vm.browseInto('/music/Author');

    scroller.jumps.clear();
    scroller.offsets.clear();

    await vm.navigateToBrowsePathWithRestore('/music');

    expect(vm.browsePath, '/music');
    expect(scroller.offsets, contains(420));
    expect(scroller.jumps, isEmpty);
  });

  test(
      'deferred directory update does not reset offset while folder selection restore pending',
      () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final vm = LibraryViewModel(libraryRepository: repo);
    addTearDown(vm.dispose);
    final scroller = _RecordingScroller()..fakeOffset = 280;
    vm.attachListScroller(scroller);

    await vm.load();
    await vm.navigateToBrowsePath('/music');
    await vm.browseInto('/music/Author');

    repo.invalidateDirectory('/music');
    scroller.jumps.clear();
    scroller.offsets.clear();

    await vm.navigateToBrowsePathWithRestore('/music');

    expect(scroller.offsets, isNotEmpty);
    expect(scroller.offsets.first, 280);
    expect(scroller.jumps, isEmpty);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(scroller.offsets.last, 280);
  });

  test('jumpToLibraryIndexChar selects first matching row', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final jumpVm = LibraryViewModel(libraryRepository: repo);
    addTearDown(jumpVm.dispose);
    await jumpVm.load();
    await jumpVm.navigateToBrowsePath('/music');

    expect(jumpVm.indexForLibraryIndexChar('A'), isNotNull);
    jumpVm.jumpToLibraryIndexChar('A');
    expect(jumpVm.keyboardSelectedIndex, isNotNull);
    final row = jumpVm.selectableRows[jumpVm.keyboardSelectedIndex!];
    expect(row.folderName?.toUpperCase().startsWith('A'), isTrue);

    // Same letter again still updates selection (scrubber re-entry).
    final again = jumpVm.indexForLibraryIndexChar('A');
    jumpVm.jumpToSelectableRow(again!);
    expect(jumpVm.keyboardSelectedIndex, again);
  });
}

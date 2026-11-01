/// UC-1: adding a library root from the shell's Add folder button.
///
/// Evidence:
/// - `picked folder becomes a library root and opens`
/// - `cancelled picker adds nothing`
/// - `denied storage access shows a message and skips the picker`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/library/add_library_folder.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';
import '../../../helpers/system_back.dart';

class _FakeFolderPicker extends LibraryFolderPicker {
  _FakeFolderPicker({this.granted = true, this.path});

  final bool granted;
  final String? path;
  int picks = 0;

  @override
  Future<bool> requestAccess() async => granted;

  @override
  Future<String?> pickFolder() async {
    picks++;
    return path;
  }
}

Future<RealApp> _pumpEmptyLibrary(
  WidgetTester tester,
  _FakeFolderPicker picker,
) => pumpRealApp(
  tester,
  roots: const [],
  seed: seedAuthorBook1Hierarchy,
  folderPicker: picker,
);

Finder get _addFolderButton => find.byIcon(Icons.folder_open);

void main() {
  testWidgets('picked folder becomes a library root and opens', (tester) async {
    final picker = _FakeFolderPicker(path: '/music');
    final app = await _pumpEmptyLibrary(tester, picker);
    final l10n = enL10n(tester);
    expect(find.text(l10n.noFoldersAdded), findsOneWidget);

    await tester.tap(_addFolderButton);
    await pumpUntil(tester, () => find.text('Author').evaluate().isNotEmpty);

    expect(picker.picks, 1);
    expect(await tester.runAsync(app.storage.getLibraryRoots), ['/music']);
    expect(app.libraryVm.browsePath, '/music');
    expect(find.text(l10n.noFoldersAdded), findsNothing);
    expect(find.text('Author'), findsOneWidget);
  });

  testWidgets('cancelled picker adds nothing', (tester) async {
    final picker = _FakeFolderPicker();
    final app = await _pumpEmptyLibrary(tester, picker);

    await tester.tap(_addFolderButton);
    await pumpFrames(tester, count: 5);

    expect(picker.picks, 1);
    expect(await tester.runAsync(app.storage.getLibraryRoots), isEmpty);
    expect(find.text(enL10n(tester).noFoldersAdded), findsOneWidget);
  });

  testWidgets('denied storage access shows a message and skips the picker', (
    tester,
  ) async {
    final picker = _FakeFolderPicker(granted: false, path: '/music');
    final app = await _pumpEmptyLibrary(tester, picker);

    await tester.tap(_addFolderButton);
    await pumpFrames(tester, count: 5);

    expect(picker.picks, 0);
    expect(find.text(enL10n(tester).audioPermissionRequired), findsOneWidget);
    expect(await tester.runAsync(app.storage.getLibraryRoots), isEmpty);
  });
}

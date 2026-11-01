/// Library keyboard focus sync: play control, arrows, enter browse, backspace.
///
/// Evidence:
/// - `folder row exposes one play control`
/// - `enter on play button plays folder without browsing`
/// - `moveSelection syncs keyboard index and row focus`
/// - `arrow enter browses highlighted folder`
/// - `backspace parent restores folder selection for enter`
library;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/ui/core/keyboard/app_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/keyboard/library_row_focus.dart';
import 'package:retroplayer/ui/core/keyboard/list_navigation_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_intents.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/keyboard_test_helpers.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';

void main() {
  late LibraryViewModel vm;
  late RecordingPlayback recordingPlayback;

  setUp(() async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);
    repo.seedTracksUnderFolder('/music/Author', [
      testTrack(
        filePath: '/music/Author/Book1/ch01.mp3',
        directoryPath: '/music/Author/Book1',
      ),
    ]);
    vm = LibraryViewModel(libraryRepository: repo);
    await vm.load();
    await vm.navigateToBrowsePath('/music');
    recordingPlayback = RecordingPlayback();
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: recordingPlayback,
        storageService: LibraryStorageService(AppDatabase.inMemory()),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider.value(value: playerVm),
        ],
        child: wrapWithL10n(
          const AppShortcuts(
            child: LibraryView(
              autoLoad: false,
              restoreSessionOnMount: false,
              embeddedInShell: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  BuildContext listNavContext(WidgetTester tester) {
    return tester.element(
      find.descendant(
        of: find.byType(ListNavigationShortcuts),
        matching: find.byType(CustomScrollView),
      ),
    );
  }

  testWidgets('folder row exposes one play control', (tester) async {
    await pumpLibrary(tester);

    final row = find.ancestor(
      of: find.text('Author'),
      matching: find.byType(LibraryRowFocusGroup),
    );
    expect(
      find.descendant(of: row, matching: find.byType(IconButton)),
      findsOneWidget,
    );
    final playButton = tester.widget<IconButton>(
      find.descendant(of: row, matching: find.byType(IconButton)),
    );
    expect(playButton.focusNode, isNull);

    final focusWidget = tester.widget<Focus>(
      find.byKey(const ValueKey('library_row_play_focus')),
    );
    expect(focusWidget.focusNode, isNotNull);
  });

  testWidgets('enter on play button plays folder without browsing', (tester) async {
    await pumpLibrary(tester);

    final focusWidget = tester.widget<Focus>(
      find.byKey(const ValueKey('library_row_play_focus')),
    );
    focusWidget.focusNode!.requestFocus();
    await tester.pump();
    await sendPlainKey(tester, LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(vm.browsePath, '/music');
    expect(
      recordingPlayback.playCalled || recordingPlayback.lastQueue != null,
      isTrue,
    );
  });

  testWidgets('moveSelection syncs keyboard index and row focus', (tester) async {
    await pumpLibrary(tester);

    final shortcutsElement = listNavContext(tester);
    Actions.invoke(shortcutsElement, const MoveSelectionIntent(1));
    await tester.pumpAndSettle();

    expect(vm.keyboardSelectedIndex, 0);
    expect(FocusManager.instance.primaryFocus, isNotNull);
    expect(FocusManager.instance.primaryFocus!.hasFocus, isTrue);
  });

  testWidgets('arrow enter browses highlighted folder', (tester) async {
    await pumpLibrary(tester);

    final shortcutsElement = listNavContext(tester);
    Actions.invoke(shortcutsElement, const MoveSelectionIntent(1));
    await tester.pumpAndSettle();

    await sendPlainKey(tester, LogicalKeyboardKey.enter);
    await pumpFrames(tester);

    expect(vm.browsePath, normalizeLibraryPath('/music/Author'));
  });

  testWidgets('pointer drag on row does not select or focus', (tester) async {
    await pumpLibrary(tester);
    expect(vm.keyboardSelectedIndex, isNull);

    await tester.drag(find.text('Author'), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(vm.keyboardSelectedIndex, isNull);
  });

  testWidgets('backspace parent restores folder selection for enter', (tester) async {
    await pumpLibrary(tester);

    final shortcutsElement = listNavContext(tester);
    Actions.invoke(shortcutsElement, const MoveSelectionIntent(1));
    await tester.pumpAndSettle();
    await sendPlainKey(tester, LogicalKeyboardKey.enter);
    await pumpFrames(tester);
    expect(vm.browsePath, normalizeLibraryPath('/music/Author'));

    await vm.navigateToParentFolder();
    await tester.pumpAndSettle();

    expect(vm.browsePath, '/music');
    expect(vm.keyboardSelectedIndex, isNotNull);
    final row = vm.selectableRows[vm.keyboardSelectedIndex!];
    expect(row.folderPath, normalizeLibraryPath('/music/Author'));

    final focusContext = FocusManager.instance.primaryFocus?.context;
    expect(focusContext, isNotNull);
    expect(
      focusContext!.findAncestorWidgetOfExactType<LibraryRowFocusGroup>(),
      isNotNull,
    );
    expect(focusContext.findAncestorWidgetOfExactType<AppBar>(), isNull);

    await sendPlainKey(tester, LogicalKeyboardKey.enter);
    await pumpFrames(tester);
    expect(vm.browsePath, normalizeLibraryPath('/music/Author'));
  });
}

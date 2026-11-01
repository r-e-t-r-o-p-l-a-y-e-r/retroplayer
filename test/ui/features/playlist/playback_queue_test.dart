/// Composed queue persistence, save location, and the queue list.
///
/// Evidence:
/// - `stored paths and index survive a new view model`
/// - `playing a folder leaves the stored queue in place`
/// - `saving from the virtual root is refused`
/// - `saving inside a library folder writes the m3u and keeps the queue`
/// - `added tracks stay after the current index moves on`
/// - `clear queue removes every track after confirmation`
/// - `cancel leaves the queue in place`
/// - `clearing the queue stops it and leaves folder playback running`
/// - `save stays disabled on the virtual library root`
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/playlist/views/playback_queue_view.dart';
import 'package:retroplayer/ui/features/playlist/views/save_queue_playlist_page.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';
import '../../../helpers/track_factory.dart';

void main() {
  late Directory temp;
  late String root;
  late AppDatabase db;
  late LibraryStorageService storage;
  late LibraryViewModel vm;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('retroplayer_queue_');
    root = normalizeLibraryPath(temp.path);
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
    await storage.addLibraryRoot(root);
    vm = LibraryViewModel(libraryRepository: testLibraryRepository(storage));
    await vm.load();
  });

  tearDown(() async {
    vm.dispose();
    await db.close();
    if (temp.existsSync()) await temp.delete(recursive: true);
  });

  test('stored paths and index survive a new view model', () async {
    final first = p.join(root, 'one.mp3');
    final second = p.join(root, 'two.mp3');
    await vm.addQueuePaths([first, second]);
    await vm.noteQueueIndex(1);

    final next = LibraryViewModel(
      libraryRepository: testLibraryRepository(storage),
    );
    await next.load();
    expect(next.queuePaths, [
      normalizeLibraryPath(first),
      normalizeLibraryPath(second),
    ]);
    expect(next.queueIndex, 1);
    next.dispose();
  });

  test('playing a folder leaves the stored queue in place', () async {
    final first = p.join(root, 'one.mp3');
    final second = p.join(root, 'two.mp3');
    await vm.addQueuePaths([first, second]);
    await vm.noteQueueIndex(1);

    final player = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    await player.playFolder(root, [
      testTrack(filePath: first, directoryPath: root),
      testTrack(filePath: second, directoryPath: root),
    ]);

    final stored = await storage.getPlaybackQueue();
    expect(stored.paths, [
      normalizeLibraryPath(first),
      normalizeLibraryPath(second),
    ]);
    expect(stored.index, 1);
    expect(player.currentItemId, PlaybackItem.folderId(root));

    final next = LibraryViewModel(
      libraryRepository: testLibraryRepository(storage),
    );
    await next.load();
    expect(next.queuePaths, stored.paths);
    expect(next.queueIndex, 1);
    player.dispose();
    next.dispose();
  });

  test('saving from the virtual root is refused', () async {
    expect(
      () => vm.saveQueueAsPlaylist(directory: null, name: 'Trip'),
      throwsStateError,
    );
    expect(
      () => vm.saveQueueAsPlaylist(directory: '/outside/library', name: 'Trip'),
      throwsStateError,
    );
  });

  test(
    'saving inside a library folder writes the m3u and keeps the queue',
    () async {
      final first = p.join(root, 'one.mp3');
      final second = p.join(root, 'two.mp3');
      await vm.addQueuePaths([first, second]);

      final playlist = await vm.saveQueueAsPlaylist(
        directory: root,
        name: 'Trip',
      );

      expect(p.basename(playlist.filePath), 'Trip.m3u');
      expect(await File(playlist.filePath).exists(), isTrue);
      final content = await File(playlist.filePath).readAsString();
      expect(content, contains('one.mp3'));
      expect(content, contains('two.mp3'));
      expect(vm.queuePaths, [
        normalizeLibraryPath(first),
        normalizeLibraryPath(second),
      ]);
      final stored = await storage.getPlaybackQueue();
      expect(stored.paths, vm.queuePaths);
      expect(stored.index, 0);
    },
  );

  testWidgets('added tracks stay after the current index moves on', (
    tester,
  ) async {
    final first = p.join(root, 'one.mp3');
    final second = p.join(root, 'two.mp3');
    await vm.addQueuePaths([first, second]);
    final player = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    addTearDown(player.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider.value(value: player),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
        ],
        child: wrapWithL10n(const PlaybackQueueView()),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);

    await vm.noteQueueIndex(1);
    await pumpFrames(tester);

    expect(vm.queueIndex, 1);
    expect(find.text('one'), findsOneWidget);
    expect(find.text('two'), findsOneWidget);
    expect(find.byType(RetroListTile), findsNWidgets(2));
  });

  testWidgets('clear queue removes every track after confirmation', (
    tester,
  ) async {
    final first = p.join(root, 'one.mp3');
    final second = p.join(root, 'two.mp3');
    await vm.addQueuePaths([first, second]);
    await vm.noteQueueIndex(1);
    final player = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    addTearDown(player.dispose);
    await player.playComposedQueue([
      testTrack(filePath: first, directoryPath: root),
      testTrack(filePath: second, directoryPath: root),
    ], startIndex: 1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider.value(value: player),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
        ],
        child: wrapWithL10n(const PlaybackQueueView()),
      ),
    );
    await pumpFrames(tester);

    await tester.tap(find.byTooltip('Clear queue'));
    await pumpFrames(tester);
    expect(find.text('Clear queue?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Clear queue'));
    await pumpFrames(tester);

    expect(vm.queuePaths, isEmpty);
    expect(vm.queueIndex, 0);
    final stored = await storage.getPlaybackQueue();
    expect(stored.paths, isEmpty);
    expect(stored.index, 0);
    expect(find.text('one'), findsNothing);
    expect(
      find.text('The queue is empty. Add tracks from your library.'),
      findsOneWidget,
    );
    expect(player.currentItemId, isNull);
    expect(player.hasTrack, isFalse);
  });

  testWidgets('cancel leaves the queue in place', (tester) async {
    final first = p.join(root, 'one.mp3');
    await vm.addQueuePaths([first]);
    final player = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: RecordingPlayback(),
        storageService: storage,
      ),
    );
    addTearDown(player.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider.value(value: player),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
        ],
        child: wrapWithL10n(const PlaybackQueueView()),
      ),
    );
    await pumpFrames(tester);

    await tester.tap(find.byTooltip('Clear queue'));
    await pumpFrames(tester);
    await tester.tap(find.text('Cancel'));
    await pumpFrames(tester);

    expect(vm.queuePaths, [normalizeLibraryPath(first)]);
    expect(find.text('one'), findsOneWidget);
  });

  testWidgets('clearing the queue leaves folder playback running', (
    tester,
  ) async {
    final first = p.join(root, 'one.mp3');
    await vm.addQueuePaths([first]);
    final playback = RecordingPlayback();
    final player = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );
    addTearDown(player.dispose);
    await player.playFolder(root, [
      testTrack(filePath: first, directoryPath: root),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider.value(value: player),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
        ],
        child: wrapWithL10n(const PlaybackQueueView()),
      ),
    );
    await pumpFrames(tester);

    await tester.tap(find.byTooltip('Clear queue'));
    await pumpFrames(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Clear queue'));
    await pumpFrames(tester);

    expect(vm.queuePaths, isEmpty);
    expect(playback.stopCalled, isFalse);
    expect(player.currentItemId, PlaybackItem.folderId(root));
    expect(player.hasTrack, isTrue);
  });

  testWidgets('save stays disabled on the virtual library root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: vm)],
        child: wrapWithL10n(const SaveQueuePlaylistPage()),
      ),
    );
    await pumpFrames(tester);

    await tester.enterText(find.byType(TextField), 'Trip');
    await pumpFrames(tester);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text(
        'Choose a folder in the library. The library root is not a folder.',
      ),
      findsOneWidget,
    );
  });
}

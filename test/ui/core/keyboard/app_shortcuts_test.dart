/// Global desktop shortcuts Ctrl+P and Ctrl+Up; plain Enter unused.
///
/// Evidence:
/// - `Ctrl+P toggles play when a track is loaded`
/// - `Ctrl+Up expands player when track is loaded`
/// - `plain Enter and Space are not handled globally`
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/keyboard/app_shortcuts.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_intents.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/keyboard_test_helpers.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/track_factory.dart';
import '../../../helpers/test_panel.dart';

void main() {
  testWidgets('Ctrl+P toggles play when a track is loaded', (tester) async {
    final playback = RecordingPlayback();
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );
    final track = testTrack(
      filePath: '/music/a.mp3',
      metadata: const TrackMetadata(title: 'A'),
    );

    await pumpWithL10n(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: playerVm),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: const AppShortcuts(child: SizedBox()),
      ),
    );

    await playback.setQueue([track]);
    await tester.pump();

    await sendShortcut(tester, key: LogicalKeyboardKey.keyP, control: true);

    expect(playback.playCalled, isTrue);
  });

  testWidgets('Ctrl+Up expands player when track is loaded', (tester) async {
    final playback = RecordingPlayback();
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final playerVm = PlayerViewModel(
      playbackRepository: PlaybackRepository(
        playbackService: playback,
        storageService: storage,
      ),
    );
    final panelVm = testPanelVm();
    final track = testTrack(
      filePath: '/music/a.mp3',
      metadata: const TrackMetadata(title: 'A'),
    );

    await pumpWithL10n(
      tester,
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: playerVm),
          ChangeNotifierProvider.value(value: panelVm),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ],
        child: const AppShortcuts(child: SizedBox()),
      ),
    );

    await playerVm.playItem(
      LibraryItem.track(track: track),
      playlistTracks: const [],
    );
    await tester.pump();
    expect(panelVm.isExpanded, isFalse);

    await sendShortcut(tester, key: LogicalKeyboardKey.arrowUp, control: true);

    expect(panelVm.isExpanded, isTrue);
  });

  testWidgets('plain Enter and Space are not handled globally', (tester) async {
    await pumpWithL10n(tester, const AppShortcuts(child: SizedBox()));

    final element = tester.element(find.byType(AppShortcuts));
    expect(
      Actions.maybeInvoke(element, const ActivateSelectionIntent()),
      isNull,
    );
    expect(Actions.maybeInvoke(element, const PlaySelectionIntent()), isNull);
  });
}

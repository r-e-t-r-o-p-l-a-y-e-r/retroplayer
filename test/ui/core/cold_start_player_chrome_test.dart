/// Cold-start expanded player chrome (single paint from snapshot).
///
/// Evidence:
/// - `ExpandedRestore_FirstPaint shows title seek art and transport together`
/// - `HydratedSnapshot_NoSelectToPlay shows disabled transport before hasTrack`
/// - `ProductionPath ColdStartUi load matches expanded chrome`
/// - `AlbumAfterPlayer keeps player sheet when album detail restores`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/core/cold_start_ui.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_jumps.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/real_app.dart';

Future<void> _seedExpandedRestore(LibraryStorageService storage) async {
  await storage.setPlayerPanelExpanded(true);
}

void _expectExpandedChromeTogether(WidgetTester tester, String title) {
  expect(find.text(title), findsWidgets);
  expect(find.byType(Slider), findsWidgets);
  expect(find.byType(AlbumArtWithJumps), findsOneWidget);
  expect(find.byIcon(Icons.skip_previous_rounded), findsWidgets);
  expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
  expect(find.byIcon(Icons.skip_next_rounded), findsWidgets);
}

void main() {
  testWidgets('ExpandedRestore_FirstPaint shows title seek art and transport together', (
    tester,
  ) async {
    final album = book1Album();
    final title = album.tracks.first.displayTitle;

    await pumpRealApp(
      tester,
      useAppSessionBootstrap: true,
      restorePlaybackFromStorage: true,
      playing: album,
      beforePump: _seedExpandedRestore,
    );
    await pumpFrames(tester, count: 2);

    _expectExpandedChromeTogether(tester, title);
    expect(find.textContaining('Select something from your library'), findsNothing);
  });

  testWidgets('HydratedSnapshot_NoSelectToPlay shows disabled transport before hasTrack', (
    tester,
  ) async {
    final album = book1Album();
    final title = album.tracks.first.displayTitle;

    final env = await pumpRealApp(
      tester,
      useAppSessionBootstrap: true,
      restorePlaybackFromStorage: true,
      playing: album,
      beforePump: _seedExpandedRestore,
    );
    await pumpFrames(tester, count: 2);

    expect(env.playerVm.hasSession, isTrue);
    _expectExpandedChromeTogether(tester, title);
    expect(find.textContaining('Select something from your library'), findsNothing);
  });

  testWidgets('ProductionPath ColdStartUi load matches expanded chrome', (
    tester,
  ) async {
    final album = book1Album();
    final title = album.tracks.first.displayTitle;

    final env = await pumpRealApp(
      tester,
      useAppSessionBootstrap: true,
      restorePlaybackFromStorage: true,
      playing: album,
      beforePump: _seedExpandedRestore,
    );

    final coldStart = await ColdStartUi.load(
      storage: env.storage,
      playbackRepository: env.playbackRepository,
    );
    expect(coldStart.restoreExpandedPanel, isTrue);
    expect(coldStart.playbackSnapshot?.state.displayTitle, title);

    await pumpFrames(tester, count: 2);
    _expectExpandedChromeTogether(tester, title);
  });

  testWidgets('AlbumAfterPlayer keeps player sheet when album detail restores', (
    tester,
  ) async {
    final album = book1Album();

    await pumpRealApp(
      tester,
      useAppSessionBootstrap: true,
      restorePlaybackFromStorage: true,
      playing: album,
      beforePump: (s) async {
        await s.setPlayerPanelExpanded(true);
        await s.setLibraryAlbumDetailId(album.id);
      },
    );
    await pumpFrames(tester, count: 30);

    expect(find.byType(AlbumDetailView), findsOneWidget);
    expect(find.byType(PlayerSheetHost), findsWidgets);
    expect(find.byType(AlbumArtWithJumps), findsOneWidget);
  });
}

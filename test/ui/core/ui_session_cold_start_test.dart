/// Cold-start UI session restore (player expanded, Settings overlay).
///
/// Evidence:
/// - `cold start restores expanded player when session and pref true`
/// - `cold start keeps collapsed player when pref false`
/// - `cold start does not expand player without session`
/// - `cold start pushes settings when overlay pref true`
/// - `cold start settings pop reveals album when album id saved`
/// - `cold start settings with expanded player keeps expanded after pop`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/real_app.dart';

Future<void> _closeSettings(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await pumpFrames(tester, count: 12);
}

Future<RealApp> _pumpColdStart(
  WidgetTester tester, {
  required Future<void> Function(LibraryStorageService storage) beforePump,
}) {
  return pumpRealApp(
    tester,
    useAppSessionBootstrap: true,
    restorePlaybackFromStorage: true,
    playing: book1Album(),
    beforePump: beforePump,
  );
}

void main() {
  testWidgets('cold start restores expanded player when session and pref true', (
    tester,
  ) async {
    final env = await _pumpColdStart(
      tester,
      beforePump: (s) async {
        await s.setPlayerPanelExpanded(true);
      },
    );

    expect(env.playerVm.hasSession, isTrue);
    expect(env.panelVm.isExpanded, isTrue);
    expect(find.text('Now Playing'), findsOneWidget);
  });

  testWidgets('cold start keeps collapsed player when pref false', (
    tester,
  ) async {
    final env = await _pumpColdStart(
      tester,
      beforePump: (s) async {
        await s.setPlayerPanelExpanded(false);
      },
    );

    expect(env.playerVm.hasSession, isTrue);
    expect(env.panelVm.isExpanded, isFalse);
  });

  testWidgets('cold start does not expand player without session', (
    tester,
  ) async {
    final env = await pumpRealApp(
      tester,
      useAppSessionBootstrap: true,
      restorePlaybackFromStorage: false,
      playing: null,
      beforePump: (s) async {
        await s.setPlayerPanelExpanded(true);
      },
    );

    expect(env.playerVm.hasSession, isFalse);
    expect(env.panelVm.isExpanded, isFalse);
  });

  testWidgets('cold start pushes settings when overlay pref true', (
    tester,
  ) async {
    await _pumpColdStart(
      tester,
      beforePump: (s) async {
        await s.setSettingsOverlayOpen(true);
      },
    );

    expect(find.byType(SettingsView), findsOneWidget);
  });

  testWidgets('cold start settings pop reveals album when album id saved', (
    tester,
  ) async {
    final album = book1Album();
    await _pumpColdStart(
      tester,
      beforePump: (s) async {
        await s.setLibraryAlbumDetailId(album.id);
        await s.setSettingsOverlayOpen(true);
      },
    );

    expect(find.byType(SettingsView), findsOneWidget);
    await _closeSettings(tester);
    expect(find.byType(AlbumDetailView), findsOneWidget);
  });

  testWidgets(
    'cold start settings with expanded player keeps expanded after pop',
    (tester) async {
      final env = await _pumpColdStart(
        tester,
        beforePump: (s) async {
          await s.setPlayerPanelExpanded(true);
          await s.setSettingsOverlayOpen(true);
        },
      );

      expect(env.panelVm.isExpanded, isTrue);
      expect(find.byType(SettingsView), findsOneWidget);
      await _closeSettings(tester);
      expect(env.panelVm.isExpanded, isTrue);
      expect(find.text('Now Playing'), findsOneWidget);
    },
  );
}

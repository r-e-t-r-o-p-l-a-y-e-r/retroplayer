/// Album detail exposes Settings in its app bar (same overlay as library shell).
///
/// Evidence:
/// - `album detail settings icon opens settings overlay`
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

import '../../../helpers/library_test_seed.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/recording_playback.dart';
import '../../../helpers/test_library_repository.dart';
import '../../../helpers/test_panel.dart';
import '../../../helpers/track_factory.dart';

AudioAlbum _album() {
  return AudioAlbum(
    id: 'dir:/music/Author/Book1',
    title: 'Book1',
    tracks: [
      testTrack(
        id: 't1',
        filePath: '/music/Author/Book1/01.mp3',
        directoryPath: '/music/Author/Book1',
        metadata: const TrackMetadata(trackNumber: 1, title: 'Chapter 1'),
      ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/Author/Book1',
  );
}

void main() {
  testWidgets('album detail settings icon opens settings overlay', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final album = _album();
    final libraryRepository = testLibraryRepository(storage);
    await storage.addLibraryRoot('/music');
    seedPlayerBreadcrumbHierarchy(libraryRepository, album);

    final libraryVm = LibraryViewModel(libraryRepository: libraryRepository);
    await libraryVm.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: libraryRepository),
          ChangeNotifierProvider.value(value: libraryVm),
          ChangeNotifierProvider(
            create: (_) => PlayerViewModel(
              playbackRepository: PlaybackRepository(
                playbackService: RecordingPlayback(),
                storageService: storage,
              ),
            ),
          ),
          ChangeNotifierProvider(create: (_) => testPanelVm()),
          ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
          ChangeNotifierProvider(
            create: (_) => EqualizerViewModel(
              equalizerService: EqualizerService(storage),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeViewModel(storageService: storage),
          ),
          ChangeNotifierProvider(
            create: (_) => LocaleViewModel(storageService: storage),
          ),
        ],
        child: wrapRouterWithL10n(
          router: AppRouter.create(initialLocation: AppRouter.library),
        ),
      ),
    );
    await pumpFrames(tester);

    final shellContext = tester.element(find.byType(MainShellView));
    GoRouter.of(shellContext).push(AppRouter.albumDetailLocation, extra: album);
    await pumpFrames(tester, count: 12);
    expect(find.byType(AlbumDetailView), findsOneWidget);

    final settingsOnAlbum = find.descendant(
      of: find.byType(AlbumDetailView),
      matching: find.byIcon(Icons.settings_outlined),
    );
    expect(settingsOnAlbum, findsOneWidget);

    await tester.tap(settingsOnAlbum);
    await pumpFrames(tester, count: 12);
    expect(find.byType(SettingsView), findsOneWidget);
  });
}

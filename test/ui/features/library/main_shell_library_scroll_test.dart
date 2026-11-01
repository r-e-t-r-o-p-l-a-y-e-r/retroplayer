/// Main-shell (Linux/desktop) library scroll: browse-up restore and jump-to-playing.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/browse_library.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/ui/features/library/views/library_view.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/real_app.dart';
import '../../../helpers/track_factory.dart';

Finder _libraryListScrollable() => find.descendant(
  of: find.byType(LibraryView),
  matching: find.byType(Scrollable),
);

ScrollPosition _libraryScrollPosition(WidgetTester tester) =>
    tester.state<ScrollableState>(_libraryListScrollable()).position;

void _seedManyTopLevelFolders(LibraryRepository repo) {
  final folders = <FolderEntry>[
    for (var i = 0; i < 30; i++)
      FolderEntry(
        path: '/music/Folder${i.toString().padLeft(2, '0')}',
        name: 'Folder${i.toString().padLeft(2, '0')}',
      ),
  ];
  repo.seedChildFolders('/music', folders);
  repo.seedDirectory('/music', const []);
  for (final folder in folders) {
    repo.seedChildFolders(folder.path, const []);
    repo.seedDirectory(folder.path, const []);
  }
}

AudioAlbum _longAlbum() {
  return AudioAlbum(
    id: 'dir:/music/Author/Book1',
    title: 'Book1',
    tracks: [
      for (var i = 0; i < 30; i++)
        testTrack(
          id: 't$i',
          filePath: '/music/Author/Book1/${i.toString().padLeft(2, '0')}.mp3',
          directoryPath: '/music/Author/Book1',
          metadata: TrackMetadata(
            trackNumber: i + 1,
            title: 'Chapter ${i + 1}',
          ),
        ),
    ],
    source: AlbumSource.directory,
    groupingKey: 'dir:/music/Author/Book1',
  );
}

void main() {
  testWidgets('AppBar back in main shell restores parent list scroll offset', (
    tester,
  ) async {
    await pumpRealApp(
      tester,
      browsePath: '/music',
      seed: _seedManyTopLevelFolders,
    );

    await tester.drag(_libraryListScrollable(), const Offset(0, -900));
    await pumpFrames(tester, count: 8);
    expect(_libraryScrollPosition(tester).pixels, greaterThan(200));

    await tester.scrollUntilVisible(
      find.text('Folder15'),
      80,
      scrollable: _libraryListScrollable(),
    );
    await pumpFrames(tester, count: 4);
    final offsetAtEnter = _libraryScrollPosition(tester).pixels;

    await tester.tap(find.text('Folder15'));
    await pumpFrames(tester, count: 16);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await pumpFrames(tester, count: 24);

    expect(
      _libraryScrollPosition(tester).pixels,
      closeTo(offsetAtEnter, 2.0),
    );
    expect(find.text('Folder15'), findsOneWidget);
  });

  testWidgets('shell breadcrumb to parent restores scroll offset', (
    tester,
  ) async {
    await pumpRealApp(
      tester,
      browsePath: '/music',
      seed: _seedManyTopLevelFolders,
    );

    await tester.drag(_libraryListScrollable(), const Offset(0, -900));
    await pumpFrames(tester, count: 8);

    await tester.scrollUntilVisible(
      find.text('Folder15'),
      80,
      scrollable: _libraryListScrollable(),
    );
    await pumpFrames(tester, count: 4);
    final offsetAtEnter = _libraryScrollPosition(tester).pixels;

    await tester.tap(find.text('Folder15'));
    await pumpFrames(tester, count: 16);

    await tester.tap(find.text('music'));
    await pumpFrames(tester, count: 24);

    expect(
      _libraryScrollPosition(tester).pixels,
      closeTo(offsetAtEnter, 2.0),
    );
  });

  testWidgets(
    'deferred directory rescan after shell browse-up does not jump list to top',
    (tester) async {
      final env = await pumpRealApp(
        tester,
        browsePath: '/music',
        seed: _seedManyTopLevelFolders,
      );

      await tester.drag(_libraryListScrollable(), const Offset(0, -900));
      await pumpFrames(tester, count: 8);
      await tester.scrollUntilVisible(
        find.text('Folder15'),
        80,
        scrollable: _libraryListScrollable(),
      );
      await pumpFrames(tester, count: 4);
      final offsetAtEnter = _libraryScrollPosition(tester).pixels;

      await tester.tap(find.text('Folder15'));
      await pumpFrames(tester, count: 16);

      env.libraryRepository.invalidateDirectory('/music');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpFrames(tester, count: 8);
      await pumpFrames(tester, count: 8);

      expect(
        _libraryScrollPosition(tester).pixels,
        closeTo(offsetAtEnter, 2.0),
      );
    },
  );

  testWidgets(
    'jumpToNowPlaying scrolls playing track into view on album detail',
    (tester) async {
      final album = _longAlbum();
      final env = await pumpRealApp(
        tester,
        playing: album,
        seed: (repo) {
          repo.seedChildFolders('/music', [
            const FolderEntry(path: '/music/Author', name: 'Author'),
          ]);
          repo.seedChildFolders('/music/Author', [
            const FolderEntry(path: '/music/Author/Book1', name: 'Book1'),
          ]);
          repo.seedChildFolders('/music/Author/Book1', const []);
          repo.seedDirectory('/music', const []);
          repo.seedDirectory('/music/Author', const []);
          repo.seedDirectory('/music/Author/Book1', [
            LibraryItem.album(album: album),
          ]);
        },
      );

      unawaited(
        env.shellRouter.push(AppRouter.albumDetailLocation, extra: album),
      );
      await pumpFrames(tester, count: 20);

      final albumList = find.descendant(
        of: find.byType(AlbumDetailView),
        matching: find.byType(ListView),
      );
      await tester.drag(albumList, const Offset(0, -1200));
      await pumpFrames(tester, count: 8);
      final albumScroll = find.descendant(
        of: albumList,
        matching: find.byType(Scrollable),
      );
      final offsetScrolledDown =
          tester.state<ScrollableState>(albumScroll).position.pixels;
      expect(offsetScrolledDown, greaterThan(200));

      await LibraryNavigator.of(
        tester.element(find.byType(AlbumDetailView)),
      ).jumpToNowPlaying();
      await pumpFrames(tester, count: 40);

      expect(
        tester.state<ScrollableState>(albumScroll).position.pixels,
        lessThan(offsetScrolledDown - 80),
      );
    },
  );
}

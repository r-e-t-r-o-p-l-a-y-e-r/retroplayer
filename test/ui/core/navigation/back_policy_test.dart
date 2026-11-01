/// The UC-14 back rules as a pure decision table.
///
/// System back, the edge swipe and Escape all resolve through
/// [BackPolicy.resolve], so these cases hold for every input.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';

void main() {
  const library = LibraryLocation();
  const album = AlbumDetailLocation();
  const playlist = PlaylistDetailLocation();
  const settings = SettingsLocation();

  BackAction resolve(
    AppLocation? location, {
    bool pageless = false,
    bool expanded = false,
    bool canPop = false,
    bool canBrowseUp = false,
    bool suppressAfterSettings = false,
  }) => BackPolicy.resolve(
    BackState(
      location: location,
      pagelessRouteOnTop: pageless,
      playerExpanded: expanded,
      canPop: canPop,
      canBrowseUp: canBrowseUp,
      suppressExpandedBackAfterSettingsClose: suppressAfterSettings,
    ),
  );

  group('BackPolicy.resolve', () {
    test('a dialog or menu on top is popped before anything else', () {
      for (final location in [library, album, playlist, settings, null]) {
        expect(
          resolve(location, pageless: true, expanded: true, canBrowseUp: true),
          BackAction.popRoute,
          reason: '$location',
        );
      }
    });

    test('Settings pops even when the player underneath is expanded', () {
      expect(resolve(settings, expanded: true), BackAction.popRoute);
    });

    test('expanded player absorbs one back after Settings overlay closes', () {
      expect(
        resolve(library, expanded: true, suppressAfterSettings: true),
        BackAction.absorb,
      );
    });

    test('expanded player collapses before a detail page pops', () {
      expect(
        resolve(album, expanded: true, canPop: true),
        BackAction.collapsePlayer,
      );
      expect(
        resolve(playlist, expanded: true, canPop: true),
        BackAction.collapsePlayer,
      );
      expect(
        resolve(library, expanded: true, canBrowseUp: true),
        BackAction.collapsePlayer,
      );
    });

    test('detail pages pop when the navigator can pop', () {
      expect(resolve(album, canPop: true), BackAction.popRoute);
      expect(resolve(playlist, canPop: true), BackAction.popRoute);
    });

    test('a detail page opened as the only route browses up instead', () {
      expect(resolve(album, canBrowseUp: true), BackAction.browseUp);
    });

    test('library ignores a stale canPop and browses up', () {
      expect(
        resolve(library, canPop: true, canBrowseUp: true),
        BackAction.browseUp,
      );
    });

    test('library root absorbs back so playback keeps running', () {
      expect(resolve(library), BackAction.absorb);
      expect(resolve(library, canPop: true), BackAction.absorb);
      expect(resolve(null), BackAction.absorb);
    });
  });
}

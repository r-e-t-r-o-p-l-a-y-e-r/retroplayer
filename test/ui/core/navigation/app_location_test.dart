import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';

void main() {
  group('AppLocation.parse', () {
    test('maps every routed path', () {
      expect(AppLocation.parse('/'), isA<LibraryLocation>());
      expect(AppLocation.parse(AppRouter.library), isA<LibraryLocation>());
      expect(
        AppLocation.parse(AppRouter.albumDetailLocation),
        isA<AlbumDetailLocation>(),
      );
      expect(
        AppLocation.parse(AppRouter.playlistDetailLocation),
        isA<PlaylistDetailLocation>(),
      );
      expect(AppLocation.parse(AppRouter.queueLocation), isA<QueueLocation>());
      expect(AppLocation.parse(AppRouter.settings), isA<SettingsLocation>());
    });

    test('Settings subpages and query strings still resolve', () {
      expect(
        AppLocation.parse('${AppRouter.settings}/about'),
        isA<SettingsLocation>(),
      );
      expect(
        AppLocation.parse('${AppRouter.albumDetailLocation}?x=1'),
        isA<AlbumDetailLocation>(),
      );
    });

    test('unknown paths are null', () {
      expect(AppLocation.parse('/nowhere'), isNull);
    });

    test('only detail pages are details; Settings hosts no player', () {
      expect(const LibraryLocation().isDetail, isFalse);
      expect(const AlbumDetailLocation().isDetail, isTrue);
      expect(const PlaylistDetailLocation().isDetail, isTrue);
      expect(const QueueLocation().isDetail, isTrue);
      expect(const QueueLocation().hostsPlayerSheet, isTrue);
      expect(const SettingsLocation().isDetail, isFalse);
      expect(const SettingsLocation().hostsPlayerSheet, isFalse);
      expect(const AlbumDetailLocation().hostsPlayerSheet, isTrue);
    });
  });
}

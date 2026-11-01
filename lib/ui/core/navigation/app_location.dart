import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/library/view_models/library_effects.dart';

/// Where the user is, resolved once from the go_router configuration.
sealed class AppLocation {
  const AppLocation();

  /// Whether this page draws the swipeable player sheet (library, album and
  /// playlist detail). Settings covers the shell and has no player.
  bool get hostsPlayerSheet => true;

  bool get isDetail => false;

  /// Parses a matched location path; null for paths the app does not route.
  static AppLocation? parse(String matchedLocation) {
    final path = Uri.tryParse(matchedLocation)?.path ?? matchedLocation;
    if (path == AppRouter.settings ||
        path.startsWith('${AppRouter.settings}/')) {
      return const SettingsLocation();
    }
    if (path == AppRouter.library || path == '/') {
      return const LibraryLocation();
    }
    if (path == AppRouter.albumDetailLocation) {
      return const AlbumDetailLocation();
    }
    if (path == AppRouter.playlistDetailLocation) {
      return const PlaylistDetailLocation();
    }
    if (path == AppRouter.queueLocation) {
      return const QueueLocation();
    }
    return null;
  }

  /// Topmost page: [SettingsLocation] while Settings (or a subpage) is open.
  ///
  /// Null when there is no router above [context].
  static AppLocation? topOf(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    return router == null ? null : topOfRouter(router);
  }

  static AppLocation? topOfRouter(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    final leaf = config.lastOrNull?.matchedLocation;
    return parse(leaf == null || leaf.isEmpty ? config.uri.path : leaf);
  }

  /// Page in the shell navigator, ignoring the Settings overlay above it.
  ///
  /// The sheet host and dock keep seeing library/album/playlist while
  /// Settings is pushed on the root navigator. Null without a router.
  static AppLocation? shellOf(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    return router == null ? null : shellOfRouter(router);
  }

  static AppLocation? shellOfRouter(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    final location =
        _deepestShellLocation(config.matches) ?? parse(config.uri.path);
    return location is SettingsLocation ? const LibraryLocation() : location;
  }

  /// Whether the shell navigator already shows the page [target] would open.
  ///
  /// Used when locating playback from the expanded player so we do not pop and
  /// push the same album or playlist detail (visible flash).
  static bool shellShowsDetailTarget(GoRouter router, LibraryEffect? target) {
    final shell = shellOfRouter(router);
    final extra = _deepestShellDetailExtra(router.routerDelegate.currentConfiguration.matches);
    return switch (target) {
      OpenAlbumDetail(:final album) =>
        shell is AlbumDetailLocation &&
        extra is AudioAlbum &&
        extra.id == album.id,
      OpenPlaylistDetail(:final playlist) =>
        shell is PlaylistDetailLocation &&
        extra is PlaylistFile &&
        extra.filePath == playlist.filePath,
      _ => false,
    };
  }

  static Object? _deepestShellDetailExtra(List<RouteMatchBase> matches) {
    for (var i = matches.length - 1; i >= 0; i--) {
      final match = matches[i];
      final nested = switch (match) {
        ShellRouteMatch(:final matches) => _deepestShellDetailExtra(matches),
        ImperativeRouteMatch(:final matches) => _deepestShellDetailExtra(
          matches.matches,
        ),
        _ => null,
      };
      if (nested != null) return nested;

      final location = parse(match.matchedLocation);
      if (location is! AlbumDetailLocation &&
          location is! PlaylistDetailLocation) {
        continue;
      }
      if (match case ImperativeRouteMatch(:final matches)) {
        return matches.extra;
      }
    }
    return null;
  }

  /// Pushes inside a [ShellRoute] nest under its [ShellRouteMatch], so the
  /// top-level list alone reports the shell's `/` on album/playlist detail.
  static AppLocation? _deepestShellLocation(List<RouteMatchBase> matches) {
    for (var i = matches.length - 1; i >= 0; i--) {
      final match = matches[i];
      final nested = switch (match) {
        ShellRouteMatch(:final matches) => matches,
        ImperativeRouteMatch(:final matches) => matches.matches,
        _ => null,
      };
      if (nested != null) {
        final location = _deepestShellLocation(nested);
        if (location != null) return location;
      }
      final location = parse(match.matchedLocation);
      if (location == null || location is SettingsLocation) continue;
      return location;
    }
    return null;
  }
}

final class LibraryLocation extends AppLocation {
  const LibraryLocation();
}

final class AlbumDetailLocation extends AppLocation {
  const AlbumDetailLocation();

  @override
  bool get isDetail => true;
}

final class PlaylistDetailLocation extends AppLocation {
  const PlaylistDetailLocation();

  @override
  bool get isDetail => true;
}

final class QueueLocation extends AppLocation {
  const QueueLocation();

  @override
  bool get isDetail => true;
}

final class SettingsLocation extends AppLocation {
  const SettingsLocation();

  @override
  bool get hostsPlayerSheet => false;
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/main_shell_view.dart';
import 'package:retroplayer/ui/core/navigation/route_stack_tracker.dart';
import 'package:retroplayer/ui/core/player_dock_shell.dart';
import 'package:retroplayer/ui/features/album_detail/views/album_detail_view.dart';
import 'package:retroplayer/ui/features/playlist/views/playback_queue_view.dart';
import 'package:retroplayer/ui/features/playlist/views/playlist_detail_view.dart';
import 'package:retroplayer/ui/features/settings/views/settings_view.dart';

class AppRouter {
  AppRouter._();

  static const library = '/';
  static const settings = '/settings';
  static const albumDetail = 'album-detail';
  static const albumDetailLocation = '/album-detail';
  static const playlistDetail = 'playlist-detail';
  static const playlistDetailLocation = '/playlist-detail';
  static const queue = 'queue';
  static const queueLocation = '/queue';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final _routeStacks = Expando<RouteStackTracker>();

  /// Route stacks of a router built by [create]; null for other routers.
  static RouteStackTracker? routeStackOf(GoRouter router) =>
      _routeStacks[router];

  static GoRouter create({String initialLocation = library}) {
    final routeStack = RouteStackTracker();
    final router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      observers: [routeStack.observer()],
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          observers: [routeStack.observer()],
          builder: (context, state, child) => PlayerDockShell(child: child),
          routes: [
            GoRoute(
              path: library,
              builder: (context, state) => const MainShellView(),
              routes: [
                GoRoute(
                  path: albumDetail,
                  builder: (context, state) {
                    final album = state.extra as AudioAlbum?;
                    if (album == null) {
                      return Scaffold(
                        body: Center(
                          child: Text(
                            AppLocalizations.of(context).albumNotFound,
                          ),
                        ),
                      );
                    }
                    return AlbumDetailView(album: album);
                  },
                ),
                GoRoute(
                  path: queue,
                  builder: (context, state) => const PlaybackQueueView(),
                ),
                GoRoute(
                  path: playlistDetail,
                  builder: (context, state) {
                    final playlist = state.extra as PlaylistFile?;
                    if (playlist == null) {
                      return Scaffold(
                        body: Center(
                          child: Text(
                            AppLocalizations.of(context).playlistNotFound,
                          ),
                        ),
                      );
                    }
                    return PlaylistDetailView(playlist: playlist);
                  },
                ),
              ],
            ),
          ],
        ),
        // Above the shell so pop restores album/playlist/library underneath.
        GoRoute(
          path: settings,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SettingsView(),
        ),
      ],
    );
    _routeStacks[router] = routeStack;
    return router;
  }
}

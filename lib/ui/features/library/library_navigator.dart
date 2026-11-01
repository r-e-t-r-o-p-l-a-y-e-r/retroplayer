import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/features/library/view_models/library_effects.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_remove_confirmation.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

/// Opens and closes library detail pages and runs [LibraryEffect]s.
///
/// The UI-side counterpart of [LibraryViewModel]: the view model decides
/// what should happen, this performs it against the router, dialogs and the
/// player.
class LibraryNavigator {
  LibraryNavigator.of(this._context)
    : _maybeRouter = GoRouter.maybeOf(_context),
      _library = _context.read<LibraryViewModel>();

  final BuildContext _context;
  final GoRouter? _maybeRouter;
  final LibraryViewModel _library;

  GoRouter get _router => _maybeRouter ?? GoRouter.of(_context);

  Future<void> openAlbumDetail(AudioAlbum album) async {
    await _library.rememberAlbumDetail(album.id);
    await _router.push(AppRouter.albumDetailLocation, extra: album);
    await _library.rememberAlbumDetail(null);
  }

  Future<void> openQueue() => _router.push(AppRouter.queueLocation);

  Future<void> openPlaylistDetail(PlaylistFile playlist) async {
    await _router.push(AppRouter.playlistDetailLocation, extra: playlist);
    await _library.refreshDisplay();
  }

  /// Reopens the album detail that was open when the app last closed.
  Future<void> restoreAlbumDetail() async {
    final album = await _library.takeAlbumDetailToRestore();
    if (album != null && _context.mounted) {
      unawaited(openAlbumDetail(album));
    }
  }

  /// Pops album and playlist detail pages back to the library list.
  Future<void> closeDetails() async {
    await _library.rememberAlbumDetail(null);
    bool onDetail() => AppLocation.topOfRouter(_router)?.isDetail ?? false;
    while (onDetail() && _router.canPop()) {
      _router.pop();
    }
    if (onDetail()) _router.go(AppRouter.library);
  }

  /// Collapses the player and shows the playing track in the library.
  ///
  /// Closing details may unmount the widget that asked, so everything needed
  /// afterwards is read up front.
  Future<void> jumpToNowPlaying() async {
    final player = _context.read<PlayerViewModel>();
    final panel = _context.read<PlayerPanelViewModel>();
    final track = player.currentTrack;
    if (track == null) return;
    final target = await _library.locateNowPlaying(
      track: track,
      playingItemId: player.currentItemId,
    );
    final alreadyOnTarget = AppLocation.shellShowsDetailTarget(_router, target);
    if (!alreadyOnTarget) {
      await closeDetails();
    }
    await panel.collapse(snapChrome: true);
    if (!alreadyOnTarget) {
      _openDetail(target);
    }
    _library.scrollHighlightedTrackIntoView();
  }

  /// Collapses the player and browses to a playback breadcrumb segment.
  Future<void> jumpToPlaybackBreadcrumb(String? path) async {
    final player = _context.read<PlayerViewModel>();
    final panel = _context.read<PlayerPanelViewModel>();
    final target = await _library.locatePlaybackBreadcrumb(
      breadcrumbPath: path,
      playingTrack: player.currentTrack,
      playingItemId: player.currentItemId,
    );
    final alreadyOnTarget = AppLocation.shellShowsDetailTarget(_router, target);
    if (!alreadyOnTarget) {
      await closeDetails();
    }
    await panel.collapse(snapChrome: true);
    if (!alreadyOnTarget) {
      _openDetail(target);
    }
  }

  void _openDetail(LibraryEffect? target) {
    switch (target) {
      case OpenAlbumDetail(:final album):
        unawaited(openAlbumDetail(album));
      case OpenPlaylistDetail(:final playlist):
        unawaited(openPlaylistDetail(playlist));
      default:
        break;
    }
  }

  Future<void> run(LibraryEffect? effect) async {
    if (effect == null || !_context.mounted) return;
    switch (effect) {
      case OpenAlbumDetail() || OpenPlaylistDetail():
        _openDetail(effect);
      case PlayFolder(:final folderPath, :final tracks):
        await _context.read<PlayerViewModel>().playFolder(folderPath, tracks);
        _expandPlayer();
      case PlayLibraryItem(:final item, :final playlistTracks):
        await _context.read<PlayerViewModel>().playItem(
          item,
          playlistTracks: playlistTracks,
        );
        _expandPlayer();
      case ShowNothingToPlay():
        ScaffoldMessenger.of(_context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(_context).playlistNothingToPlay),
          ),
        );
      case ConfirmRemoveRoot(:final path, :final displayName):
        final player = _context.read<PlayerViewModel>();
        final confirmed = await confirmRemoveLibraryRoot(
          _context,
          path: path,
          displayName: displayName,
        );
        if (!confirmed) return;
        await player.stopAndClearIfUnderLibraryRoot(path);
        await _library.removeLibraryRoot(path);
        _library.clearKeyboardSelection();
      case ConfirmDeletePlaylist(:final playlist):
        final confirmed = await confirmDeletePlaylist(
          _context,
          displayName: playlist.displayName,
        );
        if (!confirmed || !_context.mounted) return;
        await _context
            .read<PlayerViewModel>()
            .stopAndClearIfPlayingPlaylist(playlist.filePath);
        if (!_context.mounted) return;
        await _library.deletePlaylist(playlist.filePath);
        _library.clearKeyboardSelection();
    }
  }

  void _expandPlayer() {
    if (_context.mounted) unawaited(expandPlayerPanel(_context));
  }
}

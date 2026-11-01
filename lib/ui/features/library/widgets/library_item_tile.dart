import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/library_row_focus.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_remove_confirmation.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

class LibraryItemTile extends StatelessWidget {
  const LibraryItemTile({
    super.key,
    required this.item,
    this.dense = false,
    this.keyboardSelected = false,
    this.rowIndex,
  });

  final LibraryItem item;
  final bool dense;
  final bool keyboardSelected;
  final int? rowIndex;

  Future<void> _startPlayback(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final libraryVm = context.read<LibraryViewModel>();
    final playlistTracks = switch (item) {
      LibraryPlaylistItem(:final playlist) => await libraryVm.tracksForPlaylist(
        playlist,
      ),
      _ => <AudioTrack>[],
    };
    if (!context.mounted) return;
    if (playlistTracks.isEmpty && item is LibraryPlaylistItem) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.playlistNothingToPlay)));
      return;
    }
    await context.read<PlayerViewModel>().playItem(
      item,
      playlistTracks: playlistTracks,
    );
    if (context.mounted) {
      // Fire-and-forget: awaiting sheet animateTo deadlocks widget tests.
      unawaited(expandPlayerPanel(context));
    }
  }

  Widget _wrapRowFocus({
    required Widget body,
    VoidCallback? onPlayPressed,
    String? playTooltip,
  }) {
    final index = rowIndex;
    if (index == null) {
      if (onPlayPressed == null) return body;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: body),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: playTooltip,
            onPressed: onPlayPressed,
          ),
        ],
      );
    }
    return LibraryRowFocusGroup(
      rowIndex: index,
      body: body,
      onPlayPressed: onPlayPressed,
      playTooltip: playTooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItemId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentItemId,
    );
    final playingTrackId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentTrack?.id,
    );
    final transportPlaying = context.select<PlayerViewModel, bool>(
      (vm) => vm.isPlaying,
    );
    final highlightedId = context.select<LibraryViewModel, String?>(
      (vm) => vm.effectiveHighlightedTrackId(playingTrackId),
    );
    final appCreatedPlaylist = switch (item) {
      LibraryPlaylistItem(:final playlist) =>
        context.select<LibraryViewModel, bool>(
          (vm) => vm.isAppCreatedPlaylist(playlist.filePath),
        ),
      _ => false,
    };
    final isPlaying = switch (item) {
      LibraryAlbumItem(:final album) => currentItemId == album.id,
      LibraryTrackItem(:final track) => playingTrackId == track.id,
      LibraryPlaylistItem(:final playlist) => currentItemId == playlist.id,
    };
    final isHighlighted = switch (item) {
      LibraryTrackItem(:final track) => highlightedId == track.id,
      LibraryAlbumItem() => false,
      LibraryPlaylistItem() => false,
    };
    final active = isPlaying && transportPlaying;

    final l10n = AppLocalizations.of(context);

    return switch (item) {
      LibraryAlbumItem(:final album) => _wrapRowFocus(
        body: RetroListTile(
          dense: dense,
          selected: keyboardSelected || active,
          leading: AlbumArtFrame(
            size: RetroSpacing.iconChipSize,
            imagePath: album.coverArtPath,
            placeholderIcon: Icons.album_outlined,
          ),
          title: Text(item.title),
          subtitle: Text(
            l10n.tracksCountArtist(
              album.trackCount,
              album.artist ?? l10n.unknownArtist,
            ),
          ),
          onTap: () => LibraryNavigator.of(context).openAlbumDetail(album),
        ),
        playTooltip: withDesktopShortcut(
          context,
          l10n.playAlbum,
          shortcut: DesktopShortcuts.playPause,
        ),
        onPlayPressed: () => _startPlayback(context),
      ),
      LibraryTrackItem(:final track) => _wrapRowFocus(
        body: RetroListTile(
          dense: dense,
          selected: keyboardSelected || active || isHighlighted,
          leading: RetroIconChip(
            icon: Icons.music_note_outlined,
            highlight: active,
          ),
          title: Text(item.title),
          subtitle: Text(track.metadata.artist ?? l10n.trackFallback),
          onTap: () => _startPlayback(context),
        ),
      ),
      LibraryPlaylistItem(:final playlist) => _wrapRowFocus(
        body: appCreatedPlaylist
            ? PlaylistDismissible(
                playlistPath: playlist.filePath,
                displayName: playlist.displayName,
                onDelete: () async {
                  await context
                      .read<PlayerViewModel>()
                      .stopAndClearIfPlayingPlaylist(playlist.filePath);
                  if (!context.mounted) return;
                  await context.read<LibraryViewModel>().deletePlaylist(
                    playlist.filePath,
                  );
                },
                child: _playlistTile(
                  context,
                  item,
                  playlist,
                  active,
                  l10n,
                  appCreated: true,
                ),
              )
            : _playlistTile(
                context,
                item,
                playlist,
                active,
                l10n,
                appCreated: false,
              ),
        playTooltip: withDesktopShortcut(
          context,
          l10n.playPlaylist,
          shortcut: DesktopShortcuts.playPause,
        ),
        onPlayPressed: () => _startPlayback(context),
      ),
    };
  }

  Widget _playlistTile(
    BuildContext context,
    LibraryItem item,
    PlaylistFile playlist,
    bool active,
    AppLocalizations l10n, {
    required bool appCreated,
  }) {
    final count = l10n.playlistTrackCount(playlist.entryPaths.length);
    return RetroListTile(
      dense: dense,
      selected: keyboardSelected || active,
      leading: RetroIconChip(icon: Icons.playlist_play, highlight: active),
      title: Text(item.title),
      subtitle: Text(appCreated ? count : '$count · ${l10n.playlistReadOnly}'),
      onTap: () => LibraryNavigator.of(context).openPlaylistDetail(playlist),
    );
  }
}

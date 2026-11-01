import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/playback_item.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';
import 'package:retroplayer/ui/features/playlist/views/library_track_picker_page.dart';
import 'package:retroplayer/ui/features/playlist/views/save_queue_playlist_page.dart';

/// The composed queue. Tracks that have already played stay in the list.
class PlaybackQueueView extends StatefulWidget {
  const PlaybackQueueView({super.key});

  @override
  State<PlaybackQueueView> createState() => _PlaybackQueueViewState();
}

class _PlaybackQueueViewState extends State<PlaybackQueueView> {
  PlayerViewModel? _player;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LibraryViewModel>().reloadQueue();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final player = context.read<PlayerViewModel>();
    if (!identical(_player, player)) {
      _player?.removeListener(_onPlayer);
      _player = player;
      player.addListener(_onPlayer);
    }
  }

  @override
  void dispose() {
    _player?.removeListener(_onPlayer);
    super.dispose();
  }

  void _onPlayer() {
    final player = _player;
    if (player == null || !mounted) return;
    if (player.currentItemId != PlaybackItem.composedQueueId) return;
    final index = player.currentQueueIndex;
    if (index == null) return;
    unawaited(context.read<LibraryViewModel>().noteQueueIndex(index));
  }

  int _markedIndex(LibraryViewModel library, PlayerViewModel player) {
    if (player.currentItemId == PlaybackItem.composedQueueId) {
      final live = player.currentQueueIndex;
      if (live != null) return live;
    }
    return library.queueIndex;
  }

  Future<void> _addTracks() async {
    final library = context.read<LibraryViewModel>();
    final paths = await LibraryTrackPickerPage.open(
      context,
      libraryRoots: library.libraryRoots,
      alreadySelected: library.queuePaths.toSet(),
    );
    if (!mounted || paths == null || paths.isEmpty) return;
    await library.addQueuePaths(paths);
    await _retargetIfPlaying();
  }

  Future<void> _playAt(int index) async {
    final library = context.read<LibraryViewModel>();
    final tracks = library.previewTracksForQueue();
    if (!mounted || tracks.isEmpty || index >= tracks.length) return;
    await library.noteQueueIndex(index);
    if (!mounted) return;
    final player = context.read<PlayerViewModel>();
    await player.playComposedQueue(tracks, startIndex: index);
    unawaited(_adoptQueueTags(player));
  }

  Future<void> _adoptQueueTags(PlayerViewModel player) async {
    final library = context.read<LibraryViewModel>();
    final paths = library.queuePaths.join('\n');
    final tracks = await library.tracksForQueue();
    if (!mounted || library.queuePaths.join('\n') != paths) return;
    player.adoptResolvedTracks(PlaybackItem.composedQueueId, tracks);
  }

  Future<void> _retargetIfPlaying() async {
    final player = context.read<PlayerViewModel>();
    if (player.currentItemId != PlaybackItem.composedQueueId) return;
    final library = context.read<LibraryViewModel>();
    final tracks = library.previewTracksForQueue();
    if (!mounted || tracks.isEmpty) return;
    await player.retargetComposedQueue(tracks, startIndex: library.queueIndex);
    unawaited(_adoptQueueTags(player));
  }

  Future<void> _save() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SaveQueuePlaylistPage()),
    );
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearQueueTitle),
        content: Text(l10n.clearQueueBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.clearQueue),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<LibraryViewModel>().clearQueue();
    if (!mounted) return;
    await context.read<PlayerViewModel>().discardComposedQueuePlayback();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryViewModel>();
    final player = context.watch<PlayerViewModel>();
    final paths = library.queuePaths;
    final marked = paths.isEmpty ? 0 : _markedIndex(library, player);
    final hasTrack = player.hasTrack;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBarBackLeading(),
        title: Text(l10n.queue),
        actions: [
          if (paths.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.clearQueue,
              onPressed: _clear,
            ),
            TextButton(onPressed: _save, child: Text(l10n.saveAsPlaylist)),
          ],
        ],
      ),
      body: PlayerSheetHost(
        sheetKey: const ValueKey('queue_player_sheet'),
        child: paths.isEmpty
            ? Center(child: Text(l10n.queueEmpty))
            : ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: paths.length,
                onReorderItem: (oldIndex, newIndex) {
                  unawaited(() async {
                    await library.reorderQueue(oldIndex, newIndex);
                    await _retargetIfPlaying();
                  }());
                },
                itemBuilder: (context, index) {
                  final path = paths[index];
                  final current = index == marked;
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(path),
                    index: index,
                    child: Dismissible(
                      key: ValueKey('dismiss-$path'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        unawaited(() async {
                          await library.removeQueueAt(index);
                          await _retargetIfPlaying();
                        }());
                      },
                      background: const ColoredBox(
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                      child: RetroListTile(
                        selected: current,
                        leading: Icon(
                          current
                              ? Icons.play_arrow_rounded
                              : Icons.music_note_outlined,
                          color: current
                              ? RetroPalette.of(context).accent
                              : null,
                        ),
                        title: Text(p.basenameWithoutExtension(path)),
                        subtitle: Text(
                          p.basename(p.dirname(path)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RetroTypography.timeLabel(
                            context,
                            compact: true,
                          ),
                        ),
                        onTap: () => _playAt(index),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: hasTrack ? playerCollapsedExtent(context) : 0,
        ),
        child: Tooltip(
          message: withDesktopShortcut(
            context,
            l10n.addTracks,
            shortcut: DesktopShortcuts.addTracks,
          ),
          child: FloatingActionButton.extended(
            onPressed: _addTracks,
            icon: const Icon(Icons.add),
            label: Text(l10n.addTracks),
          ),
        ),
      ),
    );
  }
}

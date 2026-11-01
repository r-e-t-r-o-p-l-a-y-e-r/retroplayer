import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/ui/core/format.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/core/widgets/retro_list_tile.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/navigation/app_bar_back_leading.dart';
import 'package:retroplayer/ui/core/navigation/open_settings_overlay.dart';
import 'package:retroplayer/ui/features/player/widgets/player_sheet_host.dart';

class AlbumDetailView extends StatelessWidget {
  const AlbumDetailView({super.key, required this.album});

  final AudioAlbum album;

  @override
  Widget build(BuildContext context) =>
      _AlbumDetailBody(album: album.sortedTracks());
}

class _AlbumDetailBody extends StatefulWidget {
  const _AlbumDetailBody({required this.album});

  final AudioAlbum album;

  @override
  State<_AlbumDetailBody> createState() => _AlbumDetailBodyState();
}

class _AlbumDetailBodyState extends State<_AlbumDetailBody> {
  final _trackKeys = <String, GlobalKey>{};
  String? _lastScrolledHighlight;

  GlobalKey _keyFor(String trackId) =>
      _trackKeys.putIfAbsent(trackId, GlobalKey.new);

  void _scrollToHighlight(String? highlightId, {int attempt = 0}) {
    if (highlightId == null || highlightId == _lastScrolledHighlight) return;
    final key = _trackKeys[highlightId];
    final targetContext = key?.currentContext;
    if (targetContext == null) {
      if (attempt < 8) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToHighlight(highlightId, attempt: attempt + 1);
        });
      }
      return;
    }
    _lastScrolledHighlight = highlightId;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    final playingTrackId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentTrack?.id,
    );
    final transportPlaying = context.select<PlayerViewModel, bool>(
      (vm) => vm.isPlaying,
    );
    final highlightId = context.select<LibraryViewModel, String?>(
      (vm) => vm.effectiveHighlightedTrackId(playingTrackId),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToHighlight(highlightId);
    });

    return Scaffold(
      backgroundColor: RetroPalette.of(context).screen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBarBackLeading(),
        title: Text(AppLocalizations.of(context).album),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: withDesktopShortcut(
              context,
              AppLocalizations.of(context).settings,
              shortcut: DesktopShortcuts.settings,
            ),
            onPressed: () => openSettingsOverlay(context),
          ),
        ],
      ),
      body: PlayerSheetHost(
        sheetKey: const ValueKey('album_player_sheet'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  AlbumArtFrame(size: 56, imagePath: album.coverArtPath),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: RetroTypography.trackTitle(
                            context,
                          ).copyWith(fontSize: 17),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (album.artist != null)
                          Text(
                            album.artist!,
                            style: RetroTypography.trackSubtitle(
                              context,
                            ).copyWith(fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: album.tracks.length,
                itemBuilder: (context, index) {
                  final track = album.tracks[index];
                  final isPlaying = playingTrackId == track.id;
                  final isHighlighted = highlightId == track.id;
                  return KeyedSubtree(
                    key: _keyFor(track.id),
                    child: _TrackTile(
                      key: ValueKey(track.id),
                      track: track,
                      index: index,
                      album: album,
                      isPlaying: isPlaying && transportPlaying,
                      isHighlighted: isHighlighted,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required super.key,
    required this.track,
    required this.index,
    required this.album,
    required this.isPlaying,
    required this.isHighlighted,
  });

  final AudioTrack track;
  final int index;
  final AudioAlbum album;
  final bool isPlaying;
  final bool isHighlighted;

  Future<void> _startPlayback(BuildContext context) async {
    await context.read<PlayerViewModel>().playAlbumTrack(album, track);
  }

  @override
  Widget build(BuildContext context) {
    final duration = track.durationMs != null
        ? formatDuration(Duration(milliseconds: track.durationMs!))
        : null;

    return RetroListTile(
      key: key,
      selected: isPlaying || isHighlighted,
      leading: SizedBox(
        width: 32,
        child: Center(
          child: isPlaying
              ? Icon(
                  Icons.volume_up_rounded,
                  color: RetroPalette.of(context).accent,
                )
              : Text('${index + 1}', style: RetroTypography.timeLabel(context)),
        ),
      ),
      title: Text(track.displayTitle),
      subtitle: Text(
        [?track.metadata.artist, ?duration].whereType<String>().join(' · '),
      ),
      onTap: () => _startPlayback(context),
      onLongPress: () => _startPlayback(context),
    );
  }
}

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
import 'package:retroplayer/ui/features/player/widgets/player_sheet_metrics.dart';

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
  final _scrollController = ScrollController();
  final _trackKeys = <String, GlobalKey>{};
  String? _lastScrolledHighlight;
  int? _lastHighlightScrollNonce;
  String? _highlightScrollScheduledFor;
  int _highlightScrollScheduledNonce = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String trackId) =>
      _trackKeys.putIfAbsent(trackId, GlobalKey.new);

  void _jumpToHighlightIndex(String highlightId) {
    if (!_scrollController.hasClients) return;
    final tracks = widget.album.tracks;
    final index = tracks.indexWhere((track) => track.id == highlightId);
    if (index < 0) return;
    final position = _scrollController.position;
    final max = position.maxScrollExtent;
    if (max <= 0) return;
    final rows = tracks.length;
    final fraction = (index / rows).clamp(0.0, 1.0);
    final estimated = fraction * max;
    final viewport = position.viewportDimension;
    final target = (estimated - viewport * 0.3).clamp(0.0, max);
    _scrollController.jumpTo(target);
  }

  void _scrollToHighlight(
    String? highlightId,
    int scrollNonce, {
    int attempt = 0,
  }) {
    if (highlightId == null) {
      _lastScrolledHighlight = null;
      _lastHighlightScrollNonce = null;
      return;
    }
    if (highlightId == _lastScrolledHighlight &&
        scrollNonce == _lastHighlightScrollNonce) {
      return;
    }
    _jumpToHighlightIndex(highlightId);
    final key = _trackKeys[highlightId];
    final targetContext = key?.currentContext;
    if (targetContext == null) {
      _jumpToHighlightIndex(highlightId);
      if (attempt < 8) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToHighlight(highlightId, scrollNonce, attempt: attempt + 1);
          }
        });
      }
      return;
    }
    _lastScrolledHighlight = highlightId;
    _lastHighlightScrollNonce = scrollNonce;
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
    final scrollNonce = context.select<LibraryViewModel, int>(
      (vm) => vm.highlightScrollNonce,
    );

    if (highlightId != _highlightScrollScheduledFor ||
        scrollNonce != _highlightScrollScheduledNonce) {
      _highlightScrollScheduledFor = highlightId;
      _highlightScrollScheduledNonce = scrollNonce;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlight(highlightId, scrollNonce);
      });
    }

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
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: playerCollapsedExtent(context),
                ),
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

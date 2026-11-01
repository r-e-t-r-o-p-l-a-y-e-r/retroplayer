import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/ui/features/library/library_navigator.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/library/widgets/library_path_summary.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/now_playing_content.dart';

/// Standalone now-playing screen (used in tests; production uses [MainShellView]).
class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  Future<void> _onBreadcrumbTap(BuildContext context, String? path) =>
      LibraryNavigator.of(context).jumpToPlaybackBreadcrumb(path);

  @override
  Widget build(BuildContext context) {
    final currentTrack = context.select<PlayerViewModel, AudioTrack?>(
      (vm) => vm.currentTrack,
    );
    final currentItemId = context.select<PlayerViewModel, String?>(
      (vm) => vm.currentItemId,
    );
    final hasTrack = context.select<PlayerViewModel, bool>((vm) => vm.hasTrack);
    final vm = context.read<PlayerViewModel>();
    final libraryVm = context.watch<LibraryViewModel>();

    return Scaffold(
      backgroundColor: RetroPalette.of(context).screen,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).nowPlaying),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: LibraryPathSummary(
            breadcrumbs: libraryVm.breadcrumbsForPlayback(
              track: currentTrack,
              playingItemId: currentItemId,
            ),
            tapCurrentSegment: hasTrack,
            onNavigate: (path) => _onBreadcrumbTap(context, path),
          ),
        ),
      ),
      body: NowPlayingContent(viewModel: vm),
    );
  }
}

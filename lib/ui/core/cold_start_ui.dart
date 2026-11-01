import 'package:retroplayer/application/ports/cover_art_source.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';

/// Playback chrome read before [runApp] so the first frame can show the player.
class ColdStartUi {
  const ColdStartUi({
    this.playbackSnapshot,
    this.playerPanelExpanded = false,
  });

  final ({String itemId, SavedPlaybackState state})? playbackSnapshot;
  final bool playerPanelExpanded;

  bool get restoreExpandedPanel =>
      playerPanelExpanded && playbackSnapshot != null;

  static Future<ColdStartUi> load({
    required LibraryStorageService storage,
    required PlaybackRepository playbackRepository,
  }) async {
    final snapshot = await playbackRepository.lastActivePlaybackSnapshot();
    if (snapshot == null) {
      return const ColdStartUi();
    }
    final expanded = await storage.getPlayerPanelExpanded();
    return ColdStartUi(
      playbackSnapshot: snapshot,
      playerPanelExpanded: expanded,
    );
  }

  /// Shared wiring for [main] and widget tests.
  static PlayerViewModel createPlayerViewModel({
    required PlaybackRepository playbackRepository,
    required ColdStartUi coldStart,
    CoverArtSource? resolveCoverArt,
  }) {
    return PlayerViewModel(
      playbackRepository: playbackRepository,
      resolveCoverArt: resolveCoverArt,
      coldStartPlaybackSnapshot: coldStart.playbackSnapshot,
    );
  }

  static PlayerPanelViewModel createPanelViewModel({
    required ColdStartUi coldStart,
    SheetAnimator animator = const AnimatedSheetAnimator(),
  }) {
    return PlayerPanelViewModel(
      animator: animator,
      coldStartExpanded: coldStart.restoreExpandedPanel,
    );
  }
}

import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';

/// Panel VM that jumps the sheet instead of ticking, so widget tests cannot
/// deadlock waiting for an animation the fake binding will not pump.
PlayerPanelViewModel testPanelVm() =>
    PlayerPanelViewModel(animator: const JumpSheetAnimator());

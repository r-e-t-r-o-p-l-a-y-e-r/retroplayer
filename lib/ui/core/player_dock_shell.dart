import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/app_back_guard.dart';
import 'package:retroplayer/ui/core/keyboard/app_shortcuts.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/navigation/app_location.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/player_panel.dart';

/// Wraps shell routes and keeps the mini player docked at the bottom while playing.
///
/// Routes that host [PlayerSheetHost] (library, album, playlist) omit this dock
/// so expand stays a continuous sheet drag. Settings is pushed on the root
/// navigator above this shell, so it never shows the dock and must not collapse
/// an expanded sheet underneath. Stale expanded state off a sheet host is
/// collapsed here.
class PlayerDockShell extends StatelessWidget {
  const PlayerDockShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasSession = context.select<PlayerViewModel, bool>(
      (vm) => vm.hasSession,
    );
    final panelVm = context.watch<PlayerPanelViewModel>();
    // [AppLocation.shellOf] skips the Settings overlay so the underlying
    // library/album/playlist page still counts as a sheet host.
    final hostsSheet = AppLocation.shellOf(context)?.hostsPlayerSheet ?? false;

    if (panelVm.isExpanded && !hostsSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final panel = context.read<PlayerPanelViewModel>();
        final stillOffSheet =
            !(AppLocation.shellOf(context)?.hostsPlayerSheet ?? false);
        if (panel.isExpanded && stillOffSheet) panel.collapse();
      });
    }

    // Sheet hosts draw their own player; nowhere else under this shell shows a
    // dock today (Settings covers the shell entirely).
    final showDock = hasSession && !hostsSheet;

    return AppBackGuard(
      child: AppShortcuts(
        child: ColoredBox(
          color: RetroPalette.of(context).screen,
          child: Column(
            children: [
              Expanded(child: child),
              if (showDock) const PlayerCollapsedBar(),
            ],
          ),
        ),
      ),
    );
  }
}

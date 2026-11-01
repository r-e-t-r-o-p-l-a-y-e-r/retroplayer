import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

/// Loads library data and restores playback session at app startup, regardless
/// of which main tab is shown first.
class AppSessionBootstrap extends StatefulWidget {
  const AppSessionBootstrap({super.key, required this.child});

  final Widget child;

  @override
  State<AppSessionBootstrap> createState() => _AppSessionBootstrapState();
}

class _AppSessionBootstrapState extends State<AppSessionBootstrap> {
  var _persistenceAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final libraryVm = context.read<LibraryViewModel>();
    final libraryRepo = context.read<LibraryRepository>();
    final playerVm = context.read<PlayerViewModel>();
    final panelVm = context.read<PlayerPanelViewModel>();
    final equalizerService = context.read<EqualizerService>();

    if (!_persistenceAttached) {
      _persistenceAttached = true;
      panelVm.attachPersistence(
        onPersistExpanded: libraryRepo.savePlayerPanelExpanded,
        canPersistExpanded: () => playerVm.hasSession,
      );
    }

    final savedExpanded = libraryRepo.getSavedPlayerPanelExpanded();
    await Future.wait([
      libraryVm.ensureLoaded(),
      playerVm.restoreLastSession(libraryRepo),
    ]);
    if (!mounted) return;

    if (playerVm.hasSession &&
        await savedExpanded &&
        !panelVm.isExpanded) {
      panelVm.restoreExpandedFromSavedSession();
    }

    await equalizerService.loadAndApply();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

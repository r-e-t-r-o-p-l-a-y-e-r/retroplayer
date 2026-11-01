import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';

/// True when [BackPolicy] would do something other than absorb (UC-14).
bool backLeadingApplies(BackState state) =>
    BackPolicy.resolve(state) != BackAction.absorb;

/// Desktop AppBar leading control; mirrors Escape / Alt+← / system back.
///
/// On mobile hosts renders nothing and takes no space ([Visibility.maintainSize]).
class AppBarBackLeading extends StatelessWidget {
  const AppBarBackLeading({
    super.key,
    this.desktopHostCheck = isDesktopHost,
  });

  @visibleForTesting
  final bool Function() desktopHostCheck;

  @override
  Widget build(BuildContext context) {
    if (!desktopHostCheck()) {
      return const SizedBox.shrink();
    }

    final libraryVm = _maybeWatch<LibraryViewModel>(context);
    final panelVm = _maybeWatch<PlayerPanelViewModel>(context);
    final listenables = <Listenable>[?libraryVm, ?panelVm];

    if (listenables.isEmpty) {
      return _leadingButton(context, BackPolicy.read(context));
    }

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) =>
          _leadingButton(context, BackPolicy.read(context)),
    );
  }

  Widget _leadingButton(BuildContext context, BackState state) {
    final visible = backLeadingApplies(state);
    return Visibility(
      visible: visible,
      maintainAnimation: false,
      maintainState: false,
      maintainSize: false,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: shortcutTooltip(
          context,
          'Back',
          shortcut: DesktopShortcuts.parentFolder,
        ),
        onPressed: () => BackPolicy.handleInAppBack(context),
      ),
    );
  }
}

/// Pops a [Navigator.push] subpage (e.g. Settings detail) on desktop only.
class DesktopSubpageBackLeading extends StatelessWidget {
  const DesktopSubpageBackLeading({
    super.key,
    this.desktopHostCheck = isDesktopHost,
  });

  @visibleForTesting
  final bool Function() desktopHostCheck;

  @override
  Widget build(BuildContext context) {
    if (!desktopHostCheck() || !Navigator.canPop(context)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: shortcutTooltip(
        context,
        'Back',
        shortcut: DesktopShortcuts.parentFolder,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

T? _maybeWatch<T>(BuildContext context) {
  try {
    return context.watch<T>();
  } on ProviderNotFoundException {
    return null;
  }
}

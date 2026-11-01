import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/navigation/back_policy.dart';
import 'package:retroplayer/ui/core/system_back_ownership.dart';

/// The single handler for system back (Android edge swipe / back button).
///
/// Android only delivers back to Flutter while the framework claims it; that
/// claim is held permanently by [claimSystemBack] on `MaterialApp.router` and
/// reasserted here on resume. [BackPolicy] decides what back does; Escape
/// uses the same rules. At the library root the back is absorbed so the
/// activity is not finished (keeps background playback via the media FGS).
///
/// Users exit via Recents swipe-away, which stops audio through
/// [RetroAudioHandler.onTaskRemoved].
class AppBackGuard extends StatefulWidget {
  const AppBackGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AppBackGuard> createState() => _AppBackGuardState();
}

class _AppBackGuardState extends State<AppBackGuard> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: reassertSystemBackOwnership);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<bool> _onBack() => BackPolicy.handleSystemBack(context);

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: _onBack,
      child: widget.child,
    );
  }
}

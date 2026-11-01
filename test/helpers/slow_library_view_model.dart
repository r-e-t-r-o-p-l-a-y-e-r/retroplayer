import 'dart:async';

import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Blocks [load] until [releaseLoadGate] for bootstrap ordering tests.
class SlowLibraryViewModel extends LibraryViewModel {
  SlowLibraryViewModel({required super.libraryRepository});

  final Completer<void> _loadGate = Completer<void>();
  bool loadStarted = false;

  @override
  Future<void> load() async {
    loadStarted = true;
    await _loadGate.future;
    return super.load();
  }

  void releaseLoadGate() {
    if (!_loadGate.isCompleted) {
      _loadGate.complete();
    }
  }
}

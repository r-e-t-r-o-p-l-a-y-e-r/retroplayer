/// Android lifecycle must not stop the engine on [AppLifecycleState.detached].
///
/// Evidence:
/// - `detached lifecycle does not stop playback engine`
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/recording_playback.dart';

void main() {
  test('detached lifecycle does not stop playback engine', () {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final playback = RecordingPlayback();
    final repo = PlaybackRepository(
      playbackService: playback,
      storageService: storage,
    );
    final vm = PlayerViewModel(playbackRepository: repo);
    addTearDown(vm.dispose);

    vm.didChangeAppLifecycleState(AppLifecycleState.detached);

    expect(playback.stopCalled, isFalse);
  });
}

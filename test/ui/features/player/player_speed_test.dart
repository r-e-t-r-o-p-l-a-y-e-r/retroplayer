/// UC-10: playback speed applies to the player and persists per item.
///
/// Evidence:
/// - `setSpeed applies and is saved with the playback item`
/// - `starting the item again after restart applies the saved speed`
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

import '../../../helpers/real_app.dart';
import '../../../helpers/recording_playback.dart';

void main() {
  late AppDatabase db;
  late LibraryStorageService storage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    db = AppDatabase.inMemory();
    storage = LibraryStorageService(db);
  });

  tearDown(() => db.close());

  PlayerViewModel playerWith(RecordingPlayback playback) => PlayerViewModel(
        playbackRepository: PlaybackRepository(
          playbackService: playback,
          storageService: storage,
        ),
      );

  test('setSpeed applies and is saved with the playback item', () async {
    final playback = RecordingPlayback();
    final vm = playerWith(playback);
    final album = book1Album();
    await vm.playAlbumTrack(album, album.tracks.first);

    await vm.setSpeed(1.5);

    expect(vm.speed, 1.5);
    expect(playback.lastSpeed, 1.5);
    final saved = await storage.getPlaybackState(album.id);
    expect(saved?.speed, 1.5);
    vm.dispose();
  });

  test('starting the item again after restart applies the saved speed',
      () async {
    final album = book1Album();
    final first = playerWith(RecordingPlayback());
    await first.playAlbumTrack(album, album.tracks.first);
    await first.setSpeed(1.25);
    first.dispose();

    final playback = RecordingPlayback();
    final second = playerWith(playback);
    await second.playAlbum(album);

    expect(playback.lastSpeed, 1.25);
    second.dispose();
  });
}

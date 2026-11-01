/// Persistence harness CLI smoke: demo resume and save/verify cycles.
///
/// Evidence:
/// - `runPersistenceDemo resumes saved track and position`
/// - `save and verify in separate open/close cycles`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/dev/persistence_harness.dart';

void main() {
  group('persistence harness', () {
    test('runPersistenceDemo resumes saved track and position', () async {
      const path = '/tmp/retroplayer_persistence_harness_test.db';
      try {
        File(path).deleteSync();
      } catch (_) {}
      final result = await runPersistenceDemo(
        dbPath: path,
      );

      expect(result.startIndex, 1);
      expect(result.trackId, demoTrackId);
      expect(result.initialPosition, const Duration(seconds: 45));
      expect(result.speed, demoSpeed);
    });

    test('save and verify in separate open/close cycles', () async {
      const path = '/tmp/retroplayer_persistence_harness_split.db';
      try {
        File(path).deleteSync();
      } catch (_) {}

      await savePlaybackSession(
        dbPath: path,
        itemId: demoAlbumId,
        trackId: demoTrackId,
        positionMs: 120000,
        speed: 1.5,
      );

      final result = await verifyPlaybackResume(
        dbPath: path,
        album: demoAlbum(),
      );

      expect(result.startIndex, 1);
      expect(result.initialPosition, const Duration(minutes: 2));
      expect(result.speed, 1.5);
    });
  });
}

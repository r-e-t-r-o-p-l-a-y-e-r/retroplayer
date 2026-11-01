import 'dart:io';

import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/playback_resume.dart';

/// Result of simulating playback resume after reopening a database file.
class PersistenceHarnessResult {
  const PersistenceHarnessResult({
    required this.startIndex,
    required this.initialPosition,
    required this.speed,
    required this.trackId,
  });

  final int startIndex;
  final Duration? initialPosition;
  final double speed;
  final String trackId;
}

/// Default demo album used by the persistence harness CLI.
AudioAlbum demoAlbum() {
  const albumId = 'dir:/music/book';
  final tracks = [
    AudioTrack(
      id: '/music/book/ch01.mp3',
      filePath: '/music/book/ch01.mp3',
      directoryPath: '/music/book',
      metadata: const TrackMetadata(trackNumber: 1),
      dateAdded: DateTime(2024, 1, 1),
    ),
    AudioTrack(
      id: '/music/book/ch02.mp3',
      filePath: '/music/book/ch02.mp3',
      directoryPath: '/music/book',
      metadata: const TrackMetadata(trackNumber: 2),
      dateAdded: DateTime(2024, 1, 1),
    ),
  ];
  return AudioAlbum(
    id: albumId,
    title: 'Book',
    tracks: tracks,
    source: AlbumSource.directory,
    groupingKey: albumId,
  );
}

const demoAlbumId = 'dir:/music/book';
const demoTrackId = '/music/book/ch02.mp3';
const demoPositionMs = 45000;
const demoSpeed = 1.25;

/// Saves playback state and closes the database (simulates app exit).
Future<void> savePlaybackSession({
  required String dbPath,
  required String itemId,
  required String trackId,
  required int positionMs,
  double speed = 1.0,
}) async {
  final db = AppDatabase.openAtPath(dbPath);
  try {
    final storage = LibraryStorageService(db);
    await storage.savePlaybackState(
      itemId: itemId,
      trackId: trackId,
      positionMs: positionMs,
      speed: speed,
    );
  } finally {
    await db.close();
  }
}

/// Opens the database and resolves album resume (simulates app launch).
Future<PersistenceHarnessResult> verifyPlaybackResume({
  required String dbPath,
  required AudioAlbum album,
}) async {
  final db = AppDatabase.openAtPath(dbPath);
  try {
    final storage = LibraryStorageService(db);
    final saved = await storage.getPlaybackState(album.id);
    final plan = PlaybackResume.resolveAlbumResume(
      album: album,
      saved: saved,
    );
    return PersistenceHarnessResult(
      startIndex: plan.startIndex,
      initialPosition: plan.initialPosition,
      speed: plan.speed ?? 1.0,
      trackId: plan.trackId,
    );
  } finally {
    await db.close();
  }
}

/// Runs save + close + reopen + verify in one process (automated smoke test).
Future<PersistenceHarnessResult> runPersistenceDemo({String? dbPath}) async {
  final path = dbPath ??
      '${Directory.systemTemp.path}/retroplayer_persistence_harness.db';
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }

  await savePlaybackSession(
    dbPath: path,
    itemId: demoAlbumId,
    trackId: demoTrackId,
    positionMs: demoPositionMs,
    speed: demoSpeed,
  );

  return verifyPlaybackResume(dbPath: path, album: demoAlbum());
}

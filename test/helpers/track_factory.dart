import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

AudioTrack testTrack({
  String? id,
  required String filePath,
  String? directoryPath,
  TrackMetadata? metadata,
  DateTime? dateAdded,
  int? durationMs,
}) {
  return AudioTrack(
    id: id ?? filePath,
    filePath: filePath,
    directoryPath: directoryPath ?? filePath.replaceAll(RegExp(r'/[^/]+$'), ''),
    metadata: metadata ?? const TrackMetadata(),
    dateAdded: dateAdded ?? DateTime(2024, 1, 1),
    durationMs: durationMs,
  );
}

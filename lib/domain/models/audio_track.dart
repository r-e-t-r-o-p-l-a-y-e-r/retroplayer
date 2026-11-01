import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

part 'audio_track.freezed.dart';

@freezed
abstract class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required String id,
    required String filePath,
    required String directoryPath,
    required TrackMetadata metadata,
    required DateTime dateAdded,
    int? durationMs,
  }) = _AudioTrack;

  const AudioTrack._();

  String get displayTitle => metadata.displayTitle(filePath);

  int? get trackNumber => metadata.trackNumber;

  String? get albumTag =>
      metadata.album?.trim().isNotEmpty == true ? metadata.album!.trim() : null;
}

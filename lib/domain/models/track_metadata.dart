import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_metadata.freezed.dart';

@freezed
abstract class TrackMetadata with _$TrackMetadata {
  const factory TrackMetadata({
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    int? trackNumber,
    int? discNumber,
    int? year,
    String? genre,
    Duration? duration,
  }) = _TrackMetadata;

  const TrackMetadata._();

  String displayTitle(String filePath) {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    final name = filePath.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String displayAlbum(String directoryPath) {
    if (album != null && album!.trim().isNotEmpty) return album!.trim();
    return directoryPath.split('/').where((s) => s.isNotEmpty).lastOrNull ??
        'Unknown Album';
  }
}

extension _LastOrNull<E> on Iterable<E> {
  E? get lastOrNull {
    if (isEmpty) return null;
    return last;
  }
}

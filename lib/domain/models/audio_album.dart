import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retroplayer/domain/models/audio_track.dart';

part 'audio_album.freezed.dart';

enum AlbumSource { tag, directory, series }

@freezed
abstract class AudioAlbum with _$AudioAlbum {
  const factory AudioAlbum({
    required String id,
    required String title,
    String? artist,
    String? series,
    required List<AudioTrack> tracks,
    required AlbumSource source,
    required String groupingKey,
    String? coverArtPath,
  }) = _AudioAlbum;

  const AudioAlbum._();

  int get trackCount => tracks.length;

  Duration get totalDuration {
    var total = Duration.zero;
    for (final track in tracks) {
      if (track.durationMs != null) {
        total += Duration(milliseconds: track.durationMs!);
      }
    }
    return total;
  }

  AudioAlbum sortedTracks() {
    final sorted = List<AudioTrack>.from(tracks)
      ..sort((a, b) {
        final aDisc = a.metadata.discNumber ?? 0;
        final bDisc = b.metadata.discNumber ?? 0;
        if (aDisc != bDisc) return aDisc.compareTo(bDisc);
        final aNum = a.trackNumber ?? 9999;
        final bNum = b.trackNumber ?? 9999;
        if (aNum != bNum) return aNum.compareTo(bNum);
        return a.displayTitle.compareTo(b.displayTitle);
      });
    return copyWith(tracks: sorted);
  }
}

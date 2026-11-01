import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';

part 'library_item.freezed.dart';

@freezed
sealed class LibraryItem with _$LibraryItem {
  const factory LibraryItem.album({
    required AudioAlbum album,
  }) = LibraryAlbumItem;

  const factory LibraryItem.track({
    required AudioTrack track,
  }) = LibraryTrackItem;

  const factory LibraryItem.playlist({
    required PlaylistFile playlist,
  }) = LibraryPlaylistItem;

  const LibraryItem._();

  String get id => switch (this) {
        LibraryAlbumItem(:final album) => album.id,
        LibraryTrackItem(:final track) => track.id,
        LibraryPlaylistItem(:final playlist) => playlist.id,
      };

  String get title => switch (this) {
        LibraryAlbumItem(:final album) => album.title,
        LibraryTrackItem(:final track) => track.displayTitle,
        LibraryPlaylistItem(:final playlist) => playlist.displayName,
      };

  String? get subtitle => switch (this) {
        LibraryAlbumItem(:final album) =>
          album.artist ?? '${album.trackCount} tracks',
        LibraryTrackItem(:final track) => track.metadata.artist,
        LibraryPlaylistItem(:final playlist) =>
          '${playlist.entryPaths.length} tracks',
      };
}

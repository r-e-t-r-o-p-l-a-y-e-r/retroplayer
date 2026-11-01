import 'package:retroplayer/domain/models/audio_album.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/playlist_file.dart';

/// Something [LibraryViewModel] wants the UI to do: navigate, play, show a
/// message or ask for confirmation. The view model never touches the router,
/// dialogs or other view models; the UI layer runs these.
sealed class LibraryEffect {
  const LibraryEffect();
}

final class OpenAlbumDetail extends LibraryEffect {
  const OpenAlbumDetail(this.album);

  final AudioAlbum album;
}

final class OpenPlaylistDetail extends LibraryEffect {
  const OpenPlaylistDetail(this.playlist);

  final PlaylistFile playlist;
}

final class PlayFolder extends LibraryEffect {
  const PlayFolder(this.folderPath, this.tracks);

  final String folderPath;
  final List<AudioTrack> tracks;
}

final class PlayLibraryItem extends LibraryEffect {
  const PlayLibraryItem(this.item, {this.playlistTracks = const []});

  final LibraryItem item;

  /// Resolved entries when [item] is a playlist.
  final List<AudioTrack> playlistTracks;
}

/// A playlist resolved to no playable tracks.
final class ShowNothingToPlay extends LibraryEffect {
  const ShowNothingToPlay();
}

final class ConfirmRemoveRoot extends LibraryEffect {
  const ConfirmRemoveRoot(this.path, {this.displayName});

  final String path;
  final String? displayName;
}

final class ConfirmDeletePlaylist extends LibraryEffect {
  const ConfirmDeletePlaylist(this.playlist);

  final PlaylistFile playlist;
}

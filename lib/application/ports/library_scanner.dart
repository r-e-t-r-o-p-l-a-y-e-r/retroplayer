import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';

/// Turns folders on disk into library items.
abstract interface class LibraryScanner {
  /// Audio (grouped into albums) and playlists in one directory level.
  ///
  /// First event is placeholders named after each file; later events replace
  /// those rows as tags are read and regroup albums. Completes when done.
  Stream<DirectoryListingUpdate> watchDirectoryShallow(String directoryPath);

  /// Last snapshot of [watchDirectoryShallow].
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath);

  /// Every audio file under [rootPath], recursively.
  Future<List<AudioTrack>> scanDirectoryRecursive(String rootPath);

  Future<AudioTrack> trackFromPath(String filePath);
}

/// Read-only view of the library folders on disk.
abstract interface class LibraryFileSystem {
  /// Supported audio files directly in [directoryPath].
  Future<List<String>> listAudioFilesInDirectory(String directoryPath);

  /// `.m3u`/`.m3u8` files directly in [directoryPath].
  Future<List<String>> listPlaylistFilesInDirectory(String directoryPath);

  /// Supported audio files under [rootPath], recursively.
  Future<List<String>> scanDirectory(String rootPath);

  /// Absolute local entry paths of a playlist file.
  Future<List<String>> readPlaylistEntries(String playlistPath);
}

/// Reads tags from one audio file.
abstract interface class TrackMetadataReader {
  Future<TrackMetadata> readMetadata(String filePath);
}

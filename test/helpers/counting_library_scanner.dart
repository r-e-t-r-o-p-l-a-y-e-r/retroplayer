import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/domain/models/audio_track.dart';
import 'package:retroplayer/domain/models/directory_listing_update.dart';
import 'package:retroplayer/domain/models/library_item.dart';
import 'package:retroplayer/domain/models/track_metadata.dart';
import 'package:retroplayer/domain/use_cases/group_tracks_into_albums.dart';

import 'track_factory.dart';

/// [LibraryScanner] that counts shallow scans and tag reads for restore tests.
class CountingLibraryScanner implements LibraryScanner {
  CountingLibraryScanner({
    required Map<String, List<String>> audioFilesByDirectory,
  }) : _audioFilesByDirectory = audioFilesByDirectory;

  final Map<String, List<String>> _audioFilesByDirectory;
  final _group = const GroupTracksIntoAlbums();

  int trackFromPathCalls = 0;
  int shallowScanStarts = 0;
  final List<String> shallowScanPaths = [];

  @override
  Future<AudioTrack> trackFromPath(String filePath) async {
    trackFromPathCalls++;
    return testTrack(
      filePath: filePath,
      metadata: TrackMetadata(title: 'Tagged ${filePath.split('/').last}'),
    );
  }

  @override
  Stream<DirectoryListingUpdate> watchDirectoryShallow(
    String directoryPath,
  ) async* {
    shallowScanStarts++;
    shallowScanPaths.add(directoryPath);
    final paths = _audioFilesByDirectory[directoryPath] ?? const [];
    if (paths.isEmpty) {
      yield DirectoryListingUpdate.complete(const []);
      return;
    }
    final tracks = <AudioTrack>[];
    for (final path in paths) {
      tracks.add(await trackFromPath(path));
    }
    final items = _group(tracks);
    yield DirectoryListingUpdate.complete(items);
  }

  @override
  Future<List<LibraryItem>> scanDirectoryShallow(String directoryPath) async {
    DirectoryListingUpdate? last;
    await for (final update in watchDirectoryShallow(directoryPath)) {
      last = update;
    }
    return last?.items ?? const [];
  }

  @override
  Future<List<AudioTrack>> scanDirectoryRecursive(String rootPath) async {
    final paths = _audioFilesByDirectory[rootPath] ?? const [];
    return [for (final path in paths) await trackFromPath(path)];
  }
}

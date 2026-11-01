import 'package:retroplayer/application/ports/cover_art_source.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';
import 'package:retroplayer/domain/models/library_item.dart';

/// Resolves and fills in cover art for library items.
class CoverArtService {
  CoverArtService({CoverArtSource? source})
    : _source =
          source ??
          ResolveCoverArt(
            readEmbeddedArtwork: MetadataService().readEmbeddedArtwork,
          );

  final CoverArtSource _source;

  String? resolve({
    required String directoryPath,
    required String trackFilePath,
  }) => _source(directoryPath: directoryPath, trackFilePath: trackFilePath);

  /// Fills missing album [coverArtPath]s, yielding between albums.
  /// Returns the input list (same instance) when nothing changed.
  Future<List<LibraryItem>> enrichAlbumCovers(
    List<LibraryItem> items, {
    bool Function()? shouldContinue,
  }) async {
    final needsWork = items.any(
      (item) =>
          item is LibraryAlbumItem &&
          item.album.coverArtPath == null &&
          item.album.tracks.isNotEmpty,
    );
    if (!needsWork) return items;

    final result = <LibraryItem>[];
    var changed = false;
    for (final item in items) {
      if (shouldContinue != null && !shouldContinue()) return items;
      switch (item) {
        case LibraryAlbumItem(:final album)
            when album.coverArtPath == null && album.tracks.isNotEmpty:
          await Future<void>.delayed(Duration.zero);
          if (shouldContinue != null && !shouldContinue()) return items;
          final track = album.tracks.first;
          final cover = _source(
            directoryPath: track.directoryPath,
            trackFilePath: track.filePath,
          );
          if (cover != null) {
            changed = true;
            result.add(
              LibraryItem.album(album: album.copyWith(coverArtPath: cover)),
            );
          } else {
            result.add(item);
          }
        default:
          result.add(item);
      }
    }
    return changed ? result : items;
  }
}

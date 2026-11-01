import 'package:retroplayer/domain/models/library_item.dart';

/// One snapshot of a directory as its files are read.
class DirectoryListingUpdate {
  const DirectoryListingUpdate({
    required this.items,
    required this.scannedFileCount,
    required this.totalFileCount,
    required this.isComplete,
  });

  factory DirectoryListingUpdate.complete(List<LibraryItem> items) {
    return DirectoryListingUpdate(
      items: items,
      scannedFileCount: items.length,
      totalFileCount: items.length,
      isComplete: true,
    );
  }

  /// Albums, standalone/placeholder tracks and playlists in this folder.
  final List<LibraryItem> items;

  /// Audio files whose tags have been read.
  final int scannedFileCount;

  /// Audio files in the folder.
  final int totalFileCount;

  /// True when every file has been read (or there were none).
  final bool isComplete;
}

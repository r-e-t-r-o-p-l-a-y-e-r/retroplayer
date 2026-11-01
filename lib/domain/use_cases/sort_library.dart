import 'package:retroplayer/domain/models/library_item.dart';

/// Orders library items by track number, then title.
class SortLibrary {
  List<LibraryItem> call(List<LibraryItem> items) {
    final sorted = List<LibraryItem>.from(items);
    sorted.sort((a, b) {
      final aNum = _trackNumber(a) ?? 9999;
      final bNum = _trackNumber(b) ?? 9999;
      final cmp = aNum.compareTo(bNum);
      return cmp != 0
          ? cmp
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return sorted;
  }

  int? _trackNumber(LibraryItem item) => switch (item) {
    LibraryAlbumItem(:final album) => album.tracks.firstOrNull?.trackNumber,
    LibraryTrackItem(:final track) => track.trackNumber,
    LibraryPlaylistItem() => null,
  };
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

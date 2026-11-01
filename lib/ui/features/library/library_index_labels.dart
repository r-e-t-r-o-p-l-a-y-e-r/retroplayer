/// Index-scrubber helpers for the library list (content-driven A–Z / # / •).
library;

const libraryIndexDigitChar = '#';
const libraryIndexOtherChar = '•';

/// First index character for a display [title].
String libraryIndexCharFor(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) return libraryIndexDigitChar;
  final code = trimmed.runes.first;
  final char = String.fromCharCode(code);
  final upper = char.toUpperCase();
  if (upper.compareTo('A') >= 0 && upper.compareTo('Z') <= 0) {
    return upper;
  }
  if (code >= 0x30 && code <= 0x39) {
    return libraryIndexDigitChar;
  }
  return libraryIndexOtherChar;
}

/// Unique index labels present in [titles].
///
/// Order matches typical case-insensitive path/name sort: symbols (`.…`) first,
/// then digits, then `A`–`Z` — so a `.dotfolder` sits with `•` above `A`, not
/// after `Z`.
List<String> libraryIndexLabelsFor(Iterable<String> titles) {
  final present = <String>{};
  for (final title in titles) {
    present.add(libraryIndexCharFor(title));
  }
  final labels = <String>[];
  if (present.contains(libraryIndexOtherChar)) {
    labels.add(libraryIndexOtherChar);
  }
  if (present.contains(libraryIndexDigitChar)) {
    labels.add(libraryIndexDigitChar);
  }
  for (var i = 0; i < 26; i++) {
    final letter = String.fromCharCode(0x41 + i); // A–Z
    if (present.contains(letter)) labels.add(letter);
  }
  return labels;
}

/// First row index whose title maps to [indexChar], or null if none.
int? firstLibraryIndexMatching(
  List<String> titles,
  String indexChar,
) {
  for (var i = 0; i < titles.length; i++) {
    if (libraryIndexCharFor(titles[i]) == indexChar) return i;
  }
  return null;
}

/// Approximate scroll offset for a selectable row in the folder browse list.
double estimateLibraryRowScrollOffset({
  required int rowIndex,
  required int folderCount,
  required int playlistCount,
  required int audioCount,
  double sectionHeaderExtent = 36,
  double dividerExtent = 16,
  double rowExtent = 72,
}) {
  if (rowIndex < 0) return 0;

  var offset = 0.0;
  final hasFolders = folderCount > 0;
  final hasPlaylists = playlistCount > 0;
  final hasAudio = audioCount > 0;

  if (hasFolders) {
    offset += sectionHeaderExtent;
    if (rowIndex < folderCount) {
      return offset + rowIndex * rowExtent;
    }
    offset += folderCount * rowExtent;
  }

  if (hasPlaylists) {
    if (hasFolders) offset += dividerExtent;
    offset += sectionHeaderExtent;
    final playlistIndex = rowIndex - folderCount;
    if (playlistIndex < playlistCount) {
      return offset + playlistIndex * rowExtent;
    }
    offset += playlistCount * rowExtent;
  }

  if (hasAudio) {
    if (hasFolders || hasPlaylists) offset += dividerExtent;
    offset += sectionHeaderExtent;
    final audioIndex = rowIndex - folderCount - playlistCount;
    return offset + audioIndex.clamp(0, audioCount) * rowExtent;
  }

  return offset;
}

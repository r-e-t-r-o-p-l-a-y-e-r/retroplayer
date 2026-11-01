/// Preferred sidecar image filenames (order = preference).
const albumArtCandidateNames = [
  'cover.jpg',
  'cover.jpeg',
  'cover.png',
  'cover.webp',
  'folder.jpg',
  'folder.jpeg',
  'folder.png',
  'folder.webp',
  'album.jpg',
  'album.jpeg',
  'album.png',
  'album.webp',
  'albumart.jpg',
  'albumart.jpeg',
  'albumart.png',
  'albumart.webp',
  'front.jpg',
  'front.jpeg',
  'front.png',
  'front.webp',
  'artwork.jpg',
  'artwork.jpeg',
  'artwork.png',
  'artwork.webp',
  '.folder.jpg',
  '.folder.png',
];

final albumArtCandidateNamesLower =
    albumArtCandidateNames.map((name) => name.toLowerCase()).toSet();

/// Image extensions accepted as folder artwork (including non-standard names).
const albumArtImageExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
];

final albumArtImageExtensionsLower =
    albumArtImageExtensions.map((ext) => ext.toLowerCase()).toSet();

bool isAlbumArtImageFileName(String fileName) {
  final lower = fileName.toLowerCase();
  final dot = lower.lastIndexOf('.');
  if (dot < 0) return false;
  return albumArtImageExtensionsLower.contains(lower.substring(dot));
}

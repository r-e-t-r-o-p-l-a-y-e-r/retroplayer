/// Finds a displayable cover image for a folder or track.
abstract interface class CoverArtSource {
  /// Path to cover art, or null when none is available.
  ///
  /// With [extractEmbedded] false only cheap lookups run (no tag parse, no
  /// image copy), for listing many folders.
  String? call({
    required String directoryPath,
    String? trackFilePath,
    bool extractEmbedded = true,
  });
}

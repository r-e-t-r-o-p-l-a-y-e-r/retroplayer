package app.retroplayer.domain

object SupportedFormats {
    val audioExtensions = setOf("mp3", "m4a", "m4b", "flac", "wav", "ogg", "opus")
    val playlistExtensions = setOf("m3u", "m3u8")
    private val imageExtensions = setOf("jpg", "jpeg", "png", "webp", "gif")

    /** Sidecar artwork names, most preferred first. */
    val folderArtNames = listOf("cover", "folder", "album", "albumart", "front", "artwork", ".folder")
        .flatMap { base -> listOf("jpg", "jpeg", "png", "webp").map { "$base.$it" } }

    fun isAudio(fileName: String): Boolean = extensionOf(fileName) in audioExtensions

    fun isPlaylist(fileName: String): Boolean = extensionOf(fileName) in playlistExtensions

    fun isImage(fileName: String): Boolean = extensionOf(fileName) in imageExtensions

    /** Best artwork file among [fileNames]: a known name first, then any image. */
    fun preferredFolderArt(fileNames: List<String>): String? {
        val byLower = fileNames.associateBy { it.lowercase() }
        folderArtNames.firstNotNullOfOrNull { byLower[it] }?.let { return it }
        return fileNames.filter(::isImage).minOrNull()
    }

    private fun extensionOf(fileName: String): String {
        val dot = fileName.lastIndexOf('.')
        return if (dot > 0) fileName.substring(dot + 1).lowercase() else ""
    }
}

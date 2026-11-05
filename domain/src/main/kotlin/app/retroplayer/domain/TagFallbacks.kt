package app.retroplayer.domain

/** What to show when tags are missing, blank, placeholders or garbled. */
object TagFallbacks {
    private val placeholders = Regex(
        """^(<\s*)?(unknown( artist| album| title)?|track\s*\d+)(\s*>)?$""",
        RegexOption.IGNORE_CASE,
    )

    /** `1-05 Song`, `01 - Intro`, `03. End`, `07_chapter`: optional disc, 1–3 digit track, separator. */
    private val leadingNumber = Regex("""^\s*(?:(\d{1,2})[-.])?(\d{1,3})(?:\s*[-._)\]]+\s*|\s+)(?=\S)""")
    private val trackWord = Regex("""^\s*track\s*(\d{1,3})\b""", RegexOption.IGNORE_CASE)
    private val discFolder = Regex("""^\s*(?:cd|disc|disk|part)\s*(\d{1,3})\s*$""", RegexOption.IGNORE_CASE)

    fun clean(value: String?): String? {
        val repaired = TextRepair.repair(value)?.trim()
        if (repaired.isNullOrEmpty() || placeholders.matches(repaired)) return null
        return repaired
    }

    fun title(tag: String?, fileName: String): String {
        clean(tag)?.let { return it }
        val base = baseName(fileName)
        val match = leadingNumber.find(base) ?: return base
        val rest = base.substring(match.range.last + 1).trim()
        return rest.ifEmpty { base }
    }

    fun trackNumber(tag: Int?, fileName: String): Int? {
        if (tag != null && tag > 0) return tag
        val base = baseName(fileName)
        leadingNumber.find(base)?.let { return it.groupValues[2].toInt() }
        return trackWord.find(base)?.groupValues?.get(1)?.toInt()
    }

    fun discNumber(tag: Int?, fileName: String, folderName: String): Int? {
        if (tag != null && tag > 0) return tag
        leadingNumber.find(baseName(fileName))?.groupValues?.get(1)?.takeIf { it.isNotEmpty() }?.let { return it.toInt() }
        return discFolder.find(folderName)?.groupValues?.get(1)?.toInt()
    }

    fun artist(artist: String?, albumArtist: String?, composer: String?): String? =
        clean(artist) ?: clean(albumArtist) ?: clean(composer)

    private fun baseName(fileName: String): String {
        val dot = fileName.lastIndexOf('.')
        return if (dot > 0) fileName.substring(0, dot) else fileName
    }
}

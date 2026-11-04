package app.retroplayer.domain

import java.net.URLDecoder
import java.nio.ByteBuffer
import java.nio.charset.CharacterCodingException
import java.nio.charset.Charset
import java.nio.charset.CodingErrorAction

/** Reads and writes `.m3u` / `.m3u8` playlists. Only local entries inside the library survive. */
object M3u {
    data class Written(val text: String, val skipped: List<LibraryPath>)

    private val cp1250: Charset = Charset.forName("windows-1250")

    /** UTF-8 (with or without BOM) first, Windows-1250 for legacy files. */
    fun decode(bytes: ByteArray): String {
        val payload = if (bytes.size >= 3 && bytes[0] == 0xEF.toByte() && bytes[1] == 0xBB.toByte() && bytes[2] == 0xBF.toByte()) {
            bytes.copyOfRange(3, bytes.size)
        } else {
            bytes
        }
        return try {
            Charsets.UTF_8.newDecoder()
                .onMalformedInput(CodingErrorAction.REPORT)
                .onUnmappableCharacter(CodingErrorAction.REPORT)
                .decode(ByteBuffer.wrap(payload))
                .toString()
        } catch (_: CharacterCodingException) {
            String(payload, cp1250)
        }
    }

    /**
     * Entries resolved against the playlist's folder. Absolute paths and
     * `file:` URIs are mapped by [absolute] (null when outside the library).
     */
    fun parse(text: String, playlist: LibraryPath, absolute: (String) -> LibraryPath?): List<LibraryPath> {
        val folder = playlist.parent ?: return emptyList()
        return text.lineSequence()
            .map { it.trim() }
            .filter { it.isNotEmpty() && !it.startsWith("#") }
            .filter(LocalPathPolicy::isLocal)
            .mapNotNull { entry ->
                when {
                    entry.startsWith("file:", ignoreCase = true) -> absolute(fileUriToPath(entry))
                    entry.startsWith("/") || entry.matches(Regex("^[a-zA-Z]:[\\\\/].*")) -> absolute(entry)
                    else -> folder.resolve(entry)
                }
            }
            .toList()
    }

    /** Relative entries; entries on another root cannot be expressed and are reported as skipped. */
    fun write(playlist: LibraryPath, entries: List<LibraryPath>): Written {
        val folder = playlist.parent ?: playlist
        val lines = StringBuilder("#EXTM3U\n")
        val skipped = mutableListOf<LibraryPath>()
        for (entry in entries) {
            val relative = entry.relativeTo(folder)
            if (relative == null) skipped += entry else lines.append(relative).append('\n')
        }
        return Written(lines.toString(), skipped)
    }

    private fun fileUriToPath(uri: String): String {
        val withoutScheme = uri.substring("file:".length).let { if (it.startsWith("//")) it.substring(2) else it }
        val path = if (withoutScheme.startsWith("/")) withoutScheme else withoutScheme.substringAfter('/', "")
            .let { "/$it" }
        return URLDecoder.decode(path.replace("+", "%2B"), Charsets.UTF_8)
    }
}

object PlaylistEntries {
    /** Supported audio under one of [roots], not yet in [existing], first occurrence only. */
    fun filterNew(candidates: List<LibraryPath>, roots: List<LibraryPath>, existing: Set<LibraryPath>): List<LibraryPath> {
        val seen = existing.toMutableSet()
        return candidates.filter { path ->
            SupportedFormats.isAudio(path.name) && roots.any { path.isWithin(it) } && seen.add(path)
        }
    }
}

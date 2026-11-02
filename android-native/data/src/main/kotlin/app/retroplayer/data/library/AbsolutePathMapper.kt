package app.retroplayer.data.library

import app.retroplayer.domain.LibraryPath
import java.net.URLDecoder

data class RootLocation(val rootId: String, val authority: String, val treeDocumentId: String)

/**
 * Maps absolute filesystem paths (as written by other players into `.m3u`
 * files) onto library roots. Only external storage trees have a known
 * filesystem location; other providers are opaque.
 */
class AbsolutePathMapper(private val roots: List<RootLocation>) {
    fun toLibraryPath(absolute: String): LibraryPath? {
        val normalized = normalize(absolute) ?: return null
        return roots.firstNotNullOfOrNull { root ->
            val base = absoluteFolder(root.authority, root.treeDocumentId) ?: return@firstNotNullOfOrNull null
            when {
                normalized == base -> LibraryPath.root(root.rootId)
                normalized.startsWith("$base/") ->
                    LibraryPath.root(root.rootId).resolve(normalized.removePrefix("$base/"))
                else -> null
            }
        }
    }

    private fun normalize(path: String): String? {
        if (!path.startsWith("/")) return null
        val trimmed = path.trimEnd('/')
        return when {
            trimmed == "/sdcard" || trimmed.startsWith("/sdcard/") -> PRIMARY + trimmed.removePrefix("/sdcard")
            trimmed.startsWith("/mnt/sdcard") -> PRIMARY + trimmed.removePrefix("/mnt/sdcard")
            else -> trimmed
        }
    }

    companion object {
        const val EXTERNAL_STORAGE_AUTHORITY = "com.android.externalstorage.documents"
        private const val PRIMARY = "/storage/emulated/0"

        /** Filesystem folder of an external storage tree (`primary:Music` → `/storage/emulated/0/Music`). */
        fun absoluteFolder(authority: String, treeDocumentId: String): String? {
            if (authority != EXTERNAL_STORAGE_AUTHORITY || ':' !in treeDocumentId) return null
            val volume = treeDocumentId.substringBefore(':')
            val relative = treeDocumentId.substringAfter(':').trim('/')
            val base = if (volume.equals("primary", ignoreCase = true)) PRIMARY else "/storage/$volume"
            return if (relative.isEmpty()) base else "$base/$relative"
        }

        /** Where a picked tree lives, for row subtitles (`primary:Music` → `/Music`); null for opaque providers. */
        fun displayLocation(treeUri: String): String? {
            val authority = treeUri.removePrefix("content://").substringBefore('/', missingDelimiterValue = "")
            val encodedId = treeUri.substringAfter("/tree/", missingDelimiterValue = "").substringBefore('/')
            if (encodedId.isEmpty()) return null
            val id = URLDecoder.decode(encodedId.replace("+", "%2B"), "UTF-8")
            val folder = absoluteFolder(authority, id) ?: return null
            return folder.removePrefix(PRIMARY).ifEmpty { "/" }
        }
    }
}

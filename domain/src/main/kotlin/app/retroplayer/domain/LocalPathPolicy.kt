package app.retroplayer.domain

/** Local-only policy for playlist entries: plain paths and `file:` URIs; nothing remote. */
object LocalPathPolicy {
    private val scheme = Regex("^([a-zA-Z][a-zA-Z0-9+.-]*):")

    fun isLocal(entry: String): Boolean {
        val trimmed = entry.trim()
        if (trimmed.isEmpty()) return false
        val match = scheme.find(trimmed) ?: return true
        val name = match.groupValues[1].lowercase()
        // A single letter is a Windows drive (`C:\Music`).
        return name == "file" || name.length == 1
    }
}

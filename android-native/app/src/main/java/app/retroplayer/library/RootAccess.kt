package app.retroplayer.library

/** Grants and releases storage access for library roots. */
interface RootAccess {
    /** Keeps read access to a picked folder tree and adds it as a root; null when access was not granted. */
    suspend fun add(treeUri: String): String?

    /** Forgets a root, its stored state and its access grant. Files are untouched. */
    suspend fun remove(rootId: String)
}

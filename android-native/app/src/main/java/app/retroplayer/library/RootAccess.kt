package app.retroplayer.library

/** Grants and releases storage access for library roots. */
interface RootAccess {
    /** Keeps read access to a picked folder tree and adds it as a root; null when access was not granted. */
    suspend fun add(treeUri: String): String?

    /**
     * Upgrades [rootId] to read and write with the tree the user picked from
     * [writeAccessIntent]. Another folder is rejected (its grant is not kept)
     * and the root stays read only.
     */
    suspend fun grantWrite(rootId: String, pickedTreeUri: String): Boolean

    /** Forgets a root, its stored state and its access grant. Files are untouched. */
    suspend fun remove(rootId: String)
}

package app.retroplayer.library

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.net.toUri
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.domain.LibraryPath
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/** Library roots backed by persisted Storage Access Framework tree grants (read only by default). */
@Singleton
class SafRootAccess @Inject constructor(
    @ApplicationContext private val context: Context,
    private val store: LibraryStore,
    private val scanner: LibraryScanner,
) : RootAccess {
    override suspend fun add(treeUri: String): String? {
        val tree = treeUri.toUri()
        try {
            context.contentResolver.takePersistableUriPermission(tree, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } catch (_: SecurityException) {
            return null
        }
        return store.addRoot(treeUri, displayName(tree), canWrite = false)
    }

    override suspend fun remove(rootId: String) {
        val root = store.root(rootId) ?: return
        store.removeRoot(rootId)
        scanner.invalidate(LibraryPath.root(rootId))
        if (store.allRoots().none { it.treeUri == root.treeUri }) {
            val tree = root.treeUri.toUri()
            context.contentResolver.persistedUriPermissions
                .filter { it.uri == tree }
                .forEach { grant ->
                    val flags = (if (grant.isReadPermission) Intent.FLAG_GRANT_READ_URI_PERMISSION else 0) or
                        (if (grant.isWritePermission) Intent.FLAG_GRANT_WRITE_URI_PERMISSION else 0)
                    runCatching { context.contentResolver.releasePersistableUriPermission(tree, flags) }
                }
        }
    }

    private fun displayName(tree: Uri): String {
        val fallback = DocumentsContract.getTreeDocumentId(tree).substringAfterLast(':').substringAfterLast('/')
            .ifEmpty { tree.lastPathSegment.orEmpty() }
        val document = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        return runCatching {
            context.contentResolver.query(document, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null)
                ?.use { if (it.moveToFirst()) it.getString(0) else null }
        }.getOrNull()?.takeIf { it.isNotBlank() } ?: fallback
    }
}

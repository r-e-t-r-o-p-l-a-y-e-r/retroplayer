package app.retroplayer.data.saf

import android.content.ContentResolver
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import app.retroplayer.data.library.DocumentNode
import app.retroplayer.data.library.DocumentSource

/** Storage Access Framework backend: every uri is a document uri inside a granted tree. */
class SafDocumentSource(private val resolver: ContentResolver) : DocumentSource {
    override suspend fun children(folderUri: String): List<DocumentNode> {
        val folder = Uri.parse(folderUri)
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(folder, DocumentsContract.getDocumentId(folder))
        val nodes = mutableListOf<DocumentNode>()
        resolver.query(childrenUri, PROJECTION, null, null)?.use { c ->
            val id = c.getColumnIndexOrThrow(Document.COLUMN_DOCUMENT_ID)
            val name = c.getColumnIndexOrThrow(Document.COLUMN_DISPLAY_NAME)
            val mime = c.getColumnIndexOrThrow(Document.COLUMN_MIME_TYPE)
            val modified = c.getColumnIndexOrThrow(Document.COLUMN_LAST_MODIFIED)
            val size = c.getColumnIndexOrThrow(Document.COLUMN_SIZE)
            while (c.moveToNext()) {
                val displayName = c.getString(name) ?: continue
                nodes += DocumentNode(
                    uri = DocumentsContract.buildDocumentUriUsingTree(folder, c.getString(id)).toString(),
                    name = displayName,
                    isDirectory = c.getString(mime) == Document.MIME_TYPE_DIR,
                    lastModified = if (c.isNull(modified)) 0 else c.getLong(modified),
                    size = if (c.isNull(size)) 0 else c.getLong(size),
                )
            }
        }
        return nodes
    }

    override suspend fun read(uri: String): ByteArray =
        resolver.openInputStream(Uri.parse(uri))?.use { it.readBytes() } ?: error("cannot open $uri")

    override suspend fun write(uri: String, bytes: ByteArray) {
        resolver.openOutputStream(Uri.parse(uri), "wt")?.use { it.write(bytes) } ?: error("cannot write $uri")
    }

    override suspend fun create(folderUri: String, name: String, mimeType: String): String? =
        DocumentsContract.createDocument(resolver, Uri.parse(folderUri), mimeType, name)?.toString()

    override suspend fun delete(uri: String): Boolean = DocumentsContract.deleteDocument(resolver, Uri.parse(uri))

    companion object {
        private val PROJECTION = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_SIZE,
        )

        /** Document uri of the folder a tree grant points at. */
        fun rootDocumentUri(treeUri: String): String {
            val tree = Uri.parse(treeUri)
            return DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree)).toString()
        }
    }
}

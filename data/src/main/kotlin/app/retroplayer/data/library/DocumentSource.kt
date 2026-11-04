package app.retroplayer.data.library

import app.retroplayer.domain.model.TrackMetadata

data class DocumentNode(
    val uri: String,
    val name: String,
    val isDirectory: Boolean,
    val lastModified: Long,
    val size: Long,
)

/** Storage backend for library folders (Storage Access Framework in the app, fakes in tests). */
interface DocumentSource {
    suspend fun children(folderUri: String): List<DocumentNode>
    suspend fun read(uri: String): ByteArray
    suspend fun write(uri: String, bytes: ByteArray)

    /** Creates an empty file; returns its uri or null when the provider refuses. */
    suspend fun create(folderUri: String, name: String, mimeType: String): String?
    suspend fun delete(uri: String): Boolean
}

fun interface MetadataReader {
    /** Tags of an audio document, or null when it cannot be read. */
    suspend fun read(uri: String): TrackMetadata?
}

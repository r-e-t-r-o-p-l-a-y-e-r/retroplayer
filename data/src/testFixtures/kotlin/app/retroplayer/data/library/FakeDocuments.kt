package app.retroplayer.data.library

import app.retroplayer.domain.model.TrackMetadata

/** In-memory document tree; uris are `doc:<path>` with `/` separated names below the root uri. */
class FakeDocumentSource(private val rootUri: String = "doc:root") : DocumentSource {
    private val files = linkedMapOf<String, Pair<ByteArray, Long>>()
    private val dirs = linkedSetOf(rootUri)
    var listCalls = 0
        private set

    fun file(relative: String, bytes: ByteArray = ByteArray(4), modified: Long = 1L) {
        val uri = "$rootUri/$relative"
        files[uri] = bytes to modified
        var parent = uri.substringBeforeLast('/')
        while (parent.length >= rootUri.length) {
            dirs += parent
            if (parent == rootUri) break
            parent = parent.substringBeforeLast('/')
        }
    }

    fun dir(relative: String) {
        dirs += "$rootUri/$relative"
    }

    override suspend fun children(folderUri: String): List<DocumentNode> {
        listCalls++
        val prefix = "$folderUri/"
        val childDirs = dirs.filter { it.startsWith(prefix) && '/' !in it.removePrefix(prefix) }
            .map { DocumentNode(it, it.substringAfterLast('/'), isDirectory = true, lastModified = 0, size = 0) }
        val childFiles = files.filterKeys { it.startsWith(prefix) && '/' !in it.removePrefix(prefix) }
            .map { (uri, v) -> DocumentNode(uri, uri.substringAfterLast('/'), isDirectory = false, lastModified = v.second, size = v.first.size.toLong()) }
        return childDirs + childFiles
    }

    override suspend fun read(uri: String): ByteArray = files[uri]?.first ?: error("missing $uri")

    override suspend fun write(uri: String, bytes: ByteArray) {
        files[uri] = bytes to (files[uri]?.second ?: 0L) + 1
    }

    override suspend fun create(folderUri: String, name: String, mimeType: String): String {
        val uri = "$folderUri/$name"
        files[uri] = ByteArray(0) to 1L
        return uri
    }

    override suspend fun delete(uri: String): Boolean = files.remove(uri) != null

    fun text(relative: String): String = String(files.getValue("$rootUri/$relative").first)
}

class FakeMetadataReader(private val byName: Map<String, TrackMetadata> = emptyMap()) : MetadataReader {
    val reads = mutableListOf<String>()

    override suspend fun read(uri: String): TrackMetadata? {
        reads += uri
        return byName[uri.substringAfterLast('/')] ?: TrackMetadata(durationMs = 1000)
    }
}

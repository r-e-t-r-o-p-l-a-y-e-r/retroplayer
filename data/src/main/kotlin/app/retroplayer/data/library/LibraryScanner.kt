package app.retroplayer.data.library

import app.retroplayer.data.db.TrackCacheDao
import app.retroplayer.data.db.TrackCacheEntity
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.SupportedFormats
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.domain.model.TrackMetadata
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

data class FolderEntry(val path: LibraryPath, val uri: String)

/** One state of a progressive folder scan; [complete] once every track has its tags, [exists] false when there is no such folder. */
data class FolderListing(
    val path: LibraryPath,
    val folders: List<FolderEntry>,
    val tracks: List<AudioTrack>,
    val playlists: List<PlaylistRef>,
    val folderArtUri: String?,
    val scanned: Int,
    val total: Int,
    val complete: Boolean,
    val exists: Boolean = true,
)

/** A file found in the tree, with its library path. */
private data class Found(val path: LibraryPath, val node: DocumentNode)

/**
 * Lazy folder scanning on top of a [DocumentSource] with a persistent tag
 * cache. Folder children are cached in memory per process so path lookups
 * are cheap; [listFolder] always refreshes the folder it shows.
 */
class LibraryScanner(
    private val source: DocumentSource,
    private val reader: MetadataReader,
    private val cache: TrackCacheDao,
    private val rootUri: suspend (rootId: String) -> String?,
    private val ioDispatcher: CoroutineDispatcher,
) {
    private val children = ConcurrentHashMap<LibraryPath, List<DocumentNode>>()

    fun listFolder(path: LibraryPath): Flow<FolderListing> = flow {
        val folder = resolve(path)
        if (folder == null || !folder.isDirectory) {
            emit(FolderListing(path, emptyList(), emptyList(), emptyList(), null, 0, 0, complete = true, exists = false))
            return@flow
        }
        val nodes = refresh(path, folder.uri).filterNot { it.name.startsWith(".") }
        val folders = nodes.filter { it.isDirectory }.map { FolderEntry(path.child(it.name), it.uri) }
        val playlists = nodes.filter { !it.isDirectory && SupportedFormats.isPlaylist(it.name) }
            .map { PlaylistRef(path.child(it.name), it.uri) }
        val images = nodes.filter { !it.isDirectory && SupportedFormats.isImage(it.name) }
        val art = SupportedFormats.preferredFolderArt(images.map { it.name })
            ?.let { name -> images.first { it.name == name }.uri }
        val audio = nodes.filter { !it.isDirectory && SupportedFormats.isAudio(it.name) }
            .map { Found(path.child(it.name), it) }

        val known = cached(audio)
        val tracks = LinkedHashMap<String, AudioTrack>()
        audio.forEach { f -> tracks[f.node.uri] = known[f.node.uri] ?: AudioTrack(f.path, f.node.uri, hasMetadata = false) }
        val missing = audio.filter { it.node.uri !in known }

        var scanned = audio.size - missing.size
        fun snapshot() = FolderListing(
            path, folders, tracks.values.toList(), playlists, art,
            scanned = scanned, total = audio.size, complete = scanned == audio.size,
        )
        emit(snapshot())
        for (batch in missing.chunked(BATCH)) {
            read(batch).forEach { tracks[it.uri] = it }
            scanned += batch.size
            emit(snapshot())
        }
    }

    /** Every audio file below [path] with tags, skipping hidden folders. */
    suspend fun tracksUnder(path: LibraryPath): List<AudioTrack> {
        val folder = resolve(path) ?: return emptyList()
        if (!folder.isDirectory) return tracksAt(listOf(path)).filterNotNull()
        val found = mutableListOf<Found>()
        suspend fun walk(dir: LibraryPath, uri: String) {
            for (node in childrenOf(dir, uri)) {
                if (node.name.startsWith(".")) continue
                val child = dir.child(node.name)
                when {
                    node.isDirectory -> walk(child, node.uri)
                    SupportedFormats.isAudio(node.name) -> found += Found(child, node)
                }
            }
        }
        walk(path, folder.uri)
        return withTags(found)
    }

    /** Tracks for [paths] in order; null where the file no longer exists. */
    suspend fun tracksAt(paths: List<LibraryPath>): List<AudioTrack?> {
        val found = paths.mapNotNull { path -> resolve(path)?.takeIf { !it.isDirectory }?.let { Found(path, it) } }
        val byPath = withTags(found).associateBy { it.path }
        return paths.map { byPath[it] }
    }

    suspend fun resolve(path: LibraryPath): DocumentNode? {
        val root = rootUri(path.rootId) ?: return null
        var node = DocumentNode(root, path.rootId, isDirectory = true, lastModified = 0, size = 0)
        var current = LibraryPath.root(path.rootId)
        for (segment in path.segments) {
            if (!node.isDirectory) return null
            node = childrenOf(current, node.uri).firstOrNull { it.name == segment } ?: return null
            current = current.child(segment)
        }
        return node
    }

    private val changes = MutableSharedFlow<LibraryPath>(extraBufferCapacity = 64)

    /** Folders the app changed through [invalidate]; listings at or below them are stale. */
    val changed: SharedFlow<LibraryPath> = changes.asSharedFlow()

    /** Forgets cached children of [path] and everything below it. */
    fun invalidate(path: LibraryPath) {
        children.keys.removeIf { it.isWithin(path) }
        changes.tryEmit(path)
    }

    fun invalidateAll() = children.clear()

    private suspend fun childrenOf(path: LibraryPath, uri: String): List<DocumentNode> =
        children[path] ?: refresh(path, uri)

    private suspend fun refresh(path: LibraryPath, uri: String): List<DocumentNode> =
        withContext(ioDispatcher) { source.children(uri) }.also { children[path] = it }

    private suspend fun withTags(found: List<Found>): List<AudioTrack> {
        val known = cached(found)
        val read = found.filter { it.node.uri !in known }.chunked(BATCH).flatMap { read(it) }.associateBy { it.uri }
        return found.map { known[it.node.uri] ?: read.getValue(it.node.uri) }
    }

    /** Cached tracks whose file is unchanged, keyed by uri. */
    private suspend fun cached(found: List<Found>): Map<String, AudioTrack> {
        if (found.isEmpty()) return emptyMap()
        val byUri = found.associateBy { it.node.uri }
        val rows = found.chunked(500).flatMap { chunk -> withContext(ioDispatcher) { cache.get(chunk.map { it.node.uri }) } }
        return rows.mapNotNull { row ->
            val f = byUri[row.uri] ?: return@mapNotNull null
            if (f.node.lastModified != row.lastModified || f.node.size != row.size) return@mapNotNull null
            row.uri to AudioTrack(f.path, row.uri, row.toMetadata(), hasMetadata = true)
        }.toMap()
    }

    private suspend fun read(batch: List<Found>): List<AudioTrack> {
        val results = coroutineScope {
            batch.map { f ->
                async(ioDispatcher) { f to (runCatching { reader.read(f.node.uri) }.getOrNull() ?: TrackMetadata()) }
            }.awaitAll()
        }
        withContext(ioDispatcher) { cache.upsert(results.map { (f, meta) -> meta.toEntity(f.node) }) }
        return results.map { (f, meta) -> AudioTrack(f.path, f.node.uri, meta, hasMetadata = true) }
    }

    private fun TrackCacheEntity.toMetadata() =
        TrackMetadata(title, artist, album, albumArtist, composer, trackNumber, discNumber, year, genre, durationMs)

    private fun TrackMetadata.toEntity(node: DocumentNode) = TrackCacheEntity(
        uri = node.uri, lastModified = node.lastModified, size = node.size,
        title = title, artist = artist, album = album, albumArtist = albumArtist, composer = composer,
        trackNumber = trackNumber, discNumber = discNumber, year = year, genre = genre, durationMs = durationMs,
    )

    private companion object {
        const val BATCH = 8
    }
}

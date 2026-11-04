package app.retroplayer.data.library

import app.retroplayer.data.db.LibraryStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.M3u
import app.retroplayer.domain.model.AudioTrack

/** A playlist line; [track] is null when the file is missing. */
data class PlaylistEntry(val path: LibraryPath, val track: AudioTrack?)

/** [editable] only for playlists this app created; files found on disk stay read-only. */
data class PlaylistContent(val path: LibraryPath, val entries: List<PlaylistEntry>, val editable: Boolean)

sealed interface SaveResult {
    data class Saved(val path: LibraryPath) : SaveResult
    data class NeedsWriteAccess(val rootId: String) : SaveResult
    data object NameTaken : SaveResult
    data object InvalidName : SaveResult
    data object Failed : SaveResult
}

/** Reads any `.m3u`; creates, rewrites and deletes only app-created ones, and only with write access. */
class PlaylistFiles(
    private val source: DocumentSource,
    private val scanner: LibraryScanner,
    private val store: LibraryStore,
    private val canWrite: suspend (rootId: String) -> Boolean,
    private val absolute: (String) -> LibraryPath?,
) {
    suspend fun read(path: LibraryPath): PlaylistContent {
        val node = scanner.resolve(path) ?: return PlaylistContent(path, emptyList(), editable = false)
        val text = M3u.decode(runCatching { source.read(node.uri) }.getOrDefault(ByteArray(0)))
        val paths = M3u.parse(text, path, absolute)
        val tracks = scanner.tracksAt(paths)
        return PlaylistContent(path, paths.zip(tracks) { p, t -> PlaylistEntry(p, t) }, store.isAppPlaylist(path))
    }

    suspend fun save(folder: LibraryPath, name: String, entries: List<LibraryPath>): SaveResult {
        val fileName = fileNameFor(name) ?: return SaveResult.InvalidName
        if (!canWrite(folder.rootId)) return SaveResult.NeedsWriteAccess(folder.rootId)
        val folderNode = scanner.resolve(folder)?.takeIf { it.isDirectory } ?: return SaveResult.Failed
        val path = folder.child(fileName)
        if (scanner.resolve(path) != null) return SaveResult.NameTaken
        val uri = runCatching { source.create(folderNode.uri, fileName, MIME) }.getOrNull() ?: return SaveResult.Failed
        val ok = runCatching { source.write(uri, M3u.write(path, entries).text.toByteArray(Charsets.UTF_8)) }.isSuccess
        scanner.invalidate(folder)
        if (!ok) return SaveResult.Failed
        store.registerAppPlaylist(path)
        return SaveResult.Saved(path)
    }

    suspend fun overwrite(path: LibraryPath, entries: List<LibraryPath>): Boolean {
        if (!store.isAppPlaylist(path) || !canWrite(path.rootId)) return false
        val node = scanner.resolve(path) ?: return false
        return runCatching { source.write(node.uri, M3u.write(path, entries).text.toByteArray(Charsets.UTF_8)) }.isSuccess
    }

    suspend fun delete(path: LibraryPath): Boolean {
        if (!store.isAppPlaylist(path) || !canWrite(path.rootId)) return false
        val node = scanner.resolve(path) ?: return false
        if (!runCatching { source.delete(node.uri) }.getOrDefault(false)) return false
        store.forgetAppPlaylist(path)
        path.parent?.let(scanner::invalidate)
        return true
    }

    private fun fileNameFor(name: String): String? {
        val trimmed = name.trim()
        if (trimmed.isEmpty() || trimmed.startsWith(".") || trimmed.any { it in FORBIDDEN || it.code < 0x20 }) return null
        val lower = trimmed.lowercase()
        return if (lower.endsWith(".m3u") || lower.endsWith(".m3u8")) trimmed else "$trimmed.m3u"
    }

    private companion object {
        const val MIME = "audio/x-mpegurl"
        const val FORBIDDEN = "/\\:*?\"<>|"
    }
}

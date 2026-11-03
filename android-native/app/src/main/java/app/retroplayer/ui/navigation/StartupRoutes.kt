package app.retroplayer.ui.navigation

import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.playback.NowPlaying

/** Back stacks that put a page on screen with its parents behind it, so back walks up the tree. */
object StartupRoutes {
    fun build(browsePath: LibraryPath?, openAlbumId: String?, rootIds: Set<String>): List<Any> {
        val folder = browsePath?.takeIf { it.rootId in rootIds }
        val album = openAlbumId?.takeIf { AlbumIds.directoryOf(it)?.rootId in rootIds }
        return folderChain(folder) + listOfNotNull(album?.let(::AlbumRoute))
    }

    fun folderChain(path: LibraryPath?): List<FolderRoute> {
        if (path == null) return listOf(FolderRoute())
        val chain = generateSequence(path) { it.parent }.toList().asReversed()
        return listOf(FolderRoute()) + chain.map { FolderRoute(it.value) }
    }

    /** Back stack to show where [now] is playing (UC-13). */
    fun locate(now: NowPlaying, rootIds: Set<String>): List<Any> {
        val trackId = now.trackId ?: return listOf(FolderRoute())
        AlbumIds.directoryOf(now.itemId.orEmpty())?.takeIf { it.rootId in rootIds }?.let { dir ->
            return build(dir, now.itemId, rootIds)
        }
        PlaybackItem.playlistPathFromId(now.itemId.orEmpty())?.takeIf { it.rootId in rootIds }?.let { playlist ->
            return folderChain(playlist.parent) + PlaylistRoute(playlist.value)
        }
        PlaybackItem.folderPathFromId(now.itemId.orEmpty())?.takeIf { it.rootId in rootIds }?.let { folder ->
            return folderChain(folder)
        }
        return folderChain(LibraryPath(trackId).parent?.takeIf { it.rootId in rootIds })
    }
}

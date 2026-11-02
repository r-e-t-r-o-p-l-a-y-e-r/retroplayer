package app.retroplayer.ui.navigation

import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath

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
}

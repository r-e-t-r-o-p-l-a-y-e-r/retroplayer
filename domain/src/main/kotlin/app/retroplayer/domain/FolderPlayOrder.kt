package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem

/**
 * Queue for "play folder": what you see is what you hear. Depth first, each
 * folder's own albums and tracks in listing order, then its subfolders in
 * natural name order.
 */
class FolderPlayOrder(
    private val group: GroupTracksIntoAlbums,
    private val sort: SortLibrary,
    private val albums: AlbumOrdering,
) {
    operator fun invoke(
        folder: LibraryPath,
        tracks: List<AudioTrack>,
        choiceFor: (albumId: String) -> AlbumSortChoice,
    ): List<AudioTrack> {
        val inside = tracks.filter { it.path != folder && it.path.isWithin(folder) }
        val byDir = inside.groupBy { it.directory }
        val children = HashMap<LibraryPath, MutableSet<LibraryPath>>()
        for (dir in byDir.keys) {
            var current = dir
            while (current != folder) {
                val parent = current.parent ?: break
                children.getOrPut(parent) { linkedSetOf() } += current
                current = parent
            }
        }

        fun visit(dir: LibraryPath): List<AudioTrack> {
            val own = sort(group(byDir[dir].orEmpty())).flatMap { item ->
                when (item) {
                    is LibraryItem.Album -> albums.order(item.album.tracks, choiceFor(item.id))
                    is LibraryItem.Track -> listOf(item.track)
                    is LibraryItem.Playlist -> emptyList()
                }
            }
            return own + sort.folders(children[dir].orEmpty().toList()).flatMap(::visit)
        }
        return visit(folder)
    }
}

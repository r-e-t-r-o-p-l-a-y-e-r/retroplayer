package app.retroplayer.playback

import app.retroplayer.data.library.FolderView
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaybackItem

/** Titles of the fixed top-level nodes, from the app's string resources. */
data class TreeLabels(val sources: String, val favorites: String, val queue: String)

/** One browse node for Android Auto and other media browsers; [id] is also what plays it. */
data class TreeNode(
    val id: String,
    val title: String,
    val subtitle: String? = null,
    val browsable: Boolean,
    val playable: Boolean,
    val trackUri: String? = null,
)

/**
 * The media browse tree: root -> library sources (each root's folder tree),
 * favorites, queue. Folders and albums are browsable and playable; playing
 * a track inside an album plays the album from that track.
 */
class LibraryTree(
    private val roots: suspend () -> List<Pair<LibraryPath, String>>,
    private val favorites: suspend () -> List<LibraryPath>,
    private val folder: suspend (LibraryPath) -> FolderView?,
    private val albumTracks: suspend (albumId: String) -> List<AudioTrack>?,
    private val labels: TreeLabels,
) {
    suspend fun children(parentId: String, page: Int = 0, pageSize: Int = Int.MAX_VALUE): List<TreeNode> {
        val all = when (parentId) {
            ROOT_ID -> listOf(
                TreeNode(SOURCES_ID, labels.sources, browsable = true, playable = false),
                TreeNode(FAVORITES_ID, labels.favorites, browsable = true, playable = false),
                TreeNode(PlaybackItem.QUEUE_ID, labels.queue, browsable = false, playable = true),
            )
            SOURCES_ID -> roots().map { (path, name) -> folderNode(path, name) }
            FAVORITES_ID -> favorites().map { folderNode(it, it.name) }
            else -> PlaybackItem.folderPathFromId(parentId)?.let { folderChildren(it) }
                ?: albumTracks(parentId)?.map { trackNode(it, inItem = parentId) }
                ?: emptyList()
        }
        if (page < 0 || pageSize <= 0) return emptyList()
        val from = page.toLong() * pageSize
        return if (from >= all.size) emptyList() else all.drop(from.toInt()).take(pageSize)
    }

    private suspend fun folderChildren(path: LibraryPath): List<TreeNode> {
        val view = folder(path) ?: return emptyList()
        val items = view.items
        return view.folders.map { folderNode(it.path, it.path.name) } +
            items.filterIsInstance<LibraryItem.Playlist>().map {
                TreeNode(it.id, it.playlist.displayName, browsable = false, playable = true)
            } +
            items.mapNotNull { item ->
                when (item) {
                    is LibraryItem.Album -> TreeNode(item.id, item.album.title, item.album.artist, browsable = true, playable = true)
                    is LibraryItem.Track -> trackNode(item.track, inItem = null)
                    is LibraryItem.Playlist -> null
                }
            }
    }

    private fun folderNode(path: LibraryPath, title: String) =
        TreeNode(PlaybackItem.folderId(path), title, browsable = true, playable = true)

    private fun trackNode(track: AudioTrack, inItem: String?) = TreeNode(
        id = inItem?.let { PlaybackRequests.inItem(it, track.id) } ?: track.id,
        title = track.displayTitle,
        subtitle = track.displayArtist,
        browsable = false,
        playable = true,
        trackUri = track.uri,
    )

    companion object {
        const val ROOT_ID = "root"
        const val SOURCES_ID = "nav:roots"
        const val FAVORITES_ID = "nav:favorites"
    }
}

package app.retroplayer.data.library

import app.retroplayer.data.db.LibraryStore
import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.AlbumOrdering
import app.retroplayer.domain.FolderPlayOrder
import app.retroplayer.domain.GroupTracksIntoAlbums
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.NaturalOrder
import app.retroplayer.domain.SortLibrary
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.last
import kotlinx.coroutines.flow.map
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

/** A folder as the library shows it: subfolders, then albums, tracks and playlists in listing order. */
data class FolderView(
    val path: LibraryPath,
    val folders: List<FolderEntry>,
    val items: List<LibraryItem>,
    val artUri: String?,
    val scanned: Int,
    val total: Int,
    val complete: Boolean,
    val exists: Boolean,
)

class LibraryRepository(
    private val store: LibraryStore,
    private val scanner: LibraryScanner,
    private val locale: () -> Locale = Locale::getDefault,
) {
    private val albums = ConcurrentHashMap<String, AudioAlbum>()
    private val folderArt = ConcurrentHashMap<LibraryPath, String>()

    fun folder(path: LibraryPath): Flow<FolderView> = flow {
        val logic = logic()
        scanner.listFolder(path).map { listing ->
            listing.folderArtUri?.let { folderArt[path] = it }
            val grouped = logic.group(listing.tracks)
            grouped.filterIsInstance<LibraryItem.Album>().forEach { albums[it.id] = it.album }
            FolderView(
                path = path,
                folders = listing.folders.sortedWith(compareBy(logic.names) { it.path.name }),
                items = logic.sort(grouped + listing.playlists.map { LibraryItem.Playlist(it) }),
                artUri = listing.folderArtUri,
                scanned = listing.scanned,
                total = listing.total,
                complete = listing.complete,
                exists = listing.exists,
            )
        }.collect { emit(it) }
    }

    /** Album by id; loads its folder when it was not listed in this process (e.g. after a restart). */
    suspend fun album(id: String): AudioAlbum? {
        albums[id]?.let { return it }
        val dir = AlbumIds.directoryOf(id) ?: return null
        folder(dir).last()
        return albums[id]
    }

    /** Id of the album [track] is grouped into in its folder; null for a track shown on its own. */
    suspend fun albumOf(track: LibraryPath): String? {
        val folder = track.parent ?: return null
        return folder(folder).last().items.filterIsInstance<LibraryItem.Album>()
            .firstOrNull { album -> album.album.tracks.any { it.id == track.value } }?.id
    }

    /** Artwork file found in [folder] during its last listing. */
    fun folderArt(folder: LibraryPath): String? = folderArt[folder]

    /** Album ordering for the current locale. */
    fun albumOrdering(): AlbumOrdering = AlbumOrdering(NaturalOrder(locale()))

    suspend fun albumTracks(album: AudioAlbum): List<AudioTrack> =
        logic().ordering.order(album.tracks, store.albumSort(album.id))

    suspend fun folderQueue(path: LibraryPath): List<AudioTrack> {
        val logic = logic()
        val choices = store.albumSorts.first()
        return FolderPlayOrder(logic.group, logic.sort, logic.ordering)(path, scanner.tracksUnder(path)) { id ->
            choices[id] ?: AlbumSortChoice.AUTOMATIC
        }
    }

    private class Logic(val names: NaturalOrder, val group: GroupTracksIntoAlbums) {
        val sort = SortLibrary(names)
        val ordering = AlbumOrdering(names)
    }

    private suspend fun logic(): Logic {
        val rootNames = store.allRoots().associate { it.id to it.name }
        val names = NaturalOrder(locale())
        return Logic(names, GroupTracksIntoAlbums { path -> if (path.isRoot) rootNames[path.rootId] ?: path.name else path.name })
    }
}

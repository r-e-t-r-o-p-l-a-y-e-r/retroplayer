package app.retroplayer.playback

import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.PlaylistRef

/** Rebuilds a playback item from its persisted id. Items that exist but hold no tracks resolve with an empty queue. */
class PlaybackItemResolver(
    private val repository: LibraryRepository,
    private val scanner: LibraryScanner,
    private val playlists: PlaylistFiles,
    private val queuePaths: suspend () -> List<LibraryPath>,
) {
    suspend fun resolve(itemId: String): PlaybackItem? {
        if (itemId == PlaybackItem.QUEUE_ID) {
            return PlaybackItem.Queue(scanner.tracksAt(queuePaths()).filterNotNull())
        }
        AlbumIds.directoryOf(itemId)?.let {
            val album = repository.album(itemId) ?: return null
            return PlaybackItem.Album(album, repository.albumTracks(album))
        }
        PlaybackItem.folderPathFromId(itemId)?.let { folder ->
            if (scanner.resolve(folder)?.isDirectory != true) return null
            return PlaybackItem.Folder(folder, repository.folderQueue(folder))
        }
        PlaybackItem.playlistPathFromId(itemId)?.let { path ->
            val node = scanner.resolve(path)?.takeIf { !it.isDirectory } ?: return null
            val tracks = playlists.read(path).entries.mapNotNull { it.track }
            return PlaybackItem.Playlist(PlaylistRef(path, node.uri), tracks)
        }
        val track = scanner.tracksAt(listOf(LibraryPath(itemId))).single() ?: return null
        return PlaybackItem.Single(track)
    }
}

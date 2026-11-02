package app.retroplayer.domain.model

import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.TagFallbacks

/** Something playable: it has a persisted id and the queue it plays. */
sealed interface PlaybackItem {
    val id: String
    val tracks: List<AudioTrack>

    /** Speed applied when there is no saved state; null keeps the current speed. */
    val defaultSpeed: Float? get() = null

    data class Queue(override val tracks: List<AudioTrack>) : PlaybackItem {
        override val id: String get() = QUEUE_ID
    }

    /** An album in its effective order; tracks without tags inherit the album title and artist. */
    class Album(val album: AudioAlbum, orderedTracks: List<AudioTrack>) : PlaybackItem {
        override val id: String get() = album.id
        override val tracks: List<AudioTrack> = orderedTracks.map { track ->
            track.copy(
                metadata = track.metadata.copy(
                    artist = TagFallbacks.clean(track.metadata.artist) ?: album.artist,
                    album = TagFallbacks.clean(track.metadata.album) ?: album.title,
                ),
            )
        }
        override val defaultSpeed: Float get() = 1f
    }

    data class Folder(val folder: LibraryPath, override val tracks: List<AudioTrack>) : PlaybackItem {
        override val id: String get() = folderId(folder)
    }

    data class Playlist(val playlist: PlaylistRef, override val tracks: List<AudioTrack>) : PlaybackItem {
        override val id: String get() = playlist.id
    }

    data class Single(val track: AudioTrack) : PlaybackItem {
        override val id: String get() = track.id
        override val tracks: List<AudioTrack> get() = listOf(track)
    }

    companion object {
        const val QUEUE_ID = "queue"
        private const val FOLDER = "folder:"
        private const val PLAYLIST = "playlist:"

        fun folderId(path: LibraryPath) = FOLDER + path.value
        fun playlistId(path: LibraryPath) = PLAYLIST + path.value
        fun folderPathFromId(id: String): LibraryPath? =
            if (id.startsWith(FOLDER)) LibraryPath(id.removePrefix(FOLDER)) else null

        fun playlistPathFromId(id: String): LibraryPath? =
            if (id.startsWith(PLAYLIST)) LibraryPath(id.removePrefix(PLAYLIST)) else null
    }
}

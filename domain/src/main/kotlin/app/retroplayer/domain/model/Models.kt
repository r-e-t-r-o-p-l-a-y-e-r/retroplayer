package app.retroplayer.domain.model

import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.TagFallbacks

data class TrackMetadata(
    val title: String? = null,
    val artist: String? = null,
    val album: String? = null,
    val albumArtist: String? = null,
    val composer: String? = null,
    val trackNumber: Int? = null,
    val discNumber: Int? = null,
    val year: Int? = null,
    val genre: String? = null,
    val durationMs: Long? = null,
)

/**
 * One audio file. [path] is the stable identity (resume key); [uri] is the
 * storage document the player opens.
 */
data class AudioTrack(
    val path: LibraryPath,
    val uri: String,
    val metadata: TrackMetadata = TrackMetadata(),
    val hasMetadata: Boolean = true,
) {
    val id: String get() = path.value
    val directory: LibraryPath get() = path.parent ?: path
    val fileName: String get() = path.name
    val displayTitle: String get() = TagFallbacks.title(metadata.title, fileName)
    val displayArtist: String? get() = TagFallbacks.artist(metadata.artist, metadata.albumArtist, metadata.composer)
    val displayTrackNumber: Int? get() = TagFallbacks.trackNumber(metadata.trackNumber, fileName)
    val displayDiscNumber: Int? get() = TagFallbacks.discNumber(metadata.discNumber, fileName, directory.name)
    val albumTag: String? get() = TagFallbacks.clean(metadata.album)
    val durationMs: Long? get() = metadata.durationMs
}

enum class AlbumSource { TAG, DIRECTORY }

data class AudioAlbum(
    val id: String,
    val title: String,
    val artist: String?,
    val tracks: List<AudioTrack>,
    val source: AlbumSource,
    val directory: LibraryPath,
) {
    val totalDurationMs: Long get() = tracks.sumOf { it.durationMs ?: 0L }
}

data class PlaylistRef(val path: LibraryPath, val uri: String) {
    val id: String get() = PlaybackItem.playlistId(path)
    val displayName: String get() = path.baseName
}

sealed interface LibraryItem {
    val id: String
    val title: String

    data class Album(val album: AudioAlbum) : LibraryItem {
        override val id: String get() = album.id
        override val title: String get() = album.title
    }

    data class Track(val track: AudioTrack) : LibraryItem {
        override val id: String get() = track.id
        override val title: String get() = track.displayTitle
    }

    data class Playlist(val playlist: PlaylistRef) : LibraryItem {
        override val id: String get() = playlist.id
        override val title: String get() = playlist.displayName
    }
}

/** Persisted per-album sort. [AUTOMATIC] is the default and is never stored. */
enum class AlbumSortChoice { AUTOMATIC, TAG_FORCED, FILE_NAME, TITLE }

/** Sort options offered in the album view. */
enum class AlbumSortMode { TAG, FILE_NAME, TITLE }

data class SavedPlaybackState(
    val trackId: String,
    val positionMs: Long,
    val speed: Float = 1f,
    val displayTitle: String? = null,
    val subtitle: String? = null,
    val durationMs: Long? = null,
)

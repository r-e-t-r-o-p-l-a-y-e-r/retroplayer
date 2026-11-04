package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.AudioTrack

sealed interface AlbumSortSelection {
    data class Store(val choice: AlbumSortChoice) : AlbumSortSelection

    /** Tags cannot order this album; ask before forcing tag order. */
    data class ConfirmTagOrder(val missingTrackNumbers: Int) : AlbumSortSelection {
        fun confirmed(): Store = Store(AlbumSortChoice.TAG_FORCED)
    }
}

/** Effective track order inside an album, honoring the per-album choice. */
class AlbumOrdering(private val names: Comparator<String>) {
    fun tagsUsable(tracks: List<AudioTrack>): Boolean {
        if (tracks.any { (it.metadata.trackNumber ?: 0) <= 0 }) return false
        val keys = tracks.map { (it.metadata.discNumber ?: 0) to it.metadata.trackNumber }
        return keys.toSet().size == keys.size
    }

    fun effectiveMode(tracks: List<AudioTrack>, choice: AlbumSortChoice): AlbumSortMode = when (choice) {
        AlbumSortChoice.AUTOMATIC -> if (tagsUsable(tracks)) AlbumSortMode.TAG else AlbumSortMode.FILE_NAME
        AlbumSortChoice.TAG_FORCED -> AlbumSortMode.TAG
        AlbumSortChoice.FILE_NAME -> AlbumSortMode.FILE_NAME
        AlbumSortChoice.TITLE -> AlbumSortMode.TITLE
    }

    fun order(tracks: List<AudioTrack>, choice: AlbumSortChoice): List<AudioTrack> {
        val byFileName = compareBy(names) { track: AudioTrack -> track.fileName }
        val comparator = when (effectiveMode(tracks, choice)) {
            AlbumSortMode.TAG -> compareBy<AudioTrack> { if ((it.metadata.trackNumber ?: 0) > 0) 0 else 1 }
                .thenBy { it.metadata.discNumber ?: 0 }
                .thenBy { it.metadata.trackNumber ?: 0 }
                .then(byFileName)
            AlbumSortMode.FILE_NAME -> byFileName
            AlbumSortMode.TITLE -> compareBy(names) { track: AudioTrack -> track.displayTitle }.then(byFileName)
        }
        return tracks.sortedWith(comparator)
    }

    /** Maps a user selection to what gets stored; [AlbumSortChoice.AUTOMATIC] means "store nothing". */
    fun select(mode: AlbumSortMode, tracks: List<AudioTrack>): AlbumSortSelection {
        val usable = tagsUsable(tracks)
        return when (mode) {
            AlbumSortMode.TAG -> if (usable) {
                AlbumSortSelection.Store(AlbumSortChoice.AUTOMATIC)
            } else {
                AlbumSortSelection.ConfirmTagOrder(tracks.count { (it.metadata.trackNumber ?: 0) <= 0 })
            }
            AlbumSortMode.FILE_NAME ->
                AlbumSortSelection.Store(if (usable) AlbumSortChoice.FILE_NAME else AlbumSortChoice.AUTOMATIC)
            AlbumSortMode.TITLE -> AlbumSortSelection.Store(AlbumSortChoice.TITLE)
        }
    }
}

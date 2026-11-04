package app.retroplayer.domain

import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem

/** One breadcrumb; the library root crumb has an empty label the UI localizes. */
data class Crumb(val label: String, val path: LibraryPath?, val isLibraryRoot: Boolean = false)

object Breadcrumbs {
    private val libraryRoot = Crumb(label = "", path = null, isLibraryRoot = true)

    fun library(browse: LibraryPath?, rootName: (String) -> String?): List<Crumb> {
        if (browse == null) return listOf(libraryRoot)
        val rootLabel = rootName(browse.rootId) ?: return listOf(libraryRoot, Crumb(browse.name, null))
        var current = LibraryPath.root(browse.rootId)
        val crumbs = mutableListOf(libraryRoot, Crumb(rootLabel, current))
        for (segment in browse.segments) {
            current = current.child(segment)
            crumbs += Crumb(segment, current)
        }
        return crumbs
    }

    fun playback(track: AudioTrack?, playingItemId: String?, rootName: (String) -> String?): List<Crumb> {
        if (track == null) return listOf(libraryRoot)
        val trackCrumb = Crumb(track.displayTitle, track.path)
        val playlist = playingItemId?.let(PlaybackItem::playlistPathFromId)
        if (playlist != null) {
            return library(playlist.parent, rootName) + Crumb(playlist.baseName, playlist) + trackCrumb
        }
        return library(track.directory, rootName) + trackCrumb
    }
}

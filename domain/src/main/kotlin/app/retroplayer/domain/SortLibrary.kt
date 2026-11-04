package app.retroplayer.domain

import app.retroplayer.domain.model.LibraryItem

/** Order of a folder listing: there is no manual ordering, so this rule is the order. */
class SortLibrary(private val names: Comparator<String>) {
    operator fun invoke(items: List<LibraryItem>): List<LibraryItem> =
        items.sortedWith(
            compareBy<LibraryItem> { it is LibraryItem.Playlist }
                .thenBy { trackNumber(it) ?: Int.MAX_VALUE }
                .then(compareBy(names) { it.title }),
        )

    fun folders(folders: List<LibraryPath>): List<LibraryPath> = folders.sortedWith(compareBy(names) { it.name })

    private fun trackNumber(item: LibraryItem): Int? = when (item) {
        is LibraryItem.Album -> item.album.tracks.firstOrNull()?.metadata?.trackNumber
        is LibraryItem.Track -> item.track.metadata.trackNumber
        is LibraryItem.Playlist -> null
    }
}

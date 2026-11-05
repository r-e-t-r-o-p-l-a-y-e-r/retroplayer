package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem

/**
 * Groups the audio files of one folder listing into albums or loose tracks:
 * first by album tag (per folder and disc), then by folder (two or more
 * untagged files), the rest stays standalone.
 *
 * [folderName] maps a folder to its display name, so a library root shows the
 * name of the picked folder instead of its id.
 */
class GroupTracksIntoAlbums(private val folderName: (LibraryPath) -> String = { it.name }) {
    operator fun invoke(tracks: List<AudioTrack>): List<LibraryItem> {
        if (tracks.isEmpty()) return emptyList()
        val used = HashSet<String>()
        return byAlbumTag(tracks, used) + byFolder(tracks, used) +
            tracks.filter { it.id !in used }.map { LibraryItem.Track(it) }
    }

    private fun byAlbumTag(tracks: List<AudioTrack>, used: MutableSet<String>): List<LibraryItem> {
        val groups = LinkedHashMap<String, MutableList<AudioTrack>>()
        for (track in tracks) {
            val album = track.albumTag ?: continue
            val disc = track.metadata.discNumber ?: 0
            groups.getOrPut(AlbumIds.tag(track.directory, album, disc)) { mutableListOf() } += track
        }
        return groups.map { (key, members) ->
            members.forEach { used += it.id }
            val sorted = members.sortedWith(tagOrder)
            val dir = sorted.first().directory
            LibraryItem.Album(
                AudioAlbum(
                    id = key,
                    title = canonicalTitle(sorted, dir),
                    artist = commonArtist(sorted) ?: parentName(dir),
                    tracks = sorted,
                    source = AlbumSource.TAG,
                    directory = dir,
                ),
            )
        }
    }

    private fun byFolder(tracks: List<AudioTrack>, used: MutableSet<String>): List<LibraryItem> =
        tracks.filter { it.id !in used }
            .groupBy { it.directory }
            .filterValues { it.size >= 2 }
            .map { (dir, members) ->
                members.forEach { used += it.id }
                val sorted = members.sortedWith(tagOrder)
                LibraryItem.Album(
                    AudioAlbum(
                        id = AlbumIds.folder(dir),
                        title = canonicalTitle(sorted, dir),
                        artist = commonArtist(sorted) ?: parentName(dir),
                        tracks = sorted,
                        source = AlbumSource.DIRECTORY,
                        directory = dir,
                    ),
                )
            }

    private fun parentName(dir: LibraryPath): String? = dir.parent?.let(folderName)

    private fun canonicalTitle(tracks: List<AudioTrack>, dir: LibraryPath): String {
        val counts = LinkedHashMap<String, Int>()
        tracks.mapNotNull { it.albumTag }.forEach { counts[it] = (counts[it] ?: 0) + 1 }
        return counts.maxByOrNull { it.value }?.key ?: folderName(dir)
    }

    private fun commonArtist(tracks: List<AudioTrack>): String? =
        tracks.mapNotNull { TagFallbacks.clean(it.metadata.albumArtist) ?: it.displayArtist }
            .groupingBy { it }.eachCount().maxByOrNull { it.value }?.key

    private companion object {
        val tagOrder: Comparator<AudioTrack> = compareBy<AudioTrack> { it.metadata.discNumber ?: 0 }
            .thenBy { it.metadata.trackNumber ?: Int.MAX_VALUE }
            .thenBy { it.path.value }
    }
}

/** Album ids carry their folder: `dir:<folder>` or `tag:<folder>::<album lowercase>::<disc>`. */
object AlbumIds {
    private const val DIR = "dir:"
    private const val TAG = "tag:"

    fun folder(dir: LibraryPath) = DIR + dir.value

    fun tag(dir: LibraryPath, album: String, disc: Int) = "$TAG${dir.value}::${album.lowercase()}::$disc"

    fun directoryOf(albumId: String): LibraryPath? = when {
        albumId.startsWith(DIR) -> LibraryPath(albumId.removePrefix(DIR))
        albumId.startsWith(TAG) -> LibraryPath(albumId.removePrefix(TAG).substringBefore("::"))
        else -> null
    }
}

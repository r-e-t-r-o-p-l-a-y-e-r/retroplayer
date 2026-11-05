package app.retroplayer.domain

import java.text.Normalizer

/**
 * A–Z (and `#`, `•`) index scrubber helpers for library lists (based on Flutter
 * `library_index_labels.dart`). Unlike Flutter the bar always shows the whole
 * alphabet, so it keeps its shape; letters without rows jump to the next one.
 */
object LibraryIndex {
    const val DIGIT = "#"
    const val OTHER = "•"
    const val MIN_ROWS_FOR_BAR = 30

    private val ALPHABET = ('A'..'Z').map { it.toString() }

    /** Same order as the case- and accent-insensitive name sort: symbols, digits, letters. */
    private val ORDER = listOf(OTHER, DIGIT) + ALPHABET

    fun charFor(title: String): String {
        val trimmed = title.trim()
        if (trimmed.isEmpty()) return DIGIT
        val first = trimmed.first()
        if (first in '0'..'9') return DIGIT
        val base = Normalizer.normalize(first.toString(), Normalizer.Form.NFD).first().uppercaseChar()
        if (base in 'A'..'Z') return base.toString()
        return OTHER
    }

    fun labelsFor(titles: Iterable<String>): List<String> {
        val present = titles.map(::charFor).toSet()
        return listOf(OTHER, DIGIT).filter { it in present } + ALPHABET
    }

    fun firstMatchingIndex(titles: List<String>, indexChar: String): Int? {
        titles.forEachIndexed { index, title ->
            if (charFor(title) == indexChar) return index
        }
        return null
    }

    /** Row to scroll to for [label]: its first row, else the first row of a later label, else the last row. */
    fun jumpIndex(titles: List<String>, label: String): Int? {
        if (titles.isEmpty()) return null
        firstMatchingIndex(titles, label)?.let { return it }
        val rank = ORDER.indexOf(label)
        return titles.indexOfFirst { ORDER.indexOf(charFor(it)) > rank }.takeIf { it >= 0 } ?: titles.lastIndex
    }

    /** LazyColumn item index for the [selectableIndex] row (folders, then playlists, then audio). */
    fun lazyColumnIndexForSelectableRow(
        selectableIndex: Int,
        folderCount: Int,
        playlistCount: Int,
        audioCount: Int,
    ): Int {
        require(selectableIndex >= 0)
        var row = selectableIndex
        var index = 0
        if (folderCount > 0) {
            index++
            if (row < folderCount) return index + row
            index += folderCount
            row -= folderCount
        }
        if (playlistCount > 0) {
            index++
            if (row < playlistCount) return index + row
            index += playlistCount
            row -= playlistCount
        }
        if (audioCount > 0) {
            index++
            return index + row.coerceAtMost(audioCount - 1)
        }
        return index
    }
}

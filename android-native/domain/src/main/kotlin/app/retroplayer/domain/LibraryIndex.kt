package app.retroplayer.domain

/** A–Z (and `#`, `•`) index scrubber helpers for library lists (matches Flutter `library_index_labels.dart`). */
object LibraryIndex {
    const val DIGIT = "#"
    const val OTHER = "•"
    const val MIN_ROWS_FOR_BAR = 30

    fun charFor(title: String): String {
        val trimmed = title.trim()
        if (trimmed.isEmpty()) return DIGIT
        val code = trimmed.first().code
        val upper = trimmed.first().uppercaseChar().toString()
        if (upper.single() in 'A'..'Z') return upper
        if (code in '0'.code..'9'.code) return DIGIT
        return OTHER
    }

    fun labelsFor(titles: Iterable<String>): List<String> {
        val present = titles.map(::charFor).toSet()
        return buildList {
            if (OTHER in present) add(OTHER)
            if (DIGIT in present) add(DIGIT)
            for (i in 0 until 26) {
                val letter = ('A'.code + i).toChar().toString()
                if (letter in present) add(letter)
            }
        }
    }

    fun firstMatchingIndex(titles: List<String>, indexChar: String): Int? {
        titles.forEachIndexed { index, title ->
            if (charFor(title) == indexChar) return index
        }
        return null
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

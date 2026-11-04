package app.retroplayer.domain.model

/** A named position inside one audio file, e.g. an M4B audiobook chapter. */
data class Chapter(val startMs: Long, val title: String)

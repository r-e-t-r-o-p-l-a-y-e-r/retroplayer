package app.retroplayer.domain

/**
 * Logical location inside the library: `<rootId>/<folder>/.../<name>`.
 *
 * Independent of the storage backend so it can be used for grouping, ordering,
 * breadcrumbs and persisted resume keys. Segment names never contain `/`.
 */
@JvmInline
value class LibraryPath(val value: String) {
    val rootId: String get() = value.substringBefore(SEPARATOR)

    val isRoot: Boolean get() = SEPARATOR !in value

    /** Segments below the root. */
    val segments: List<String>
        get() = if (isRoot) emptyList() else value.substringAfter(SEPARATOR).split(SEPARATOR)

    val name: String get() = value.substringAfterLast(SEPARATOR)

    val parent: LibraryPath? get() = if (isRoot) null else LibraryPath(value.substringBeforeLast(SEPARATOR))

    val extension: String
        get() {
            val dot = name.lastIndexOf('.')
            return if (dot > 0) name.substring(dot + 1).lowercase() else ""
        }

    val baseName: String
        get() {
            val dot = name.lastIndexOf('.')
            return if (dot > 0) name.substring(0, dot) else name
        }

    fun child(name: String): LibraryPath = LibraryPath("$value$SEPARATOR$name")

    fun isWithin(ancestor: LibraryPath): Boolean =
        value == ancestor.value || value.startsWith(ancestor.value + SEPARATOR)

    /** Resolves a relative entry (`/` or `\` separated, may contain `.` and `..`) against this folder. */
    fun resolve(relative: String): LibraryPath? {
        val parts = segments.toMutableList()
        for (part in relative.split('/', '\\')) {
            when (part) {
                "", "." -> Unit
                ".." -> if (parts.isEmpty()) return null else parts.removeAt(parts.lastIndex)
                else -> parts += part
            }
        }
        return parts.fold(root(rootId)) { path, segment -> path.child(segment) }
    }

    /** Relative entry from [folder] to this path, or null when they live under different roots. */
    fun relativeTo(folder: LibraryPath): String? {
        if (rootId != folder.rootId) return null
        val from = folder.segments
        val to = segments
        var common = 0
        while (common < from.size && common < to.size && from[common] == to[common]) common++
        val ups = List(from.size - common) { ".." }
        return (ups + to.drop(common)).joinToString("/")
    }

    override fun toString(): String = value

    companion object {
        const val SEPARATOR = '/'

        fun root(rootId: String): LibraryPath = LibraryPath(rootId)
    }
}

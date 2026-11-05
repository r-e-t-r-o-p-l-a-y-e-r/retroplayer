package app.retroplayer.data

import com.google.common.truth.Truth.assertWithMessage
import java.io.File
import org.junit.Test

/**
 * The user's folders and media are read-only; only app-created playlists may be written, and only
 * through `PlaylistFiles` (see AGENTS.md hard rules). Scans every module's main sources.
 */
class DiskWriteGuardTest {
    private val modules = File("..").canonicalFile

    private val documentWrites = Regex(
        "openOutputStream|openFileDescriptor\\([^)]*\"[wa]|DocumentsContract\\.(create|delete|rename|move|copy)Document|" +
            "\\.(createFile|createDirectory|renameTo)\\(|\\bsource\\.(write|create|delete)\\(",
    )

    /** The SAF primitive itself, and the one class allowed to call it for app playlists. */
    private val allowed = setOf("SafDocumentSource.kt", "PlaylistFiles.kt")

    @Test
    fun `only playlist files write documents`() {
        val sources = modules.walk().onEnter { it.name !in setOf("build", ".gradle", ".git") }
            .filter { it.isFile && it.extension == "kt" && "${File.separator}src${File.separator}main${File.separator}" in it.path }
            .toList()
        assertWithMessage("no main sources found under $modules").that(sources).isNotEmpty()
        val offenders = sources.filter { it.name !in allowed }.flatMap { file ->
            file.readLines().mapIndexedNotNull { i, line ->
                "${file.relativeTo(modules)}:${i + 1}: ${line.trim()}".takeIf { documentWrites.containsMatchIn(line) }
            }
        }
        assertWithMessage("code that can write the user's documents").that(offenders).isEmpty()
    }
}

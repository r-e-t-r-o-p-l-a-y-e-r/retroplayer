package app.retroplayer.ui

import com.google.common.truth.Truth.assertWithMessage
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.isDirectory
import kotlin.io.path.listDirectoryEntries
import kotlin.io.path.name
import kotlin.io.path.readText
import org.junit.Test

class TranslationsTest {
    @Test
    fun `every locale translates every string`() {
        val res = resDir()
        val english = keys(res.resolve("values/strings_arb.xml"))
        val locales = res.listDirectoryEntries("values-*")
            .map { it.resolve("strings_arb.xml") }
            .filter { Files.isRegularFile(it) }
        assertWithMessage("locale files").that(locales.size).isGreaterThan(40)
        locales.forEach { file ->
            assertWithMessage(file.parent.name).that(keys(file)).containsExactlyElementsIn(english)
        }
    }

    @Test
    fun `the language picker lists every translated locale`() {
        val res = resDir()
        val folders = res.listDirectoryEntries("values-*")
            .filter { Files.isRegularFile(it.resolve("strings_arb.xml")) }
            .map { tagOf(it.name.removePrefix("values-")) }
        val config = Regex("""<locale android:name="([^"]+)"/>""")
            .findAll(res.resolve("xml/locales_config.xml").readText()).map { it.groupValues[1] }.toList()
        assertWithMessage("locales_config.xml").that(config).containsExactlyElementsIn(folders + "en")
    }

    /** `pt-rBR` → `pt-BR`, `b+zh+Hant` → `zh-Hant`. */
    private fun tagOf(qualifier: String): String =
        if (qualifier.startsWith("b+")) qualifier.removePrefix("b+").replace('+', '-') else qualifier.replace("-r", "-")

    private fun keys(file: Path): List<String> =
        Regex("""<string name="([a-z0-9_]+)"""").findAll(file.readText()).map { it.groupValues[1] }.toList()

    private fun resDir(): Path {
        var dir: Path = Path.of(System.getProperty("user.dir"))
        while (!dir.resolve("app/src/main/res").isDirectory() && dir.parent != null) {
            dir = dir.parent
        }
        return dir.resolve("app/src/main/res")
    }
}

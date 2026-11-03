package app.retroplayer.ui.settings

import com.google.common.truth.Truth.assertThat
import java.nio.file.Files
import java.nio.file.Path
import kotlin.io.path.readText
import org.junit.Test

class LicensesTest {
    @Test
    fun `every catalog library is listed`() {
        val toml = catalogToml()
        val keys = toml.lineSequence()
            .dropWhile { !it.trim().startsWith("[libraries]") }
            .drop(1)
            .takeWhile { it.isNotBlank() && !it.trim().startsWith('[') }
            .mapNotNull { line ->
                Regex("^([a-z0-9-]+)\\s=").find(line.trim())?.groupValues?.get(1)
            }
            .toSet()
        val testOnly = setOf(
            "junit", "truth", "turbine", "robolectric",
            "androidx-test-ext-junit", "androidx-test-runner", "androidx-test-core",
            "room-compiler", "room-testing", "hilt-compiler", "hilt-android-testing",
            "compose-ui-tooling", "compose-ui-test-junit4", "compose-ui-test-manifest",
            "media3-test-utils", "media3-test-utils-robolectric",
            "kotlinx-coroutines-test",
        )
        val runtimeKeys = keys - testOnly
        assertThat(runtimeKeys).isNotEmpty()
        assertThat(OpenSourceCatalog.catalogKeys).containsAtLeastElementsIn(runtimeKeys)
    }

    private fun catalogToml(): String {
        var dir: Path = Path.of(System.getProperty("user.dir"))
        while (dir.fileName?.toString() != "android-native" && dir.parent != null) {
            dir = dir.parent
        }
        val file = dir.resolve("gradle/libs.versions.toml")
        return Files.readString(file)
    }
}

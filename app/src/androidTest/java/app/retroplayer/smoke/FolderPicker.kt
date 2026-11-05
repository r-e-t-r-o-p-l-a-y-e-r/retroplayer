package app.retroplayer.smoke

import android.os.Build
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.Until
import java.io.ByteArrayOutputStream
import java.util.regex.Pattern

/** Drives the system folder picker (DocumentsUI), the only screen these tests do not own. */
class FolderPicker(private val device: UiDevice) {
    private val docs = Pattern.compile("com\\.(google\\.)?android\\.documentsui")

    private fun id(name: String): BySelector = By.pkg(docs).res(Pattern.compile(".*:id/$name"))

    private fun await(selector: BySelector, what: String, timeoutMs: Long = TIMEOUT_MS): UiObject2 =
        device.wait(Until.findObject(selector), timeoutMs) ?: fail("$what not shown")

    /** The texts and view ids on screen, so a failure on an unfamiliar picker version shows what it looked like. */
    private fun fail(message: String): Nothing {
        val dump = ByteArrayOutputStream().also { device.dumpWindowHierarchy(it) }.toString()
        val nodes = Regex("""text="([^"]*)"[^>]*?resource-id="([^"]*)"""").findAll(dump)
            .map { it.groupValues }
            .filter { (_, text, id) -> text.isNotEmpty() || id.isNotEmpty() }
            .joinToString("\n") { (_, text, id) -> "  '$text' $id" }
        error("folder picker: $message\n$nodes")
    }

    /** Picks `<storage>/<path...>` and grants access. The picker may open anywhere; start at the storage root. */
    fun choose(vararg path: String) {
        await(By.pkg(docs), "picker")
        val crumbs = device.wait(Until.findObjects(id("breadcrumb_text")), SHORT_MS)
        if (!crumbs.isNullOrEmpty()) {
            crumbs.first().click()
        } else {
            showInternalStorage()
            await(By.pkg(docs).desc("Show roots"), "roots drawer").click()
            await(By.pkg(docs).text(Build.MODEL), "storage root").click()
        }
        path.forEach { name ->
            await(id("title").text(name), "folder $name").click()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                await(id("header_title").textContains(name), "inside $name")
            } else {
                await(id("dropdown_breadcrumb").hasDescendant(By.text(name)), "inside $name")
            }
        }
        confirm()
    }

    /** Android 9 and older hide the device storage until the overflow menu shows it. */
    private fun showInternalStorage() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) return
        val more = device.wait(Until.findObject(By.pkg(docs).desc("More options")), SHORT_MS) ?: return
        more.click()
        val show = device.wait(Until.findObject(By.text(Pattern.compile("Show internal storage", Pattern.CASE_INSENSITIVE))), SHORT_MS)
        if (show != null) show.click() else device.pressBack()
    }

    /** Accepts the folder the picker opened at (write-grant upgrades open at the root already). */
    fun confirm() {
        await(By.pkg(docs).res("android:id/button1"), "use this folder").click()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            await(By.text(Pattern.compile("allow", Pattern.CASE_INSENSITIVE)).clickable(true), "allow").click()
        }
        device.wait(Until.gone(By.pkg(docs)), TIMEOUT_MS)
    }

    private companion object {
        const val TIMEOUT_MS = 10_000L
        const val SHORT_MS = 2_000L
    }
}

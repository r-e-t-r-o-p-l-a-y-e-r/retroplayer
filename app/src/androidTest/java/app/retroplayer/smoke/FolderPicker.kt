package app.retroplayer.smoke

import android.os.Build
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.StaleObjectException
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

    /** The picker redraws its lists while loading; a node found a moment ago can be gone by the click. */
    private fun click(selector: BySelector, what: String) {
        repeat(STALE_RETRIES) {
            try {
                await(selector, what).click()
                return
            } catch (_: StaleObjectException) {
            }
        }
        fail("$what kept changing")
    }

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
        if (device.wait(Until.hasObject(id("breadcrumb_text")), SHORT_MS)) {
            click(id("breadcrumb_text"), "storage crumb")
        } else {
            showInternalStorage()
            click(By.pkg(docs).desc("Show roots"), "roots drawer")
            click(By.pkg(docs).text(Build.MODEL), "storage root")
        }
        path.forEach { name ->
            click(id("title").text(name), "folder $name")
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
        val useFolder = By.pkg(docs).res("android:id/button1")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            click(useFolder, "use this folder")
        } else {
            val allow = By.text(Pattern.compile("allow", Pattern.CASE_INSENSITIVE)).clickable(true)
            // A slow picker ignores the tap while it still loads the folder, and no dialog follows.
            repeat(CONFIRM_TAPS) {
                if (device.hasObject(allow) || !device.hasObject(By.pkg(docs))) return@repeat
                click(useFolder, "use this folder")
                device.wait(Until.hasObject(allow), SHORT_MS)
            }
            if (device.hasObject(By.pkg(docs))) click(allow, "allow")
        }
        device.wait(Until.gone(By.pkg(docs)), TIMEOUT_MS)
    }

    private companion object {
        const val TIMEOUT_MS = 10_000L
        const val SHORT_MS = 2_000L
        const val STALE_RETRIES = 3
        const val CONFIRM_TAPS = 4
    }
}

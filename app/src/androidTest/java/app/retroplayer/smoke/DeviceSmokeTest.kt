package app.retroplayer.smoke

import app.retroplayer.ui.settings.LANGUAGE_DROPDOWN_TAG
import androidx.compose.ui.test.hasScrollAction
import androidx.compose.ui.test.isPopup
import android.content.res.Configuration
import android.os.ParcelFileDescriptor
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.ui.test.ComposeTimeoutException
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasAnyAncestor
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasSetTextAction
import androidx.compose.ui.test.hasTestTag
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.isDialog
import androidx.compose.ui.test.isRoot
import androidx.compose.ui.test.isToggleable
import androidx.compose.ui.test.junit4.v2.createAndroidComposeRule
import androidx.compose.ui.test.onFirst
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.test.printToString
import androidx.core.os.LocaleListCompat
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice
import app.retroplayer.MainActivity
import app.retroplayer.R
import app.retroplayer.ui.player.EXPANDED_PLAYER_TAG
import app.retroplayer.ui.player.MINI_PLAYER_TAG
import app.retroplayer.ui.settings.SETTINGS_SCREEN_TAG
import java.util.Locale
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end checks on a device, against the real app. The sample folder is created when
 * missing ([SampleLibrary]); run through `scripts/device-smoke.sh` or a managed device group.
 */
@RunWith(AndroidJUnit4::class)
class DeviceSmokeTest {
    @get:Rule val compose = createAndroidComposeRule<MainActivity>()

    private val instrumentation = InstrumentationRegistry.getInstrumentation()
    private val device = UiDevice.getInstance(instrumentation)
    private val picker = FolderPicker(device)

    private fun s(id: Int, vararg args: Any): String = compose.activity.getString(id, *args)

    private fun shell(command: String): String =
        ParcelFileDescriptor.AutoCloseInputStream(instrumentation.uiAutomation.executeShellCommand(command))
            .bufferedReader().use { it.readText() }

    private fun playlistFile(): String = shell("find $SAMPLES -name $PLAYLIST.m3u").trim()

    private fun waitFor(matcher: SemanticsMatcher, timeoutMs: Long = TIMEOUT_MS) {
        try {
            compose.waitUntil(timeoutMs) { compose.onAllNodes(matcher).fetchSemanticsNodes().isNotEmpty() }
        } catch (e: ComposeTimeoutException) {
            throw AssertionError("not shown: ${matcher.description}\n" + compose.onAllNodes(isRoot()).printToString(maxDepth = Int.MAX_VALUE), e)
        }
    }

    private fun click(matcher: SemanticsMatcher) {
        waitFor(matcher)
        compose.onAllNodes(matcher).onFirst().performClick()
    }

    private fun clickText(text: String) = click(hasText(text))

    private fun pickLanguage(language: SemanticsMatcher) {
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasTestTag(LANGUAGE_DROPDOWN_TAG))
        click(hasTestTag(LANGUAGE_DROPDOWN_TAG))
        val inMenu = hasAnyAncestor(isPopup())
        waitFor(language and inMenu)
        compose.onNode(hasScrollAction() and inMenu).performScrollToNode(language and inMenu)
        click(language and inMenu)
    }

    private fun back() = compose.runOnUiThread { compose.activity.onBackPressedDispatcher.onBackPressed() }

    @Before
    fun fixtures() {
        SampleLibrary(compose.activity, ::shell).ensure()
        shell("find $SAMPLES -name $PLAYLIST.m3u -delete")
    }

    /** Adds the sample folder through the system picker; the app then shows its contents. */
    private fun addSamples() {
        click(hasContentDescription(s(R.string.add_folder)))
        picker.choose("Music", "RetroPlayerSamples")
        waitFor(hasText("Demo Artist"))
    }

    /** Playing from the library opens the full player (UC-09); back collapses it to the mini player. */
    private fun playSamplesFromLibrary() {
        back()
        click(hasContentDescription(s(R.string.play_folder)))
        waitFor(hasTestTag(EXPANDED_PLAYER_TAG))
        waitFor(hasContentDescription(s(R.string.pause)))
        back()
        waitFor(hasTestTag(MINI_PLAYER_TAG))
    }

    @Test
    fun aFreshStartShowsTheEmptyLibrary() {
        waitFor(hasText(s(R.string.no_folders_added)))
        compose.onNode(hasContentDescription(s(R.string.add_folder))).assertIsDisplayed()
    }

    @Test
    fun rotatingKeepsThePageAndThePlayer() {
        addSamples()
        playSamplesFromLibrary()
        val root = hasContentDescription(s(R.string.play_folder))
        waitFor(root)
        try {
            device.setOrientationLeft()
            waitFor(root)
            waitFor(hasTestTag(MINI_PLAYER_TAG))
            waitFor(hasContentDescription(s(R.string.pause)))
        } finally {
            device.setOrientationNatural()
            device.unfreezeRotation()
        }
    }

    @Test
    fun playingAFolderShowsThePlayerAndTheQueue() {
        addSamples()
        playSamplesFromLibrary()
        compose.onNode(hasTestTag(MINI_PLAYER_TAG)).assertIsDisplayed()
        click(hasContentDescription(s(R.string.queue)))
        waitFor(hasContentDescription(s(R.string.add_tracks)))
    }

    @Test
    fun theQueueSavesAsAPlaylistThatCanBeDeleted() {
        addSamples()
        clickText("Demo Artist")
        clickText("Demo Album")
        click(hasContentDescription(s(R.string.queue)))
        click(hasContentDescription(s(R.string.add_tracks)))
        clickText("RetroPlayerSamples")
        clickText("Demo Artist")
        clickText("Demo Album")
        click(isToggleable())
        click(hasContentDescription(s(R.string.add_selected_tracks)))
        clickText(s(R.string.save_as_playlist))
        clickText("RetroPlayerSamples")
        clickText("Demo Artist")
        clickText("Demo Album")
        compose.onNode(hasSetTextAction()).performTextInput(PLAYLIST)
        clickText(s(R.string.save))
        picker.confirm()
        compose.waitUntil(TIMEOUT_MS) { playlistFile().isNotEmpty() }
        // The save page closes itself once the file is written; a back press before that would close it instead.
        waitFor(hasContentDescription(s(R.string.add_tracks)))

        back()
        clickText(PLAYLIST)
        clickText(s(R.string.delete_playlist_title))
        click(hasText(s(R.string.remove)) and hasAnyAncestor(isDialog()))
        compose.waitUntil(TIMEOUT_MS) { playlistFile().isEmpty() }
    }

    @Test
    fun theIndexBarJumpsAndTheScrollSurvivesRecreation() {
        addSamples()
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("LongList"))
        clickText("LongList")
        waitFor(hasText("alpha"))
        clickText("Z")
        compose.onNode(hasText("zebra")).assertIsDisplayed()
        compose.activityRule.scenario.recreate()
        waitFor(hasText("zebra"))
        compose.onNode(hasText("zebra")).assertIsDisplayed()
    }

    @Test
    fun settingsPagesOpenWithoutThePlayer() {
        addSamples()
        playSamplesFromLibrary()
        click(hasContentDescription(s(R.string.settings)))
        waitFor(hasTestTag(SETTINGS_SCREEN_TAG))
        compose.onNode(hasTestTag(MINI_PLAYER_TAG)).assertDoesNotExist()
        compose.onNode(hasTestTag(EXPANDED_PLAYER_TAG)).assertDoesNotExist()

        val pages = listOf(
            R.string.data_storage to hasText("retroplayer.db", substring = true),
            R.string.open_source_licenses to hasText("AndroidX Media3 ExoPlayer", substring = true),
        )
        listOf(hasContentDescription("60 Hz"), hasText(s(R.string.about_version), substring = true)).forEach {
            compose.onNode(hasScrollToIndexAction()).performScrollToNode(it)
            waitFor(it)
        }
        pages.forEach { (row, content) ->
            compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(s(row)))
            clickText(s(row))
            compose.waitUntil(TIMEOUT_MS) { compose.onAllNodes(hasTestTag(SETTINGS_SCREEN_TAG)).fetchSemanticsNodes().isEmpty() }
            compose.onAllNodes(hasScrollToIndexAction()).fetchSemanticsNodes().firstOrNull()?.let {
                compose.onNode(hasScrollToIndexAction()).performScrollToNode(content)
            }
            waitFor(content)
            back()
            waitFor(hasTestTag(SETTINGS_SCREEN_TAG))
        }
    }

    @Test
    fun choosingGermanTranslatesTheAppUntilSystemIsChosenAgain() {
        val settings = s(R.string.settings)
        val german = compose.activity.createConfigurationContext(
            Configuration(compose.activity.resources.configuration).apply { setLocale(Locale.GERMAN) },
        )
        try {
            click(hasContentDescription(settings))
            pickLanguage(hasText("Deutsch"))
            waitFor(hasText(german.getString(R.string.settings)))
            pickLanguage(hasText(german.getString(R.string.language_system)))
            waitFor(hasText(settings))
        } finally {
            compose.runOnUiThread { AppCompatDelegate.setApplicationLocales(LocaleListCompat.getEmptyLocaleList()) }
        }
    }

    private companion object {
        const val SAMPLES = SampleLibrary.ROOT
        const val PLAYLIST = "SmokeTrip"
        const val TIMEOUT_MS = 15_000L
    }
}

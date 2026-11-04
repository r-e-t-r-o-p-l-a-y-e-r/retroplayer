package app.retroplayer.ui.player

import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.doubleClick
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.getBoundsInRoot
import androidx.compose.ui.unit.dp
import app.retroplayer.ui.assertNoClippedText
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performSemanticsAction
import androidx.compose.ui.test.performTouchInput
import androidx.test.core.app.ApplicationProvider
import android.content.Context
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.Chapter
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ExpandedPlayerTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val calls = mutableListOf<String>()
    private val actions = PlayerActions(
        toggle = {},
        previous = {},
        next = {},
        seekTo = { calls += "seekTo:$it" },
        jumpBack = { calls += "jumpBack" },
        jumpForward = { calls += "jumpForward" },
        setSpeed = { calls += "speed:$it" },
        locate = { calls += "locate" },
        playbackCrumb = { calls += "crumb:${it.label}" },
        previousChapter = { calls += "previousChapter" },
        nextChapter = { calls += "nextChapter" },
    )

    private val playing = PlayerUiState(
        NowPlaying(
            title = "Song 2",
            subtitle = "Tester",
            hasTrack = true,
            isPlaying = true,
            speed = 1f,
            positionMs = 30_000,
            durationMs = 180_000,
        ),
        crumbs = listOf(
            Crumb("", null, isLibraryRoot = true),
            Crumb("Music", LibraryPath("1")),
            Crumb("Test Album", LibraryPath("1/Alb")),
            Crumb("Song 2", null),
        ),
    )

    private fun show(state: PlayerUiState = playing) = compose.setContent {
        RetroTheme {
            PlayerHost(state, expanded = true, onExpandedChange = {}, actions) { LibraryHeader() }
        }
    }

    @Test
    fun `jump buttons call jump actions`() {
        show()
        compose.onNodeWithContentDescription(context.getString(R.string.jump_back)).performClick()
        compose.onNodeWithContentDescription(context.getString(R.string.jump_forward)).performClick()
        assertThat(calls).containsExactly("jumpBack", "jumpForward").inOrder()
    }

    @Test
    fun `double tap on the left half jumps back`() {
        show()
        compose.onNodeWithTag(EXPANDED_ART_TAG).performTouchInput {
            doubleClick(Offset(width * 0.25f, height / 2f))
        }
        assertThat(calls).containsExactly("jumpBack")
    }

    @Test
    fun `double tap on the right half jumps forward`() {
        show()
        compose.onNodeWithTag(EXPANDED_ART_TAG).performTouchInput {
            doubleClick(Offset(width * 0.75f, height / 2f))
        }
        assertThat(calls).containsExactly("jumpForward")
    }

    @Test
    fun `speed slider shows the formatted speed`() {
        show()
        compose.onNodeWithText("1.0x").assertIsDisplayed()
    }

    @Test
    fun `speed slider changes in quarter steps`() {
        show()
        compose.onNodeWithTag(SPEED_SLIDER_TAG).performSemanticsAction(SemanticsActions.SetProgress) { it(1.25f) }
        assertThat(calls).contains("speed:1.25")
    }

    @Test
    fun `tapping the title calls locate`() {
        show()
        compose.onNodeWithTag(EXPANDED_LOCATE_TITLE_TAG).performClick()
        assertThat(calls).containsExactly("locate")
    }

    @Test
    fun `breadcrumbs of the playing item are shown`() {
        show()
        compose.onNodeWithText("Library").assertIsDisplayed()
        compose.onNodeWithText("Music").assertIsDisplayed()
        compose.onNodeWithText("Test Album").assertIsDisplayed()
    }

    @Test
    fun `tapping a playback breadcrumb opens the folder`() {
        show()
        compose.onNodeWithText("Music").performClick()
        assertThat(calls).contains("crumb:Music")
    }

    @Test
    @Config(qualifiers = "w800dp-h360dp")
    @GraphicsMode(GraphicsMode.Mode.NATIVE)
    fun `landscape player shows art and controls side by side`() {
        show()
        val root = compose.onRoot().getBoundsInRoot()
        val art = compose.onNodeWithTag(EXPANDED_ART_TAG).getBoundsInRoot()
        val play = compose.onNodeWithContentDescription(context.getString(R.string.pause))
        play.assertIsDisplayed()
        assertThat(art.right).isAtMost(play.getBoundsInRoot().left)
        assertThat(art.top).isAtLeast(root.top)
        assertThat(art.bottom).isAtMost(root.bottom)
        assertThat(art.bottom - art.top).isAtLeast(120.dp)
        compose.onNodeWithTag(SPEED_SLIDER_TAG).assertIsDisplayed()
        compose.assertNoClippedText()
    }

    private val book = playing.copy(
        nowPlaying = playing.nowPlaying.copy(title = "Book", positionMs = 700_000, durationMs = 1_800_000),
        chapters = listOf(Chapter(0, "Intro"), Chapter(600_000, "Middle"), Chapter(1_200_000, "End")),
    )

    @Test
    fun `a track without chapters has no chapter controls`() {
        show()
        compose.onNodeWithContentDescription(context.getString(R.string.next_chapter)).assertDoesNotExist()
        compose.onNodeWithContentDescription(context.getString(R.string.chapters)).assertDoesNotExist()
    }

    @Test
    fun `the current chapter shows under the titles with chapter steps`() {
        show(book)
        compose.onNodeWithText("Middle").assertIsDisplayed()
        compose.onNodeWithContentDescription(context.getString(R.string.previous_chapter)).performClick()
        compose.onNodeWithContentDescription(context.getString(R.string.next_chapter)).performClick()
        assertThat(calls).containsExactly("previousChapter", "nextChapter").inOrder()
    }

    @Test
    fun `chapter list seeks to the chapter`() {
        show(book)
        compose.onNodeWithText("Middle").performClick()
        compose.onNodeWithText("Intro").assertIsDisplayed()
        compose.onNodeWithText("End").performClick()
        compose.waitForIdle()
        assertThat(calls).containsExactly("seekTo:1200000")
        compose.onNodeWithText("Intro").assertDoesNotExist()
    }

    @Test
    fun `the settings cog opens settings`() {
        compose.setContent {
            RetroTheme {
                PlayerHost(playing, expanded = true, onExpandedChange = {}, actions.copy(openSettings = { calls += "settings" })) {
                    LibraryHeader()
                }
            }
        }
        compose.onNodeWithContentDescription(context.getString(R.string.settings)).performClick()
        assertThat(calls).containsExactly("settings")
    }
}

/** A library page header (bar and breadcrumbs) that the open player takes over. */
@androidx.compose.runtime.Composable
internal fun LibraryHeader() {
    androidx.compose.foundation.layout.Column {
        ShareHeaderWithPlayer()
        app.retroplayer.ui.components.RetroTopBar("Folder page")
        app.retroplayer.ui.components.BreadcrumbStrip(listOf(app.retroplayer.domain.Crumb("", null, isLibraryRoot = true)), onCrumb = {})
    }
}

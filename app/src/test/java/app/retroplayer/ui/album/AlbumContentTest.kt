package app.retroplayer.ui.album

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeLeft
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AlbumContentTest {
    @get:Rule val compose = createComposeRule()

    private val tracks = listOf(
        AudioTrack(LibraryPath("1/Alb/a.mp3"), "doc:a", TrackMetadata(title = "First", artist = "Ann", trackNumber = 1, durationMs = 61_000)),
        AudioTrack(LibraryPath("1/Alb/b.mp3"), "doc:b", TrackMetadata(title = "Second")),
    )
    private val ready = AlbumUiState.Ready(
        album = AudioAlbum("dir:1/Alb", "Alb", "Ann", tracks, AlbumSource.DIRECTORY, LibraryPath("1/Alb")),
        tracks = tracks,
        mode = AlbumSortMode.FILE_NAME,
        tagsUsable = false,
        crumbs = emptyList(),
        artUri = null,
    )
    private val calls = mutableListOf<String>()
    private val actions = AlbumActions(
        play = { calls += "play:" + it.fileName },
        playAll = { calls += "playAll" },
        selectSort = { calls += "sort:" + it },
        confirmTagOrder = { calls += "confirm" },
        dismissTagOrder = { calls += "dismiss" },
        addToQueue = { track, onAdded ->
            calls += "queue:" + track.fileName
            onAdded(1)
        },
    )

    private fun show(confirm: Int? = null) = compose.setContent {
        RetroTheme { AlbumContent(ready, confirm, null, null, null, actions) }
    }

    @Test
    fun `tracks show number, title and artist with duration`() {
        show()
        compose.onNodeWithText("Album").assertIsDisplayed()
        compose.onNodeWithText("First").assertIsDisplayed()
        compose.onNodeWithText("Ann · 01:01").assertIsDisplayed()
        compose.onNodeWithText("2").assertIsDisplayed()
    }

    @Test
    fun `swiping a track left adds it to the queue`() {
        show()
        compose.onNodeWithText("Second").performTouchInput { swipeLeft() }
        compose.onNodeWithText("1 track added to the queue").assertIsDisplayed()
        assertThat(calls).containsExactly("queue:b.mp3")
    }

    @Test
    fun `playing track shows the speaker instead of its number`() {
        compose.setContent { RetroTheme { AlbumContent(ready, null, null, tracks[1].id, null, actions) } }
        compose.onNodeWithContentDescription("Now Playing").assertIsDisplayed()
        compose.onNodeWithText("2").assertDoesNotExist()
    }

    @Test
    fun `current order is selected and choosing another one asks the view model`() {
        show()
        compose.onNodeWithContentDescription("Track order").performClick()
        compose.onNodeWithTag("sort:FILE_NAME").assertIsSelected()
        compose.onNodeWithTag("sort:TAG").performClick()
        compose.onNodeWithContentDescription("Track order").performClick()
        compose.onNodeWithTag("sort:FILE_NAME").performClick()
        assertThat(calls).containsExactly("sort:TAG")
    }

    @Test
    fun `tag order confirmation offers both choices`() {
        show(confirm = 1)
        compose.onNodeWithText("Sort by tag anyway?").assertIsDisplayed()
        compose.onNodeWithText("Keep file name order").performClick()
        compose.onNodeWithText("Sort by tag anyway").performClick()
        assertThat(calls).containsExactly("dismiss", "confirm").inOrder()
    }

    @Test
    fun `tapping a track and play album start playback`() {
        show()
        compose.onNodeWithTag("track:b.mp3").performClick()
        compose.onNodeWithContentDescription("Play album").performClick()
        assertThat(calls).containsExactly("play:b.mp3", "playAll").inOrder()
    }

    @Test
    fun `the settings cog opens settings`() {
        var opened = false
        compose.setContent { RetroTheme { AlbumContent(ready, null, null, null, null, actions.copy(openSettings = { opened = true })) } }
        compose.onNodeWithContentDescription("Settings").performClick()
        assertThat(opened).isTrue()
    }
}

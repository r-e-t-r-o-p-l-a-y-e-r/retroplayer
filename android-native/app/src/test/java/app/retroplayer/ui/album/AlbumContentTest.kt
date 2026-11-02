package app.retroplayer.ui.album

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
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
        AudioTrack(LibraryPath("1/Alb/a.mp3"), "doc:a", TrackMetadata(title = "First", trackNumber = 1, durationMs = 61_000)),
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
    )

    private fun show(confirm: Int? = null) = compose.setContent {
        RetroTheme { AlbumContent(ready, confirm, null, null, actions) }
    }

    @Test
    fun `tracks show number, title and duration`() {
        show()
        compose.onNodeWithText("First").assertIsDisplayed()
        compose.onAllNodesWithText("1:01").assertCountEquals(2)
        compose.onNodeWithText("–").assertIsDisplayed()
    }

    @Test
    fun `current order is selected and choosing another one asks the view model`() {
        show()
        compose.onNodeWithTag("sort:FILE_NAME").assertIsSelected()
        compose.onNodeWithTag("sort:TAG").performClick()
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
        compose.onNodeWithText("Play album").performClick()
        assertThat(calls).containsExactly("play:b.mp3", "playAll").inOrder()
    }
}

package app.retroplayer.ui.queue

import android.content.Context
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsOff
import androidx.compose.ui.test.assertIsOn
import androidx.compose.ui.test.isToggleable
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AddTracksContentTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val music = LibraryPath("1")
    private val books = music.child("Books")
    private val album = AudioAlbum(
        "dir:1/Alb", "Alb", "Ann",
        listOf(AudioTrack(music.child("Alb").child("t1.mp3"), "doc:t1")),
        AlbumSource.DIRECTORY, music.child("Alb"),
    )
    private val browse = AddTracksUiState.Browse(
        path = music,
        crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", music)),
        folders = listOf(books),
        audio = listOf(LibraryItem.Album(album)),
        selected = emptySet(),
        complete = true,
        checkedFolders = setOf(books),
    )
    private val calls = mutableListOf<String>()
    private val actions = AddTracksActions(
        openFolder = { calls += "open ${it.name}" },
        toggleFolder = { calls += "toggle ${it.name}" },
        openAlbum = { calls += "open album ${it.title}" },
        toggleAlbum = { calls += "toggle album ${it.title}" },
        toggleTrack = { calls += "toggle ${it.name}" },
        confirm = { calls += "confirm" },
    )

    /** Folders are listed before audio, so the folder's checkbox comes first. */
    private fun checkbox(index: Int) = compose.onAllNodes(isToggleable(), useUnmergedTree = true)[index]

    @Test
    fun `a folder opens on tap and is selected by its checkbox`() {
        compose.setContent { RetroTheme { AddTracksContent(browse, actions) } }
        compose.onNodeWithText("Books").performClick()
        checkbox(0).assertIsOn().performClick()
        assertThat(calls).containsExactly("open Books", "toggle Books").inOrder()
    }

    @Test
    fun `an album opens on tap and is selected by its checkbox`() {
        compose.setContent { RetroTheme { AddTracksContent(browse, actions) } }
        compose.onNodeWithText("Alb").performClick()
        checkbox(1).assertIsOff().performClick()
        assertThat(calls).containsExactly("open album Alb", "toggle album Alb").inOrder()
    }

    @Test
    fun `an opened album lists its tracks to pick`() {
        val state = AddTracksUiState.AlbumTracks(album, browse.crumbs, album.tracks, emptySet())
        compose.setContent { RetroTheme { AddTracksContent(state, actions) } }
        compose.onNodeWithText("t1").performClick()
        assertThat(calls).containsExactly("toggle t1.mp3")
    }

    @Test
    fun `add selected tracks is a floating button`() {
        compose.setContent { RetroTheme { AddTracksContent(browse, actions) } }
        compose.onNodeWithContentDescription(context.getString(R.string.add_selected_tracks)).assertIsDisplayed().performClick()
        assertThat(calls).containsExactly("confirm")
    }
}

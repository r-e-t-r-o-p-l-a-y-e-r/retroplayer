package app.retroplayer.ui.library

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.longClick
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.library.FolderEntry
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.ui.components.PLAYING_STRIP_TAG
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class FolderContentTest {
    @get:Rule val compose = createComposeRule()

    private val calls = mutableListOf<String>()
    private val navigation = FolderNavigation(
        openFolder = { calls += "open:" + it.value },
        openCrumb = { calls += "crumb:" + it.path?.value },
        openAlbum = { calls += "album:" + it.id },
    )
    private val actions = FolderActions(
        play = { calls += "play:" + it.id },
        playFolder = { calls += "playFolder:" + it?.value },
        toggleFavorite = { calls += "fav:" + it.value },
        addFolder = { calls += "add" },
        removeRoot = { calls += "remove:" + it.id },
    )

    private val music = LibraryRoot("1", "content://com.android.externalstorage.documents/tree/primary%3AMusic", "Music", false)

    private fun show(state: FolderUiState, isRoot: Boolean = false) = compose.setContent {
        RetroTheme { FolderContent(state, isRoot, null, navigation, actions) }
    }

    @Test
    fun `empty library explains how to start and offers add folder`() {
        show(FolderUiState.Root(emptyList(), emptyList()), isRoot = true)
        compose.onNodeWithText("No folders added. Tap \"Add folder\" to get started.").assertIsDisplayed()
        compose.onNodeWithText("Add folder", substring = false, ignoreCase = false, useUnmergedTree = true).performClick()
        assertThat(calls).containsExactly("add")
    }

    @Test
    fun `root rows show where they live and play the root`() {
        show(FolderUiState.Root(listOf(music), emptyList()), isRoot = true)
        compose.onNodeWithText("Library sources").assertIsDisplayed()
        compose.onNodeWithText("/Music").assertIsDisplayed()
        compose.onNodeWithContentDescription("Play folder").performClick()
        compose.onNodeWithText("Music").performClick()
        assertThat(calls).containsExactly("playFolder:1", "open:1").inOrder()
    }

    @Test
    fun `the root holding the playing track is highlighted`() {
        compose.setContent {
            RetroTheme {
                FolderContent(FolderUiState.Root(listOf(music), emptyList()), true, "1/Books/a.mp3", navigation, actions)
            }
        }
        compose.onNodeWithTag(PLAYING_STRIP_TAG, useUnmergedTree = true).assertIsDisplayed()
    }

    @Test
    fun `roots without the playing track are not highlighted`() {
        compose.setContent {
            RetroTheme {
                FolderContent(FolderUiState.Root(listOf(music), emptyList()), true, "10/a.mp3", navigation, actions)
            }
        }
        compose.onNodeWithTag(PLAYING_STRIP_TAG, useUnmergedTree = true).assertDoesNotExist()
    }

    @Test
    fun `long press on a root asks before removing it`() {
        show(FolderUiState.Root(listOf(music), emptyList()), isRoot = true)
        compose.onNodeWithText("Music").performTouchInput { longClick() }
        compose.onNodeWithText("Remove library folder?").assertIsDisplayed()
        compose.onNodeWithText("Remove").performClick()
        assertThat(calls).containsExactly("remove:1")
    }

    @Test
    fun `folder page shows sections and routes taps`() {
        val books = LibraryPath("1/Books")
        show(
            FolderUiState.Folder(
                path = books,
                crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Books", books)),
                folders = listOf(FolderRow(FolderEntry(books.child("Alpha"), "doc:a"), isFavorite = false)),
                playlists = listOf(PlaylistRef(books.child("mix.m3u"), "doc:m")),
                audio = listOf(LibraryItem.Track(AudioTrack(books.child("single.mp3"), "doc:s"))),
                artUri = null,
                scanned = 1,
                total = 1,
                complete = true,
            ),
        )
        compose.onNodeWithText("Folders").assertIsDisplayed()
        compose.onNodeWithText("Playlists").assertIsDisplayed()
        compose.onNodeWithText("Audio").assertIsDisplayed()
        compose.onNodeWithText("Alpha").performClick()
        compose.onNodeWithText("Alpha").performTouchInput { longClick() }
        compose.onNodeWithContentDescription("Play folder").performClick()
        compose.onNodeWithText("single").performClick()
        compose.onNodeWithText("Music").performClick()
        assertThat(calls).containsExactly(
            "open:1/Books/Alpha",
            "fav:1/Books/Alpha",
            "playFolder:1/Books/Alpha",
            "play:1/Books/single.mp3",
            "crumb:1",
        ).inOrder()
    }

    @Test
    fun `missing folder says so`() {
        show(FolderUiState.Missing)
        compose.onNodeWithText("This folder is no longer available.").assertIsDisplayed()
    }
}

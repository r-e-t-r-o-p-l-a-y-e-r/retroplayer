package app.retroplayer.ui.player

import androidx.compose.ui.test.getBoundsInRoot
import androidx.activity.BackEventCompat
import androidx.activity.ComponentActivity
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.performScrollToNode
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import app.retroplayer.data.library.FolderEntry
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryIndex
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.library.FolderActions
import app.retroplayer.ui.library.FolderContent
import app.retroplayer.ui.library.FolderListScroll
import app.retroplayer.ui.library.FolderNavigation
import app.retroplayer.ui.library.FolderRow
import app.retroplayer.ui.library.FolderUiState
import app.retroplayer.ui.navigation.AbsorbBackAtRoot
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/** UC-14 order: expanded player, then detail/folder pages, then absorb at the library root. */
@RunWith(RobolectricTestRunner::class)
class BackChainTest {
    @get:Rule val compose = createAndroidComposeRule<ComponentActivity>()

    private var expanded by mutableStateOf(false)
    private lateinit var nav: NavHostController
    private val state = PlayerUiState(NowPlaying(title = "Song", hasTrack = true))
    private val actions = PlayerActions(
        toggle = {},
        previous = {},
        next = {},
        seekTo = {},
        jumpBack = {},
        jumpForward = {},
        setSpeed = {},
        locate = {},
        playbackCrumb = {},
    )

    private fun show() = compose.setContent {
        RetroTheme {
            nav = rememberNavController()
            PlayerHost(state, expanded, { expanded = it }, actions) {
                NavHost(nav, startDestination = "root") {
                    composable("root") {
                        AbsorbBackAtRoot(isRoot = true)
                        Text("root page")
                    }
                    composable("album") { Text("album page") }
                }
            }
        }
    }

    private fun pressBack() {
        compose.runOnUiThread { compose.activity.onBackPressedDispatcher.onBackPressed() }
        compose.waitForIdle()
    }

    @Test
    fun `back collapses the expanded player first`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        expanded = true
        compose.waitForIdle()

        pressBack()
        assertThat(expanded).isFalse()
        compose.onNodeWithText("album page").assertIsDisplayed()
    }

    @Test
    fun `back from an album returns to its folder`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        compose.waitForIdle()

        pressBack()
        compose.onNodeWithText("root page").assertIsDisplayed()
    }

    @Test
    fun `back at the library root is absorbed`() {
        show()
        pressBack()
        assertThat(compose.activity.isFinishing).isFalse()
        compose.onNodeWithText("root page").assertIsDisplayed()
    }

    @Test
    fun `back at the root collapses the expanded player instead of being absorbed`() {
        show()
        compose.runOnUiThread { nav.navigate("album") }
        compose.waitForIdle()
        pressBack()
        expanded = true
        compose.waitForIdle()

        pressBack()
        assertThat(expanded).isFalse()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertDoesNotExist()
    }

    private fun longBooksFolder(): FolderUiState.Folder {
        val books = LibraryPath("1/Books")
        val audio = buildList {
            add(LibraryItem.Track(AudioTrack(books.child("alpha.mp3"), "doc:a")))
            repeat(LibraryIndex.MIN_ROWS_FOR_BAR - 1) { i ->
                add(LibraryItem.Track(AudioTrack(books.child("track$i.mp3"), "doc:$i")))
            }
            add(LibraryItem.Track(AudioTrack(books.child("zebra.mp3"), "doc:z")))
        }
        return FolderUiState.Folder(
            path = books,
            crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Books", books)),
            folders = listOf(FolderRow(FolderEntry(books.child("Sub"), "doc:sub"), isFavorite = false)),
            playlists = emptyList(),
            audio = audio,
            artUri = null,
            scanned = audio.size,
            total = audio.size,
            complete = true,
        )
    }

    @Test
    fun `going up restores the parent scroll position`() {
        val parent = longBooksFolder()
        val sub = LibraryPath("1/Books/Sub")
        val child = FolderUiState.Folder(
            path = sub,
            crumbs = listOf(
                Crumb("", null, isLibraryRoot = true),
                Crumb("Books", LibraryPath("1/Books")),
                Crumb("Sub", sub),
            ),
            folders = emptyList(),
            playlists = emptyList(),
            audio = emptyList(),
            artUri = null,
            scanned = 0,
            total = 0,
            complete = true,
        )
        var depth by mutableIntStateOf(1)
        var savedScroll = 0 to 0
        val navigation = FolderNavigation(openFolder = { depth = 2 }, openCrumb = {}, openAlbum = {})
        compose.setContent {
            RetroTheme {
                when (depth) {
                    1 -> FolderContent(
                        parent,
                        isRoot = false,
                        playingTrackId = null,
                        navigation = navigation,
                        actions = FolderActions(),
                        listScroll = FolderListScroll(savedScroll.first, savedScroll.second) { index, offset ->
                            savedScroll = index to offset
                        },
                    )
                    else -> FolderContent(child, false, null, navigation, FolderActions())
                }
            }
        }
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("zebra"))
        compose.waitForIdle()
        depth = 2
        compose.waitForIdle()
        compose.onNodeWithText("This folder is empty.").assertIsDisplayed()
        depth = 1
        compose.waitForIdle()
        compose.onNodeWithText("zebra").assertIsDisplayed()
    }

    @Test
    fun `back closes settings before the player`() {
        compose.setContent {
            RetroTheme {
                PlayerHost(state, expanded = true, { expanded = it }, actions, showPlayer = false) {
                    Text("settings page")
                }
            }
        }
        compose.waitForIdle()
        compose.onNodeWithText("settings page").assertIsDisplayed()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertDoesNotExist()
        compose.onNodeWithTag(MINI_PLAYER_TAG).assertDoesNotExist()
    }

    @Test
    fun `a back swipe pulls the player down with the finger`() {
        expanded = true
        show()
        compose.waitForIdle()
        val open = compose.onNodeWithTag(EXPANDED_PLAYER_TAG).getBoundsInRoot().top
        val dispatcher = compose.activity.onBackPressedDispatcher
        compose.runOnUiThread {
            dispatcher.dispatchOnBackStarted(BackEventCompat(0f, 500f, 0f, BackEventCompat.EDGE_LEFT))
            dispatcher.dispatchOnBackProgressed(BackEventCompat(200f, 500f, 0.4f, BackEventCompat.EDGE_LEFT))
        }
        compose.waitForIdle()
        assertThat(compose.onNodeWithTag(EXPANDED_PLAYER_TAG).getBoundsInRoot().top).isGreaterThan(open)
        assertThat(expanded).isTrue()

        compose.runOnUiThread { dispatcher.onBackPressed() }
        compose.waitForIdle()
        assertThat(expanded).isFalse()
        compose.onNodeWithTag(EXPANDED_PLAYER_TAG).assertDoesNotExist()
    }

    @Test
    fun `a cancelled back swipe leaves the player open`() {
        expanded = true
        show()
        compose.waitForIdle()
        val open = compose.onNodeWithTag(EXPANDED_PLAYER_TAG).getBoundsInRoot().top
        val dispatcher = compose.activity.onBackPressedDispatcher
        compose.runOnUiThread {
            dispatcher.dispatchOnBackStarted(BackEventCompat(0f, 500f, 0f, BackEventCompat.EDGE_LEFT))
            dispatcher.dispatchOnBackProgressed(BackEventCompat(200f, 500f, 0.4f, BackEventCompat.EDGE_LEFT))
            dispatcher.dispatchOnBackCancelled()
        }
        compose.waitForIdle()
        assertThat(expanded).isTrue()
        assertThat(compose.onNodeWithTag(EXPANDED_PLAYER_TAG).getBoundsInRoot().top).isEqualTo(open)
    }
}

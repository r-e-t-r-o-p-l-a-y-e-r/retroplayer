package app.retroplayer.ui.library

import androidx.compose.ui.test.getBoundsInRoot
import androidx.compose.ui.test.hasClickAction
import androidx.compose.ui.test.hasContentDescription
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.hasAnyDescendant
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.test.longClick
import androidx.compose.ui.unit.dp
import androidx.compose.ui.test.performScrollToNode
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipe
import androidx.compose.ui.test.swipeLeft
import androidx.compose.ui.test.swipeRight
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.setValue
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.library.FolderEntry
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.ui.components.PLAYING_STRIP_TAG
import app.retroplayer.domain.LibraryIndex
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
        moveRoot = { from, to -> calls += "moveRoot:$from->$to" },
        moveFavorite = { from, to -> calls += "moveFavorite:$from->$to" },
        addToQueue = { id, onAdded ->
            calls += "queue:" + id
            added?.let(onAdded)
        },
    )
    private var added: Int? = 2

    private val music = LibraryRoot("1", "content://com.android.externalstorage.documents/tree/primary%3AMusic", "Music", false)
    private val books = LibraryRoot("2", "content://com.android.externalstorage.documents/tree/primary%3ABooks", "Books", false)

    /** Long-press, then drag down by [rows] row heights and release. */
    private fun dragDown(text: String, rows: Float) = compose.onNodeWithText(text).performTouchInput {
        down(center)
        advanceEventTime(viewConfiguration.longPressTimeoutMillis + 100)
        val step = 56.dp.toPx() * rows / 20
        repeat(20) {
            moveBy(Offset(0f, step))
            advanceEventTime(16)
        }
        up()
    }

    private fun show(state: FolderUiState, isRoot: Boolean = false) = compose.setContent {
        RetroTheme { FolderContent(state, isRoot, null, navigation, actions) }
    }

    @Test
    fun `empty library explains how to start and offers add folder`() {
        show(FolderUiState.Root(emptyList(), emptyList()), isRoot = true)
        compose.onNodeWithText("No folders added. Tap \"Add folder\" to get started.").assertIsDisplayed()
        compose.onNode(hasContentDescription("Add folder") and hasClickAction()).performClick()
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
    fun `swiping a root asks before removing it`() {
        show(FolderUiState.Root(listOf(music), emptyList()), isRoot = true)
        compose.onNodeWithText("Music").performTouchInput { swipeLeft() }
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
        compose.onNodeWithText("Alpha").performTouchInput { swipeRight() }
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
    fun `long press drags a root to a new place`() {
        show(FolderUiState.Root(listOf(music, books), emptyList()), isRoot = true)
        dragDown("Music", rows = 1.5f)
        assertThat(calls).containsExactly("moveRoot:0->1")
    }

    @Test
    fun `long press drags a favorite to a new place and leaves the roots alone`() {
        val links = listOf(FavoriteLink(LibraryPath("1/A"), "A", null), FavoriteLink(LibraryPath("1/B"), "B", null))
        show(FolderUiState.Root(listOf(music), links), isRoot = true)
        dragDown("A", rows = 1.5f)
        dragDown("Music", rows = 3f)
        assertThat(calls).containsExactly("moveFavorite:0->1")
    }

    @Test
    fun `swiping a favorite left queues it and swiping right unfavorites it`() {
        val link = FavoriteLink(LibraryPath("1/A"), "A", null)
        show(FolderUiState.Root(listOf(music), listOf(link)), isRoot = true)
        compose.onNodeWithText("A").performTouchInput { swipeLeft() }
        compose.onNodeWithText("2 tracks added to the queue").assertIsDisplayed()
        compose.onNodeWithText("A").performTouchInput { swipeRight() }
        assertThat(calls).containsExactly("queue:" + PlaybackItem.folderId(link.path), "fav:1/A").inOrder()
    }

    @Test
    fun `a folder row swipes both ways, one action each`() {
        added = null
        val books = LibraryPath("1/Books")
        show(
            FolderUiState.Folder(
                path = books,
                crumbs = listOf(Crumb("", null, isLibraryRoot = true)),
                folders = listOf(FolderRow(FolderEntry(books.child("Alpha"), "doc:a"), isFavorite = false)),
                playlists = emptyList(), audio = emptyList(), artUri = null, scanned = 1, total = 1, complete = true,
            ),
        )
        compose.onNodeWithText("Alpha").performTouchInput { swipeLeft() }
        compose.onNodeWithText("Alpha").performTouchInput { swipeRight() }
        assertThat(calls).containsExactly("queue:" + PlaybackItem.folderId(books.child("Alpha")), "fav:1/Books/Alpha").inOrder()
    }

    @Test
    fun `a row can be swiped again after it snapped back`() {
        added = null
        show(FolderUiState.Root(listOf(music), listOf(FavoriteLink(LibraryPath("1/A"), "A", null))), isRoot = true)
        compose.onNodeWithText("A").performTouchInput { swipeLeft() }
        compose.onNodeWithText("A").performTouchInput { swipeLeft() }
        assertThat(calls).hasSize(2)
    }

    private fun actionsOf(row: String) = compose
        .onNode(hasAnyDescendant(hasText(row, substring = false)) and SemanticsMatcher.keyIsDefined(SemanticsActions.CustomActions))
        .fetchSemanticsNode().config[SemanticsActions.CustomActions]

    private fun runAction(row: String, label: String) {
        val action = actionsOf(row).first { it.label == label }
        compose.runOnUiThread { action.action() }
    }

    @Test
    fun `screen readers move roots and favorites with up and down actions`() {
        val links = listOf(FavoriteLink(LibraryPath("1/A"), "A", null), FavoriteLink(LibraryPath("1/B"), "B", null))
        show(FolderUiState.Root(listOf(music, books), links), isRoot = true)
        runAction("Music", "Move down")
        runAction("B", "Move up")
        assertThat(calls).containsExactly("moveRoot:0->1", "moveFavorite:1->0").inOrder()
        assertThat(actionsOf("Music").map { it.label }).doesNotContain("Move up")
        assertThat(actionsOf("Books").map { it.label }).doesNotContain("Move down")
        assertThat(actionsOf("B").map { it.label }).doesNotContain("Move down")
    }

    @Test
    fun `adding nothing new says so`() {
        added = 0
        show(FolderUiState.Root(listOf(music), listOf(FavoriteLink(LibraryPath("1/A"), "A", null))), isRoot = true)
        compose.onNodeWithText("A").performTouchInput { swipeLeft() }
        compose.onNodeWithText("No new tracks added to the queue").assertIsDisplayed()
    }

    @Test
    fun `long press neither opens a menu nor the row, a later tap does`() {
        show(FolderUiState.Root(listOf(music), emptyList()), isRoot = true)
        compose.onNodeWithText("Music").performTouchInput { longClick() }
        compose.onNodeWithText("Add to queue").assertDoesNotExist()
        assertThat(calls).isEmpty()
        compose.onNodeWithText("Music").performClick()
        assertThat(calls).containsExactly("open:1")
    }

    @Test
    fun `swiping any folder page row left adds it to the queue`() {
        added = null
        val books = LibraryPath("1/Books")
        val album = AudioAlbum("dir:1/Books", "Alb", "Ann", listOf(AudioTrack(books.child("t1.mp3"), "doc:t1")), AlbumSource.DIRECTORY, books)
        show(
            FolderUiState.Folder(
                path = books,
                crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Books", books)),
                folders = listOf(FolderRow(FolderEntry(books.child("Alpha"), "doc:a"), isFavorite = false)),
                playlists = listOf(PlaylistRef(books.child("mix.m3u"), "doc:m")),
                audio = listOf(LibraryItem.Album(album), LibraryItem.Track(AudioTrack(books.child("single.mp3"), "doc:s"))),
                artUri = null,
                scanned = 1,
                total = 1,
                complete = true,
            ),
        )
        for (row in listOf("Alpha", "mix", "Alb", "single")) {
            compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(row, substring = false))
            compose.onNodeWithText(row).performTouchInput { swipeLeft() }
        }
        assertThat(calls).containsExactly(
            "queue:" + PlaybackItem.folderId(books.child("Alpha")),
            "queue:" + LibraryItem.Playlist(PlaylistRef(books.child("mix.m3u"), "doc:m")).id,
            "queue:" + LibraryItem.Album(album).id,
            "queue:1/Books/single.mp3",
        ).inOrder()
    }

    @Test
    fun `album rows count one track in the singular`() {
        val books = LibraryPath("1/Books")
        fun album(id: String, title: String, count: Int) = LibraryItem.Album(
            AudioAlbum(id, title, "Ann", List(count) { AudioTrack(books.child("$title$it.mp3"), "doc:$title$it") }, AlbumSource.TAG, books),
        )
        show(
            FolderUiState.Folder(
                path = books,
                crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Books", books)),
                folders = emptyList(),
                playlists = emptyList(),
                audio = listOf(album("tag:a", "One", 1), album("tag:b", "Two", 2)),
                artUri = null,
                scanned = 3,
                total = 3,
                complete = true,
            ),
        )
        compose.onNodeWithText("1 track · Ann").assertIsDisplayed()
        compose.onNodeWithText("2 tracks · Ann").assertIsDisplayed()
    }

    @Test
    fun `missing folder says so`() {
        show(FolderUiState.Missing)
        compose.onNodeWithText("This folder is no longer available.").assertIsDisplayed()
    }

    private fun longAudioFolder(): FolderUiState.Folder {
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
    fun `index bar appears for long lists`() {
        show(longAudioFolder())
        compose.onNodeWithTag(LIBRARY_INDEX_BAR_TAG).assertIsDisplayed()
    }

    @Test
    fun `tapping a letter scrolls to it`() {
        show(longAudioFolder())
        compose.onNodeWithText("Z", substring = false).performClick()
        compose.waitForIdle()
        compose.onNodeWithText("zebra").assertIsDisplayed()
    }

    @Test
    fun `the index bar still jumps after the scroll position was saved`() {
        var saved = 0 to 0
        var saves by mutableIntStateOf(0)
        compose.setContent {
            saves
            val scroll = FolderListScroll(saved.first, saved.second) { index, offset ->
                saved = index to offset
                saves++
            }
            RetroTheme { FolderContent(longAudioFolder(), false, null, navigation, actions, listScroll = scroll) }
        }
        compose.onNodeWithText("Z").performClick()
        compose.waitForIdle()
        compose.onNodeWithText("zebra").assertIsDisplayed()
        compose.onNodeWithText("A").performClick()
        compose.waitForIdle()
        compose.onNodeWithText("alpha").assertIsDisplayed()
    }

    @Test
    fun `sliding along the index bar jumps to the letter under the finger`() {
        show(longAudioFolder())
        compose.onNodeWithTag(LIBRARY_INDEX_BAR_TAG).performTouchInput {
            swipe(start = topCenter, end = bottomCenter.copy(y = bottomCenter.y - 1f), durationMillis = 300)
        }
        compose.waitForIdle()
        compose.onNodeWithText("zebra").assertIsDisplayed()
    }

    @Test
    fun `settings sit at the end of the top bar after the queue`() {
        show(FolderUiState.Root(listOf(music), emptyList()), isRoot = true)
        val queue = compose.onNodeWithContentDescription("Queue").getBoundsInRoot()
        val settings = compose.onNodeWithContentDescription("Settings").getBoundsInRoot()
        assertThat(settings.left).isGreaterThan(queue.left)
    }
}

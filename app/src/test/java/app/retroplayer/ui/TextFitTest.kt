package app.retroplayer.ui

import app.retroplayer.ui.queue.SavePlaylistActions
import app.retroplayer.ui.queue.SaveFolderChoice
import app.retroplayer.ui.queue.SavePlaylistUiState
import app.retroplayer.ui.queue.SavePlaylistContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import android.content.Context
import androidx.compose.ui.test.hasScrollToIndexAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.ComposeContentTestRule
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import app.retroplayer.ui.settings.LANGUAGE_DROPDOWN_TAG
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollToNode
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.ui.playlist.PlaylistActions
import app.retroplayer.ui.playlist.PlaylistContent
import app.retroplayer.ui.playlist.PlaylistEntryUi
import app.retroplayer.ui.playlist.PlaylistUiState
import app.retroplayer.ui.queue.AddTracksActions
import app.retroplayer.ui.queue.AddTracksContent
import app.retroplayer.ui.queue.AddTracksUiState
import app.retroplayer.ui.settings.SettingsDataContent
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.library.FolderEntry
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSource
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.Chapter
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.album.AlbumActions
import app.retroplayer.ui.album.AlbumContent
import app.retroplayer.ui.album.AlbumUiState
import app.retroplayer.ui.library.FavoriteLink
import app.retroplayer.ui.library.FolderActions
import app.retroplayer.ui.library.FolderContent
import app.retroplayer.ui.library.FolderNavigation
import app.retroplayer.ui.library.FolderRow
import app.retroplayer.ui.library.FolderUiState
import app.retroplayer.ui.player.PlayerActions
import app.retroplayer.ui.player.PlayerHost
import app.retroplayer.ui.player.LibraryHeader
import app.retroplayer.ui.player.PlayerUiState
import app.retroplayer.ui.queue.QueueActions
import app.retroplayer.ui.queue.QueueContent
import app.retroplayer.ui.queue.QueueEntry
import app.retroplayer.ui.queue.QueueUiState
import app.retroplayer.ui.settings.EqualizerActions
import app.retroplayer.ui.settings.EqualizerSection
import app.retroplayer.ui.settings.EqualizerUiState
import app.retroplayer.ui.settings.HeadsetActions
import app.retroplayer.ui.settings.HeadsetSection
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.ui.settings.LanguageOption
import app.retroplayer.ui.settings.SettingsActions
import app.retroplayer.ui.settings.SettingsContent
import app.retroplayer.ui.settings.SettingsUiState
import app.retroplayer.ui.theme.RetroTheme
import org.junit.Rule
import org.junit.Test
import org.junit.rules.RuleChain
import org.junit.runner.RunWith
import org.robolectric.ParameterizedRobolectricTestRunner
import org.robolectric.annotation.GraphicsMode

/** Every screen on a narrow phone (or a short landscape one) at font scale 2 in the longest translations and both pseudo-locales. */
@RunWith(ParameterizedRobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class TextFitTest(private val screen: Screen, private val locale: String) {
    private val compose = createComposeRule()

    @get:Rule val rules: RuleChain = RuleChain.outerRule(DisplayRule("$locale-${screen.size}", 2f)).around(compose)

    @Test
    fun `controls fit`() {
        compose.setContent { RetroTheme { screen.content() } }
        compose.waitForIdle()
        screen.open(compose)
        compose.waitForIdle()
        compose.assertNoClippedText()
    }

    enum class Screen(
        val content: @Composable () -> Unit,
        val open: (ComposeContentTestRule) -> Unit = {},
        val size: String = "w320dp-h640dp",
    ) {
        EMPTY_LIBRARY({ FolderContent(FolderUiState.Root(emptyList(), emptyList()), true, null, NAVIGATION, FolderActions()) }),
        LIBRARY({ FolderContent(FolderUiState.Root(listOf(music, books), favorites), true, null, NAVIGATION, FolderActions()) }),
        FOLDER({ FolderContent(folder, false, null, NAVIGATION, FolderActions()) }),
        ALBUM({ AlbumContent(album, null, null, null, null, AlbumActions()) }),
        ALBUM_MISSING_TAGS({ AlbumContent(album, 2, null, null, null, AlbumActions()) }),
        QUEUE({ QueueContent(queue, QueueActions()) }),
        QUEUE_CLEAR({ QueueContent(queue.copy(confirmClear = true), QueueActions()) }),
        SAVE_PLAYLIST_SOURCES({
            SavePlaylistContent(SavePlaylistUiState(null, null, listOf(SaveFolderChoice(LibraryPath("1"), "Music")), loading = false), SavePlaylistActions())
        }),
        SAVE_PLAYLIST_FOLDER({
            SavePlaylistContent(SavePlaylistUiState(LibraryPath("1/Mix"), "Mix", listOf(SaveFolderChoice(LibraryPath("1/Mix/Road"), "Road")), loading = false), SavePlaylistActions())
        }),
        PLAYLIST({ PlaylistContent(playlist, PlaylistActions()) }),
        PLAYLIST_READ_ONLY({ PlaylistContent(playlist.copy(editable = false), PlaylistActions()) }),
        PLAYLIST_SELECT({ PlaylistContent(playlist.copy(selectMode = true, selectedIndices = setOf(0)), PlaylistActions()) }),
        PLAYLIST_REMOVE({ PlaylistContent(playlist.copy(confirmRemove = setOf(0, 1)), PlaylistActions()) }),
        PLAYLIST_DELETE({ PlaylistContent(playlist.copy(confirmDelete = true), PlaylistActions()) }),
        ADD_TRACKS_ROOTS({ AddTracksContent(AddTracksUiState.PickRoot(listOf(music, books), emptySet()), AddTracksActions()) }),
        ADD_TRACKS_FOLDER({ AddTracksContent(addTracksFolder, AddTracksActions()) }),
        ADD_TRACKS_ALBUM({
            AddTracksContent(AddTracksUiState.AlbumTracks(album.album, addTracksFolder.crumbs, tracks, setOf(tracks[0].path)), AddTracksActions())
        }),
        SETTINGS({ SettingsContent(SettingsUiState(languages = languages), SettingsActions()) }),
        SETTINGS_RESET(
            { SettingsContent(SettingsUiState(languages = languages), SettingsActions()) },
            { compose ->
                compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(string(R.string.reset_database)))
                compose.onNodeWithText(string(R.string.reset_database)).performClick()
            },
        ),
        SETTINGS_DATA({ SettingsDataContent(SettingsUiState(databaseFileName = "retroplayer.db", databasePath = "/data/user/0/app.retroplayer/databases"), {}) }),
        EQUALIZER_UNAVAILABLE({ SettingsContent(SettingsUiState(languages = languages), SettingsActions(), EqualizerUiState(available = false)) }),
        EQUALIZER({ Column(Modifier.verticalScroll(rememberScrollState())) { EqualizerSection(EqualizerUiState(available = true, settings = EqualizerSettings(enabled = true)), EqualizerActions()) } }),
        HEADSET({ Column(Modifier.verticalScroll(rememberScrollState())) { HeadsetSection(HeadsetSettings(autoRewindSeconds = 30), HeadsetActions()) } }),
        ABOUT(
            { SettingsContent(SettingsUiState(languages = languages), SettingsActions()) },
            { compose -> compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(string(R.string.about_git_commit))) },
        ),
        LANGUAGES(
            { SettingsContent(SettingsUiState(languages = languages), SettingsActions()) },
            { compose -> compose.onNodeWithTag(LANGUAGE_DROPDOWN_TAG).performClick() },
        ),
        PLAYER({ PlayerHost(playing, expanded = true, onExpandedChange = {}, PLAYER_ACTIONS) { LibraryHeader() } }),
        PLAYER_LANDSCAPE({ PlayerHost(playing, expanded = true, onExpandedChange = {}, PLAYER_ACTIONS) { LibraryHeader() } }, size = "w800dp-h360dp"),
        MINI_PLAYER({ PlayerHost(playing, expanded = false, onExpandedChange = {}, PLAYER_ACTIONS) {} }),
        PLAYER_CHAPTERS({ PlayerHost(book, expanded = true, onExpandedChange = {}, PLAYER_ACTIONS) { LibraryHeader() } }),
        CHAPTER_LIST(
            { PlayerHost(book, expanded = true, onExpandedChange = {}, PLAYER_ACTIONS) { LibraryHeader() } },
            { compose -> compose.onNodeWithText(book.chapters[1].title).performClick() },
        ),
        ;

        override fun toString() = name.lowercase()
    }

    companion object {
        @JvmStatic
        @ParameterizedRobolectricTestRunner.Parameters(name = "{0} in {1}")
        fun cases(): List<Array<Any>> =
            Screen.entries.flatMap { screen -> LOCALES.map { arrayOf(screen, it) } }

        private val NAVIGATION = FolderNavigation(openFolder = {}, openCrumb = {}, openAlbum = {})
        private val PLAYER_ACTIONS = PlayerActions(
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
        private val LOCALES = listOf("en", "de", "fi", "el", "ru", "en-rXA", "ar-rXB")

        private val music = LibraryRoot("1", "content://com.android.externalstorage.documents/tree/primary%3AMusic", "Music", false)
        private val books = LibraryRoot("2", "content://com.android.externalstorage.documents/tree/primary%3ABooks", "Books", false)
        private val favorites = listOf(FavoriteLink(LibraryPath("1/Jazz"), "Jazz", "Music"))
        private val folderPath = LibraryPath("1/Books")
        private val folder = FolderUiState.Folder(
            path = folderPath,
            crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Books", folderPath)),
            folders = listOf(FolderRow(FolderEntry(folderPath.child("Alpha"), "doc:a"), isFavorite = true)),
            playlists = listOf(PlaylistRef(folderPath.child("mix.m3u"), "doc:m")),
            audio = listOf(LibraryItem.Track(AudioTrack(folderPath.child("single.mp3"), "doc:s"))),
            artUri = null,
            scanned = 1,
            total = 3,
            complete = false,
        )
        private val tracks = listOf(
            AudioTrack(LibraryPath("1/Alb/a.mp3"), "doc:a", TrackMetadata(title = "First", artist = "Ann", trackNumber = 1, durationMs = 61_000)),
            AudioTrack(LibraryPath("1/Alb/b.mp3"), "doc:b", TrackMetadata(title = "Second", trackNumber = 2, durationMs = 3_700_000)),
        )
        private val album = AlbumUiState.Ready(
            album = AudioAlbum("dir:1/Alb", "Alb", "Ann", tracks, AlbumSource.DIRECTORY, LibraryPath("1/Alb")),
            tracks = tracks,
            mode = AlbumSortMode.FILE_NAME,
            tagsUsable = true,
            crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Alb", LibraryPath("1/Alb"))),
            artUri = null,
        )
        private val queue = QueueUiState.Ready(
            tracks.map { QueueEntry(it.path, it) } + QueueEntry(LibraryPath("1/gone.mp3"), null),
            playingTrackId = tracks[0].id,
            confirmClear = false,
        )
        private fun string(id: Int, vararg args: Any) = ApplicationProvider.getApplicationContext<Context>().getString(id, *args)

        private val playlist = PlaylistUiState.Ready(
            title = "Road trip",
            entries = tracks.map { PlaylistEntryUi(it.path, it) } + PlaylistEntryUi(LibraryPath("1/gone.mp3"), null),
            editable = true,
            selectMode = false,
            selectedIndices = emptySet(),
            confirmRemove = null,
            confirmDelete = false,
            playingTrackId = null,
        )
        private val addTracksFolder = AddTracksUiState.Browse(
            path = folderPath,
            crumbs = listOf(Crumb("", null, isLibraryRoot = true), Crumb("Music", LibraryPath("1")), Crumb("Books", folderPath)),
            folders = listOf(folderPath.child("Alpha")),
            audio = listOf(LibraryItem.Track(AudioTrack(folderPath.child("single.mp3"), "doc:s"))),
            selected = setOf(folderPath.child("Alpha")),
            complete = true,
        )
        private val languages = listOf(LanguageOption("de", "Deutsch"), LanguageOption("fi", "suomi"))
        private val book by lazy {
            playing.copy(
                nowPlaying = playing.nowPlaying.copy(positionMs = 70_000),
                chapters = listOf(
                    Chapter(0, "Prologue"),
                    Chapter(60_000, "Chapter 1: A rather long chapter title that does not fit on one line"),
                    Chapter(120_000, "Epilogue"),
                ),
            )
        }

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
                Crumb("Alb", LibraryPath("1/Alb")),
                Crumb("Song 2", null),
            ),
        )
    }
}

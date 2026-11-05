package app.retroplayer.ui

import app.retroplayer.domain.model.PlaybackItem
import kotlinx.coroutines.async
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.AlbumIds
import app.retroplayer.playback.NowPlaying
import app.retroplayer.runVmTest
import app.retroplayer.ui.navigation.AlbumRoute
import app.retroplayer.ui.navigation.FolderRoute
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import org.junit.After
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AppViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary

    @After
    fun tearDown() = lib.close()

    @Test
    fun `start routes are the saved folder chain plus the open album`() = main.runVmTest {
        lib = TestLibrary(tmp)
        val root = lib.addRoot()
        val album = AlbumIds.folder(lib.p("A"))
        lib.settings.setBrowsePath(lib.p("A"))
        lib.settings.setOpenAlbum(album)

        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback, lib.repository)
        val routes = viewModel.startRoutes.filterNotNull().first()
        assertThat(routes).containsExactly(FolderRoute(), FolderRoute(root), FolderRoute(lib.p("A").value), AlbumRoute(album)).inOrder()
    }

    @Test
    fun `start routes are read once and ignore later session changes`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.settings.setBrowsePath(lib.p("A"))
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback, lib.repository)
        val routes = viewModel.startRoutes.filterNotNull().first()

        lib.settings.setBrowsePath(null)
        assertThat(viewModel.startRoutes.value).isEqualTo(routes)
    }

    @Test
    fun `locate sets the located track`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        val track = lib.p("Rock/Album/01 Song.mp3").value
        val album = AlbumIds.folder(lib.p("Rock/Album"))
        lib.playback.nowPlaying.value = NowPlaying(trackId = track, itemId = album, hasTrack = true)
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback, lib.repository)
        val done = async { viewModel.locateRoutes.first() }
        viewModel.locate()
        assertThat(viewModel.locatedTrackId.filterNotNull().first()).isEqualTo(track)
        done.await()
    }

    @Test
    fun `locate after playing a folder opens the album of the track`() = main.runVmTest {
        lib = TestLibrary(tmp)
        val root = lib.addRoot()
        lib.docs.file("Rock/Album/01 Song.mp3")
        lib.docs.file("Rock/Album/02 Song.mp3")
        val track = lib.p("Rock/Album/01 Song.mp3").value
        lib.playback.nowPlaying.value = NowPlaying(trackId = track, itemId = PlaybackItem.folderId(lib.p("Rock")), hasTrack = true)
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback, lib.repository)
        val routes = async { viewModel.locateRoutes.first() }
        viewModel.locate()
        assertThat(routes.await()).containsExactly(
            FolderRoute(),
            FolderRoute(root),
            FolderRoute(lib.p("Rock").value),
            FolderRoute(lib.p("Rock/Album").value),
            AlbumRoute(AlbumIds.folder(lib.p("Rock/Album"))),
        ).inOrder()
    }

    @Test
    fun `manual navigation clears the located track`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.playback.nowPlaying.value = NowPlaying(trackId = lib.p("A/t.mp3").value, hasTrack = true)
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback, lib.repository)
        val done = async { viewModel.locateRoutes.first() }
        viewModel.locate()
        assertThat(viewModel.locatedTrackId.filterNotNull().first()).isNotNull()
        done.await()
        viewModel.onUserBrowsing()
        assertThat(viewModel.locatedTrackId.value).isNull()
    }
}

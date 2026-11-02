package app.retroplayer.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.album.AlbumScreen
import app.retroplayer.ui.library.FolderNavigation
import app.retroplayer.ui.library.FolderScreen
import app.retroplayer.ui.library.FolderViewModel
import app.retroplayer.ui.navigation.AbsorbBackAtRoot
import app.retroplayer.ui.navigation.AlbumRoute
import app.retroplayer.ui.navigation.FolderRoute
import app.retroplayer.ui.navigation.StartupRoutes
import app.retroplayer.ui.navigation.rememberRestoredNavController
import app.retroplayer.ui.player.PlayerActions
import app.retroplayer.ui.player.PlayerHost
import app.retroplayer.ui.player.PlayerViewModel
import app.retroplayer.ui.theme.RetroTheme

@Composable
fun RetroApp(appViewModel: AppViewModel = hiltViewModel(), playerViewModel: PlayerViewModel = hiltViewModel()) {
    val theme by appViewModel.theme.collectAsStateWithLifecycle()
    val nowPlaying = appViewModel.nowPlaying.collectAsStateWithLifecycle()
    val player by playerViewModel.state.collectAsStateWithLifecycle()
    val startRoutes by appViewModel.startRoutes.collectAsStateWithLifecycle()
    RetroTheme(theme) {
        val routes = startRoutes
        if (routes == null) {
            Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background))
            return@RetroTheme
        }
        var expanded by rememberSaveable { mutableStateOf(false) }
        // UC-09: starting playback from a library page brings up the player.
        LaunchedEffect(Unit) { appViewModel.playRequests.collect { expanded = true } }
        val playerActions = PlayerActions(
            toggle = playerViewModel::toggle,
            previous = playerViewModel::previous,
            next = playerViewModel::next,
        )
        PlayerHost(player, expanded, { expanded = it }, playerActions) {
            LibraryNavHost(routes, nowPlaying)
        }
    }
}

@Composable
private fun LibraryNavHost(routes: List<Any>, nowPlaying: State<NowPlaying>) {
    lateinit var nav: NavController
    val folderNavigation = FolderNavigation(
        openFolder = { nav.navigate(FolderRoute(it.value)) },
        openCrumb = { nav.openCrumb(it) },
        openAlbum = { nav.navigate(AlbumRoute(it.id)) },
    )
    nav = rememberRestoredNavController(routes) {
        composable<FolderRoute> {
            val viewModel: FolderViewModel = hiltViewModel()
            AbsorbBackAtRoot(isRoot = viewModel.path == null)
            FolderScreen(viewModel, folderNavigation, nowPlaying.value.trackId)
        }
        composable<AlbumRoute> {
            AlbumScreen(
                viewModel = hiltViewModel(),
                playingTrackId = nowPlaying.value.trackId,
                back = { nav.popBackStack() },
                openCrumb = { nav.openCrumb(it) },
            )
        }
    }
    NavHost(nav, nav.graph)
}

/** Shows a folder with its parents behind it; reuses the back stack when the folder is already on it. */
fun NavController.showFolder(path: LibraryPath?) {
    if (popBackStack(FolderRoute(path?.value), inclusive = false)) return
    popBackStack(FolderRoute(), inclusive = false)
    StartupRoutes.folderChain(path).drop(1).forEach { navigate(it) }
}

private fun NavController.openCrumb(crumb: Crumb) = showFolder(crumb.path)

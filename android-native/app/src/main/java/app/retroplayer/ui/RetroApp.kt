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
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import kotlinx.coroutines.flow.SharedFlow
import androidx.compose.ui.Modifier
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.album.AlbumScreen
import app.retroplayer.ui.library.FolderNavigation
import app.retroplayer.ui.library.FolderScreen
import app.retroplayer.ui.library.FolderViewModel
import app.retroplayer.ui.navigation.AbsorbBackAtRoot
import app.retroplayer.ui.navigation.AddTracksRoute
import app.retroplayer.ui.navigation.AlbumRoute
import app.retroplayer.ui.navigation.FolderRoute
import app.retroplayer.ui.navigation.PlaylistRoute
import app.retroplayer.ui.navigation.QueueRoute
import app.retroplayer.ui.navigation.SettingsAboutRoute
import app.retroplayer.ui.navigation.SettingsDataRoute
import app.retroplayer.ui.navigation.SettingsEqualizerRoute
import app.retroplayer.ui.navigation.SettingsLicensesRoute
import app.retroplayer.ui.navigation.SettingsRoute
import app.retroplayer.ui.settings.SettingsAboutScreen
import app.retroplayer.ui.settings.SettingsDataScreen
import app.retroplayer.ui.settings.SettingsEqualizerScreen
import app.retroplayer.ui.settings.SettingsLicensesScreen
import app.retroplayer.ui.settings.SettingsScreen
import app.retroplayer.ui.playlist.PlaylistScreen
import app.retroplayer.ui.playlist.PlaylistViewModel
import app.retroplayer.ui.navigation.StartupRoutes
import app.retroplayer.ui.queue.AddTracksScreen
import app.retroplayer.ui.queue.QueueScreen
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
        var settingsOpen by remember { mutableStateOf(false) }
        val locatedTrackId by appViewModel.locatedTrackId.collectAsStateWithLifecycle()
        val navRef = remember { mutableStateOf<NavController?>(null) }
        // UC-09: starting playback from a library page brings up the player.
        LaunchedEffect(Unit) { appViewModel.playRequests.collect { expanded = true } }
        val playerActions = PlayerActions(
            toggle = playerViewModel::toggle,
            previous = playerViewModel::previous,
            next = playerViewModel::next,
            seekTo = playerViewModel::seekTo,
            jumpBack = playerViewModel::jumpBack,
            jumpForward = playerViewModel::jumpForward,
            setSpeed = playerViewModel::setSpeed,
            locate = {
                expanded = false
                appViewModel.locate(nowPlaying.value)
            },
            playbackCrumb = { crumb ->
                expanded = false
                appViewModel.onUserBrowsing()
                navRef.value?.showFolder(crumb.path)
            },
        )
        LaunchedEffect(settingsOpen) {
            if (settingsOpen) expanded = false
        }
        PlayerHost(player, expanded, { expanded = it }, playerActions, allowExpansion = !settingsOpen) {
            LibraryNavHost(
                routes = routes,
                nowPlaying = nowPlaying,
                scrollToTrackId = locatedTrackId,
                locateRoutes = appViewModel.locateRoutes,
                onExpandedChange = { expanded = it },
                onNavReady = { navRef.value = it },
                onUserBrowsing = appViewModel::onUserBrowsing,
                onSettingsOpen = { settingsOpen = it },
            )
        }
    }
}

@Composable
private fun LibraryNavHost(
    routes: List<Any>,
    nowPlaying: State<NowPlaying>,
    scrollToTrackId: String?,
    locateRoutes: SharedFlow<List<Any>>,
    onExpandedChange: (Boolean) -> Unit,
    onNavReady: (NavController) -> Unit,
    onUserBrowsing: () -> Unit,
    onSettingsOpen: (Boolean) -> Unit,
) {
    lateinit var nav: NavController
    val folderNavigation = FolderNavigation(
        openFolder = {
            onUserBrowsing()
            nav.navigate(FolderRoute(it.value)) {
                launchSingleTop = true
                restoreState = true
            }
        },
        openCrumb = {
            onUserBrowsing()
            nav.openCrumb(it)
        },
        openAlbum = {
            onUserBrowsing()
            nav.navigate(AlbumRoute(it.id))
        },
        openQueue = { nav.navigate(QueueRoute) },
        openPlaylist = { nav.navigate(PlaylistRoute(it.value)) },
        openSettings = {
            onUserBrowsing()
            nav.navigate(SettingsRoute)
        },
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
                scrollToTrackId = scrollToTrackId,
                back = {
                    onUserBrowsing()
                    nav.popBackStack()
                },
            )
        }
        composable<QueueRoute> {
            QueueScreen(
                viewModel = hiltViewModel(),
                back = { nav.popBackStack() },
                onAddTracks = { nav.navigate(AddTracksRoute()) },
            )
        }
        composable<PlaylistRoute> {
            val playlistViewModel: PlaylistViewModel = hiltViewModel()
            PlaylistScreen(
                viewModel = playlistViewModel,
                back = { nav.popBackStack() },
                onAddTracks = {
                    val playlist = playlistViewModel.path
                    nav.navigate(AddTracksRoute(path = playlist.parent?.value, playlistPath = playlist.value))
                },
                onDeleted = { nav.popBackStack() },
            )
        }
        composable<AddTracksRoute> {
            AddTracksScreen(
                viewModel = hiltViewModel(),
                back = { nav.popBackStack() },
                onDone = { nav.popBackStack() },
            )
        }
        composable<SettingsRoute> {
            SettingsScreen(
                back = { nav.popBackStack() },
                openDataStorage = { nav.navigate(SettingsDataRoute) },
                openLicenses = { nav.navigate(SettingsLicensesRoute) },
                openAbout = { nav.navigate(SettingsAboutRoute) },
                openEqualizer = { nav.navigate(SettingsEqualizerRoute) },
            )
        }
        composable<SettingsDataRoute> {
            SettingsDataScreen(back = { nav.popBackStack() })
        }
        composable<SettingsLicensesRoute> {
            SettingsLicensesScreen(back = { nav.popBackStack() })
        }
        composable<SettingsAboutRoute> {
            SettingsAboutScreen(back = { nav.popBackStack() })
        }
        composable<SettingsEqualizerRoute> {
            SettingsEqualizerScreen(back = { nav.popBackStack() })
        }
    }
    val backStackEntry by nav.currentBackStackEntryAsState()
    LaunchedEffect(backStackEntry) {
        val route = backStackEntry?.destination?.route.orEmpty()
        onSettingsOpen(route.contains("Settings", ignoreCase = true))
    }
    LaunchedEffect(nav) {
        onNavReady(nav)
        locateRoutes.collect { stack ->
            onExpandedChange(false)
            nav.navigateLocateStack(stack)
        }
    }
    NavHost(nav, nav.graph)
}

/** Shows a folder with its parents behind it; reuses the back stack when the folder is already on it. */
fun NavController.showFolder(path: LibraryPath?) {
    if (popBackStack(FolderRoute(path?.value), inclusive = false)) return
    popBackStack(FolderRoute(), inclusive = false)
    StartupRoutes.folderChain(path).drop(1).forEach { route ->
        navigate(route) {
            launchSingleTop = true
            restoreState = true
        }
    }
}

private fun NavController.openCrumb(crumb: Crumb) = showFolder(crumb.path)

/** Replaces the library back stack when locating the playing track (UC-13). */
private fun NavController.navigateLocateStack(routes: List<Any>) {
    navigate(FolderRoute()) {
        popUpTo(graph.startDestinationId) { inclusive = true }
    }
    routes.drop(1).forEach { route -> navigate(route) { launchSingleTop = true } }
}

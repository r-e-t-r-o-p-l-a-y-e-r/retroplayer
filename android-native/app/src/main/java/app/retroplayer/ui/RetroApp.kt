package app.retroplayer.ui

import androidx.activity.compose.BackHandler
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.album.AlbumScreen
import app.retroplayer.ui.library.FolderNavigation
import app.retroplayer.ui.library.FolderScreen
import app.retroplayer.ui.library.FolderViewModel
import app.retroplayer.ui.navigation.AlbumRoute
import app.retroplayer.ui.navigation.FolderRoute
import app.retroplayer.ui.navigation.StartupRoutes
import app.retroplayer.ui.theme.RetroTheme

@Composable
fun RetroApp(appViewModel: AppViewModel = hiltViewModel()) {
    val theme by appViewModel.theme.collectAsStateWithLifecycle()
    val nowPlaying by appViewModel.nowPlaying.collectAsStateWithLifecycle()
    RetroTheme(theme) {
        val nav = rememberNavController()
        var restored by rememberSaveable { mutableStateOf(false) }
        LaunchedEffect(Unit) {
            if (!restored) {
                restored = true
                appViewModel.startRoutes().drop(1).forEach { nav.navigate(it) }
            }
        }
        val folderNavigation = FolderNavigation(
            openFolder = { nav.navigate(FolderRoute(it.value)) },
            openCrumb = { nav.openCrumb(it) },
            openAlbum = { nav.navigate(AlbumRoute(it.id)) },
        )
        NavHost(navController = nav, startDestination = FolderRoute()) {
            composable<FolderRoute> {
                val viewModel: FolderViewModel = hiltViewModel()
                // UC-14: back at the library root stays in the app.
                BackHandler(enabled = viewModel.path == null) {}
                FolderScreen(viewModel, folderNavigation, nowPlaying.trackId)
            }
            composable<AlbumRoute> {
                AlbumScreen(
                    viewModel = hiltViewModel(),
                    playingTrackId = nowPlaying.trackId,
                    back = { nav.popBackStack() },
                    openCrumb = { nav.openCrumb(it) },
                )
            }
        }
    }
}

/** Shows a folder with its parents behind it; reuses the back stack when the folder is already on it. */
fun NavController.showFolder(path: LibraryPath?) {
    if (popBackStack(FolderRoute(path?.value), inclusive = false)) return
    popBackStack(FolderRoute(), inclusive = false)
    StartupRoutes.folderChain(path).drop(1).forEach { navigate(it) }
}

private fun NavController.openCrumb(crumb: Crumb) = showFolder(crumb.path)

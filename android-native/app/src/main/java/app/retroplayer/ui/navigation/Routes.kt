package app.retroplayer.ui.navigation

import androidx.navigation.NavDestination
import androidx.navigation.NavDestination.Companion.hasRoute
import kotlinx.serialization.Serializable

/** A library page; [path] null is the virtual root listing the library folders. Argument name matches FolderViewModel.PATH_ARG. */
@Serializable
data class FolderRoute(val path: String? = null)

/** Argument name matches AlbumViewModel.ALBUM_ID_ARG. */
@Serializable
data class AlbumRoute(val albumId: String)

@Serializable
data object QueueRoute

/** Optional [path] opens the picker on that folder; [playlistPath] appends to a playlist instead of the queue. */
@Serializable
data class AddTracksRoute(val path: String? = null, val playlistPath: String? = null)

@Serializable
data class PlaylistRoute(val path: String)

@Serializable
data object SettingsRoute

@Serializable
data object SettingsDataRoute

@Serializable
data object SettingsLicensesRoute

private val settingsRoutes = listOf(
    SettingsRoute::class,
    SettingsDataRoute::class,
    SettingsLicensesRoute::class,
)

fun NavDestination.isSettings(): Boolean = settingsRoutes.any { hasRoute(it) }

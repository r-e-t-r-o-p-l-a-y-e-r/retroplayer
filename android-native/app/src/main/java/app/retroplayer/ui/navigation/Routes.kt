package app.retroplayer.ui.navigation

import kotlinx.serialization.Serializable

/** A library page; [path] null is the virtual root listing the library folders. Argument name matches FolderViewModel.PATH_ARG. */
@Serializable
data class FolderRoute(val path: String? = null)

/** Argument name matches AlbumViewModel.ALBUM_ID_ARG. */
@Serializable
data class AlbumRoute(val albumId: String)

@Serializable
data object QueueRoute

/** Optional [path] is the folder the picker opens on; null starts at library sources. */
@Serializable
data class AddTracksRoute(val path: String? = null)

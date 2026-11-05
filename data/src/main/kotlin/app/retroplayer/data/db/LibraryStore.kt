package app.retroplayer.data.db

import androidx.room.withTransaction
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.SavedPlaybackState
import app.retroplayer.domain.settings.AppSettings
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

data class LibraryRoot(val id: String, val treeUri: String, val name: String, val canWrite: Boolean) {
    val path: LibraryPath get() = LibraryPath.root(id)
}

/** Library data in Room: roots, favorites, resume positions, album sorts, app playlists. */
class LibraryStore(private val db: RetroDatabase, private val clock: () -> Long = System::currentTimeMillis) {
    val roots: Flow<List<LibraryRoot>> = db.rootDao().observeAll().map { list -> list.map { it.toModel() } }

    val favorites: Flow<List<LibraryPath>> = db.favoriteDao().observeAll().map { list -> list.map { LibraryPath(it.path) } }

    /** Adds a root, or updates name and write access when the same tree is picked again. */
    suspend fun addRoot(treeUri: String, name: String, canWrite: Boolean): String = db.withTransaction {
        val existing = db.rootDao().byTree(treeUri)
        if (existing != null) {
            db.rootDao().update(existing.id, name, canWrite)
            existing.id.toString()
        } else {
            val position = (db.rootDao().all().maxOfOrNull { it.position } ?: -1) + 1
            db.rootDao().insert(RootEntity(treeUri = treeUri, name = name, canWrite = canWrite, addedAt = clock(), position = position)).toString()
        }
    }

    suspend fun allRoots(): List<LibraryRoot> = db.rootDao().all().map { it.toModel() }

    suspend fun root(id: String): LibraryRoot? = id.toLongOrNull()?.let { db.rootDao().byId(it) }?.toModel()

    suspend fun removeRoot(id: String) = db.withTransaction {
        db.rootDao().delete(id.toLong())
        db.favoriteDao().deleteUnderRoot(id)
        db.playbackDao().deleteUnderRoot(id)
        db.albumSortDao().deleteUnderRoot(id)
        db.appPlaylistDao().deleteUnderRoot(id)
    }

    suspend fun toggleFavorite(path: LibraryPath) = db.withTransaction {
        val current = db.favoriteDao().all()
        if (current.any { it.path == path.value }) {
            db.favoriteDao().delete(path.value)
        } else {
            db.favoriteDao().upsert(listOf(FavoriteEntity(path.value, (current.maxOfOrNull { it.position } ?: -1) + 1)))
        }
    }

    suspend fun setCanWrite(id: String, canWrite: Boolean) {
        id.toLongOrNull()?.let { db.rootDao().setCanWrite(it, canWrite) }
    }

    suspend fun moveRoot(from: Int, to: Int) = db.withTransaction {
        val list = db.rootDao().all().toMutableList()
        if (from !in list.indices || to !in list.indices) return@withTransaction
        list.add(to, list.removeAt(from))
        list.forEachIndexed { index, root -> db.rootDao().setPosition(root.id, index) }
    }

    suspend fun moveFavorite(from: Int, to: Int) = db.withTransaction {
        val list = db.favoriteDao().all().toMutableList()
        if (from !in list.indices || to !in list.indices) return@withTransaction
        list.add(to, list.removeAt(from))
        db.favoriteDao().upsert(list.mapIndexed { index, f -> f.copy(position = index) })
    }

    suspend fun savePlayback(itemId: String, state: SavedPlaybackState) {
        db.playbackDao().upsert(
            PlaybackEntity(
                itemId = itemId,
                trackId = state.trackId,
                positionMs = state.positionMs,
                speed = state.speed.takeIf { it != AppSettings.DEFAULT_SPEED },
                displayTitle = state.displayTitle,
                subtitle = state.subtitle,
                durationMs = state.durationMs,
            ),
        )
    }

    suspend fun playback(itemId: String): SavedPlaybackState? = db.playbackDao().get(itemId)?.let {
        SavedPlaybackState(it.trackId, it.positionMs, it.speed ?: AppSettings.DEFAULT_SPEED, it.displayTitle, it.subtitle, it.durationMs)
    }

    suspend fun clearPlayback(itemId: String) = db.playbackDao().delete(itemId)

    val albumSorts: Flow<Map<String, AlbumSortChoice>> = db.albumSortDao().observeAll().map { rows ->
        rows.mapNotNull { row -> AlbumSortChoice.entries.firstOrNull { it.name == row.choice }?.let { row.albumId to it } }.toMap()
    }

    suspend fun setAlbumSort(albumId: String, choice: AlbumSortChoice) {
        if (choice == AlbumSortChoice.AUTOMATIC) {
            db.albumSortDao().delete(albumId)
        } else {
            db.albumSortDao().upsert(AlbumSortEntity(albumId, choice.name))
        }
    }

    suspend fun albumSort(albumId: String): AlbumSortChoice =
        db.albumSortDao().get(albumId)?.let { stored -> AlbumSortChoice.entries.firstOrNull { it.name == stored } }
            ?: AlbumSortChoice.AUTOMATIC

    suspend fun registerAppPlaylist(path: LibraryPath) = db.appPlaylistDao().insert(AppPlaylistEntity(path.value))

    suspend fun forgetAppPlaylist(path: LibraryPath) = db.appPlaylistDao().delete(path.value)

    suspend fun isAppPlaylist(path: LibraryPath): Boolean = db.appPlaylistDao().exists(path.value)

    /** Clears favorites, resume positions and album sorts; optionally the roots too. Files are never touched. */
    suspend fun reset(keepRoots: Boolean) = db.withTransaction {
        db.favoriteDao().clear()
        db.playbackDao().clear()
        db.albumSortDao().clear()
        if (!keepRoots) {
            db.rootDao().clear()
            db.appPlaylistDao().clear()
            db.trackCacheDao().clear()
        }
    }

    private fun RootEntity.toModel() = LibraryRoot(id.toString(), treeUri, name, canWrite)
}

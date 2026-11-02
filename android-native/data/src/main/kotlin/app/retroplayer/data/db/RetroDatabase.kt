package app.retroplayer.data.db

import androidx.room.AutoMigration
import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Index
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.RoomDatabase
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "library_roots", indices = [Index(value = ["treeUri"], unique = true)])
data class RootEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val treeUri: String,
    val name: String,
    val canWrite: Boolean,
    val addedAt: Long,
    /** User order; rows from version 1 all start at 0 and fall back to addedAt. */
    @ColumnInfo(defaultValue = "0") val position: Int = 0,
)

@Entity(tableName = "favorite_folders")
data class FavoriteEntity(@PrimaryKey val path: String, val position: Int)

/** `speed` is null for normal speed so the default is not stored. */
@Entity(tableName = "playback_states")
data class PlaybackEntity(
    @PrimaryKey val itemId: String,
    val trackId: String,
    val positionMs: Long,
    val speed: Float?,
    val displayTitle: String?,
    val subtitle: String?,
    val durationMs: Long?,
)

/** Only non-default per-album sort choices have a row. */
@Entity(tableName = "album_sorts")
data class AlbumSortEntity(@PrimaryKey val albumId: String, val choice: String)

@Entity(tableName = "app_playlists")
data class AppPlaylistEntity(@PrimaryKey val path: String)

/** Tag cache keyed by document; a row is valid while lastModified and size match. */
@Entity(tableName = "track_cache")
data class TrackCacheEntity(
    @PrimaryKey val uri: String,
    val lastModified: Long,
    val size: Long,
    val title: String?,
    val artist: String?,
    val album: String?,
    val albumArtist: String?,
    val composer: String?,
    val trackNumber: Int?,
    val discNumber: Int?,
    val year: Int?,
    val genre: String?,
    val durationMs: Long?,
)

@Dao
interface RootDao {
    @Query("SELECT * FROM library_roots ORDER BY position, addedAt, id")
    fun observeAll(): Flow<List<RootEntity>>

    @Query("SELECT * FROM library_roots ORDER BY position, addedAt, id")
    suspend fun all(): List<RootEntity>

    @Query("UPDATE library_roots SET position = :position WHERE id = :id")
    suspend fun setPosition(id: Long, position: Int)

    @Query("SELECT * FROM library_roots WHERE treeUri = :treeUri")
    suspend fun byTree(treeUri: String): RootEntity?

    @Query("SELECT * FROM library_roots WHERE id = :id")
    suspend fun byId(id: Long): RootEntity?

    @Insert
    suspend fun insert(root: RootEntity): Long

    @Query("UPDATE library_roots SET canWrite = :canWrite, name = :name WHERE id = :id")
    suspend fun update(id: Long, name: String, canWrite: Boolean)

    @Query("DELETE FROM library_roots WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("DELETE FROM library_roots")
    suspend fun clear()
}

@Dao
interface FavoriteDao {
    @Query("SELECT * FROM favorite_folders ORDER BY position")
    fun observeAll(): Flow<List<FavoriteEntity>>

    @Query("SELECT * FROM favorite_folders ORDER BY position")
    suspend fun all(): List<FavoriteEntity>

    @Upsert
    suspend fun upsert(items: List<FavoriteEntity>)

    @Query("DELETE FROM favorite_folders WHERE path = :path")
    suspend fun delete(path: String)

    @Query("DELETE FROM favorite_folders WHERE path = :rootId OR path LIKE :rootId || '/%'")
    suspend fun deleteUnderRoot(rootId: String)

    @Query("DELETE FROM favorite_folders")
    suspend fun clear()
}

@Dao
interface PlaybackDao {
    @Query("SELECT * FROM playback_states WHERE itemId = :itemId")
    suspend fun get(itemId: String): PlaybackEntity?

    @Upsert
    suspend fun upsert(state: PlaybackEntity)

    @Query("DELETE FROM playback_states WHERE itemId = :itemId")
    suspend fun delete(itemId: String)

    @Query("DELETE FROM playback_states WHERE trackId LIKE :rootId || '/%'")
    suspend fun deleteUnderRoot(rootId: String)

    @Query("DELETE FROM playback_states")
    suspend fun clear()
}

@Dao
interface AlbumSortDao {
    @Query("SELECT choice FROM album_sorts WHERE albumId = :albumId")
    suspend fun get(albumId: String): String?

    @Query("SELECT * FROM album_sorts")
    fun observeAll(): Flow<List<AlbumSortEntity>>

    @Upsert
    suspend fun upsert(entity: AlbumSortEntity)

    @Query("DELETE FROM album_sorts WHERE albumId = :albumId")
    suspend fun delete(albumId: String)

    @Query(
        "DELETE FROM album_sorts WHERE albumId = 'dir:' || :rootId OR albumId LIKE 'dir:' || :rootId || '/%' " +
            "OR albumId LIKE 'tag:' || :rootId || '/%' OR albumId LIKE 'tag:' || :rootId || '::%'",
    )
    suspend fun deleteUnderRoot(rootId: String)

    @Query("SELECT COUNT(*) FROM album_sorts")
    suspend fun count(): Int

    @Query("DELETE FROM album_sorts")
    suspend fun clear()
}

@Dao
interface AppPlaylistDao {
    @Query("SELECT EXISTS(SELECT 1 FROM app_playlists WHERE path = :path)")
    suspend fun exists(path: String): Boolean

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(entity: AppPlaylistEntity)

    @Query("DELETE FROM app_playlists WHERE path = :path")
    suspend fun delete(path: String)

    @Query("DELETE FROM app_playlists WHERE path LIKE :rootId || '/%'")
    suspend fun deleteUnderRoot(rootId: String)

    @Query("DELETE FROM app_playlists")
    suspend fun clear()
}

@Dao
interface TrackCacheDao {
    @Query("SELECT * FROM track_cache WHERE uri IN (:uris)")
    suspend fun get(uris: List<String>): List<TrackCacheEntity>

    @Upsert
    suspend fun upsert(entities: List<TrackCacheEntity>)

    @Query("DELETE FROM track_cache")
    suspend fun clear()
}

@Database(
    entities = [
        RootEntity::class,
        FavoriteEntity::class,
        PlaybackEntity::class,
        AlbumSortEntity::class,
        AppPlaylistEntity::class,
        TrackCacheEntity::class,
    ],
    version = 2,
    exportSchema = true,
    autoMigrations = [AutoMigration(from = 1, to = 2)],
)
abstract class RetroDatabase : RoomDatabase() {
    abstract fun rootDao(): RootDao
    abstract fun favoriteDao(): FavoriteDao
    abstract fun playbackDao(): PlaybackDao
    abstract fun albumSortDao(): AlbumSortDao
    abstract fun appPlaylistDao(): AppPlaylistDao
    abstract fun trackCacheDao(): TrackCacheDao

    companion object {
        const val FILE_NAME = "retroplayer.db"
    }
}

package app.retroplayer.di

import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.preferencesDataStoreFile
import androidx.room.Room
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.data.library.AbsolutePathMapper
import app.retroplayer.data.library.DocumentSource
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.QueueRepository
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.data.library.RootLocation
import app.retroplayer.data.saf.RetrieverMetadataReader
import app.retroplayer.data.saf.SafDocumentSource
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.playback.ApplicationScope
import app.retroplayer.playback.PlaybackItemResolver
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import javax.inject.Qualifier
import javax.inject.Singleton

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class LibraryRoots

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides
    @Singleton
    @ApplicationScope
    fun applicationScope(): CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    @Provides
    @Singleton
    fun database(@ApplicationContext context: Context): RetroDatabase =
        Room.databaseBuilder(context, RetroDatabase::class.java, RetroDatabase.FILE_NAME).build()

    @Provides
    @Singleton
    fun libraryStore(db: RetroDatabase) = LibraryStore(db)

    @Provides
    @Singleton
    fun settingsStore(@ApplicationContext context: Context, @ApplicationScope scope: CoroutineScope) = SettingsStore(
        PreferenceDataStoreFactory.create(scope = CoroutineScope(scope.coroutineContext + Dispatchers.IO)) {
            context.preferencesDataStoreFile("settings")
        },
    )

    @Provides
    @Singleton
    @LibraryRoots
    fun roots(store: LibraryStore, @ApplicationScope scope: CoroutineScope): StateFlow<List<LibraryRoot>> =
        store.roots.stateIn(scope, SharingStarted.Eagerly, emptyList())

    @Provides
    @Singleton
    fun documentSource(@ApplicationContext context: Context): DocumentSource = SafDocumentSource(context.contentResolver)

    @Provides
    @Singleton
    fun scanner(@ApplicationContext context: Context, source: DocumentSource, db: RetroDatabase, store: LibraryStore) =
        LibraryScanner(
            source,
            RetrieverMetadataReader(context),
            db.trackCacheDao(),
            rootUri = { id -> store.root(id)?.let { SafDocumentSource.rootDocumentUri(it.treeUri) } },
            ioDispatcher = Dispatchers.IO,
        )

    @Provides
    @Singleton
    fun repository(store: LibraryStore, scanner: LibraryScanner) = LibraryRepository(store, scanner)

    @Provides
    @Singleton
    fun queue(settings: SettingsStore, scanner: LibraryScanner) = QueueRepository(settings, scanner)

    @Provides
    @Singleton
    fun playlists(
        source: DocumentSource,
        scanner: LibraryScanner,
        store: LibraryStore,
        @LibraryRoots roots: StateFlow<@JvmSuppressWildcards List<LibraryRoot>>,
    ) = PlaylistFiles(
        source,
        scanner,
        store,
        canWrite = { id -> store.root(id)?.canWrite == true },
        absolute = { path -> AbsolutePathMapper(roots.value.mapNotNull(::location)).toLibraryPath(path) },
    )

    @Provides
    @Singleton
    fun resolver(repository: LibraryRepository, scanner: LibraryScanner, playlists: PlaylistFiles, settings: SettingsStore) =
        PlaybackItemResolver(repository, scanner, playlists) { settings.session.first().queue }

    private fun location(root: LibraryRoot): RootLocation? = runCatching {
        val tree = Uri.parse(root.treeUri)
        RootLocation(root.id, tree.authority ?: return null, DocumentsContract.getTreeDocumentId(tree))
    }.getOrNull()
}

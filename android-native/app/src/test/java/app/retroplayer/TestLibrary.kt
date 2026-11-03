package app.retroplayer

import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.data.library.FakeDocumentSource
import app.retroplayer.data.library.FakeMetadataReader
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.data.library.QueueRepository
import app.retroplayer.playback.PlaybackItemResolver
import kotlinx.coroutines.flow.first
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.library.RootAccess
import app.retroplayer.playback.NowPlaying
import app.retroplayer.playback.PlaybackControls
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.test.TestDispatcher
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.rules.TemporaryFolder
import org.junit.rules.TestWatcher
import org.junit.runner.Description
import java.io.File
import java.util.Locale
import kotlin.time.Duration.Companion.seconds

@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(val dispatcher: TestDispatcher = UnconfinedTestDispatcher()) : TestWatcher() {
    override fun starting(description: Description) = Dispatchers.setMain(dispatcher)
    override fun finished(description: Description) = Dispatchers.resetMain()
}

/** [runTest] on the main dispatcher with a short timeout, so a waiting assertion fails fast. */
fun MainDispatcherRule.runVmTest(block: suspend TestScope.() -> Unit) = runTest(dispatcher, timeout = 10.seconds, testBody = block)

/** A library over in-memory documents, Room and DataStore, rooted at one folder named "Music". */
class TestLibrary(tmp: TemporaryFolder, metadata: Map<String, TrackMetadata> = emptyMap()) {
    private val scope = CoroutineScope(SupervisorJob() + UnconfinedTestDispatcher())
    val docs = FakeDocumentSource()
    val db: RetroDatabase = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
        .allowMainThreadQueries().build()
    val store = LibraryStore(db)
    val settingsData = PreferenceDataStoreFactory.create(scope = scope) { File(tmp.newFolder(), "s.preferences_pb") }
    val settings = SettingsStore(settingsData)
    var rootId = ""
    private val roots = mutableMapOf<String, String>()
    val scanner = LibraryScanner(docs, FakeMetadataReader(metadata), db.trackCacheDao(), { roots[it] }, UnconfinedTestDispatcher())
    val repository = LibraryRepository(store, scanner) { Locale.ENGLISH }
    val playlists = PlaylistFiles(docs, scanner, store, canWrite = { store.root(it)?.canWrite == true }, absolute = { null })
    val items = PlaybackItemResolver(repository, scanner, playlists) { settings.session.first().queue }
    val queue = QueueRepository(settings, scanner)
    val playback = FakePlayback()
    val access = FakeRootAccess()

    suspend fun addRoot(name: String = "Music"): String {
        rootId = store.addRoot("content://tree/$name", name, canWrite = false)
        roots[rootId] = "doc:root"
        return rootId
    }

    fun p(relative: String) = LibraryPath("$rootId/$relative")

    fun close() {
        db.close()
        scope.cancel()
    }

    inner class FakeRootAccess : RootAccess {
        val added = mutableListOf<String>()
        val removed = mutableListOf<String>()

        override suspend fun add(treeUri: String): String? {
            added += treeUri
            return store.addRoot(treeUri, treeUri.substringAfterLast('/'), canWrite = false)
        }

        override suspend fun grantWrite(rootId: String, pickedTreeUri: String): Boolean {
            val ok = store.root(rootId)?.treeUri == pickedTreeUri
            if (ok) store.setCanWrite(rootId, true)
            return ok
        }

        /** Like [app.retroplayer.library.SafRootAccess]: an unknown root has no grant to release. */
        override suspend fun remove(rootId: String) {
            if (store.root(rootId) == null) return
            removed += rootId
            store.removeRoot(rootId)
        }
    }
}

class FakePlayback : PlaybackControls {
    override val nowPlaying = MutableStateFlow(NowPlaying())
    override val playRequests = MutableSharedFlow<String>(extraBufferCapacity = 8)
    val played = mutableListOf<Pair<String, String?>>()

    /** Every transport call by name, with its argument when it has one (`seekTo:1000`). */
    val calls = mutableListOf<String>()

    override fun play(itemId: String, startTrackId: String?) {
        played += itemId to startTrackId
        playRequests.tryEmit(itemId)
    }

    override fun togglePlayPause() { calls += "toggle" }

    override fun seekTo(positionMs: Long) { calls += "seekTo:$positionMs" }

    override fun jumpBack() { calls += "jumpBack" }

    override fun jumpForward() { calls += "jumpForward" }

    override fun skipToPrevious() { calls += "previous" }

    override fun skipToNext() { calls += "next" }

    override fun setSpeed(speed: Float) { calls += "speed:$speed" }

    override fun stop() { calls += "stop" }
}

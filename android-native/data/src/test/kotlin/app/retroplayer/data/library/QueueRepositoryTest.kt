package app.retroplayer.data.library

import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class QueueRepositoryTest {
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var db: RetroDatabase
    private val docs = FakeDocumentSource()
    private lateinit var rootId: String

    @Before
    fun setUp() = runTest {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        rootId = LibraryStore(db).addRoot("content://tree/music", "Music", canWrite = false)
        listOf("a.mp3", "b.mp3", "c.mp3").forEach { docs.file("Mix/$it") }
    }

    @After
    fun tearDown() = db.close()

    private fun p(name: String) = LibraryPath("$rootId/Mix/$name")

    private fun TestScope.settings(): SettingsStore {
        val file = tmp.root.resolve("s.preferences_pb")
        return SettingsStore(PreferenceDataStoreFactory.create(scope = backgroundScope) { file })
    }

    private fun repository(settings: SettingsStore): QueueRepository {
        val scanner = LibraryScanner(
            docs,
            FakeMetadataReader(emptyMap()),
            db.trackCacheDao(),
            rootUri = { if (it == rootId) "doc:root" else null },
            ioDispatcher = UnconfinedTestDispatcher(),
        )
        return QueueRepository(settings, scanner)
    }

    @Test
    fun `edits persist across a new repository`() = runTest(UnconfinedTestDispatcher()) {
        val settings = settings()
        val first = repository(settings)
        first.add(listOf(p("a.mp3"), p("b.mp3"), p("c.mp3")))
        first.move(from = 2, to = 0)
        first.remove(1)
        first.add(listOf(p("c.mp3")))

        val tracks = repository(settings).queue.first()
        assertThat(tracks.map { it?.path }).containsExactly(p("c.mp3"), p("b.mp3")).inOrder()
        assertThat(settings.session.first().queue).containsExactly(p("c.mp3"), p("b.mp3")).inOrder()
    }

    @Test
    fun `missing files resolve to null entries`() = runTest(UnconfinedTestDispatcher()) {
        val repository = repository(settings())
        repository.add(listOf(p("a.mp3"), p("gone.mp3"), p("b.mp3")))
        assertThat(repository.queue.first().map { it?.path }).containsExactly(p("a.mp3"), null, p("b.mp3")).inOrder()
    }

    @Test
    fun `clear removes the stored key`() = runTest(UnconfinedTestDispatcher()) {
        val settings = settings()
        val repository = repository(settings)
        repository.add(listOf(p("a.mp3")))
        repository.clear()
        assertThat(settings.session.first().queue).isEmpty()
        assertThat(repository.queue.first()).isEmpty()
    }
}

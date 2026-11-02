package app.retroplayer.data.library

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.TrackMetadata
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class LibraryScannerTest {
    private lateinit var db: RetroDatabase
    private val docs = FakeDocumentSource()
    private val reader = FakeMetadataReader(mapOf("01.mp3" to TrackMetadata(title = "One", album = "A", trackNumber = 1)))

    private fun scanner() = LibraryScanner(docs, reader, db.trackCacheDao(), rootUri = { if (it == "1") "doc:root" else null }, ioDispatcher = UnconfinedTestDispatcher())

    @Before
    fun setUp() {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        docs.file("Book/01.mp3")
        docs.file("Book/02.mp3")
        docs.file("Book/cover.jpg")
        docs.file("Book/notes.txt")
        docs.file("Book/Mix.m3u")
        docs.file("Book/CD2/01.mp3")
        docs.file("Book/.hidden/x.mp3")
        docs.dir("Book/Empty")
    }

    @After
    fun tearDown() = db.close()

    @Test
    fun `first emission has folders playlists and placeholder tracks before metadata`() = runTest(UnconfinedTestDispatcher()) {
        val emissions = scanner().listFolder(LibraryPath("1/Book")).toList()
        val first = emissions.first()
        assertThat(first.folders.map { it.path.value }).containsExactly("1/Book/CD2", "1/Book/Empty")
        assertThat(first.playlists.map { it.path.value }).containsExactly("1/Book/Mix.m3u")
        assertThat(first.tracks.map { it.path.value }).containsExactly("1/Book/01.mp3", "1/Book/02.mp3")
        assertThat(first.tracks.none { it.hasMetadata }).isTrue()
        assertThat(first.complete).isFalse()
        assertThat(first.folderArtUri).isEqualTo("doc:root/Book/cover.jpg")

        val last = emissions.last()
        assertThat(last.complete).isTrue()
        assertThat(last.tracks.all { it.hasMetadata }).isTrue()
        assertThat(last.tracks.first { it.fileName == "01.mp3" }.metadata.title).isEqualTo("One")
        assertThat(last.scanned).isEqualTo(2)
        assertThat(last.total).isEqualTo(2)
    }

    @Test
    fun `second listing uses the metadata cache and emits once complete`() = runTest(UnconfinedTestDispatcher()) {
        scanner().listFolder(LibraryPath("1/Book")).toList()
        reader.reads.clear()
        val emissions = scanner().listFolder(LibraryPath("1/Book")).toList()
        assertThat(reader.reads).isEmpty()
        assertThat(emissions).hasSize(1)
        assertThat(emissions.single().complete).isTrue()
        assertThat(emissions.single().tracks.first { it.fileName == "01.mp3" }.metadata.album).isEqualTo("A")
    }

    @Test
    fun `changed file is read again`() = runTest(UnconfinedTestDispatcher()) {
        scanner().listFolder(LibraryPath("1/Book")).toList()
        reader.reads.clear()
        docs.file("Book/02.mp3", modified = 99)
        scanner().listFolder(LibraryPath("1/Book")).toList()
        assertThat(reader.reads).containsExactly("doc:root/Book/02.mp3")
    }

    @Test
    fun `tracks under a folder are recursive with metadata and skip hidden folders`() = runTest(UnconfinedTestDispatcher()) {
        val tracks = scanner().tracksUnder(LibraryPath("1/Book"))
        assertThat(tracks.map { it.path.value }).containsExactly("1/Book/01.mp3", "1/Book/02.mp3", "1/Book/CD2/01.mp3")
        assertThat(tracks.all { it.hasMetadata }).isTrue()
    }

    @Test
    fun `resolves a nested path to its document`() = runTest(UnconfinedTestDispatcher()) {
        assertThat(scanner().resolve(LibraryPath("1/Book/CD2/01.mp3"))?.uri).isEqualTo("doc:root/Book/CD2/01.mp3")
        assertThat(scanner().resolve(LibraryPath("1"))?.uri).isEqualTo("doc:root")
        assertThat(scanner().resolve(LibraryPath("1/Nope"))).isNull()
        assertThat(scanner().resolve(LibraryPath("2/Book"))).isNull()
    }

    @Test
    fun `listing is reused within one scanner`() = runTest(UnconfinedTestDispatcher()) {
        val scanner = scanner()
        scanner.resolve(LibraryPath("1/Book/CD2/01.mp3"))
        val calls = docs.listCalls
        scanner.resolve(LibraryPath("1/Book/02.mp3"))
        assertThat(docs.listCalls).isEqualTo(calls)
        scanner.invalidate(LibraryPath("1/Book"))
        scanner.resolve(LibraryPath("1/Book/02.mp3"))
        assertThat(docs.listCalls).isGreaterThan(calls)
    }
}

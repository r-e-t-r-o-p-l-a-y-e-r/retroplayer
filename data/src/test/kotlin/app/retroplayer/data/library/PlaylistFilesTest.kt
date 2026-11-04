package app.retroplayer.data.library

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.domain.LibraryPath
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class PlaylistFilesTest {
    private lateinit var db: RetroDatabase
    private lateinit var store: LibraryStore
    private val docs = FakeDocumentSource()
    private lateinit var scanner: LibraryScanner
    private lateinit var playlists: PlaylistFiles
    private var canWrite = true

    @Before
    fun setUp() {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        store = LibraryStore(db)
        docs.file("Mix/a.mp3")
        docs.file("Mix/Album/b.mp3")
        docs.file("Mix/Disk.m3u", "#EXTM3U\na.mp3\nhttps://x/y.mp3\ngone.mp3\n".toByteArray())
        scanner = LibraryScanner(docs, FakeMetadataReader(), db.trackCacheDao(), rootUri = { "doc:root" }, ioDispatcher = UnconfinedTestDispatcher())
        playlists = PlaylistFiles(docs, scanner, store, canWrite = { canWrite }, absolute = { null })
    }

    @After
    fun tearDown() = db.close()

    @Test
    fun `reading a playlist from disk marks missing entries and drops remote ones`() = runTest(UnconfinedTestDispatcher()) {
        val content = playlists.read(LibraryPath("1/Mix/Disk.m3u"))
        assertThat(content.entries.map { it.path.value }).containsExactly("1/Mix/a.mp3", "1/Mix/gone.mp3").inOrder()
        assertThat(content.entries.map { it.track != null }).containsExactly(true, false).inOrder()
        assertThat(content.editable).isFalse()
    }

    @Test
    fun `saving creates a relative m3u and registers it as editable`() = runTest(UnconfinedTestDispatcher()) {
        val result = playlists.save(LibraryPath("1/Mix"), "Road Trip", listOf(LibraryPath("1/Mix/Album/b.mp3"), LibraryPath("1/Mix/a.mp3")))
        assertThat(result).isEqualTo(SaveResult.Saved(LibraryPath("1/Mix/Road Trip.m3u")))
        assertThat(docs.text("Mix/Road Trip.m3u")).isEqualTo("#EXTM3U\nAlbum/b.mp3\na.mp3\n")
        assertThat(playlists.read(LibraryPath("1/Mix/Road Trip.m3u")).editable).isTrue()
    }

    @Test
    fun `saving without write access asks for it and writes nothing`() = runTest(UnconfinedTestDispatcher()) {
        canWrite = false
        assertThat(playlists.save(LibraryPath("1/Mix"), "X", listOf(LibraryPath("1/Mix/a.mp3")))).isEqualTo(SaveResult.NeedsWriteAccess("1"))
        assertThat(scanner.resolve(LibraryPath("1/Mix/X.m3u"))).isNull()
    }

    @Test
    fun `saving refuses an existing name and invalid names`() = runTest(UnconfinedTestDispatcher()) {
        assertThat(playlists.save(LibraryPath("1/Mix"), "Disk", emptyList())).isEqualTo(SaveResult.NameTaken)
        assertThat(playlists.save(LibraryPath("1/Mix"), "  ", emptyList())).isEqualTo(SaveResult.InvalidName)
        assertThat(playlists.save(LibraryPath("1/Mix"), "a/b", emptyList())).isEqualTo(SaveResult.InvalidName)
    }

    @Test
    fun `only app created playlists can be overwritten or deleted`() = runTest(UnconfinedTestDispatcher()) {
        assertThat(playlists.overwrite(LibraryPath("1/Mix/Disk.m3u"), emptyList())).isFalse()
        assertThat(playlists.delete(LibraryPath("1/Mix/Disk.m3u"))).isFalse()

        playlists.save(LibraryPath("1/Mix"), "Mine", listOf(LibraryPath("1/Mix/a.mp3")))
        assertThat(playlists.overwrite(LibraryPath("1/Mix/Mine.m3u"), listOf(LibraryPath("1/Mix/Album/b.mp3")))).isTrue()
        assertThat(docs.text("Mix/Mine.m3u")).isEqualTo("#EXTM3U\nAlbum/b.mp3\n")
        assertThat(playlists.delete(LibraryPath("1/Mix/Mine.m3u"))).isTrue()
        assertThat(store.isAppPlaylist(LibraryPath("1/Mix/Mine.m3u"))).isFalse()
    }
}

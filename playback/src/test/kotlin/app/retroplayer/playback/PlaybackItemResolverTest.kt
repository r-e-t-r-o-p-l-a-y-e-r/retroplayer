package app.retroplayer.playback

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.data.library.FakeDocumentSource
import app.retroplayer.data.library.FakeMetadataReader
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.Locale

@RunWith(RobolectricTestRunner::class)
class PlaybackItemResolverTest {
    private lateinit var db: RetroDatabase
    private lateinit var resolver: PlaybackItemResolver
    private lateinit var rootId: String
    private val docs = FakeDocumentSource()
    private var queue = emptyList<LibraryPath>()

    private fun p(relative: String) = LibraryPath("$rootId/$relative")

    @Before
    fun setUp() = runTest {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        val store = LibraryStore(db)
        rootId = store.addRoot("content://tree/music", "Music", canWrite = false)
        docs.file("Book/01.mp3")
        docs.file("Book/02.mp3")
        docs.file("Book/Extra/03.mp3")
        docs.file("Lists/mix.m3u", "../Book/02.mp3\nmissing.mp3\n../Book/01.mp3\n".toByteArray())
        val scanner = LibraryScanner(docs, FakeMetadataReader(), db.trackCacheDao(), { if (it == rootId) "doc:root" else null }, UnconfinedTestDispatcher())
        val repository = LibraryRepository(store, scanner) { Locale.ENGLISH }
        val playlists = PlaylistFiles(docs, scanner, store, canWrite = { false }, absolute = { null })
        resolver = PlaybackItemResolver(repository, scanner, playlists) { queue }
    }

    @After
    fun tearDown() = db.close()

    @Test
    fun `album id resolves to the album in its effective order`() = runTest(UnconfinedTestDispatcher()) {
        val item = resolver.resolve(AlbumIds.folder(p("Book"))) as PlaybackItem.Album
        assertThat(item.tracks.map { it.fileName }).containsExactly("01.mp3", "02.mp3").inOrder()
    }

    @Test
    fun `folder id resolves to the folder walk`() = runTest(UnconfinedTestDispatcher()) {
        val item = resolver.resolve(PlaybackItem.folderId(p("Book"))) as PlaybackItem.Folder
        assertThat(item.tracks.map { it.fileName }).containsExactly("01.mp3", "02.mp3", "03.mp3").inOrder()
    }

    @Test
    fun `playlist id resolves to its existing entries in file order`() = runTest(UnconfinedTestDispatcher()) {
        val item = resolver.resolve(PlaybackItem.playlistId(p("Lists/mix.m3u"))) as PlaybackItem.Playlist
        assertThat(item.playlist.uri).isEqualTo("doc:root/Lists/mix.m3u")
        assertThat(item.tracks.map { it.fileName }).containsExactly("02.mp3", "01.mp3").inOrder()
    }

    @Test
    fun `queue id resolves the stored queue and skips missing files`() = runTest(UnconfinedTestDispatcher()) {
        queue = listOf(p("Book/Extra/03.mp3"), p("Book/gone.mp3"), p("Book/01.mp3"))
        val item = resolver.resolve(PlaybackItem.QUEUE_ID) as PlaybackItem.Queue
        assertThat(item.tracks.map { it.fileName }).containsExactly("03.mp3", "01.mp3").inOrder()
    }

    @Test
    fun `track path resolves to a single track`() = runTest(UnconfinedTestDispatcher()) {
        val item = resolver.resolve(p("Book/02.mp3").value) as PlaybackItem.Single
        assertThat(item.track.uri).isEqualTo("doc:root/Book/02.mp3")
    }

    @Test
    fun `unknown ids resolve to nothing`() = runTest(UnconfinedTestDispatcher()) {
        assertThat(resolver.resolve(p("Book/nope.mp3").value)).isNull()
        assertThat(resolver.resolve(p("Book").value)).isNull()
        assertThat(resolver.resolve(PlaybackItem.folderId(p("Nope")))).isNull()
        assertThat(resolver.resolve("999/x.mp3")).isNull()
    }
}

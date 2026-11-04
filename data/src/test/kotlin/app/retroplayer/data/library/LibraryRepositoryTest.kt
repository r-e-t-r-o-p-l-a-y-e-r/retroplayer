package app.retroplayer.data.library

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.db.RetroDatabase
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.TrackMetadata
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.last
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.Locale

@RunWith(RobolectricTestRunner::class)
class LibraryRepositoryTest {
    private lateinit var db: RetroDatabase
    private lateinit var store: LibraryStore
    private val docs = FakeDocumentSource()
    private val reader = FakeMetadataReader(
        mapOf(
            "b.mp3" to TrackMetadata(album = "Alb", trackNumber = 1),
            "a.mp3" to TrackMetadata(album = "Alb", trackNumber = 2),
        ),
    )
    private lateinit var rootId: String

    private lateinit var scanner: LibraryScanner

    private fun repository(): LibraryRepository {
        scanner = LibraryScanner(docs, reader, db.trackCacheDao(), rootUri = { if (it == rootId) "doc:root" else null }, ioDispatcher = UnconfinedTestDispatcher())
        return LibraryRepository(store, scanner, locale = { Locale.ENGLISH })
    }

    private suspend fun watchedPlaylists(changed: LibraryPath) = coroutineScope {
        val repository = repository()
        val latest = MutableStateFlow<FolderView?>(null)
        val watching = launch { repository.watchFolder(p("Solo")).collect { latest.value = it } }
        val playlists = { view: FolderView? -> view?.items?.filterIsInstance<LibraryItem.Playlist>()?.map { it.playlist.path } }
        assertThat(playlists(latest.first { it != null })).isEmpty()
        docs.file("Solo/Mix.m3u")
        scanner.invalidate(changed)
        val found = playlists(latest.first { !playlists(it).isNullOrEmpty() })
        watching.cancel()
        found
    }

    @Test
    fun `a watched folder lists again when the app changes it`() = runTest {
        assertThat(watchedPlaylists(changed = p("Solo"))).containsExactly(p("Solo/Mix.m3u"))
    }

    @Test
    fun `a change above a watched folder lists it again`() = runTest {
        assertThat(watchedPlaylists(changed = LibraryPath.root(rootId))).containsExactly(p("Solo/Mix.m3u"))
    }

    @Before
    fun setUp() = runTest {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        store = LibraryStore(db)
        rootId = store.addRoot("content://tree/music", "Music", canWrite = false)
        listOf("CD10", "CD2", "CD1").forEach { docs.file("Book/$it/01.mp3") }
        docs.file("Mix/Alb/a.mp3")
        docs.file("Mix/Alb/b.mp3")
        docs.file("Mix/loose 10.mp3")
        docs.file("Mix/loose 2.mp3")
        docs.file("Mix/List.m3u")
        docs.file("Solo/01.mp3")
        docs.file("Solo/02.mp3")
    }

    @After
    fun tearDown() = db.close()

    private fun p(relative: String) = LibraryPath("$rootId/$relative")

    @Test
    fun `folder view sorts folders naturally and groups items with playlists last`() = runTest(UnconfinedTestDispatcher()) {
        val book = repository().folder(p("Book")).last()
        assertThat(book.folders.map { it.path.name }).containsExactly("CD1", "CD2", "CD10").inOrder()

        val mix = repository().folder(p("Mix")).last()
        assertThat(mix.complete).isTrue()
        assertThat(mix.folders.map { it.path.name }).containsExactly("Alb")
        assertThat(mix.items.map { it.title }).containsExactly("Mix", "List").inOrder()
        assertThat(mix.items.last()).isInstanceOf(LibraryItem.Playlist::class.java)

        docs.file("Single/only.mp3")
        val single = repository().folder(p("Single")).last()
        assertThat(single.items.single()).isInstanceOf(LibraryItem.Track::class.java)
    }

    @Test
    fun `folder view tells a missing folder from an empty one`() = runTest(UnconfinedTestDispatcher()) {
        docs.dir("Empty")
        assertThat(repository().folder(p("Empty")).last().exists).isTrue()
        assertThat(repository().folder(p("Gone")).last().exists).isFalse()
    }

    @Test
    fun `folder album at the root level takes the root display name as artist`() = runTest(UnconfinedTestDispatcher()) {
        val solo = repository().folder(p("Solo")).last()
        val album = (solo.items.single() as LibraryItem.Album).album
        assertThat(album.title).isEqualTo("Solo")
        assertThat(album.artist).isEqualTo("Music")
    }

    @Test
    fun `album is found by id in a fresh repository`() = runTest(UnconfinedTestDispatcher()) {
        val albumId = (repository().folder(p("Mix/Alb")).last().items.single() as LibraryItem.Album).id
        val album = repository().album(albumId)
        assertThat(album?.title).isEqualTo("Alb")
        assertThat(album?.tracks).hasSize(2)
        assertThat(repository().album("dir:$rootId/Nope")).isNull()
    }

    @Test
    fun `album of a track is the album it is listed in`() = runTest(UnconfinedTestDispatcher()) {
        val repo = repository()
        val alb = (repo.folder(p("Mix/Alb")).last().items.single() as LibraryItem.Album).id
        assertThat(repository().albumOf(p("Mix/Alb/a.mp3"))).isEqualTo(alb)
        assertThat(repository().albumOf(p("Mix/loose 2.mp3"))).isNotNull()

        docs.file("Single/only.mp3")
        assertThat(repository().albumOf(p("Single/only.mp3"))).isNull()
        assertThat(repository().albumOf(p("Gone/x.mp3"))).isNull()
    }

    @Test
    fun `album tracks follow the stored sort choice`() = runTest(UnconfinedTestDispatcher()) {
        val repo = repository()
        val album = (repo.folder(p("Mix/Alb")).last().items.single() as LibraryItem.Album).album
        assertThat(repo.albumTracks(album).map { it.fileName }).containsExactly("b.mp3", "a.mp3").inOrder()
        store.setAlbumSort(album.id, AlbumSortChoice.FILE_NAME)
        assertThat(repo.albumTracks(album).map { it.fileName }).containsExactly("a.mp3", "b.mp3").inOrder()
    }

    @Test
    fun `folder queue walks depth first in display order with stored choices`() = runTest(UnconfinedTestDispatcher()) {
        val repo = repository()
        assertThat(repo.folderQueue(p("Book")).map { it.path.value.removePrefix("$rootId/") })
            .containsExactly("Book/CD1/01.mp3", "Book/CD2/01.mp3", "Book/CD10/01.mp3").inOrder()
        assertThat(repo.folderQueue(p("Mix")).map { it.fileName })
            .containsExactly("loose 2.mp3", "loose 10.mp3", "b.mp3", "a.mp3").inOrder()
    }
}

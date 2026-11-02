package app.retroplayer.data.db

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.SavedPlaybackState
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RetroDatabaseTest {
    private lateinit var db: RetroDatabase
    private lateinit var library: LibraryStore

    @Before
    fun setUp() {
        db = Room.inMemoryDatabaseBuilder(ApplicationProvider.getApplicationContext(), RetroDatabase::class.java)
            .allowMainThreadQueries().build()
        library = LibraryStore(db)
    }

    @After
    fun tearDown() = db.close()

    @Test
    fun `roots are listed in insertion order and a duplicate tree updates instead of adding`() = runTest {
        val a = library.addRoot("content://t/a", "Music", canWrite = false)
        val b = library.addRoot("content://t/b", "Books", canWrite = false)
        assertThat(library.addRoot("content://t/a", "Music", canWrite = true)).isEqualTo(a)
        val roots = library.roots.first()
        assertThat(roots.map { it.id }).containsExactly(a, b).inOrder()
        assertThat(roots.first().canWrite).isTrue()
    }

    @Test
    fun `removing a root forgets its favorites, playback states and album sorts`() = runTest {
        val id = library.addRoot("content://t/a", "Music", canWrite = false)
        val other = library.addRoot("content://t/b", "Books", canWrite = false)
        library.toggleFavorite(LibraryPath("$id/x"))
        library.toggleFavorite(LibraryPath("$other/y"))
        library.savePlayback("folder:$id/x", SavedPlaybackState("$id/x/1.mp3", 10))
        library.setAlbumSort("dir:$id/x", AlbumSortChoice.TITLE)

        library.removeRoot(id)

        assertThat(library.roots.first().map { it.id }).containsExactly(other)
        assertThat(library.favorites.first()).containsExactly(LibraryPath("$other/y"))
        assertThat(library.playback("folder:$id/x")).isNull()
        assertThat(library.albumSort("dir:$id/x")).isEqualTo(AlbumSortChoice.AUTOMATIC)
    }

    @Test
    fun `favorites toggle and keep a user order`() = runTest {
        val a = LibraryPath("1/a")
        val b = LibraryPath("1/b")
        val c = LibraryPath("1/c")
        listOf(a, b, c).forEach { library.toggleFavorite(it) }
        assertThat(library.favorites.first()).containsExactly(a, b, c).inOrder()
        library.moveFavorite(from = 2, to = 0)
        assertThat(library.favorites.first()).containsExactly(c, a, b).inOrder()
        library.toggleFavorite(a)
        assertThat(library.favorites.first()).containsExactly(c, b).inOrder()
    }

    @Test
    fun `playback state round trips and normal speed is stored as null`() = runTest {
        library.savePlayback("queue", SavedPlaybackState("1/a.mp3", 5_000, 1.5f, "A", "Artist", 60_000))
        assertThat(library.playback("queue")).isEqualTo(SavedPlaybackState("1/a.mp3", 5_000, 1.5f, "A", "Artist", 60_000))
        library.savePlayback("queue", SavedPlaybackState("1/a.mp3", 6_000, 1f))
        assertThat(db.playbackDao().get("queue")!!.speed).isNull()
        assertThat(library.playback("queue")!!.speed).isEqualTo(1f)
    }

    @Test
    fun `album sort stores only non default choices`() = runTest {
        library.setAlbumSort("dir:1/a", AlbumSortChoice.TAG_FORCED)
        assertThat(library.albumSort("dir:1/a")).isEqualTo(AlbumSortChoice.TAG_FORCED)
        assertThat(db.albumSortDao().count()).isEqualTo(1)
        library.setAlbumSort("dir:1/a", AlbumSortChoice.AUTOMATIC)
        assertThat(db.albumSortDao().count()).isEqualTo(0)
        assertThat(library.albumSort("dir:1/a")).isEqualTo(AlbumSortChoice.AUTOMATIC)
    }

    @Test
    fun `app created playlists are registered and forgotten`() = runTest {
        val path = LibraryPath("1/Mix.m3u")
        assertThat(library.isAppPlaylist(path)).isFalse()
        library.registerAppPlaylist(path)
        assertThat(library.isAppPlaylist(path)).isTrue()
        library.forgetAppPlaylist(path)
        assertThat(library.isAppPlaylist(path)).isFalse()
    }

    @Test
    fun `reset keeps or clears roots`() = runTest {
        val id = library.addRoot("content://t/a", "Music", canWrite = false)
        library.toggleFavorite(LibraryPath("$id/x"))
        library.savePlayback("queue", SavedPlaybackState("$id/a.mp3", 1))
        library.reset(keepRoots = true)
        assertThat(library.roots.first()).hasSize(1)
        assertThat(library.favorites.first()).isEmpty()
        assertThat(library.playback("queue")).isNull()
        library.reset(keepRoots = false)
        assertThat(library.roots.first()).isEmpty()
    }
}

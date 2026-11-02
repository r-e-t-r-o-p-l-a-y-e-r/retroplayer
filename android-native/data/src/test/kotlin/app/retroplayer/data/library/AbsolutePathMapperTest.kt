package app.retroplayer.data.library

import app.retroplayer.domain.LibraryPath
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class AbsolutePathMapperTest {
    private val external = "com.android.externalstorage.documents"
    private val roots = listOf(
        RootLocation(rootId = "1", authority = external, treeDocumentId = "primary:Music"),
        RootLocation(rootId = "2", authority = external, treeDocumentId = "1A2B-3C4D:Audiobooks/Kids"),
        RootLocation(rootId = "3", authority = "com.other.provider", treeDocumentId = "opaque-42"),
    )
    private val mapper = AbsolutePathMapper(roots)

    @Test
    fun `primary storage paths map to the matching root`() {
        assertThat(mapper.toLibraryPath("/storage/emulated/0/Music/Mix/a.mp3")).isEqualTo(LibraryPath("1/Mix/a.mp3"))
        assertThat(mapper.toLibraryPath("/sdcard/Music/b.mp3")).isEqualTo(LibraryPath("1/b.mp3"))
    }

    @Test
    fun `sd card volumes map by volume id`() {
        assertThat(mapper.toLibraryPath("/storage/1A2B-3C4D/Audiobooks/Kids/x/01.mp3")).isEqualTo(LibraryPath("2/x/01.mp3"))
    }

    @Test
    fun `paths outside every root or on opaque providers are unknown`() {
        assertThat(mapper.toLibraryPath("/storage/emulated/0/Podcasts/a.mp3")).isNull()
        assertThat(mapper.toLibraryPath("/storage/emulated/0/MusicVideos/a.mp3")).isNull()
        assertThat(mapper.toLibraryPath("opaque-42/a.mp3")).isNull()
    }

    @Test
    fun `primary root folder is suggested for the picker`() {
        assertThat(AbsolutePathMapper.absoluteFolder(external, "primary:Music")).isEqualTo("/storage/emulated/0/Music")
        assertThat(AbsolutePathMapper.absoluteFolder(external, "primary:")).isEqualTo("/storage/emulated/0")
        assertThat(AbsolutePathMapper.absoluteFolder("x", "primary:Music")).isNull()
    }

    @Test
    fun `root location is shown relative to internal storage`() {
        val tree = "content://$external/tree/"
        assertThat(AbsolutePathMapper.displayLocation(tree + "primary%3AMusic")).isEqualTo("/Music")
        assertThat(AbsolutePathMapper.displayLocation(tree + "primary%3AAudio%2FBooks%20%2B%20Kids")).isEqualTo("/Audio/Books + Kids")
        assertThat(AbsolutePathMapper.displayLocation(tree + "primary%3A")).isEqualTo("/")
        assertThat(AbsolutePathMapper.displayLocation(tree + "1A2B-3C4D%3AAudiobooks")).isEqualTo("/storage/1A2B-3C4D/Audiobooks")
        assertThat(AbsolutePathMapper.displayLocation("content://com.other.provider/tree/opaque-42")).isNull()
        assertThat(AbsolutePathMapper.displayLocation("not a uri")).isNull()
    }
}

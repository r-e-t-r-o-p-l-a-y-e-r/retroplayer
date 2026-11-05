package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import com.google.common.truth.Truth.assertWithMessage
import org.junit.Test

class SupportedFormatsTest {
    @Test
    fun `audio formats including ogg and opus are supported case insensitively`() {
        listOf("a.mp3", "b.M4A", "c.m4b", "d.flac", "e.wav", "f.ogg", "g.OPUS")
            .forEach { assertWithMessage(it).that(SupportedFormats.isAudio(it)).isTrue() }
    }

    @Test
    fun `other files are not audio`() {
        listOf("cover.jpg", "notes.txt", "list.m3u", "mp3", "noext")
            .forEach { assertWithMessage(it).that(SupportedFormats.isAudio(it)).isFalse() }
    }

    @Test
    fun `m3u and m3u8 are playlists`() {
        assertThat(SupportedFormats.isPlaylist("Mix.M3U")).isTrue()
        assertThat(SupportedFormats.isPlaylist("mix.m3u8")).isTrue()
        assertThat(SupportedFormats.isPlaylist("mix.pls")).isFalse()
    }

    @Test
    fun `folder art names are recognised in preference order`() {
        assertThat(SupportedFormats.isImage("Cover.JPG")).isTrue()
        assertThat(SupportedFormats.isImage("x.gif")).isTrue()
        assertThat(SupportedFormats.isImage("x.mp3")).isFalse()
        val picked = SupportedFormats.preferredFolderArt(listOf("scan.png", "Folder.jpg", "cover.webp"))
        assertThat(picked).isEqualTo("cover.webp")
        assertThat(SupportedFormats.preferredFolderArt(listOf("scan.png", "notes.txt"))).isEqualTo("scan.png")
        assertThat(SupportedFormats.preferredFolderArt(listOf("notes.txt"))).isNull()
    }
}

package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import com.google.common.truth.Truth.assertWithMessage
import org.junit.Test

class LocalPathPolicyTest {
    @Test
    fun `accepts absolute and relative filesystem paths`() {
        assertThat(LocalPathPolicy.isLocal("/music/track.mp3")).isTrue()
        assertThat(LocalPathPolicy.isLocal("album/track.flac")).isTrue()
        assertThat(LocalPathPolicy.isLocal("C:\\Music\\track.mp3")).isTrue()
    }

    @Test
    fun `accepts file URIs`() {
        assertThat(LocalPathPolicy.isLocal("file:///music/track.mp3")).isTrue()
    }

    @Test
    fun `rejects remote and streaming schemes`() {
        listOf(
            "https://example.com/a.mp3",
            "http://cdn/x.mp3",
            "rtsp://cam/stream",
            "ftp://host/a.mp3",
            "smb://nas/a.mp3",
            "content://evil/a.mp3",
            "HTTPS://EXAMPLE.COM/A.MP3",
        ).forEach { assertWithMessage(it).that(LocalPathPolicy.isLocal(it)).isFalse() }
    }

    @Test
    fun `rejects empty`() {
        assertThat(LocalPathPolicy.isLocal("")).isFalse()
        assertThat(LocalPathPolicy.isLocal("   ")).isFalse()
    }
}

package app.retroplayer.playback

import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import androidx.media3.test.utils.TestExoPlayerBuilder
import androidx.media3.test.utils.robolectric.TestPlayerRunHelper.advance
import androidx.test.core.app.ApplicationProvider
import com.google.common.truth.Truth.assertThat
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class NowPlayingSnapshotTest {
    private lateinit var exo: ExoPlayer

    @Before
    fun setUp() {
        exo = TestExoPlayerBuilder(ApplicationProvider.getApplicationContext()).setMediaSourceFactory(FakeMediaSourceFactory()).build()
    }

    @After
    fun tearDown() = exo.release()

    private fun load(metadata: MediaMetadata) {
        exo.setMediaItem(MediaItem.Builder().setMediaId("1/a.mp3").setUri("doc:a").setMediaMetadata(metadata).build())
        exo.prepare()
        advance(exo).untilState(Player.STATE_READY)
    }

    @Test
    fun `nothing loaded is an empty paused snapshot`() {
        assertThat(NowPlayingSnapshot.of(exo)).isEqualTo(NowPlayingSnapshot())
    }

    @Test
    fun `takes title, artist and artwork of the current track`() {
        load(MediaMetadata.Builder().setTitle("Song").setArtist("Band").setAlbumTitle("Album").setArtworkUri(android.net.Uri.parse("doc:cover")).build())
        assertThat(NowPlayingSnapshot.of(exo)).isEqualTo(NowPlayingSnapshot("Song", "Band", isPlaying = false, artUri = "doc:cover"))
    }

    @Test
    fun `falls back to the album without an artist`() {
        load(MediaMetadata.Builder().setTitle("Song").setAlbumTitle("Album").build())
        assertThat(NowPlayingSnapshot.of(exo).subtitle).isEqualTo("Album")
    }

    @Test
    fun `playing once play is requested`() {
        load(MediaMetadata.Builder().setTitle("Song").build())
        exo.play()
        assertThat(NowPlayingSnapshot.of(exo).isPlaying).isTrue()
    }
}

package app.retroplayer.domain

import app.retroplayer.domain.model.SavedPlaybackState
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class PlaybackResumeTest {
    private val tracks = listOf(track("1/a/1.mp3"), track("1/a/2.mp3"), track("1/a/3.mp3"))

    @Test
    fun `starts at the beginning without saved state`() {
        val plan = PlaybackResume.resolve(tracks, saved = null)
        assertThat(plan.startIndex).isEqualTo(0)
        assertThat(plan.positionMs).isNull()
        assertThat(plan.speed).isNull()
        assertThat(plan.trackId).isEqualTo("1/a/1.mp3")
    }

    @Test
    fun `resumes saved track position and speed`() {
        val plan = PlaybackResume.resolve(tracks, SavedPlaybackState("1/a/2.mp3", positionMs = 42_000, speed = 1.5f))
        assertThat(plan.startIndex).isEqualTo(1)
        assertThat(plan.positionMs).isEqualTo(42_000)
        assertThat(plan.speed).isEqualTo(1.5f)
    }

    @Test
    fun `ignores a saved track that is no longer in the queue`() {
        val plan = PlaybackResume.resolve(tracks, SavedPlaybackState("1/a/gone.mp3", positionMs = 5_000, speed = 2f))
        assertThat(plan.startIndex).isEqualTo(0)
        assertThat(plan.positionMs).isNull()
        assertThat(plan.speed).isNull()
    }

    @Test
    fun `explicit start position overrides the saved position but keeps the track`() {
        val plan = PlaybackResume.resolve(tracks, SavedPlaybackState("1/a/3.mp3", 9_000, 1f), startPositionMs = 1_000)
        assertThat(plan.startIndex).isEqualTo(2)
        assertThat(plan.positionMs).isEqualTo(1_000)
    }

    @Test
    fun `zero or negative positions mean start of track`() {
        assertThat(PlaybackResume.resolve(tracks, SavedPlaybackState("1/a/2.mp3", 0, 1f)).positionMs).isNull()
    }

    @Test
    fun `empty queue has no track id`() {
        assertThat(PlaybackResume.resolve(emptyList(), null).trackId).isEmpty()
    }
}

package app.retroplayer.domain

import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.SavedPlaybackState

/** Where a queue starts; [speed] is only set when the saved track was found. */
data class ResumePlan(val startIndex: Int, val positionMs: Long?, val speed: Float?, val trackId: String)

object PlaybackResume {
    fun resolve(tracks: List<AudioTrack>, saved: SavedPlaybackState?, startPositionMs: Long? = null): ResumePlan {
        var index = 0
        var position = startPositionMs
        var speed: Float? = null
        if (saved != null) {
            val found = tracks.indexOfFirst { it.id == saved.trackId }
            if (found >= 0) {
                index = found
                position = position ?: saved.positionMs
                speed = saved.speed
            }
        }
        return ResumePlan(
            startIndex = index,
            positionMs = position?.takeIf { it > 0 },
            speed = speed,
            trackId = tracks.getOrNull(index)?.id.orEmpty(),
        )
    }
}

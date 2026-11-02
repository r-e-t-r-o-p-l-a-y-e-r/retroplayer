package app.retroplayer.domain

import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.TrackMetadata

fun track(
    path: String,
    title: String? = null,
    album: String? = null,
    artist: String? = null,
    albumArtist: String? = null,
    composer: String? = null,
    trackNumber: Int? = null,
    discNumber: Int? = null,
    durationMs: Long? = null,
) = AudioTrack(
    path = LibraryPath(path),
    uri = "content://test/$path",
    metadata = TrackMetadata(
        title = title,
        artist = artist,
        album = album,
        albumArtist = albumArtist,
        composer = composer,
        trackNumber = trackNumber,
        discNumber = discNumber,
        durationMs = durationMs,
    ),
)

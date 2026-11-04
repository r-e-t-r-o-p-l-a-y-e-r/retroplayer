package app.retroplayer.data.saf

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import app.retroplayer.data.library.MetadataReader
import app.retroplayer.domain.model.TrackMetadata

/** Tags via the platform [MediaMetadataRetriever]; works for every format the app plays. */
class RetrieverMetadataReader(private val context: Context) : MetadataReader {
    override suspend fun read(uri: String): TrackMetadata? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(context, Uri.parse(uri))
            fun get(key: Int) = retriever.extractMetadata(key)?.takeIf { it.isNotBlank() }
            TrackMetadata(
                title = get(MediaMetadataRetriever.METADATA_KEY_TITLE),
                artist = get(MediaMetadataRetriever.METADATA_KEY_ARTIST),
                album = get(MediaMetadataRetriever.METADATA_KEY_ALBUM),
                albumArtist = get(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST),
                composer = get(MediaMetadataRetriever.METADATA_KEY_COMPOSER) ?: get(MediaMetadataRetriever.METADATA_KEY_WRITER),
                trackNumber = leadingNumber(get(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)),
                discNumber = leadingNumber(get(MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER)),
                year = year(get(MediaMetadataRetriever.METADATA_KEY_YEAR), get(MediaMetadataRetriever.METADATA_KEY_DATE)),
                genre = get(MediaMetadataRetriever.METADATA_KEY_GENRE),
                durationMs = get(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull()?.takeIf { it > 0 },
            )
        } catch (_: RuntimeException) {
            null
        } finally {
            runCatching { retriever.release() }
        }
    }

    companion object {
        /** `3`, `03/12`, ` 1 / 2 ` → leading positive number. */
        fun leadingNumber(value: String?): Int? =
            value?.trim()?.substringBefore('/')?.trim()?.toIntOrNull()?.takeIf { it > 0 }

        fun year(year: String?, date: String?): Int? =
            (year?.trim()?.toIntOrNull() ?: date?.trim()?.take(4)?.toIntOrNull())?.takeIf { it in 1..9999 }
    }
}

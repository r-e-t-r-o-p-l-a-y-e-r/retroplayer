package app.retroplayer.ui.art

import android.content.Context
import android.media.MediaMetadataRetriever
import androidx.core.net.toUri
import coil3.ImageLoader
import coil3.decode.DataSource
import coil3.decode.ImageSource
import coil3.fetch.FetchResult
import coil3.fetch.Fetcher
import coil3.fetch.SourceFetchResult
import coil3.key.Keyer
import coil3.request.Options
import okio.Buffer
import okio.FileSystem

/** Cover picture embedded in an audio document. */
data class EmbeddedArt(val audioUri: String)

class EmbeddedArtFetcher(private val context: Context, private val art: EmbeddedArt) : Fetcher {
    override suspend fun fetch(): FetchResult? {
        val bytes = MediaMetadataRetriever().run {
            try {
                setDataSource(context, art.audioUri.toUri())
                embeddedPicture
            } catch (_: RuntimeException) {
                null
            } finally {
                release()
            }
        } ?: return null
        return SourceFetchResult(
            source = ImageSource(Buffer().write(bytes), FileSystem.SYSTEM),
            mimeType = null,
            dataSource = DataSource.DISK,
        )
    }

    class Factory(private val context: Context) : Fetcher.Factory<EmbeddedArt> {
        override fun create(data: EmbeddedArt, options: Options, imageLoader: ImageLoader): Fetcher =
            EmbeddedArtFetcher(context, data)
    }
}

class EmbeddedArtKeyer : Keyer<EmbeddedArt> {
    override fun key(data: EmbeddedArt, options: Options): String = "embedded:${data.audioUri}"
}

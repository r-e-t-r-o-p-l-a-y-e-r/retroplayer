package app.retroplayer.playback

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.media3.common.util.BitmapLoader
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSourceBitmapLoader
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.ListeningExecutorService
import com.google.common.util.concurrent.MoreExecutors
import java.util.concurrent.Executors

/** Loads artwork files as usual, and audio documents through their embedded picture. */
@UnstableApi
class EmbeddedArtBitmapLoader(private val context: Context) : BitmapLoader {
    private val executor: ListeningExecutorService = MoreExecutors.listeningDecorator(Executors.newSingleThreadExecutor())
    private val files = DataSourceBitmapLoader.Builder(context).setExecutorService(executor).build()

    override fun supportsMimeType(mimeType: String): Boolean = files.supportsMimeType(mimeType)

    override fun decodeBitmap(data: ByteArray): ListenableFuture<Bitmap> = files.decodeBitmap(data)

    override fun loadBitmap(uri: Uri): ListenableFuture<Bitmap> {
        val type = runCatching { context.contentResolver.getType(uri) }.getOrNull()
        if (type?.startsWith("audio/") != true) return files.loadBitmap(uri)
        return executor.submit<Bitmap> {
            val bytes = MediaMetadataRetriever().run {
                try {
                    setDataSource(context, uri)
                    embeddedPicture
                } finally {
                    release()
                }
            } ?: error("no embedded picture")
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: error("undecodable picture")
        }
    }
}

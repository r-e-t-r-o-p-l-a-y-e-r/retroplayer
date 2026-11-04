package app.retroplayer.data.saf

import android.content.ContentResolver
import android.net.Uri
import app.retroplayer.data.chapters.ByteSource
import app.retroplayer.data.chapters.ChapterSource
import app.retroplayer.data.chapters.Mp4ChapterReader
import app.retroplayer.domain.model.Chapter
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext
import java.io.FileInputStream

/** Opens the document read only and parses only the MP4 boxes that hold chapters. */
class SafChapterSource(private val resolver: ContentResolver, private val io: CoroutineDispatcher) : ChapterSource {
    override suspend fun read(uri: String): List<Chapter> = withContext(io) {
        val descriptor = resolver.openFileDescriptor(Uri.parse(uri), "r") ?: error("cannot open $uri")
        descriptor.use { pfd ->
            FileInputStream(pfd.fileDescriptor).channel.use { Mp4ChapterReader.read(ByteSource.of(it)) }
        }
    }
}

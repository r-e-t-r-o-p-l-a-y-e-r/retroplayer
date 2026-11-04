package app.retroplayer.playback

import android.content.ComponentName
import android.content.Context
import androidx.annotation.OptIn
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.guava.await
import javax.inject.Inject

/** Provides the player the UI drives; null when the service cannot be reached. */
fun interface PlayerConnector {
    suspend fun connect(): Player?
}

class MediaControllerConnector @Inject constructor(@ApplicationContext private val context: Context) : PlayerConnector {
    @OptIn(UnstableApi::class)
    override suspend fun connect(): Player? {
        val token = SessionToken(context, ComponentName(context, PlaybackService::class.java))
        return runCatching { MediaController.Builder(context, token).buildAsync().await() }.getOrNull()
    }
}

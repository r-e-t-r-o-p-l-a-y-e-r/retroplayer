package app.retroplayer.playback

import android.app.PendingIntent
import android.content.Intent
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import androidx.core.net.toUri
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.analytics.AnalyticsListener
import androidx.media3.session.LibraryResult
import androidx.media3.session.MediaLibraryService
import androidx.media3.session.MediaSession
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionResult
import app.retroplayer.data.chapters.ChapterRepository
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.Chapter
import app.retroplayer.domain.settings.HeadsetSettings
import com.google.common.collect.ImmutableList
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.guava.future
import kotlinx.coroutines.launch
import javax.inject.Inject

@UnstableApi
@AndroidEntryPoint
class PlaybackService : MediaLibraryService() {
    @Inject lateinit var resolver: PlaybackItemResolver
    @Inject lateinit var store: LibraryStore
    @Inject lateinit var settings: SettingsStore
    @Inject lateinit var repository: LibraryRepository
    @Inject @ApplicationScope lateinit var appScope: CoroutineScope
    @Inject lateinit var equalizerAvailability: EqualizerAvailability
    @Inject lateinit var treeLabels: TreeLabels
    @Inject lateinit var chapterLabels: ChapterLabels
    @Inject lateinit var chapterRepository: ChapterRepository
    @Inject lateinit var nowPlayingSink: NowPlayingSink

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var session: MediaLibrarySession? = null
    private lateinit var player: RetroPlayer
    private lateinit var saver: ProgressSaver
    private lateinit var queue: SessionQueue
    private lateinit var equalizer: EqualizerBinder
    private lateinit var tree: LibraryTree
    private lateinit var chapterTracker: ChapterTracker
    private lateinit var outputs: AudioDeviceCallback

    @Volatile private var headset = HeadsetSettings()

    override fun onCreate() {
        super.onCreate()
        val exo = ExoPlayer.Builder(this)
            .setAudioAttributes(
                AudioAttributes.Builder().setUsage(C.USAGE_MEDIA).setContentType(C.AUDIO_CONTENT_TYPE_MUSIC).build(),
                true,
            )
            .setHandleAudioBecomingNoisy(true)
            .setWakeMode(C.WAKE_MODE_LOCAL)
            .build()
        equalizer = EqualizerBinder(AudioFxEqualizer::createOrNull, equalizerAvailability::report)
        exo.addAnalyticsListener(
            object : AnalyticsListener {
                override fun onAudioSessionIdChanged(eventTime: AnalyticsListener.EventTime, audioSessionId: Int) =
                    equalizer.onSession(audioSessionId)
            },
        )
        equalizer.onSession(exo.audioSessionId)
        chapterTracker = ChapterTracker(exo, scope, ::chaptersOf) { chapters ->
            session?.setMediaButtonPreferences(ChapterCommands.buttons(chapters, chapterLabels))
        }
        player = RetroPlayer(exo, AutoRewindTracker(SystemClock::elapsedRealtime), { headset }) {
            chapterTracker.chapters.map { it.startMs }
        }
        val reconnect = ReconnectWatcher(SystemClock::elapsedRealtime, { headset.resumeOnReconnect }, player::play)
        exo.addListener(
            object : Player.Listener {
                override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) =
                    reconnect.onPlayWhenReadyChanged(playWhenReady, reason)
            },
        )
        outputs = object : AudioDeviceCallback() {
            override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) =
                reconnect.onOutputsAdded(addedDevices.filter { it.isSink }.map { it.type })
        }
        getSystemService(AudioManager::class.java).registerAudioDeviceCallback(outputs, Handler(Looper.getMainLooper()))
        player.addListener(
            object : Player.Listener {
                override fun onEvents(player: Player, events: Player.Events) = nowPlayingSink.update(NowPlayingSnapshot.of(player))
            },
        )
        saver = ProgressSaver(player, appScope) { id, state -> store.savePlayback(id, state) }
        saver.start()
        queue = SessionQueue(
            items = resolver::resolve,
            savedState = store::playback,
            lastItemId = { settings.session.first().lastItemId },
            rememberLastItem = settings::setLastItem,
            artwork = ::artworkFor,
            rootNames = { store.allRoots().associate { it.id to it.name } },
        )
        tree = LibraryTree(
            roots = { store.allRoots().map { it.path to it.name } },
            favorites = { store.favorites.first() },
            folder = { path -> repository.folder(path).first { it.complete || !it.exists }.takeIf { it.exists } },
            albumTracks = { id -> repository.album(id)?.let { repository.albumTracks(it) } },
            labels = treeLabels,
        )
        session = MediaLibrarySession.Builder(this, player, Callback())
            .setBitmapLoader(EmbeddedArtBitmapLoader(this))
            .apply { launchIntent()?.let(::setSessionActivity) }
            .build()
        scope.launch {
            settings.settings.collect {
                headset = it.headset
                equalizer.onSettings(it.equalizer)
            }
        }
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaLibrarySession? = session

    override fun onTaskRemoved(rootIntent: Intent?) {
        saver.saveNow()
        pauseAllPlayersAndStopSelf()
    }

    override fun onDestroy() {
        getSystemService(AudioManager::class.java).unregisterAudioDeviceCallback(outputs)
        nowPlayingSink.update(NowPlayingSnapshot.of(player).copy(isPlaying = false))
        saver.saveNow()
        saver.stop()
        equalizer.release()
        session?.run {
            player.release()
            release()
        }
        session = null
        scope.cancel()
        super.onDestroy()
    }

    private suspend fun chaptersOf(item: MediaItem): List<Chapter> {
        val uri = PlaybackRequests.trackUriOf(item) ?: item.localConfiguration?.uri?.toString() ?: return emptyList()
        return chapterRepository.chapters(uri, LibraryPath(item.mediaId).name)
    }

    private fun artworkFor(track: AudioTrack): Uri =
        (repository.folderArt(track.directory) ?: track.uri).toUri()

    private fun launchIntent(): PendingIntent? {
        val intent = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        return PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun PreparedQueue.toResult(): MediaSession.MediaItemsWithStartPosition {
        speed?.let(player::setPlaybackSpeed)
        return MediaSession.MediaItemsWithStartPosition(mediaItems, startIndex, startPositionMs)
    }

    private inner class Callback : MediaLibrarySession.Callback {
        override fun onConnect(session: MediaSession, controller: MediaSession.ControllerInfo): MediaSession.ConnectionResult =
            MediaSession.ConnectionResult.AcceptedResultBuilder()
                .setAvailablePlayerCommands(MediaSession.ConnectionResult.DEFAULT_PLAYER_COMMANDS)
                .setAvailableSessionCommands(
                    ChapterCommands.addTo(MediaSession.ConnectionResult.DEFAULT_SESSION_AND_LIBRARY_COMMANDS),
                )
                .setMediaButtonPreferences(ChapterCommands.buttons(chapterTracker.chapters, chapterLabels))
                .build()

        override fun onCustomCommand(
            session: MediaSession,
            controller: MediaSession.ControllerInfo,
            customCommand: SessionCommand,
            args: Bundle,
        ): ListenableFuture<SessionResult> {
            val target = when (customCommand) {
                ChapterCommands.PREVIOUS -> chapterTracker.previousTarget()
                ChapterCommands.NEXT -> chapterTracker.nextTarget()
                else -> return super.onCustomCommand(session, controller, customCommand, args)
            }
            target?.let(player::seekTo)
            return Futures.immediateFuture(SessionResult(SessionResult.RESULT_SUCCESS))
        }

        override fun onSetMediaItems(
            mediaSession: MediaSession,
            controller: MediaSession.ControllerInfo,
            mediaItems: MutableList<MediaItem>,
            startIndex: Int,
            startPositionMs: Long,
        ): ListenableFuture<MediaSession.MediaItemsWithStartPosition> {
            val request = mediaItems.singleOrNull()?.takeIf { it.localConfiguration == null }?.let(PlaybackRequests::parse)
                ?: return super.onSetMediaItems(mediaSession, controller, mediaItems, startIndex, startPositionMs)
            saver.saveNow()
            return scope.future {
                (queue.prepare(request) ?: throw IllegalArgumentException("Nothing to play for ${request.itemId}")).toResult()
            }
        }

        override fun onAddMediaItems(
            mediaSession: MediaSession,
            controller: MediaSession.ControllerInfo,
            mediaItems: MutableList<MediaItem>,
        ): ListenableFuture<MutableList<MediaItem>> = scope.future {
            mediaItems.flatMap { item ->
                if (item.localConfiguration != null) {
                    listOf(item)
                } else {
                    queue.expand(listOf(item.mediaId), PlaybackRequests.additionTargetOf(item))
                }
            }.toMutableList()
        }

        override fun onPlaybackResumption(
            mediaSession: MediaSession,
            controller: MediaSession.ControllerInfo,
            isForPlayback: Boolean,
        ): ListenableFuture<MediaSession.MediaItemsWithStartPosition> = scope.future {
            (queue.resumption() ?: throw IllegalStateException("Nothing to resume")).toResult()
        }

        override fun onGetChildren(
            session: MediaLibrarySession,
            browser: MediaSession.ControllerInfo,
            parentId: String,
            page: Int,
            pageSize: Int,
            params: LibraryParams?,
        ): ListenableFuture<LibraryResult<ImmutableList<MediaItem>>> = scope.future {
            LibraryResult.ofItemList(tree.children(parentId, page, pageSize).map { it.toMediaItem() }, params)
        }

        override fun onGetItem(
            session: MediaLibrarySession,
            browser: MediaSession.ControllerInfo,
            mediaId: String,
        ): ListenableFuture<LibraryResult<MediaItem>> = Futures.immediateFuture(
            LibraryResult.ofItem(
                MediaItem.Builder()
                    .setMediaId(mediaId)
                    .setMediaMetadata(MediaMetadata.Builder().setIsBrowsable(false).setIsPlayable(true).build())
                    .build(),
                null,
            ),
        )

        override fun onGetLibraryRoot(
            session: MediaLibrarySession,
            browser: MediaSession.ControllerInfo,
            params: LibraryParams?,
        ): ListenableFuture<LibraryResult<MediaItem>> = Futures.immediateFuture(
            LibraryResult.ofItem(
                MediaItem.Builder()
                    .setMediaId(LibraryTree.ROOT_ID)
                    .setMediaMetadata(
                        MediaMetadata.Builder()
                            .setIsBrowsable(true)
                            .setIsPlayable(false)
                            .setMediaType(MediaMetadata.MEDIA_TYPE_FOLDER_MIXED)
                            .build(),
                    )
                    .build(),
                params,
            ),
        )
    }

    private fun TreeNode.toMediaItem(): MediaItem = MediaItem.Builder()
        .setMediaId(id)
        .setMediaMetadata(
            MediaMetadata.Builder()
                .setTitle(title)
                .setArtist(subtitle)
                .setIsBrowsable(browsable)
                .setIsPlayable(playable)
                .setMediaType(if (browsable) MediaMetadata.MEDIA_TYPE_FOLDER_MIXED else MediaMetadata.MEDIA_TYPE_MUSIC)
                .build(),
        )
        .build()
}

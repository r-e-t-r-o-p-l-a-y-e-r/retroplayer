package app.retroplayer.di

import app.retroplayer.library.RootAccess
import app.retroplayer.library.SafRootAccess
import app.retroplayer.playback.MediaControllerConnector
import app.retroplayer.playback.NowPlayingSink
import app.retroplayer.ui.widget.WidgetUpdater
import app.retroplayer.playback.PlaybackControls
import app.retroplayer.playback.PlayerConnection
import app.retroplayer.playback.PlayerConnector
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
interface BindingsModule {
    @Binds
    fun playbackControls(connection: PlayerConnection): PlaybackControls

    @Binds
    fun playerConnector(connector: MediaControllerConnector): PlayerConnector

    @Binds
    fun rootAccess(access: SafRootAccess): RootAccess

    @Binds
    fun nowPlayingSink(updater: WidgetUpdater): NowPlayingSink
}

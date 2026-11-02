package app.retroplayer.di

import app.retroplayer.library.RootAccess
import app.retroplayer.library.SafRootAccess
import app.retroplayer.playback.PlaybackControls
import app.retroplayer.playback.PlayerConnection
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
    fun rootAccess(access: SafRootAccess): RootAccess
}

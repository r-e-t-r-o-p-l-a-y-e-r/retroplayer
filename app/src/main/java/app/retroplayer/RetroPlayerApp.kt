package app.retroplayer

import android.app.Application
import app.retroplayer.ui.art.EmbeddedArtFetcher
import app.retroplayer.ui.art.EmbeddedArtKeyer
import coil3.ImageLoader
import coil3.PlatformContext
import coil3.SingletonImageLoader
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class RetroPlayerApp : Application(), SingletonImageLoader.Factory {
    override fun newImageLoader(context: PlatformContext): ImageLoader = ImageLoader.Builder(context)
        .components {
            add(EmbeddedArtFetcher.Factory(this@RetroPlayerApp))
            add(EmbeddedArtKeyer())
        }
        .build()
}

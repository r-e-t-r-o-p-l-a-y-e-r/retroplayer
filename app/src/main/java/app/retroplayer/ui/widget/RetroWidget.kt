package app.retroplayer.ui.widget

import android.content.Context
import android.graphics.Bitmap
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.playback.NowPlayingSnapshot
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.flow.first

/** Home-screen player: the live session while the service runs, else the last item's bookmark. */
class RetroWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Responsive(setOf(SMALL, ROW, WIDE))

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val deps = EntryPointAccessors.fromApplication(context, WidgetEntryPoint::class.java)
        val updater = deps.widgetUpdater()
        val lastPlayed = lastPlayed(deps.settings(), deps.store())
        provideContent {
            val live by updater.current.collectAsState()
            val shown = live ?: lastPlayed
            val art by produceState<Bitmap?>(null, shown.artUri) { value = shown.artUri?.let { updater.loadArt(it) } }
            WidgetContent(shown, art)
        }
    }

    private suspend fun lastPlayed(settings: SettingsStore, store: LibraryStore): NowPlayingSnapshot {
        val itemId = settings.session.first().lastItemId ?: return NowPlayingSnapshot()
        val saved = store.playback(itemId) ?: return NowPlayingSnapshot()
        return NowPlayingSnapshot(title = saved.displayTitle, subtitle = saved.subtitle)
    }

    companion object {
        val SMALL = DpSize(110.dp, 40.dp)
        val ROW = DpSize(250.dp, 40.dp)
        val WIDE = DpSize(250.dp, 110.dp)
    }
}

class RetroWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = RetroWidget()
}

@EntryPoint
@InstallIn(SingletonComponent::class)
interface WidgetEntryPoint {
    fun widgetUpdater(): WidgetUpdater

    fun settings(): SettingsStore

    fun store(): LibraryStore
}

package app.retroplayer.ui.widget

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.view.KeyEvent
import androidx.annotation.OptIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.action.actionStartActivity
import androidx.glance.appwidget.action.actionStartService
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.RowScope
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import androidx.media3.common.util.UnstableApi
import app.retroplayer.MainActivity
import app.retroplayer.R
import app.retroplayer.playback.NowPlayingSnapshot
import app.retroplayer.playback.PlaybackService
import app.retroplayer.ui.theme.RetroPalette

/**
 * The widget at its current size: title and play/pause when small; cover and the jumps on one
 * row; cover and titles above previous, jumps, play/pause and next when there is room.
 */
@Composable
fun WidgetContent(snapshot: NowPlayingSnapshot, art: Bitmap?) {
    val size = LocalSize.current
    Box(
        GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(palette { screenElevated })
            .cornerRadius(16.dp)
            .clickable(actionStartActivity<MainActivity>())
            .padding(horizontal = 12.dp, vertical = 8.dp),
        contentAlignment = Alignment.CenterStart,
    ) {
        when {
            size.width < RetroWidget.ROW.width -> Row(GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Titles(snapshot, GlanceModifier.defaultWeight())
                PlayPause(snapshot.isPlaying)
            }
            size.height < RetroWidget.WIDE.height -> Row(GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Cover(art, 40.dp)
                Titles(snapshot, GlanceModifier.defaultWeight().padding(horizontal = 10.dp))
                Jump(forward = false)
                Spacer(GlanceModifier.width(4.dp))
                PlayPause(snapshot.isPlaying)
                Spacer(GlanceModifier.width(4.dp))
                Jump(forward = true)
            }
            else -> Column(GlanceModifier.fillMaxSize()) {
                Row(GlanceModifier.fillMaxWidth().defaultWeight(), verticalAlignment = Alignment.CenterVertically) {
                    Cover(art, 56.dp)
                    Titles(snapshot, GlanceModifier.defaultWeight().padding(start = 12.dp))
                }
                Row(GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Slot { Control(R.drawable.ic_widget_previous, R.string.previous, mediaKey(KeyEvent.KEYCODE_MEDIA_PREVIOUS)) }
                    Slot { Jump(forward = false) }
                    Slot { PlayPause(snapshot.isPlaying, size = 48.dp) }
                    Slot { Jump(forward = true) }
                    Slot { Control(R.drawable.ic_widget_next, R.string.next, mediaKey(KeyEvent.KEYCODE_MEDIA_NEXT)) }
                }
            }
        }
    }
}

@Composable
private fun RowScope.Slot(content: @Composable () -> Unit) {
    Box(GlanceModifier.defaultWeight(), contentAlignment = Alignment.Center) { content() }
}

@Composable
private fun Titles(snapshot: NowPlayingSnapshot, modifier: GlanceModifier) {
    val context = LocalContext.current
    Column(modifier) {
        Text(
            snapshot.title ?: context.getString(R.string.app_name),
            maxLines = 1,
            style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Medium, color = palette { textPrimary }),
        )
        snapshot.subtitle?.let {
            Text(it, maxLines = 1, style = TextStyle(fontSize = 12.sp, color = palette { textSecondary }))
        }
    }
}

@Composable
private fun Cover(art: Bitmap?, size: Dp) {
    if (art != null) {
        Image(ImageProvider(art), contentDescription = null, contentScale = ContentScale.Crop, modifier = GlanceModifier.size(size).cornerRadius(6.dp))
    } else {
        Box(GlanceModifier.size(size).cornerRadius(6.dp).background(palette { albumPlaceholderEnd }), contentAlignment = Alignment.Center) {
            Image(ImageProvider(R.drawable.ic_widget_note), contentDescription = null, colorFilter = ColorFilter.tint(palette { textSecondary }), modifier = GlanceModifier.size(size / 2))
        }
    }
}

@Composable
private fun PlayPause(playing: Boolean, size: Dp = 40.dp) {
    if (playing) {
        Control(R.drawable.ic_widget_pause, R.string.pause, mediaKey(KeyEvent.KEYCODE_MEDIA_PAUSE), primary = true, size = size)
    } else {
        Control(R.drawable.ic_widget_play, R.string.play, mediaKey(KeyEvent.KEYCODE_MEDIA_PLAY, foreground = true), primary = true, size = size)
    }
}

@Composable
private fun Jump(forward: Boolean) {
    if (forward) {
        Control(R.drawable.ic_widget_jump_forward, R.string.jump_forward, mediaKey(KeyEvent.KEYCODE_MEDIA_FAST_FORWARD), seconds = true)
    } else {
        Control(R.drawable.ic_widget_jump_back, R.string.jump_back, mediaKey(KeyEvent.KEYCODE_MEDIA_REWIND), seconds = true)
    }
}

@Composable
private fun Control(icon: Int, label: Int, action: Action, primary: Boolean = false, size: Dp = 36.dp, seconds: Boolean = false) {
    val ink = if (primary) ColorProvider(Color.White) else palette { textSecondary }
    Box(
        GlanceModifier.size(size).cornerRadius(size / 2).background(if (primary) palette { accent } else palette { iconChip }).clickable(action),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            ImageProvider(icon),
            contentDescription = LocalContext.current.getString(label),
            colorFilter = ColorFilter.tint(ink),
            modifier = GlanceModifier.size(size * if (seconds) 0.75f else 0.6f),
        )
        if (seconds) {
            Text(
                "15",
                style = TextStyle(fontSize = 7.sp, fontWeight = FontWeight.Bold, color = ink),
                modifier = GlanceModifier.padding(top = size * 0.1f),
            )
        }
    }
}

/**
 * A media button for [PlaybackService]; Media3 runs it like a headset key (jumps follow the
 * chapter rules). Only play may start the service in the foreground. The category keeps the
 * pending intents of the buttons apart.
 */
@OptIn(UnstableApi::class)
@Composable
private fun mediaKey(keyCode: Int, foreground: Boolean = false): Action {
    val context: Context = LocalContext.current
    val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
        .setComponent(ComponentName(context, PlaybackService::class.java))
        .addCategory("app.retroplayer.widget.KEY_$keyCode")
        .putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
    return actionStartService(intent, isForegroundService = foreground)
}

private fun palette(color: RetroPalette.() -> Color): ColorProvider =
    ColorProvider(day = RetroPalette.Light.color(), night = RetroPalette.Dark.color())

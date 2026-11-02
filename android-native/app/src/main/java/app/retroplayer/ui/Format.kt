package app.retroplayer.ui

import java.text.NumberFormat
import java.util.Locale

/** `m:ss`, or `h:mm:ss` from one hour. */
fun formatDuration(ms: Long): String {
    val total = ms.coerceAtLeast(0) / 1000
    val hours = total / 3600
    val minutes = total % 3600 / 60
    val seconds = total % 60
    return if (hours > 0) {
        "%d:%02d:%02d".format(Locale.ROOT, hours, minutes, seconds)
    } else {
        "%d:%02d".format(Locale.ROOT, minutes, seconds)
    }
}

fun formatSpeed(speed: Float, locale: Locale = Locale.getDefault()): String {
    val number = NumberFormat.getNumberInstance(locale).apply { maximumFractionDigits = 2 }
    return number.format(speed.toDouble()) + "×"
}

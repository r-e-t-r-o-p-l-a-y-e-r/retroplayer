package app.retroplayer.ui

import java.text.NumberFormat
import java.util.Locale

/** `mm:ss`, or `hh:mm:ss` from one hour (as the Flutter app). */
fun formatDuration(ms: Long): String {
    val total = ms.coerceAtLeast(0) / 1000
    val hours = total / 3600
    val minutes = total % 3600 / 60
    val seconds = total % 60
    return if (hours > 0) {
        "%02d:%02d:%02d".format(Locale.ROOT, hours, minutes, seconds)
    } else {
        "%02d:%02d".format(Locale.ROOT, minutes, seconds)
    }
}

fun formatSpeed(speed: Float, locale: Locale = Locale.getDefault()): String {
    val number = NumberFormat.getNumberInstance(locale).apply {
        minimumFractionDigits = 1
        maximumFractionDigits = 2
    }
    return number.format(speed.toDouble()) + "x"
}

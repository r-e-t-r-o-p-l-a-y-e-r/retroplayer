package app.retroplayer.ui.settings

import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

private val BUILD_TIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

/** The build's commit time in [zone], like the Flutter app's About section; 0 means git was not available. */
fun buildTimeLabel(epochSeconds: Long, zone: ZoneId = ZoneId.systemDefault()): String =
    if (epochSeconds <= 0) "unknown" else BUILD_TIME_FORMAT.format(Instant.ofEpochSecond(epochSeconds).atZone(zone))

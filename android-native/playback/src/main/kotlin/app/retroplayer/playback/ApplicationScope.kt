package app.retroplayer.playback

import javax.inject.Qualifier

/** Main-thread scope that outlives screens and the playback service, for writes that must finish. */
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class ApplicationScope

package app.retroplayer.ui.settings

/** Runtime and UI dependencies from `gradle/libs.versions.toml` ([libraries] keys). */
object OpenSourceCatalog {
    data class Entry(val catalogKey: String, val displayName: String, val license: String)

    val entries: List<Entry> = listOf(
        Entry("kotlinx-coroutines-core", "Kotlin Coroutines", "Apache License 2.0"),
        Entry("kotlinx-coroutines-android", "Kotlin Coroutines (Android)", "Apache License 2.0"),
        Entry("kotlinx-coroutines-guava", "Kotlin Coroutines Guava", "Apache License 2.0"),
        Entry("kotlinx-serialization-json", "Kotlin Serialization", "Apache License 2.0"),
        Entry("androidx-core-ktx", "AndroidX Core KTX", "Apache License 2.0"),
        Entry("androidx-appcompat", "AndroidX AppCompat", "Apache License 2.0"),
        Entry("androidx-activity-compose", "AndroidX Activity Compose", "Apache License 2.0"),
        Entry("androidx-lifecycle-runtime-compose", "AndroidX Lifecycle Runtime Compose", "Apache License 2.0"),
        Entry("androidx-lifecycle-viewmodel-compose", "AndroidX Lifecycle ViewModel Compose", "Apache License 2.0"),
        Entry("androidx-lifecycle-service", "AndroidX Lifecycle Service", "Apache License 2.0"),
        Entry("androidx-navigation-compose", "AndroidX Navigation Compose", "Apache License 2.0"),
        Entry("androidx-documentfile", "AndroidX DocumentFile", "Apache License 2.0"),
        Entry("compose-bom", "Jetpack Compose BOM", "Apache License 2.0"),
        Entry("compose-ui", "Jetpack Compose UI", "Apache License 2.0"),
        Entry("compose-foundation", "Jetpack Compose Foundation", "Apache License 2.0"),
        Entry("compose-material3", "Material 3 for Compose", "Apache License 2.0"),
        Entry("compose-material-icons", "Material Icons for Compose", "Apache License 2.0"),
        Entry("media3-exoplayer", "AndroidX Media3 ExoPlayer", "Apache License 2.0"),
        Entry("media3-session", "AndroidX Media3 Session", "Apache License 2.0"),
        Entry("media3-common", "AndroidX Media3 Common", "Apache License 2.0"),
        Entry("room-runtime", "AndroidX Room", "Apache License 2.0"),
        Entry("room-ktx", "AndroidX Room KTX", "Apache License 2.0"),
        Entry("datastore-preferences", "AndroidX DataStore Preferences", "Apache License 2.0"),
        Entry("glance-appwidget", "AndroidX Glance App Widget", "Apache License 2.0"),
        Entry("glance-material3", "AndroidX Glance Material 3", "Apache License 2.0"),
        Entry("hilt-android", "Dagger Hilt", "Apache License 2.0"),
        Entry("hilt-navigation-compose", "AndroidX Hilt Navigation Compose", "Apache License 2.0"),
        Entry("coil-compose", "Coil", "Apache License 2.0"),
        Entry("reorderable", "Reorderable (Compose)", "Apache License 2.0"),
    )

    val catalogKeys: Set<String> = entries.map { it.catalogKey }.toSet()
}

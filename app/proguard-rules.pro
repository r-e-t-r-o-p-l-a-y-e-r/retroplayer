# Navigation type-safe routes are serialized with kotlinx.serialization.
-keepclassmembers @kotlinx.serialization.Serializable class app.retroplayer.** {
    *** Companion;
    kotlinx.serialization.KSerializer serializer(...);
}

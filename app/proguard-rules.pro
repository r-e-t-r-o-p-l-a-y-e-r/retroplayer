# Navigation type-safe routes are serialized with kotlinx.serialization.
-keepclassmembers @kotlinx.serialization.Serializable class app.retroplayer.** {
    *** Companion;
    kotlinx.serialization.KSerializer serializer(...);
}

# R8 9.5 types the continuation parameter of emitAbort (Flow.take, first) as Continuation or
# ContinuationImpl at random, so a third of the builds differ and F-Droid's rebuild would not
# match. Not optimising these members makes the APK reproducible; they stay shrinkable.
-keepclassmembers,allowobfuscation,allowshrinking class kotlinx.coroutines.flow.FlowKt__LimitKt** {
    *;
}

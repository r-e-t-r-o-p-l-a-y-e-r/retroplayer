package app.retroplayer.ui.components

import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.SemanticsPropertyKey
import androidx.compose.ui.semantics.semantics

/** Marks user data (titles, names, paths) that may end in an ellipsis; labels of controls must never be cut. */
val MayEllipsizeKey = SemanticsPropertyKey<Unit>("MayEllipsize")

fun Modifier.mayEllipsize(): Modifier = semantics { this[MayEllipsizeKey] = Unit }

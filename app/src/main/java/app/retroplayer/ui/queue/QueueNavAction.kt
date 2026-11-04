package app.retroplayer.ui.queue

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.QueueMusic
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import app.retroplayer.R

@Composable
fun QueueNavAction(onOpen: () -> Unit) {
    IconButton(onClick = onOpen) {
        Icon(Icons.AutoMirrored.Rounded.QueueMusic, contentDescription = stringResource(R.string.queue))
    }
}

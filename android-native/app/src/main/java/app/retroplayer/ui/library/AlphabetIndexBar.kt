package app.retroplayer.ui.library

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.ui.theme.LocalRetroPalette

const val LIBRARY_INDEX_BAR_TAG = "libraryIndexBar"

@Composable
fun AlphabetIndexBar(
    labels: List<String>,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    if (labels.isEmpty()) return
    val barLabel = stringResource(R.string.library_index)
    val palette = LocalRetroPalette.current
    Column(
        modifier = modifier
            .width(44.dp)
            .fillMaxHeight()
            .testTag(LIBRARY_INDEX_BAR_TAG)
            .semantics { contentDescription = barLabel }
            .pointerInput(labels) {
                detectTapGestures { offset ->
                    val fraction = (offset.y / size.height).coerceIn(0f, 0.999f)
                    val index = (fraction * labels.size).toInt().coerceIn(0, labels.lastIndex)
                    onSelect(labels[index])
                }
            }
            .padding(vertical = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        labels.forEach { label ->
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = palette.accent,
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .padding(vertical = 1.dp)
                    .pointerInput(label) {
                        detectTapGestures { onSelect(label) }
                    },
            )
        }
    }
}

package app.retroplayer.ui.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.ui.components.RetroSegmentedRow
import app.retroplayer.ui.components.RetroSlider
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlin.math.roundToInt

data class EqualizerActions(
    val choosePreset: (EqualizerPreset) -> Unit = {},
    val setBand: (index: Int, gainDb: Float) -> Unit = { _, _ -> },
    val reset: () -> Unit = {},
)

/** The equalizer block of the settings page: presets, then one row per band (label, slider, dB). */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun EqualizerSection(state: EqualizerUiState, actions: EqualizerActions) {
    val palette = LocalRetroPalette.current
    val enabled = state.available
    Column {
        SettingsTitle(stringResource(R.string.equalizer))
        if (!state.available) {
            Text(
                stringResource(R.string.equalizer_unavailable),
                color = palette.textMuted,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
            )
        }
        val presets = EqualizerPreset.entries
        RetroSegmentedRow(
            labels = presets.map { stringResource(it.label) },
            selected = presets.indexOf(state.settings.preset),
            onSelect = { actions.choosePreset(presets[it]) },
            enabled = enabled,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        )
        FlowRow(
            Modifier.fillMaxWidth().padding(start = 16.dp, end = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            itemVerticalAlignment = Alignment.CenterVertically,
        ) {
            Text(stringResource(R.string.bands), style = MaterialTheme.typography.labelMedium, color = palette.textMuted)
            TextButton(onClick = actions.reset, enabled = enabled) { Text(stringResource(R.string.reset)) }
        }
        state.gainsDb.forEachIndexed { index, gain ->
            BandRow(EqualizerSettings.BAND_HZ[index], gain, enabled) { actions.setBand(index, it) }
        }
    }
}

@Composable
private fun BandRow(hz: Int, gainDb: Float, enabled: Boolean, onChange: (Float) -> Unit) {
    val palette = LocalRetroPalette.current
    val db = "${gainDb.roundToInt()} dB"
    val label = MaterialTheme.typography.labelMedium
    Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(shortFrequency(hz), style = label, color = palette.textMuted, modifier = Modifier.widthIn(min = 40.dp).clearAndSetSemantics {})
        RetroSlider(
            value = gainDb,
            onValueChange = { onChange(it.roundToInt().toFloat()) },
            valueRange = EqualizerViewModel.MIN_DB..EqualizerViewModel.MAX_DB,
            enabled = enabled,
            modifier = Modifier
                .weight(1f)
                .heightIn(max = 36.dp)
                .padding(horizontal = 8.dp)
                .semantics {
                    contentDescription = frequency(hz)
                    stateDescription = db
                },
        )
        Text(db, style = label, color = palette.textMuted, textAlign = TextAlign.End, modifier = Modifier.widthIn(min = 48.dp).clearAndSetSemantics {})
    }
}

/** Spoken and described: "3.6 kHz". */
private fun frequency(hz: Int): String = shortFrequency(hz).let { if (it.endsWith("k")) it.dropLast(1) + " kHz" else "$it Hz" }

/** Shown beside the slider: "60", "3.6k". */
private fun shortFrequency(hz: Int): String = when {
    hz < 1000 -> "$hz"
    hz % 1000 == 0 -> "${hz / 1000}k"
    else -> "${hz / 1000}.${hz % 1000 / 100}k"
}

private val EqualizerPreset.label: Int
    get() = when (this) {
        EqualizerPreset.MANUAL -> R.string.eq_manually
        EqualizerPreset.BASS_BOOST -> R.string.eq_bass
        EqualizerPreset.TREBLE_BOOST -> R.string.eq_treble
        EqualizerPreset.VOICE -> R.string.eq_voice
    }

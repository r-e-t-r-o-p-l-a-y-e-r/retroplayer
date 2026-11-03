package app.retroplayer.ui.settings

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.FilterChip
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.layout
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlin.math.roundToInt

data class EqualizerActions(
    val back: () -> Unit = {},
    val setEnabled: (Boolean) -> Unit = {},
    val choosePreset: (EqualizerPreset) -> Unit = {},
    val setBand: (index: Int, gainDb: Float) -> Unit = { _, _ -> },
    val reset: () -> Unit = {},
)

@Composable
fun EqualizerScreen(back: () -> Unit, viewModel: EqualizerViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    EqualizerContent(
        state,
        EqualizerActions(
            back = back,
            setEnabled = viewModel::setEnabled,
            choosePreset = viewModel::choosePreset,
            setBand = viewModel::setBand,
            reset = viewModel::reset,
        ),
    )
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun EqualizerContent(state: EqualizerUiState, actions: EqualizerActions) {
    val palette = LocalRetroPalette.current
    val enabled = state.available
    Scaffold(
        topBar = { RetroTopBar(stringResource(R.string.equalizer), navigationIcon = { BackButton(actions.back) }) },
    ) { padding ->
        Column(
            Modifier.padding(padding).fillMaxSize().verticalScroll(rememberScrollState()).padding(bottom = 96.dp),
        ) {
            if (!state.available) {
                Text(
                    stringResource(R.string.equalizer_unavailable),
                    color = palette.textMuted,
                    modifier = Modifier.padding(16.dp),
                )
            }
            ListItem(
                headlineContent = { Text(stringResource(R.string.equalizer)) },
                trailingContent = { Switch(checked = state.settings.enabled, onCheckedChange = null, enabled = enabled) },
                modifier = Modifier.toggleable(
                    value = state.settings.enabled,
                    enabled = enabled,
                    role = Role.Switch,
                    onValueChange = actions.setEnabled,
                ),
            )
            FlowRow(
                Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                EqualizerPreset.entries.forEach { preset ->
                    FilterChip(
                        selected = state.settings.preset == preset,
                        onClick = { actions.choosePreset(preset) },
                        label = { Text(stringResource(preset.label)) },
                        enabled = enabled,
                    )
                }
            }
            Row(Modifier.fillMaxWidth().padding(end = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                SectionHeader(stringResource(R.string.bands), Modifier.weight(1f))
                TextButton(onClick = actions.reset, enabled = enabled) { Text(stringResource(R.string.reset)) }
            }
            // Bands run low to high frequency left to right, and up means louder, in every language.
            CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
                Row(Modifier.fillMaxWidth().padding(horizontal = 8.dp)) {
                    state.gainsDb.forEachIndexed { index, gain ->
                        BandSlider(
                            hz = frequencyLabel(EqualizerSettings.BAND_HZ[index]),
                            gainDb = gain,
                            enabled = enabled,
                            onChange = { actions.setBand(index, it) },
                            modifier = Modifier.weight(1f),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun BandSlider(hz: String, gainDb: Float, enabled: Boolean, onChange: (Float) -> Unit, modifier: Modifier) {
    val db = "${gainDb.roundToInt()} dB"
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Text(db, style = MaterialTheme.typography.labelSmall)
        Slider(
            value = gainDb,
            onValueChange = { onChange(it.roundToInt().toFloat()) },
            valueRange = EqualizerViewModel.MIN_DB..EqualizerViewModel.MAX_DB,
            steps = STEPS,
            enabled = enabled,
            modifier = Modifier
                .vertical()
                .height(48.dp)
                .padding(vertical = 4.dp)
                .semantics {
                    contentDescription = hz
                    stateDescription = db
                },
        )
        Text(hz, style = MaterialTheme.typography.labelSmall)
    }
}

/** Turns a horizontal slider by a quarter turn: minimum at the bottom, measured with swapped constraints. */
private fun Modifier.vertical(length: Dp = SLIDER_LENGTH) = this
    .graphicsLayer {
        rotationZ = 270f
        transformOrigin = TransformOrigin(0f, 0f)
    }
    .layout { measurable, constraints ->
        val px = length.roundToPx()
        val placeable = measurable.measure(Constraints(minWidth = px, maxWidth = px, minHeight = 0, maxHeight = constraints.maxWidth))
        layout(placeable.height, placeable.width) { placeable.place(-placeable.width, 0) }
    }

private fun frequencyLabel(hz: Int): String = when {
    hz < 1000 -> "$hz Hz"
    hz % 1000 == 0 -> "${hz / 1000} kHz"
    else -> "${hz / 1000}.${hz % 1000 / 100} kHz"
}

private val EqualizerPreset.label: Int
    get() = when (this) {
        EqualizerPreset.MANUAL -> R.string.eq_manually
        EqualizerPreset.BASS_BOOST -> R.string.eq_bass
        EqualizerPreset.TREBLE_BOOST -> R.string.eq_treble
        EqualizerPreset.VOICE -> R.string.eq_voice
    }

/** One stop per dB from -15 to 15. */
private const val STEPS = 29
private val SLIDER_LENGTH = 200.dp

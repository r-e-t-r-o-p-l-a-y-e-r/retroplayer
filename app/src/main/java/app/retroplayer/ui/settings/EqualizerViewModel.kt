package app.retroplayer.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.playback.EqualizerAvailability
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class EqualizerUiState(
    val available: Boolean = false,
    val settings: EqualizerSettings = EqualizerSettings.DEFAULT,
) {
    /** What the sliders show: the preset's curve, or the manual one. */
    val gainsDb: List<Float>
        get() = if (settings.preset == EqualizerPreset.MANUAL) settings.manualGainsDb else settings.preset.gainsDb
}

@HiltViewModel
class EqualizerViewModel @Inject constructor(
    private val settings: SettingsStore,
    private val availability: EqualizerAvailability,
) : ViewModel() {
    /** Edits not yet stored, so a dragged slider follows the finger without waiting for DataStore. */
    private val draft = MutableStateFlow<EqualizerSettings?>(null)
    private var pendingSave: Job? = null

    val state: StateFlow<EqualizerUiState> =
        combine(settings.settings, draft, availability.info) { stored, edit, info ->
            EqualizerUiState(available = availability.supported || info != null, settings = edit ?: stored.equalizer)
        }.stateIn(viewModelScope, SharingStarted.Eagerly, EqualizerUiState())

    private val current: EqualizerSettings get() = state.value.settings

    fun choosePreset(preset: EqualizerPreset) = save(current.copy(preset = preset))

    fun reset() = save(current.copy(preset = EqualizerPreset.MANUAL, manualGainsDb = EqualizerSettings.FLAT))

    fun setBand(index: Int, gainDb: Float) {
        val gains = state.value.gainsDb.toMutableList()
        if (index !in gains.indices) return
        gains[index] = gainDb.coerceIn(MIN_DB, MAX_DB)
        save(current.copy(preset = EqualizerPreset.MANUAL, manualGainsDb = gains), debounceMs = SLIDER_DEBOUNCE_MS)
    }

    /** No separate switch: anything but flat manual bands is on, so flat stores nothing. */
    private fun save(edit: EqualizerSettings, debounceMs: Long = 0) {
        val flat = edit.preset == EqualizerPreset.MANUAL && edit.manualGainsDb.all { it == 0f }
        val next = edit.copy(enabled = !flat)
        draft.value = next
        pendingSave?.cancel()
        pendingSave = viewModelScope.launch {
            delay(debounceMs)
            settings.setEqualizer(next)
        }
    }

    companion object {
        const val MIN_DB = -15f
        const val MAX_DB = 15f
        private const val SLIDER_DEBOUNCE_MS = 100L
    }
}

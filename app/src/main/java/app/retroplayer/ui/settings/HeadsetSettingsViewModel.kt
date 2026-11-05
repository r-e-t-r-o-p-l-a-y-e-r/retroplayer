package app.retroplayer.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.settings.HeadsetSettings
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class HeadsetSettingsViewModel @Inject constructor(private val settings: SettingsStore) : ViewModel() {
    val state: StateFlow<HeadsetSettings> = settings.settings.map { it.headset }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), HeadsetSettings.DEFAULT)

    fun setAutoRewind(on: Boolean) = update { it.copy(autoRewind = on) }

    fun setAutoRewindSeconds(seconds: Int) = update { it.copy(autoRewindSeconds = seconds) }

    fun setResumeOnReconnect(on: Boolean) = update { it.copy(resumeOnReconnect = on) }

    private fun update(change: (HeadsetSettings) -> HeadsetSettings) {
        viewModelScope.launch { settings.setHeadset(change(settings.settings.first().headset)) }
    }

    companion object {
        val REWIND_SECONDS = listOf(5, 10, 15, 30)
    }
}

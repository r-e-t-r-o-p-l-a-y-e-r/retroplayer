package app.retroplayer.ui.settings

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.selection.toggleable
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.ui.components.RetroSegmentedRow
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.theme.LocalRetroPalette

data class HeadsetActions(
    val setAutoRewind: (Boolean) -> Unit = {},
    val setAutoRewindSeconds: (Int) -> Unit = {},
    val setResumeOnReconnect: (Boolean) -> Unit = {},
)

/** The headphones block of the settings page: rewind on resume (and by how much), resume on reconnect. */
@Composable
fun HeadsetSection(settings: HeadsetSettings, actions: HeadsetActions) {
    val palette = LocalRetroPalette.current
    Column {
        SectionHeader(stringResource(R.string.headphones))
        SwitchRow(stringResource(R.string.auto_rewind), stringResource(R.string.auto_rewind_hint), settings.autoRewind, actions.setAutoRewind)
        Text(
            stringResource(R.string.rewind_by),
            style = MaterialTheme.typography.labelMedium,
            color = palette.textMuted,
            modifier = Modifier.padding(horizontal = 16.dp),
        )
        val choices = HeadsetSettingsViewModel.REWIND_SECONDS
        RetroSegmentedRow(
            labels = choices.map { stringResource(R.string.seconds_short, it) },
            selected = choices.indexOf(settings.autoRewindSeconds),
            onSelect = { actions.setAutoRewindSeconds(choices[it]) },
            enabled = settings.autoRewind,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        )
        SwitchRow(
            stringResource(R.string.resume_on_reconnect),
            stringResource(R.string.resume_on_reconnect_hint),
            settings.resumeOnReconnect,
            actions.setResumeOnReconnect,
        )
    }
}

@Composable
private fun SwitchRow(title: String, hint: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    val palette = LocalRetroPalette.current
    ListItem(
        headlineContent = { Text(title) },
        supportingContent = { Text(hint, color = palette.textMuted) },
        trailingContent = {
            Switch(
                checked = checked,
                onCheckedChange = null,
                colors = SwitchDefaults.colors(
                    checkedThumbColor = Color.White,
                    checkedTrackColor = palette.accent,
                    uncheckedBorderColor = palette.divider,
                ),
            )
        },
        modifier = Modifier.toggleable(value = checked, role = Role.Switch, onValueChange = onChange),
    )
}

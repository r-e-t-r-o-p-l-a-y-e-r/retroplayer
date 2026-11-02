package app.retroplayer.data.library

import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.QueueEdits
import app.retroplayer.domain.model.AudioTrack
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

/**
 * The user's queue (UC-08), stored as paths in [SettingsStore]. Entries whose
 * file is gone stay in the queue and resolve to null, so the user sees and
 * can remove them.
 */
class QueueRepository(private val settings: SettingsStore, private val scanner: LibraryScanner) {
    val queue: Flow<List<AudioTrack?>> = settings.session
        .map { it.queue }
        .distinctUntilChanged()
        .map { scanner.tracksAt(it) }

    suspend fun add(paths: List<LibraryPath>) = settings.updateQueue { QueueEdits.add(it, paths) }

    suspend fun move(from: Int, to: Int) = settings.updateQueue { QueueEdits.move(it, from, to) }

    suspend fun remove(index: Int) = settings.updateQueue { QueueEdits.remove(it, index) }

    suspend fun clear() = settings.updateQueue { emptyList() }
}

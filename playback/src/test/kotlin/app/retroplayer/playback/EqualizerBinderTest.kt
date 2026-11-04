package app.retroplayer.playback

import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class EqualizerBinderTest {
    private class FakeEngine(val sessionId: Int) : EqualizerEngine {
        override val centersHz = listOf(60, 230, 910, 3600, 14000)
        override val rangeDb = -15f..15f
        val applied = mutableListOf<List<Float>>()
        var enabled: Boolean? = null
        var released = false
        override fun apply(gainsDb: List<Float>) { applied += gainsDb }
        override fun setEnabled(enabled: Boolean) { this.enabled = enabled }
        override fun release() { released = true }
    }

    private val engines = mutableListOf<FakeEngine>()
    private val reports = mutableListOf<EqualizerInfo?>()
    private var failing = false
    private val binder = EqualizerBinder(
        create = { id -> if (failing) null else FakeEngine(id).also { engines += it } },
        report = { reports += it },
    )
    private val bass = EqualizerSettings(enabled = true, preset = EqualizerPreset.BASS_BOOST)

    @Test
    fun `applies device gains when a session starts`() {
        binder.onSettings(bass)
        binder.onSession(7)
        val engine = engines.single()
        assertThat(engine.sessionId).isEqualTo(7)
        assertThat(engine.applied.last()).isEqualTo(EqualizerPreset.BASS_BOOST.gainsDb)
        assertThat(engine.enabled).isTrue()
        assertThat(reports.last()).isEqualTo(EqualizerInfo(engine.centersHz, engine.rangeDb))
    }

    @Test
    fun `reapplies when settings change`() {
        binder.onSession(7)
        binder.onSettings(bass)
        assertThat(engines.single().applied.last()).isEqualTo(EqualizerPreset.BASS_BOOST.gainsDb)
    }

    @Test
    fun `disabled settings turn the effect off`() {
        binder.onSession(7)
        binder.onSettings(bass)
        binder.onSettings(bass.copy(enabled = false))
        assertThat(engines.single().enabled).isFalse()
    }

    @Test
    fun `releases the old effect on a new session and ignores an unset session`() {
        binder.onSession(7)
        binder.onSession(8)
        binder.onSession(EqualizerBinder.NO_SESSION)
        assertThat(engines.map { it.sessionId }).containsExactly(7, 8).inOrder()
        assertThat(engines[0].released).isTrue()
        assertThat(engines[1].released).isFalse()
        binder.release()
        assertThat(engines[1].released).isTrue()
        assertThat(reports.last()).isNull()
    }

    @Test
    fun `creation failure reports unavailable`() {
        failing = true
        binder.onSession(7)
        binder.onSettings(bass)
        assertThat(engines).isEmpty()
        assertThat(reports.last()).isNull()
    }
}

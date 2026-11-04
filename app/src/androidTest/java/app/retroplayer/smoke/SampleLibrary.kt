package app.retroplayer.smoke

import android.content.Context
import java.io.File
import java.io.RandomAccessFile
import kotlin.math.PI
import kotlin.math.sin

/**
 * The sample folder the smoke tests pick, created on shared storage when it is missing, so a
 * fresh (managed) device needs no adb push. Same layout as `scripts/push-smoke-fixtures.sh`,
 * as untagged WAV tones. The files are written to the app's external files folder and copied
 * by the shell user, which may write to shared storage on every API level.
 *
 * Shell commands are split at spaces and not run through a shell, so only space-free paths
 * are passed to them.
 */
class SampleLibrary(private val context: Context, private val shell: (String) -> String) {
    fun ensure() {
        if ("zebra" in shell("ls $LONG_LIST")) return
        val staging = File(context.getExternalFilesDir(null), "samples").apply { deleteRecursively() }
        LONG_LIST_NAMES.forEachIndexed { i, name -> tone(File(staging, "LongList/$name/tone.wav"), 400 + i * 10, 1) }
        if ("loose-demo" in shell("ls $ROOT")) {
            shell("cp -r ${staging.path}/LongList $LONG_LIST")
        } else {
            val album = File(staging, "Demo Artist/Demo Album")
            tone(File(album, "01-opening.wav"), 440, 8)
            tone(File(album, "02-middle.wav"), 523, 8)
            tone(File(album, "03-finale.wav"), 659, 8)
            tone(File(staging, "loose-demo.wav"), 880, 5)
            shell("mkdir -p ${ROOT.substringBeforeLast('/')}")
            shell("cp -r ${staging.path} $ROOT")
        }
        check("zebra" in shell("ls $LONG_LIST")) { "could not create the sample folder at $ROOT" }
    }

    /** A mono 16-bit sine tone. */
    private fun tone(file: File, hz: Int, seconds: Int) {
        file.parentFile?.mkdirs()
        val samples = RATE * seconds
        val data = ByteArray(samples * 2)
        for (i in 0 until samples) {
            val v = (sin(2 * PI * hz * i / RATE) * Short.MAX_VALUE * 0.3).toInt()
            data[2 * i] = v.toByte()
            data[2 * i + 1] = (v shr 8).toByte()
        }
        RandomAccessFile(file, "rw").use { out ->
            out.setLength(0)
            out.writeBytes("RIFF"); out.writeIntLe(36 + data.size); out.writeBytes("WAVE")
            out.writeBytes("fmt "); out.writeIntLe(16); out.writeShortLe(1); out.writeShortLe(1)
            out.writeIntLe(RATE); out.writeIntLe(RATE * 2); out.writeShortLe(2); out.writeShortLe(16)
            out.writeBytes("data"); out.writeIntLe(data.size); out.write(data)
        }
    }

    private fun RandomAccessFile.writeIntLe(v: Int) = write(byteArrayOf(v.toByte(), (v shr 8).toByte(), (v shr 16).toByte(), (v shr 24).toByte()))

    private fun RandomAccessFile.writeShortLe(v: Int) = write(byteArrayOf(v.toByte(), (v shr 8).toByte()))

    companion object {
        const val ROOT = "/sdcard/Music/RetroPlayerSamples"
        const val LONG_LIST = "$ROOT/LongList"
        private const val RATE = 8_000
        private val LONG_LIST_NAMES = listOf("alpha") + (0..28).map { "track%02d".format(it) } + "zebra"
    }
}

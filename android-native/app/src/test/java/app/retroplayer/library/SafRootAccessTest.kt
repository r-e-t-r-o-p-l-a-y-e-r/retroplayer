package app.retroplayer.library

import android.content.Intent
import android.provider.DocumentsContract
import androidx.core.net.toUri
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.runVmTest
import com.google.common.truth.Truth.assertThat
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SafRootAccessTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private lateinit var lib: TestLibrary
    private lateinit var access: SafRootAccess

    private val music = "content://com.android.externalstorage.documents/tree/primary%3AMusic"
    private val books = "content://com.android.externalstorage.documents/tree/primary%3ABooks"

    @Before
    fun setUp() {
        lib = TestLibrary(tmp)
        access = SafRootAccess(context, lib.store, lib.scanner)
    }

    @After
    fun tearDown() = lib.close()

    private fun grants() = context.contentResolver.persistedUriPermissions

    @Test
    fun `write grant for the same tree marks the root writable`() = main.runVmTest {
        val id = access.add(music)!!
        assertThat(lib.store.root(id)!!.canWrite).isFalse()

        assertThat(access.grantWrite(id, music)).isTrue()

        assertThat(lib.store.root(id)!!.canWrite).isTrue()
        assertThat(grants().single { it.uri == music.toUri() }.isWritePermission).isTrue()
    }

    @Test
    fun `a different tree is rejected and its grant released`() = main.runVmTest {
        val id = access.add(music)!!

        assertThat(access.grantWrite(id, books)).isFalse()

        assertThat(lib.store.root(id)!!.canWrite).isFalse()
        assertThat(grants().map { it.uri }).containsExactly(music.toUri())
    }

    @Test
    fun `the write request opens the picker at the root and asks for write access`() {
        val intent = writeAccessIntent(music)
        assertThat(intent.action).isEqualTo(Intent.ACTION_OPEN_DOCUMENT_TREE)
        assertThat(intent.getParcelableExtra<android.net.Uri>(DocumentsContract.EXTRA_INITIAL_URI)).isEqualTo(music.toUri())
        assertThat(intent.flags and Intent.FLAG_GRANT_WRITE_URI_PERMISSION).isNotEqualTo(0)
        assertThat(intent.flags and Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION).isNotEqualTo(0)
    }
}

package app.retroplayer.data.saf

import android.content.pm.ProviderInfo
import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.provider.DocumentsProvider
import androidx.test.core.app.ApplicationProvider
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import java.io.File

/** Minimal file-backed DocumentsProvider: document id = path relative to [base]. */
class TestDocumentsProvider : DocumentsProvider() {
    override fun onCreate() = true

    private fun file(id: String) = if (id == ROOT) base else File(base, id.removePrefix("$ROOT/"))

    private fun row(cursor: MatrixCursor, id: String) {
        val f = file(id)
        cursor.newRow()
            .add(Document.COLUMN_DOCUMENT_ID, id)
            .add(Document.COLUMN_DISPLAY_NAME, if (id == ROOT) "root" else f.name)
            .add(Document.COLUMN_MIME_TYPE, if (f.isDirectory) Document.MIME_TYPE_DIR else "audio/mpeg")
            .add(Document.COLUMN_LAST_MODIFIED, f.lastModified())
            .add(Document.COLUMN_SIZE, f.length())
            .add(Document.COLUMN_FLAGS, Document.FLAG_SUPPORTS_WRITE or Document.FLAG_SUPPORTS_DELETE or Document.FLAG_DIR_SUPPORTS_CREATE)
    }

    override fun queryRoots(projection: Array<out String>?): Cursor = MatrixCursor(arrayOf("root_id"))

    override fun queryDocument(documentId: String, projection: Array<out String>?): Cursor =
        MatrixCursor(COLUMNS).also { row(it, documentId) }

    override fun queryChildDocuments(parentDocumentId: String, projection: Array<out String>?, sortOrder: String?): Cursor =
        MatrixCursor(COLUMNS).also { c ->
            file(parentDocumentId).listFiles().orEmpty().sortedBy { it.name }.forEach {
                row(c, "$parentDocumentId/${it.name}")
            }
        }

    override fun isChildDocument(parentDocumentId: String, documentId: String) =
        documentId.startsWith("$parentDocumentId/")

    override fun openDocument(documentId: String, mode: String, signal: CancellationSignal?): ParcelFileDescriptor =
        ParcelFileDescriptor.open(file(documentId), ParcelFileDescriptor.parseMode(mode))

    override fun createDocument(parentDocumentId: String, mimeType: String, displayName: String): String {
        val id = "$parentDocumentId/$displayName"
        file(id).createNewFile()
        return id
    }

    override fun deleteDocument(documentId: String) {
        file(documentId).delete()
    }

    companion object {
        const val AUTHORITY = "app.retroplayer.test.documents"
        const val ROOT = "root"
        lateinit var base: File
        val COLUMNS = arrayOf(
            Document.COLUMN_DOCUMENT_ID, Document.COLUMN_DISPLAY_NAME, Document.COLUMN_MIME_TYPE,
            Document.COLUMN_LAST_MODIFIED, Document.COLUMN_SIZE, Document.COLUMN_FLAGS,
        )
    }
}

@RunWith(RobolectricTestRunner::class)
class SafDocumentSourceTest {
    @get:Rule
    val tmp = TemporaryFolder()

    private lateinit var source: SafDocumentSource
    private val tree = DocumentsContract.buildTreeDocumentUri(TestDocumentsProvider.AUTHORITY, TestDocumentsProvider.ROOT)

    @Before
    fun setUp() {
        TestDocumentsProvider.base = tmp.root
        File(tmp.root, "Book").mkdirs()
        File(tmp.root, "Book/01.mp3").writeBytes(byteArrayOf(1, 2, 3))
        File(tmp.root, "Book/cover.jpg").writeBytes(byteArrayOf(9))
        val info = ProviderInfo().apply {
            authority = TestDocumentsProvider.AUTHORITY
            exported = true
            grantUriPermissions = true
            readPermission = android.Manifest.permission.MANAGE_DOCUMENTS
            writePermission = android.Manifest.permission.MANAGE_DOCUMENTS
        }
        Robolectric.buildContentProvider(TestDocumentsProvider::class.java).create(info)
        source = SafDocumentSource(ApplicationProvider.getApplicationContext<android.content.Context>().contentResolver)
    }

    @Test
    fun `root document of a tree lists its children with type size and date`() = runTest {
        val root = SafDocumentSource.rootDocumentUri(tree.toString())
        val children = source.children(root)
        assertThat(children.map { it.name }).containsExactly("Book")
        assertThat(children.single().isDirectory).isTrue()

        val files = source.children(children.single().uri)
        assertThat(files.map { it.name }).containsExactly("01.mp3", "cover.jpg").inOrder()
        assertThat(files.first().size).isEqualTo(3)
        assertThat(files.first().isDirectory).isFalse()
    }

    @Test
    fun `reads creates writes and deletes documents`() = runTest {
        val book = source.children(SafDocumentSource.rootDocumentUri(tree.toString())).single()
        val song = source.children(book.uri).first()
        assertThat(source.read(song.uri)).isEqualTo(byteArrayOf(1, 2, 3))

        val created = source.create(book.uri, "Mix.m3u", "audio/x-mpegurl")!!
        source.write(created, "#EXTM3U\n".toByteArray())
        assertThat(File(tmp.root, "Book/Mix.m3u").readText()).isEqualTo("#EXTM3U\n")

        assertThat(source.delete(created)).isTrue()
        assertThat(File(tmp.root, "Book/Mix.m3u").exists()).isFalse()
    }
}

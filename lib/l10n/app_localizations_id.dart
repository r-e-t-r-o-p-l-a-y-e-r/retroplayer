// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Pengaturan';

  @override
  String get about => 'Tentang';

  @override
  String get aboutSubtitle =>
      'Hanya audio lokal. Tanpa iklan, tanpa telemetri, tanpa akses jaringan.\nFormat yang didukung: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutBuildDate => 'Waktu pembuatan';

  @override
  String get aboutGitBranch => 'Cabang';

  @override
  String get aboutGitCommit => 'Build';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Fitur Equalizer tidak tersedia di platform ini.';

  @override
  String get bands => 'Grup musik';

  @override
  String get reset => 'Atur Ulang';

  @override
  String get library => 'Perpustakaan';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Daftar Putar';

  @override
  String get nowPlaying => 'Sedang Diputar';

  @override
  String get addFolder => 'Tambahkan folder';

  @override
  String get audioPermissionRequired => 'Di Android, diperlukan izin audio';

  @override
  String get expandPlayer => 'Perluas pemutar';

  @override
  String get showLibrary => 'Tampilkan perpustakaan';

  @override
  String errorMessage(String message) {
    return 'Kesalahan: $message';
  }

  @override
  String get noFoldersAdded =>
      'Belum ada folder yang ditambahkan. Ketuk \"Tambahkan folder\" untuk memulai.';

  @override
  String get folderEmpty => 'Folder ini kosong.';

  @override
  String get librarySources => 'Sumber perpustakaan';

  @override
  String get favorites => 'Favorit';

  @override
  String get favorite => 'Favorit';

  @override
  String get removeFavorite => 'Hapus dari daftar favorit';

  @override
  String get folders => 'Folder';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Folder Putar';

  @override
  String get playAlbum => 'Putar album';

  @override
  String get removeLibraryFolderTitle => 'Hapus folder library?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Apakah Anda ingin menghapus \"$name\" dari perpustakaan Anda?\n\nFile audio Anda di disk tidak akan dihapus.';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get remove => 'Hapus';

  @override
  String get albumNotFound => 'Album tidak ditemukan';

  @override
  String get playlistNotFound => 'Daftar putar tidak ditemukan';

  @override
  String get selectToPlay =>
      'Pilih sesuatu dari perpustakaan Anda untuk diputar.';

  @override
  String get speed => 'Kecepatan';

  @override
  String get previous => 'Sebelumnya';

  @override
  String get pause => 'Jeda';

  @override
  String get play => 'Mainkan';

  @override
  String get next => 'Selanjutnya';

  @override
  String get jumpBack => 'Kembali 15 detik';

  @override
  String get jumpForward => 'Maju 15 detik';

  @override
  String get trackFallback => 'Lintasan';

  @override
  String get unknownArtist => 'Tidak diketahui';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count lagu · $artist';
  }

  @override
  String get resetDatabase => 'Atur ulang basis data';

  @override
  String get resetDatabaseTitle => 'Mereset basis data?';

  @override
  String get resetDatabaseBody =>
      'Tindakan ini akan menghapus posisi pemutaran, daftar favorit, folder yang terbuka, tema, bahasa, dan pengaturan equalizer. Opsi \"Hapus Semuanya\" juga akan menghapus folder perpustakaan yang telah ditambahkan. File musik dan daftar putar yang ada di disk tidak akan dihapus.';

  @override
  String get resetDatabaseKeepFolders => 'Simpan folder perpustakaan';

  @override
  String get resetDatabaseClearEverything => 'Hapus semuanya';

  @override
  String get eqManually => 'Secara manual';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqTreble => 'Treble';

  @override
  String get eqVoice => 'Suara';

  @override
  String get appearance => 'Penampilan';

  @override
  String get themeLight => 'Cahaya';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get openSourceLicenses => 'Lisensi sumber terbuka';

  @override
  String get openSourceLegalese => '© 2026 Para kontributor Retro Player';

  @override
  String get dataStorage => 'Penyimpanan data';

  @override
  String get dataStorageIntro =>
      'Retro Player menyimpan pengaturan aplikasi dalam basis data lokal berukuran kecil. Musik dan daftar putar Anda tetap tersimpan sebagai file biasa di dalam folder yang Anda pilih.';

  @override
  String get dataStorageAppDataTitle => 'Basis data aplikasi';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'File: $dbFileName\nJalur: $dbPath\n\nMenyimpan preferensi akar perpustakaan, status penelusuran, kelanjutan pemutaran, equalizer, tema, dan bahasa.';
  }

  @override
  String get dataStorageLibraryTitle => 'File musik';

  @override
  String get dataStorageLibraryBody =>
      'File audio tidak pernah disalin ke dalam basis data aplikasi. Tambahkan folder perpustakaan, dan Retro Player akan membaca file langsung dari disk.';

  @override
  String get dataStoragePlaylistsTitle => 'Berkas daftar putar';

  @override
  String get dataStoragePlaylistsBody =>
      'Daftar putar adalah berkas .m3u biasa yang disimpan di dalam folder perpustakaan Anda. Anda dapat mengeditnya di dalam aplikasi atau menggunakan editor teks apa pun.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platform: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Data aplikasi disimpan di dalam direktori app-support (biasanya ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Data aplikasi Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Data aplikasi disimpan di ~/.local/share/app.retroplayer/. Folder tersebut hanya digunakan untuk basis data dan pengaturan.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Integrasi bilah tugas Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Untuk ikon pada bilah tugas dan kisi aplikasi, lingkungan desktop Linux memerlukan berkas Freedesktop terpisah. Retro Player menginstal berkas-berkas ini dari paket aplikasi saat dijalankan:\n\n• ~/.local/share/applications/app.retroplayer.desktop — entri peluncur yang menghubungkan jendela yang sedang berjalan ke aplikasi ini\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikon bertema yang disalin dari paket\n\nAplikasi ini tidak pernah menulis berkas hicolor/index.theme milik pengguna (karena hal itu akan menimpa tema sistem dan menyembunyikan ikon lainnya). Ikon juga disematkan dalam berkas biner aplikasi. Salinan di atas membantu GNOME/KDE menampilkan ikon peluncur yang benar, bukan ikon pengganti umum.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Izin dan penyimpanan Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player menyimpan basis datanya di area dukungan khusus aplikasi pada penyimpanan internal. File musik Anda tetap tersimpan di folder yang Anda pilih menggunakan pemilih folder bawaan sistem.\n\nDi Android, aplikasi mungkin meminta izin akses audio untuk membaca trek, serta izin akses foto/gambar agar gambar sampul folder (misalnya cover.jpg) dapat ditampilkan. File audio tidak pernah disalin ke basis data aplikasi.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Pemutaran latar belakang di Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Saat audio sedang diputar, Retro Player menjalankan layanan media di latar depan sehingga pemutaran tetap berlanjut meskipun Anda mengunci ponsel atau berpindah aplikasi, dengan tombol kontrol pemutaran yang muncul di notifikasi sistem. Menggeser aplikasi keluar dari daftar aplikasi yang baru saja digunakan akan menghentikan pemutaran dan menghapus notifikasi tersebut.';

  @override
  String get dataStorageIOSAccessTitle => 'Akses folder di iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player menyimpan basis datanya di area dukungan khusus aplikasi pada penyimpanan perangkat. File musik Anda tetap berada di folder yang Anda pilih menggunakan pemilih folder bawaan sistem.\n\niOS memberikan akses melalui URL dengan cakupan keamanan untuk folder yang Anda pilih. Retro Player membaca file secara langsung dari lokasi-lokasi tersebut; aplikasi ini tidak menyalin perpustakaan Anda ke penyimpanan aplikasi.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Audio latar belakang iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Pemutaran dapat dilanjutkan meskipun aplikasi sedang berjalan di latar belakang atau layar terkunci. Posisi pemutaran dan status antrian disimpan dalam basis data lokal aplikasi.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Data aplikasi disimpan di area pendukung khusus aplikasi pada penyimpanan internal.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Data aplikasi disimpan di area pendukung khusus aplikasi pada penyimpanan perangkat.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Data aplikasi disimpan di ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Data aplikasi disimpan di dalam direktori dukungan aplikasi Anda.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Data aplikasi disimpan di penyimpanan lokal browser untuk asal ini.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Data aplikasi disimpan di area dukungan aplikasi platform.';

  @override
  String get loading => 'Sedang dimuat…';

  @override
  String get libraryIndex => 'Indeks perpustakaan';

  @override
  String get playlists => 'Daftar Putar';

  @override
  String get playPlaylist => 'Putar daftar putar';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trek',
      one: '1 lagu',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Buat daftar putar';

  @override
  String get queue => 'Antrean';

  @override
  String get saveAsPlaylist => 'Simpan sebagai daftar putar';

  @override
  String get queueEmpty =>
      'Antriannya kosong. Tambahkan lagu dari perpustakaan Anda.';

  @override
  String get choosePlaylistFolder =>
      'Pilih sebuah folder di perpustakaan. Akar perpustakaan bukanlah sebuah folder.';

  @override
  String get clearQueue => 'Hapus antrian';

  @override
  String get clearQueueTitle => 'Hapus antrian?';

  @override
  String get clearQueueBody =>
      'Tindakan ini akan menghapus semua lagu dari antrian. File audio dan daftar putar yang telah disimpan tetap ada.';

  @override
  String get newPlaylistName => 'Nama daftar putar';

  @override
  String get addTracks => 'Tambahkan trek';

  @override
  String get save => 'Simpan';

  @override
  String get addTracksFromLibrary => 'Tambahkan dari perpustakaan';

  @override
  String addTracksConfirm(int count) {
    return 'Tambahkan ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Pilih satu atau beberapa lagu di perpustakaan Anda.';

  @override
  String get libraryEmptyNoRoots =>
      'Tambahkan folder perpustakaan terlebih dahulu, lalu pilih lagu-lagu dari folder tersebut.';

  @override
  String get playlistEmpty => 'Daftar putar ini belum memiliki lagu apa pun.';

  @override
  String get missingTrack => 'Berkas tidak ditemukan';

  @override
  String get playlistReadOnly => 'Hanya Baca';

  @override
  String get playlistSelect => 'Pilih';

  @override
  String get playlistSelectAll => 'Pilih semua';

  @override
  String get playlistDeselectAll => 'Batalkan pemilihan semua';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 terpilih',
      zero: 'Pilih lagu',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus lagu-lagu $count dari daftar putar?',
      one: 'Hapus lagu dari daftar putar?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ini akan menghapus entri-entri tersebut dari berkas daftar putar saat Anda menyimpannya.',
      one: 'Tindakan ini akan menghapus entri tersebut dari berkas daftar putar saat Anda menyimpannya.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Tidak ada lagu baru yang ditambahkan. Mungkin lagu-lagu tersebut sudah ada di daftar putar.';

  @override
  String get addToQueue => 'Tambahkan ke antrean';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trek ditambahkan ke antrean',
      one: '1 trek ditambahkan ke antrean',
      zero: 'Tidak ada trek baru yang ditambahkan ke antrean',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Pindahkan ke atas';

  @override
  String get moveDown => 'Pindahkan ke bawah';

  @override
  String get playlistNothingToPlay =>
      'Daftar putar ini tidak memiliki lagu yang dapat diputar.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Hapus daftar putar?';

  @override
  String deletePlaylistBody(String name) {
    return 'Hapus \"$name\"? Tindakan ini akan menghapus berkas daftar putar dari disk.';
  }
}

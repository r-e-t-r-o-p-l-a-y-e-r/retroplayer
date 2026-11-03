// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Albanian (`sq`).
class AppLocalizationsSq extends AppLocalizations {
  AppLocalizationsSq([String locale = 'sq']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Caktimet';

  @override
  String get about => 'Rreth';

  @override
  String get aboutSubtitle =>
      'Audio lokale vetëm. Pa reklama, pa telemetri, pa akses në rrjet.\nFormate të mbështetura: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versioni';

  @override
  String get aboutBuildDate => 'Koha e ndërtimit';

  @override
  String get aboutGitBranch => 'Degë';

  @override
  String get aboutGitCommit => 'Ndërtim';

  @override
  String get equalizer => 'Equalizues';

  @override
  String get equalizerUnavailable =>
      'Equalizer nuk është i disponueshëm në këtë platformë.';

  @override
  String get bands => 'Grupet';

  @override
  String get reset => 'Rinis';

  @override
  String get library => 'Biblioteka';

  @override
  String get album => 'Albumi';

  @override
  String get playlist => 'Lista e këngëve';

  @override
  String get nowPlaying => 'Tani po luhet';

  @override
  String get addFolder => 'Shto dosjen';

  @override
  String get audioPermissionRequired => 'Leja e audios kërkohet në Android';

  @override
  String get expandPlayer => 'Zgjero lojtarin';

  @override
  String get showLibrary => 'Shfaq bibliotekën';

  @override
  String errorMessage(String message) {
    return 'Gabim: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nuk është shtuar asnjë dosje. Trokitni \"Shto dosje\" për të filluar.';

  @override
  String get folderEmpty => 'Ky dosje është bosh.';

  @override
  String get librarySources => 'Burimet e bibliotekës';

  @override
  String get favorites => 'Të preferuarit';

  @override
  String get favorite => 'I preferuari';

  @override
  String get removeFavorite => 'Hiqni të preferuarin';

  @override
  String get folders => 'Dosjet';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Luaj dosjen';

  @override
  String get playAlbum => 'Luaj albumin';

  @override
  String get removeLibraryFolderTitle => 'Të fshihet dosja e bibliotekës?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Të hiqni \"$name\" nga biblioteka juaj?\n\nSkedarët tuaj audio në disk nuk fshihen.';
  }

  @override
  String get cancel => 'Shfuqizo';

  @override
  String get remove => 'Hiq';

  @override
  String get albumNotFound => 'Albumi nuk u gjet';

  @override
  String get playlistNotFound => 'Playlista nuk u gjet';

  @override
  String get selectToPlay => 'Zgjidh diçka nga biblioteka jote për ta luajtur.';

  @override
  String get speed => 'Shpejtësi';

  @override
  String get previous => 'Më parë';

  @override
  String get pause => 'Ndalo';

  @override
  String get play => 'Luaj';

  @override
  String get next => 'Më tej';

  @override
  String get jumpBack => 'Kthehu 15 sekonda';

  @override
  String get jumpForward => 'Shko përpara 15 sekonda';

  @override
  String get trackFallback => 'Këngë';

  @override
  String get unknownArtist => 'E panjohur';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count këngë · $artist';
  }

  @override
  String get resetDatabase => 'Rinis bazën e të dhënave';

  @override
  String get resetDatabaseTitle => 'Rinisni bazën e të dhënave?';

  @override
  String get resetDatabaseBody =>
      'Kjo pastron pozicionet e riprodhimit, të preferuarat, dosjen e hapur, temën, gjuhën dhe cilësimet e ekualizatorit. Pastrimi i gjithçkaje gjithashtu harron dosjet e bibliotekës së shtuar. Skedarët muzikorë dhe listat e luajtjes në disk nuk fshihen.';

  @override
  String get resetDatabaseKeepFolders => 'Ruaj dosjet e bibliotekës';

  @override
  String get resetDatabaseClearEverything => 'Pastro gjithçka';

  @override
  String get eqManually => 'Me dorë';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Urtë';

  @override
  String get eqVoice => 'Zëri';

  @override
  String get appearance => 'Pamja';

  @override
  String get themeLight => 'E lehtë';

  @override
  String get themeDark => 'I errët';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get language => 'Gjuhë';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get openSourceLicenses => 'Licencat me burim të hapur';

  @override
  String get openSourceLegalese => '© 2026 kontribuesit e Retro Player';

  @override
  String get dataStorage => 'Ruajtja e të dhënave';

  @override
  String get dataStorageIntro =>
      'Retro Player ruan cilësimet e aplikacionit në një bazë të vogël të dhënash lokale. Muzika juaj dhe listat e luajtjes mbeten si skedarë normalë në dosjet që zgjidhni.';

  @override
  String get dataStorageAppDataTitle => 'Baza e të dhënave e aplikacionit';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Skedar: $dbFileName\nRruga: $dbPath\n\nRuan rrënjët e bibliotekës, gjendjen e shfletimit, rifillimin e luajtjes, ekualizatorin, temën dhe preferencat e gjuhës.';
  }

  @override
  String get dataStorageLibraryTitle => 'Skedarë muzike';

  @override
  String get dataStorageLibraryBody =>
      'Skedarët audio kurrë nuk kopjohen në bazën e të dhënave të aplikacionit. Shtoni dosjet e bibliotekës dhe Retro Player i lexon skedarët direkt nga disku.';

  @override
  String get dataStoragePlaylistsTitle => 'Skedarët e listës së luajtjes';

  @override
  String get dataStoragePlaylistsBody =>
      'Playlistat janë skedarë të thjeshtë .m3u të ruajtur brenda dosjeve të bibliotekës suaj. Ju mund t\'i redaktoni ato në aplikacion ose me ndonjë redaktor teksti.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platformë: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Të dhënat e aplikacionit ruhen në dosjen tuaj të mbështetjes së aplikacioneve (zakonisht ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Të dhënat e aplikacionit Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Të dhënat e aplikacionit ruhen në ~/.local/share/app.retroplayer/. Ai dosje është vetëm për bazën e të dhënave dhe cilësimet.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrimi i shiritit të detyrave në Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Për ikonën e shiritit të detyrave dhe rrjetën e aplikacioneve, mjediset e desktopit në Linux presin skedarë të veçantë Freedesktop. Retro Player i instalon këta nga paketa e aplikacionit në fillim:\n\n• ~/.local/share/applications/app.retroplayer.desktop — hyrje në launcher që lidh dritaren e hapur me këtë aplikacion\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikona me temë të kopjuara nga paketa\n\nAi nuk krijon kurrë një skedar hicolor/index.theme për përdoruesin (i cili do të mbulonte temën e sistemit dhe do të fshihte ikonat e tjera). Ikonat janë gjithashtu të ngulitura në binarin e aplikacionit. Kopjet e mësipërme ndihmojnë GNOME/KDE të shfaqë ikonën e saktë të lansuesit në vend të një vendmbajtësi të përgjithshëm.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Lejet dhe ruajtja e Android-it';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player ruan bazën e të dhënave në zonën private të mbështetjes së aplikacionit në ruajtjen e brendshme. Skedarët tuaj të muzikës mbeten në dosjet që zgjidhni me zgjedhësin e dosjeve të sistemit.\n\nNë Android, aplikacioni mund të kërkojë akses audio për të lexuar këngët, dhe akses në foto/imazhe që të mund të shfaqë artin e dosjes (për shembull cover.jpg). Skedarët audio kurrë nuk kopjohen në bazën e të dhënave të aplikacionit.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Lojtimi në sfond i Android-it';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Kur audio po luhet, Retro Player përdor një shërbim media në plan të parë që riprodhimi të vazhdojë edhe nëse bllokoni telefonin ose ndryshoni aplikacionet, me kontrolle transporti në njoftimin e sistemit. Tërheqja e aplikacionit nga seksioni \"Të fundit\" ndalon riprodhimin dhe heq njoftimin.';

  @override
  String get dataStorageIOSAccessTitle => 'Qasja në dosjet e iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player ruan bazën e të dhënave në zonën private të mbështetjes së aplikacionit në ruajtjen e pajisjes. Skedarët tuaj të muzikës mbeten në dosjet që zgjidhni me zgjedhësin e dosjeve të sistemit.\n\niOS jep akses përmes URL-ve me fushë sigurie për dosjet që zgjidhni. Retro Player lexon skedarët direkt nga ato vende; ai nuk kopjon bibliotekën tuaj në ruajtjen e aplikacionit.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Audio në sfond i iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Luajtja mund të vazhdojë ndërsa aplikacioni është në sfond ose ekrani është i kyçur. Pozicionet e rifillimit dhe gjendja e radhës ruhen në bazën lokale të të dhënave të aplikacionit.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Të dhënat e aplikacionit ruhen në zonën private të mbështetjes së aplikacionit në magazinimin e brendshëm.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Të dhënat e aplikacionit ruhen në zonën private të mbështetjes së aplikacionit në ruajtjen e pajisjes.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Të dhënat e aplikacionit ruhen në ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Të dhënat e aplikacionit ruhen në dosjen e mbështetjes së aplikacionit tuaj.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Të dhënat e aplikacionit ruhen në ruajtjen lokale të shfletuesit për këtë origjinë.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Të dhënat e aplikacionit ruhen në zonën e mbështetjes së aplikacioneve të platformës.';

  @override
  String get loading => 'Po ngarkohet…';

  @override
  String get libraryIndex => 'Indeksi i bibliotekës';

  @override
  String get playlists => 'Lista të luajtjes';

  @override
  String get playPlaylist => 'Lësho listën e luajtjes';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gjurmët',
      one: '1 këngë',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Krijo listë lojërash';

  @override
  String get queue => 'Radha';

  @override
  String get saveAsPlaylist => 'Ruaj si listë luajtjeje';

  @override
  String get queueEmpty =>
      'Rreshti është bosh. Shto këngë nga biblioteka jote.';

  @override
  String get choosePlaylistFolder =>
      'Zgjidhni një dosje në bibliotekë. Rrënja e bibliotekës nuk është një dosje.';

  @override
  String get clearQueue => 'Pastro radhën';

  @override
  String get clearQueueTitle => 'Pastroni radhën?';

  @override
  String get clearQueueBody =>
      'Kjo heq çdo këngë nga radha. Skedarët audio dhe listat e luajtjes së ruajtura mbeten.';

  @override
  String get newPlaylistName => 'Emri i listës së luajtjes';

  @override
  String get addTracks => 'Shto këngë';

  @override
  String get addSelectedTracks => 'Shto këngët e zgjedhura';

  @override
  String get save => 'Ruaj';

  @override
  String get addTracksFromLibrary => 'Shto nga biblioteka';

  @override
  String addTracksConfirm(int count) {
    return 'Shto ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Zgjidhni një ose më shumë këngë në bibliotekën tuaj.';

  @override
  String get libraryEmptyNoRoots =>
      'Së pari shto një dosje biblioteke, pastaj zgjidh këngët prej saj.';

  @override
  String get playlistEmpty => 'Kjo listë muzikore nuk ka ende asnjë këngë.';

  @override
  String get missingTrack => 'Skedar i munguar';

  @override
  String get playlistReadOnly => 'Vetëm për lexim';

  @override
  String get playlistSelect => 'Zgjidh';

  @override
  String get playlistSelectAll => 'Zgjidh të gjitha';

  @override
  String get playlistDeselectAll => 'Hiqni të gjitha';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count i zgjedhur',
      one: '1 i zgjedhur',
      zero: 'Zgjidhni këngët',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Heqni $count nga lista e luajtjes?',
      one: 'Heqni këngën nga lista e luajtjes?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kjo heq hyrjet nga skedari i listës së luajtjes kur ruani.',
      one: 'Kjo heq hyrjen nga skedari i listës së luajtjes kur e ruani.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nuk u shtuan këngë të reja. Ato mund të jenë tashmë në listën e luajtjes.';

  @override
  String get addToQueue => 'Shto në radhë';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'U shtuan në radhë: $count',
      one: 'U shtua 1 këngë në radhë',
      zero: 'Nuk u shtua asnjë këngë e re në radhë',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Lëviz lart';

  @override
  String get moveDown => 'Lëviz poshtë';

  @override
  String get playlistNothingToPlay =>
      'Kjo listë nuk ka asnjë këngë të luajtshme.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Fshij listën e luajtjes?';

  @override
  String deletePlaylistBody(String name) {
    return 'Fshi \"$name\"? Kjo heq skedarin e listës së luajtjes nga disku.';
  }
}

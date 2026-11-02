// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Seaded';

  @override
  String get about => 'Info';

  @override
  String get aboutSubtitle =>
      'Ainult kohalik heli. Ei mingeid reklaame, telemeetriat ega juurdepääsu võrgule.\nToetatud vormingud: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versioon';

  @override
  String get aboutBuildDate => 'Ehitusaeg';

  @override
  String get aboutGitBranch => 'Haru';

  @override
  String get aboutGitCommit => 'Koostamine';

  @override
  String get equalizer => 'Ekvalaiser';

  @override
  String get equalizerUnavailable =>
      'Ekvalaiser pole sellel platvormil saadaval.';

  @override
  String get bands => 'Bändid';

  @override
  String get reset => 'Lähtesta';

  @override
  String get library => 'Raamatukogu';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Esitusloend';

  @override
  String get nowPlaying => 'Praegu mängitakse';

  @override
  String get addFolder => 'Lisa kaust';

  @override
  String get audioPermissionRequired => 'Androidi puhul on vaja heliluba';

  @override
  String get expandPlayer => 'Laienda mängijat';

  @override
  String get showLibrary => 'Kuva teek';

  @override
  String errorMessage(String message) {
    return 'Viga: $message';
  }

  @override
  String get noFoldersAdded =>
      'Kaustu pole lisatud. Alustamiseks puuduta nuppu „Lisa kaust“.';

  @override
  String get folderEmpty => 'See kaust on tühi.';

  @override
  String get librarySources => 'Raamatukogu allikad';

  @override
  String get favorites => 'Lemmikud';

  @override
  String get favorite => 'Lemmik';

  @override
  String get removeFavorite => 'Eemalda lemmik';

  @override
  String get folders => 'Kaustad';

  @override
  String get audio => 'Heli';

  @override
  String get playFolder => 'Esita kaust';

  @override
  String get playAlbum => 'Esita album';

  @override
  String get removeLibraryFolderTitle => 'Kas eemaldada teegi kaust?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Kas soovid eemaldada „$name“ oma raamatukogust?\n\nKettal olevad helifailid ei kustutata.';
  }

  @override
  String get cancel => 'Tühista';

  @override
  String get remove => 'Eemalda';

  @override
  String get albumNotFound => 'Albumit ei leitud';

  @override
  String get playlistNotFound => 'Esitusloendit ei leitud';

  @override
  String get selectToPlay => 'Vali oma teegist mängimiseks midagi.';

  @override
  String get speed => 'Kiirus';

  @override
  String get previous => 'Eelmine';

  @override
  String get pause => 'Peata';

  @override
  String get play => 'Esita';

  @override
  String get next => 'Järgmine';

  @override
  String get jumpBack => 'Tagasi 15 sekundit';

  @override
  String get jumpForward => 'Edasi 15 sekundit';

  @override
  String get trackFallback => 'Rada';

  @override
  String get unknownArtist => 'Teadmata';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count roomikut · $artist';
  }

  @override
  String get resetDatabase => 'Lähtesta andmebaas';

  @override
  String get resetDatabaseTitle => 'Kas lähtestada andmebaas?';

  @override
  String get resetDatabaseBody =>
      'See kustutab taasesituse asukohad, lemmikud, avatud kausta, teema, keele ja ekvalaiseri seaded. Tühjenda kõik, unustades ka lisatud teegi kaustad. Kettal olevaid muusikafaile ja esitusloendeid ei kustutata.';

  @override
  String get resetDatabaseKeepFolders => 'Säilita teegi kaustad';

  @override
  String get resetDatabaseClearEverything => 'Tühjenda kõik';

  @override
  String get eqManually => 'Käsitsi';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqTreble => 'Diskant';

  @override
  String get eqVoice => 'Hääl';

  @override
  String get appearance => 'Välimus';

  @override
  String get themeLight => 'Valgus';

  @override
  String get themeDark => 'Tume';

  @override
  String get themeSystem => 'Süsteem';

  @override
  String get language => 'Keel';

  @override
  String get languageSystem => 'Süsteem';

  @override
  String get openSourceLicenses => 'Avatud lähtekoodiga litsentsid';

  @override
  String get openSourceLegalese => '© 2026 Retro Playeri kaastöötajad';

  @override
  String get dataStorage => 'Andmete säilitamine';

  @override
  String get dataStorageIntro =>
      'Retro Player hoiab rakenduse seadeid väikeses kohalikus andmebaasis. Teie muusika ja esitusloendid jäävad teie valitud kaustades tavalisteks failideks.';

  @override
  String get dataStorageAppDataTitle => 'Rakenduste andmebaas';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fail: $dbFileName\nTee: $dbPath\n\nSalvestab teegi juured, sirvimisoleku, taasesituse jätkamise, ekvalaiseri, teema ja keele-eelistused.';
  }

  @override
  String get dataStorageLibraryTitle => 'Muusikafailid';

  @override
  String get dataStorageLibraryBody =>
      'Helifaile ei kopeerita kunagi rakenduse andmebaasi. Lisa teegi kaustu ja Retro Player loeb faile otse kettalt.';

  @override
  String get dataStoragePlaylistsTitle => 'Esitusloendi failid';

  @override
  String get dataStoragePlaylistsBody =>
      'Esitusloendid on tavalised .m3u-failid, mis on salvestatud teie teegi kaustadesse. Saad neid muuta rakenduses või mis tahes tekstiredaktoris.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platvorm: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Rakenduse andmed salvestatakse sinu rakenduse tugikataloogi (tavaliselt ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Linuxi rakenduse andmed';

  @override
  String get dataStorageLinuxDataBody =>
      'Rakenduse andmed jäävad asukohta ~/.local/share/app.retroplayer/. See kaust on ainult andmebaasi ja seadete jaoks.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Linuxi tegumiriba integreerimine';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Tegumiriba ja rakenduse ruudustiku ikooni jaoks ootavad Linuxi töölauakeskkonnad eraldi Freedesktopi faile. Retro Player installib need rakenduste komplektist käivitamisel:\n\n• ~/.local/share/applications/app.retroplayer.desktop — käivitaja kirje, mis ühendab töötava akna selle rakendusega\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — paketist kopeeritud temaatilised ikoonid\n\nSee ei kirjuta kunagi kasutaja hicolor/index.theme (mis varjaks süsteemi teemat ja peidaks teisi ikoone). Ikoonid on manustatud ka rakenduse binaarfaili. Ülaltoodud koopiad aitavad GNOME/kde-l kuvada üldise kohatäite asemel õiget käivitaja ikooni.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Androidi õigused ja salvestusruum';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player salvestab oma andmebaasi rakenduste privaatsesse tugialasse sisemälus. Teie muusikafailid jäävad kaustadesse, mille valite süsteemikaustade valijaga.\n\nAndroidi puhul võib rakendus taotleda audiojuurdepääsu lugudele ja juurdepääsu fotodele/piltidele, et saaks kuvada kaustade kujundust (nt cover.jpg). Helifaile ei kopeerita kunagi rakenduse andmebaasi.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Androidi tausta taasesitus';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Kui heli mängib, käivitab Retro Player esiplaanil meediateenuse, nii et taasesitus jätkub, kui lukustate telefoni või lülitate rakendusi, kusjuures süsteemiteatises on transpordi juhtnupud. Rakenduse viimaste hulgast eemaldamine peatab taasesituse ja eemaldab teavituse.';

  @override
  String get dataStorageIOSAccessTitle => 'juurdepääs iOS-i kaustale';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player salvestab oma andmebaasi seadme salvestusruumi rakenduse privaatses tugialas. Teie muusikafailid jäävad kaustadesse, mille valite süsteemikaustade valijaga.\n\niOS annab sinu valitud kaustadele juurdepääsu turvaskoobiga URL-ide kaudu. Retro Player loeb faile otse nendest asukohtadest; see ei kopeeri teie teeki rakenduse salvestusruumi.';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS-i taustaheli';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Taasesitus võib jätkuda, kui rakendus on taustal või ekraan on lukustatud. Jätkamiskohad ja järjekorra olek salvestatakse kohaliku rakenduse andmebaasi.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Rakenduse andmed salvestatakse rakenduse privaatsesse tugialasse sisemälus.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Rakenduse andmed salvestatakse seadme salvestusruumis rakenduse privaatsesse tugialasse.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Rakenduse andmed salvestatakse aadressil ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Rakenduse andmed salvestatakse sinu rakenduse tugikataloogi.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Rakenduse andmed salvestatakse brauseris - selle päritolu jaoks kohalikus salvestusruumis.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Rakenduse andmed salvestatakse platvormirakenduse tugialal.';

  @override
  String get loading => 'Laadimine…';

  @override
  String get libraryIndex => 'Teegi register';

  @override
  String get playlists => 'Esitusloendid';

  @override
  String get playPlaylist => 'Esita esitusloend';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugu',
      one: '1 lugu',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Loo esitusloend';

  @override
  String get queue => 'Järjekord';

  @override
  String get saveAsPlaylist => 'Salvesta esitusloendina';

  @override
  String get queueEmpty => 'Järjekord on tühi. Lisa oma teegist lugusid.';

  @override
  String get choosePlaylistFolder =>
      'Vali kaust teegist. Teegi juur pole kaust.';

  @override
  String get clearQueue => 'Tühjenda järjekord';

  @override
  String get clearQueueTitle => 'Kas tühjendada järjekord?';

  @override
  String get clearQueueBody =>
      'See eemaldab järjekorrast kõik rajad. Helifailid ja salvestatud esitusloendid jäävad alles.';

  @override
  String get newPlaylistName => 'Esitusloendi nimi';

  @override
  String get addTracks => 'Lisa lugusid';

  @override
  String get save => 'Salvesta';

  @override
  String get addTracksFromLibrary => 'Lisa teegist';

  @override
  String addTracksConfirm(int count) {
    return 'Lisa ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Vali oma teegist üks või mitu muusikapala.';

  @override
  String get libraryEmptyNoRoots =>
      'Lisa esmalt teegi kaust ja vali sealt palad.';

  @override
  String get playlistEmpty => 'Sellel esitusloendil pole veel lugusid.';

  @override
  String get missingTrack => 'Fail puudub';

  @override
  String get playlistReadOnly => 'Kirjutuskaitstud';

  @override
  String get playlistSelect => 'Vali';

  @override
  String get playlistSelectAll => 'Vali kõik';

  @override
  String get playlistDeselectAll => 'Tühista kõigi valik';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valitud',
      one: '1 valitud',
      zero: 'Vali lood',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kas soovid eemaldada $count lood esitusloendist?',
      one: 'Kas soovid loo esitusloendist eemaldada?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'See eemaldab kirjed esitusloendi failist salvestamisel.',
      one: 'See eemaldab kirje esitusloendi failist salvestamisel.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Uusi lugusid ei lisatud. Need võivad juba esitusloendis olla.';

  @override
  String get addToQueue => 'Lisa järjekorda';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Järjekorda lisatud: $count',
      one: 'Järjekorda lisati 1 lugu',
      zero: 'Järjekorda ei lisatud uusi lugusid',
    );
    return '$_temp0';
  }

  @override
  String get playlistNothingToPlay =>
      'Sellel esitusloendil pole esitatavaid lugusid.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Kas kustutada esitusloend?';

  @override
  String deletePlaylistBody(String name) {
    return 'Kustuta \"$name\"? See eemaldab esitusloendi faili kettalt.';
  }
}

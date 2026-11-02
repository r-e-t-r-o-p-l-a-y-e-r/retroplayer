// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Nastavenia';

  @override
  String get about => 'O nás';

  @override
  String get aboutSubtitle =>
      'Iba lokálne audio. Žiadne reklamy, žiadna telemetria, žiadny prístup k sieti.\nPodporované formáty: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Verzia';

  @override
  String get aboutBuildDate => 'Doba zostavenia';

  @override
  String get aboutGitBranch => 'Vetva';

  @override
  String get aboutGitCommit => 'Zostavenie';

  @override
  String get equalizer => 'Ekvalizér';

  @override
  String get equalizerUnavailable =>
      'Na tejto platforme nie je k dispozícii ekvalizér.';

  @override
  String get bands => 'Kapely';

  @override
  String get reset => 'Vrátiť do pôvodného stavu';

  @override
  String get library => 'Knižnica';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Zoznam skladieb';

  @override
  String get nowPlaying => 'Práve prehráva';

  @override
  String get addFolder => 'Pridať priečinok';

  @override
  String get audioPermissionRequired =>
      'V systéme Android je potrebné povolenie na prístup k zvuku';

  @override
  String get expandPlayer => 'Rozbaliť prehrávač';

  @override
  String get showLibrary => 'Zobraziť knižnicu';

  @override
  String errorMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get noFoldersAdded =>
      'Neboli pridané žiadne priečinky. Ťuknite na „Pridať priečinok“, aby ste mohli začať.';

  @override
  String get folderEmpty => 'Táto zložka je prázdna.';

  @override
  String get librarySources => 'Knižničné zdroje';

  @override
  String get favorites => 'Obľúbené';

  @override
  String get favorite => 'Obľúbené';

  @override
  String get removeFavorite => 'Odstrániť z obľúbených';

  @override
  String get folders => 'Zložky';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Zložka „Play“';

  @override
  String get playAlbum => 'Prehrať album';

  @override
  String get removeLibraryFolderTitle => 'Odstrániť priečinok s knižnicou?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Chcete odstrániť „$name“ z vašej knižnice?\n\nVaše zvukové súbory na disku nebudú odstránené.';
  }

  @override
  String get cancel => 'Zrušiť';

  @override
  String get remove => 'Odstrániť';

  @override
  String get albumNotFound => 'Album sa nenašiel';

  @override
  String get playlistNotFound => 'Zoznam skladieb nebol nájdený';

  @override
  String get selectToPlay =>
      'Vyberte si niečo zo svojej knižnice na prehrávanie.';

  @override
  String get speed => 'Rýchlosť';

  @override
  String get previous => 'Predchádzajúce';

  @override
  String get pause => 'Pauza';

  @override
  String get play => 'Hrať';

  @override
  String get next => 'Ďalej';

  @override
  String get jumpBack => 'Späť o 15 sekúnd';

  @override
  String get jumpForward => 'Posunúť o 15 sekúnd dopredu';

  @override
  String get trackFallback => 'Trať';

  @override
  String get unknownArtist => 'Neznáme';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count skladieb · $artist';
  }

  @override
  String get resetDatabase => 'Obnoviť databázu';

  @override
  String get resetDatabaseTitle => 'Obnoviť databázu?';

  @override
  String get resetDatabaseBody =>
      'Týmto sa vymažú polohy prehrávania, obľúbené položky, otvorená zložka, motív, jazyk a nastavenia ekvalizéra. Funkcia „Vymazať všetko“ tiež odstráni pridané zložky knižnice. Hudobné súbory a zoznamy skladieb na disku sa nevymažú.';

  @override
  String get resetDatabaseKeepFolders => 'Zachovať priečinky knižnice';

  @override
  String get resetDatabaseClearEverything => 'Vymazať všetko';

  @override
  String get eqManually => 'Ručne';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Vysoké tóny';

  @override
  String get eqVoice => 'Hlas';

  @override
  String get appearance => 'Vzhľad';

  @override
  String get themeLight => 'Svetlo';

  @override
  String get themeDark => 'Tma';

  @override
  String get themeSystem => 'Systém';

  @override
  String get language => 'Jazyk';

  @override
  String get languageSystem => 'Systém';

  @override
  String get openSourceLicenses => 'Licencie otvoreného zdrojového kódu';

  @override
  String get openSourceLegalese => '© 2026 Prispievatelia Retro Player';

  @override
  String get dataStorage => 'Ukladanie údajov';

  @override
  String get dataStorageIntro =>
      'Aplikácia Retro Player ukladá nastavenia aplikácie do malej lokálnej databázy. Vaša hudba a zoznamy skladieb zostávajú ako bežné súbory v priečinkoch, ktoré si sami vyberiete.';

  @override
  String get dataStorageAppDataTitle => 'Databáza aplikácií';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Súbor: $dbFileName\nCesta: $dbPath\n\nUkladá nastavenia koreňových adresárov knižníc, stav prehliadania, obnovenie prehrávania, ekvalizér, motív a jazyk.';
  }

  @override
  String get dataStorageLibraryTitle => 'Hudobné súbory';

  @override
  String get dataStorageLibraryBody =>
      'Zvukové súbory sa nikdy nekopírujú do databázy aplikácie. Pridajte priečinky s knižnicou a Retro Player bude súbory čítať priamo z disku.';

  @override
  String get dataStoragePlaylistsTitle => 'Súbory zoznamov skladieb';

  @override
  String get dataStoragePlaylistsBody =>
      'Zoznamy skladieb sú bežné súbory s príponou .m3u uložené vo vašich priečinkoch knižnice. Môžete ich upravovať v aplikácii alebo pomocou ľubovoľného textového editora.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Dáta aplikácie sú uložené v adresári app-support (zvyčajne ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Dáta aplikácií pre Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Dáta aplikácie sa ukladajú do adresára ~/.local/share/app.retroplayer/. Tento adresár slúži výlučne na ukladanie databázy a nastavení.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrácia s hlavným panelom v systéme Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Pre ikonu na paneli úloh a v mriežke aplikácií vyžadujú desktopové prostredia Linuxu samostatné súbory Freedesktop. Retro Player ich pri spustení nainštaluje z balíka aplikácie:\n\n• ~/.local/share/applications/app.retroplayer.desktop — položka spúšťača, ktorá prepojí spustené okno s touto aplikáciou\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — tematické ikony skopírované z balíka\n\nNikdy nevytvára používateľský súbor hicolor/index.theme (ktorý by prekryl systémovú tému a skryl ostatné ikony). Ikony sú tiež vložené do binárneho súboru aplikácie. Vyššie uvedené kópie pomáhajú prostrediam GNOME/KDE zobraziť správnu ikonu spúšťača namiesto generického zástupného symbolu.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Oprávnenia a úložisko v systéme Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Aplikácia Retro Player ukladá svoju databázu do súkromnej podporné oblasti aplikácie vo vnútornom úložisku. Vaše hudobné súbory zostávajú v priečinkoch, ktoré si vyberiete pomocou systémového výberu priečinkov.\n\nV systéme Android môže aplikácia požiadať o prístup k zvukovým súborom na čítanie skladieb a o prístup k fotografiám/obrázkom, aby bolo možné zobraziť obaly albumov (napríklad cover.jpg). Zvukové súbory sa nikdy nekopírujú do databázy aplikácie.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Prehrávanie na pozadí v systéme Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Počas prehrávania zvuku spúšťa Retro Player mediálnu službu v popredí, vďaka čomu prehrávanie pokračuje aj v prípade, že telefón uzamknete alebo prepnete medzi aplikáciami, pričom ovládacie prvky prehrávania sa zobrazujú v systémovej notifikácii. Ak aplikáciu potiahnete preč zo zoznamu nedávno používaných aplikácií, prehrávanie sa zastaví a notifikácia sa skryje.';

  @override
  String get dataStorageIOSAccessTitle => 'Prístup k zložkám v systéme iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Aplikácia Retro Player ukladá svoju databázu v súkromnej podporné oblasti aplikácie v úložisku zariadenia. Vaše hudobné súbory zostávajú v priečinkoch, ktoré si vyberiete pomocou systémového výberu priečinkov.\n\nSystém iOS udeľuje prístup k priečinkom, ktoré vyberiete, prostredníctvom URL adries s obmedzeným bezpečnostným rozsahom. Aplikácia Retro Player číta súbory priamo z týchto umiestnení; vašu knižnicu nekopíruje do úložiska aplikácie.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Zvuk na pozadí v systéme iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Prehrávanie môže pokračovať aj vtedy, keď je aplikácia spustená na pozadí alebo je obrazovka uzamknutá. Pozície, od ktorých sa má prehrávanie obnoviť, a stav fronty sa ukladajú do lokálnej databázy aplikácie.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Dáta aplikácie sa ukladajú v súkromnej podporné oblasti aplikácie vo vnútornom úložisku.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Dáta aplikácie sa ukladajú v súkromnej podporné oblasti aplikácie v úložisku zariadenia.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Dáta aplikácie sú uložené v priečinku ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Dáta aplikácie sú uložené v adresári na podporu aplikácií.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Dáta aplikácie sa ukladajú do lokálneho úložiska prehliadača pre tento pôvod.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Dáta aplikácie sa ukladajú v oblasti podpory aplikácií platformy.';

  @override
  String get loading => 'Načítava sa…';

  @override
  String get libraryIndex => 'Zoznam knižnice';

  @override
  String get playlists => 'Zoznamy skladieb';

  @override
  String get playPlaylist => 'Prehrať zoznam skladieb';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skladby',
      one: '1 skladba',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Vytvoriť zoznam skladieb';

  @override
  String get queue => 'Čakacia fronta';

  @override
  String get saveAsPlaylist => 'Uložiť ako zoznam skladieb';

  @override
  String get queueEmpty =>
      'Zoznam skladieb je prázdny. Pridajte skladby zo svojej knižnice.';

  @override
  String get choosePlaylistFolder =>
      'Vyberte priečinok v knižnici. Koreňový priečinok knižnice nie je priečinok.';

  @override
  String get clearQueue => 'Vymazať frontu';

  @override
  String get clearQueueTitle => 'Vymazať frontu?';

  @override
  String get clearQueueBody =>
      'Týmto sa odstránia všetky skladby z fronty. Zvukové súbory a uložené zoznamy skladieb zostanú zachované.';

  @override
  String get newPlaylistName => 'Názov zoznamu skladieb';

  @override
  String get addTracks => 'Pridať skladby';

  @override
  String get save => 'Uložiť';

  @override
  String get addTracksFromLibrary => 'Pridať z knižnice';

  @override
  String addTracksConfirm(int count) {
    return 'Pridať ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Vyberte jednu alebo viac skladieb vo vašej knižnici.';

  @override
  String get libraryEmptyNoRoots =>
      'Najskôr pridajte priečinok s knižnicou a potom z neho vyberte skladby.';

  @override
  String get playlistEmpty =>
      'Tento zoznam skladieb zatiaľ neobsahuje žiadne skladby.';

  @override
  String get missingTrack => 'Chýbajúci súbor';

  @override
  String get playlistReadOnly => 'Iba na čítanie';

  @override
  String get playlistSelect => 'Vybrať';

  @override
  String get playlistSelectAll => 'Vybrať všetko';

  @override
  String get playlistDeselectAll => 'Zrušiť výber všetkých';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vybrané',
      one: '1 vybraný',
      zero: 'Vybrať skladby',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstrániť skladby $count zo zoznamu skladieb?',
      one: 'Odstrániť skladbu zo zoznamu skladieb?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Týmto sa pri uložení odstránia položky zo súboru so zoznamom skladieb.',
      one: 'Týmto sa pri uložení odstráni záznam zo súboru so zoznamom skladieb.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Neboli pridané žiadne nové skladby. Možno už sú v zozname skladieb.';

  @override
  String get addToQueue => 'Pridať do čakacej fronty';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pridané do čakacej fronty: $count',
      one: 'Do čakacej fronty bola pridaná 1 skladba',
      zero: 'Do čakacej fronty neboli pridané žiadne nové skladby',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Posunúť nahor';

  @override
  String get moveDown => 'Posunúť nadol';

  @override
  String get playlistNothingToPlay =>
      'Tento zoznam skladieb neobsahuje žiadne skladby, ktoré by sa dali prehrať.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Odstrániť zoznam skladieb?';

  @override
  String deletePlaylistBody(String name) {
    return 'Odstrániť „$name“? Týmto sa súbor so zoznamom skladieb odstráni z disku.';
  }
}

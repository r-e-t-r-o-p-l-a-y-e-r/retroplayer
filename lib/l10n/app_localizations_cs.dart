// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Nastavení';

  @override
  String get about => 'O nás';

  @override
  String get aboutSubtitle =>
      'Pouze místní zvuk. Žádné reklamy, žádná telemetrie, žádný přístup k síti.\nPodporované formáty: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Verze';

  @override
  String get aboutBuildDate => 'Doba sestavení';

  @override
  String get aboutGitBranch => 'Větev';

  @override
  String get aboutGitCommit => 'Sestavení';

  @override
  String get equalizer => 'Ekvalizér';

  @override
  String get equalizerUnavailable =>
      'Na této platformě není ekvalizér k dispozici.';

  @override
  String get bands => 'Kapely';

  @override
  String get reset => 'Obnovit';

  @override
  String get library => 'Knihovna';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Seznam skladeb';

  @override
  String get nowPlaying => 'Právě hraje';

  @override
  String get addFolder => 'Přidat složku';

  @override
  String get audioPermissionRequired =>
      'V systému Android je nutné udělit oprávnění pro zvuk';

  @override
  String get expandPlayer => 'Rozbalit přehrávač';

  @override
  String get showLibrary => 'Zobrazit knihovnu';

  @override
  String errorMessage(String message) {
    return 'Chyba: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nebyly přidány žádné složky. Klepnutím na „Přidat složku“ můžete začít.';

  @override
  String get folderEmpty => 'Tato složka je prázdná.';

  @override
  String get librarySources => 'Knihovní zdroje';

  @override
  String get favorites => 'Oblíbené';

  @override
  String get favorite => 'Oblíbené';

  @override
  String get removeFavorite => 'Odstranit z oblíbených';

  @override
  String get folders => 'Složky';

  @override
  String get audio => 'Zvuk';

  @override
  String get playFolder => 'Složka „Play“';

  @override
  String get playAlbum => 'Přehrát album';

  @override
  String get removeLibraryFolderTitle => 'Odstranit složku knihovny?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Chcete odstranit „$name“ z knihovny?\n\nVaše zvukové soubory na disku nebudou smazány.';
  }

  @override
  String get cancel => 'Zrušit';

  @override
  String get remove => 'Odebrat';

  @override
  String get albumNotFound => 'Album nebylo nalezeno';

  @override
  String get playlistNotFound => 'Seznam skladeb nebyl nalezen';

  @override
  String get selectToPlay => 'Vyberte si z knihovny něco k přehrání.';

  @override
  String get speed => 'Rychlost';

  @override
  String get previous => 'Předchozí';

  @override
  String get pause => 'Pauza';

  @override
  String get play => 'Hrát';

  @override
  String get next => 'Dále';

  @override
  String get jumpBack => 'O 15 sekund zpět';

  @override
  String get jumpForward => 'Posunout o 15 sekund dopředu';

  @override
  String get trackFallback => 'Trať';

  @override
  String get unknownArtist => 'Neznámé';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count skladeb · $artist';
  }

  @override
  String get resetDatabase => 'Obnovit databázi';

  @override
  String get resetDatabaseTitle => 'Obnovit databázi?';

  @override
  String get resetDatabaseBody =>
      'Tím se vymažou pozice přehrávání, oblíbené položky, otevřená složka, motiv, jazyk a nastavení ekvalizéru. Funkce „Vymazat vše“ také odstraní přidané složky knihovny. Hudební soubory a seznamy skladeb na disku se nesmažou.';

  @override
  String get resetDatabaseKeepFolders => 'Zachovat složky knihovny';

  @override
  String get resetDatabaseClearEverything => 'Vymazat vše';

  @override
  String get eqManually => 'Ručně';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Výšky';

  @override
  String get eqVoice => 'Hlas';

  @override
  String get appearance => 'Vzhled';

  @override
  String get themeLight => 'Světlo';

  @override
  String get themeDark => 'Tma';

  @override
  String get themeSystem => 'Systém';

  @override
  String get language => 'Jazyk';

  @override
  String get languageSystem => 'Systém';

  @override
  String get openSourceLicenses => 'Licence open source';

  @override
  String get openSourceLegalese => '© 2026 Přispěvatelé Retro Playeru';

  @override
  String get dataStorage => 'Ukládání dat';

  @override
  String get dataStorageIntro =>
      'Aplikace Retro Player ukládá nastavení aplikace do malé lokální databáze. Vaše hudba a seznamy skladeb zůstávají jako běžné soubory ve složkách, které si sami vyberete.';

  @override
  String get dataStorageAppDataTitle => 'Databáze aplikací';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Soubor: $dbFileName\nCesta: $dbPath\n\nUkládá kořenové adresáře knihoven, stav procházení, obnovení přehrávání, ekvalizér, motiv a jazykové předvolby.';
  }

  @override
  String get dataStorageLibraryTitle => 'Hudební soubory';

  @override
  String get dataStorageLibraryBody =>
      'Zvukové soubory se nikdy nekopírují do databáze aplikace. Přidejte složky s knihovnou a Retro Player bude soubory načítat přímo z disku.';

  @override
  String get dataStoragePlaylistsTitle => 'Soubory se seznamy skladeb';

  @override
  String get dataStoragePlaylistsBody =>
      'Seznamy skladeb jsou prosté soubory ve formátu .m3u uložené ve složkách vaší knihovny. Můžete je upravovat v aplikaci nebo v libovolném textovém editoru.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Data aplikace jsou uložena ve složce app-support (obvykle ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Data aplikací pro Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Data aplikace se ukládají do složky ~/.local/share/app.retroplayer/. Tato složka slouží výhradně pro databázi a nastavení.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrace s hlavním panelem v systému Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Pro ikonu na hlavním panelu a v mřížce aplikací vyžadují desktopová prostředí Linuxu samostatné soubory Freedesktop. Retro Player je při spuštění nainstaluje z balíčku aplikace:\n\n• ~/.local/share/applications/app.retroplayer.desktop — položka spouštěče, která propojuje spuštěné okno s touto aplikací\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikony v daném motivu zkopírované z balíčku\n\nNikdy nevytváří uživatelský soubor hicolor/index.theme (který by zastínil systémové téma a skryl ostatní ikony). Ikony jsou také zabudovány do binárního souboru aplikace. Výše uvedené kopie pomáhají prostředí GNOME/KDE zobrazit správnou ikonu spouštěče namísto obecného zástupného symbolu.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Oprávnění a úložiště v systému Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Aplikace Retro Player ukládá svou databázi do soukromé podpůrné oblasti aplikace ve vnitřním úložišti. Vaše hudební soubory zůstávají ve složkách, které vyberete pomocí systémového výběru složek.\n\nV systému Android může aplikace požádat o přístup k audiu za účelem čtení skladeb a o přístup k fotografiím/obrázkům, aby bylo možné zobrazit obaly alb (například cover.jpg). Zvukové soubory se nikdy nekopírují do databáze aplikace.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Přehrávání na pozadí v systému Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Při přehrávání zvuku spouští Retro Player mediální službu v popředí, takže přehrávání pokračuje i po uzamčení telefonu nebo přepnutí mezi aplikacemi, přičemž ovládací prvky přehrávání se zobrazují v systémové notifikaci. Odstraněním aplikace z seznamu nedávno použitých aplikací se přehrávání zastaví a notifikace zmizí.';

  @override
  String get dataStorageIOSAccessTitle => 'Přístup ke složkám v systému iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Aplikace Retro Player ukládá svou databázi do soukromé podpůrné oblasti aplikace v úložišti zařízení. Vaše hudební soubory zůstávají ve složkách, které si vyberete pomocí systémového výběru složek.\n\nSystém iOS uděluje přístup k vámi vybraným složkám prostřednictvím URL adres s omezeným bezpečnostním rozsahem. Aplikace Retro Player načítá soubory přímo z těchto umístění; vaši knihovnu nekopíruje do úložiště aplikace.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Zvuk na pozadí v systému iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Přehrávání může pokračovat i tehdy, když je aplikace spuštěna na pozadí nebo je obrazovka uzamčena. Pozice, od které se má přehrávání obnovit, a stav fronty se ukládají do místní databáze aplikace.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Data aplikace jsou uložena v soukromé podpůrné oblasti aplikace na interním úložišti.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Data aplikace jsou uložena v soukromé podpůrné oblasti aplikace v úložišti zařízení.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Data aplikace jsou uložena ve složce ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Data aplikace jsou uložena ve vašem adresáři „Application Support“.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Data aplikace jsou uložena v lokálním úložišti prohlížeče pro tento původ.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Data aplikace se ukládají v oblasti podpory aplikací platformy.';

  @override
  String get loading => 'Načítání…';

  @override
  String get libraryIndex => 'Rejstřík knihovny';

  @override
  String get playlists => 'Seznamy skladeb';

  @override
  String get playPlaylist => 'Přehrát seznam skladeb';

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
  String get createPlaylist => 'Vytvořit seznam skladeb';

  @override
  String get queue => 'Fronta';

  @override
  String get saveAsPlaylist => 'Uložit jako seznam skladeb';

  @override
  String get queueEmpty =>
      'Seznam skladeb je prázdný. Přidejte skladby ze své knihovny.';

  @override
  String get choosePlaylistFolder =>
      'Vyberte složku v knihovně. Kořenový adresář knihovny není složkou.';

  @override
  String get clearQueue => 'Vymazat frontu';

  @override
  String get clearQueueTitle => 'Vymazat frontu?';

  @override
  String get clearQueueBody =>
      'Tím se odstraní všechny skladby z fronty. Zvukové soubory a uložené seznamy skladeb zůstanou zachovány.';

  @override
  String get newPlaylistName => 'Název seznamu skladeb';

  @override
  String get addTracks => 'Přidat skladby';

  @override
  String get addSelectedTracks => 'Přidat vybrané skladby';

  @override
  String get save => 'Uložit';

  @override
  String get addTracksFromLibrary => 'Přidat z knihovny';

  @override
  String addTracksConfirm(int count) {
    return 'Přidat ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Vyberte jednu nebo více skladeb ve své knihovně.';

  @override
  String get libraryEmptyNoRoots =>
      'Nejprve přidejte složku s knihovnou a poté z ní vyberte skladby.';

  @override
  String get playlistEmpty =>
      'Tento seznam skladeb zatím neobsahuje žádné skladby.';

  @override
  String get missingTrack => 'Chybějící soubor';

  @override
  String get playlistReadOnly => 'Pouze pro čtení';

  @override
  String get playlistSelect => 'Vybrat';

  @override
  String get playlistSelectAll => 'Vybrat vše';

  @override
  String get playlistDeselectAll => 'Zrušit výběr všeho';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vybráno',
      one: '1 vybráno',
      zero: 'Vybrat skladby',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstranit skladby $count ze seznamu skladeb?',
      one: 'Odstranit skladbu ze seznamu skladeb?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tím se při uložení odstraní položky ze souboru se seznamem skladeb.',
      one:
          'Tím se při uložení odstraní položka ze souboru se seznamem skladeb.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nebyly přidány žádné nové skladby. Možná už jsou v seznamu skladeb.';

  @override
  String get addToQueue => 'Přidat do fronty';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přidáno do fronty: $count',
      one: 'Do fronty byla přidána 1 skladba',
      zero: 'Do fronty nebyly přidány žádné nové skladby',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Posunout nahoru';

  @override
  String get moveDown => 'Posunout dolů';

  @override
  String get playlistNothingToPlay =>
      'Tento seznam skladeb neobsahuje žádné skladby, které by bylo možné přehrát.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Smazat seznam skladeb?';

  @override
  String deletePlaylistBody(String name) {
    return 'Odstranit „$name“? Tím se soubor se seznamem skladeb odstraní z disku.';
  }
}

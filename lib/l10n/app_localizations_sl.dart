// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Nastavitve';

  @override
  String get about => 'O nas';

  @override
  String get aboutSubtitle =>
      'Samo lokalni zvok. Brez oglasov, brez telemetrije, brez dostopa do omrežja.\nPodprti formati: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Različica';

  @override
  String get aboutBuildDate => 'Čas izdelave';

  @override
  String get aboutGitBranch => 'Veja';

  @override
  String get aboutGitCommit => 'Zgradba';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Na tej platformi izenačevalnik ni na voljo.';

  @override
  String get bands => 'Glasbene skupine';

  @override
  String get reset => 'Ponastavi';

  @override
  String get library => 'Knjižnica';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Seznam predvajanja';

  @override
  String get nowPlaying => 'Trenutno predvaja';

  @override
  String get addFolder => 'Dodaj mapo';

  @override
  String get audioPermissionRequired =>
      'Na sistemu Android je potrebno dovoljenje za predvajanje zvoka';

  @override
  String get expandPlayer => 'Razširi predvajalnik';

  @override
  String get showLibrary => 'Prikaži knjižnico';

  @override
  String errorMessage(String message) {
    return 'Napaka: $message';
  }

  @override
  String get noFoldersAdded =>
      'Ni dodanih map. Za začetek tapnite »Dodaj mapo«.';

  @override
  String get folderEmpty => 'Ta mapa je prazna.';

  @override
  String get librarySources => 'Knjižnični viri';

  @override
  String get favorites => 'Priljubljene';

  @override
  String get favorite => 'Priljubljeno';

  @override
  String get removeFavorite => 'Odstrani iz priljubljenih';

  @override
  String get folders => 'Mape';

  @override
  String get audio => 'Zvok';

  @override
  String get playFolder => 'Mapa »Play«';

  @override
  String get playAlbum => 'Predvajaj album';

  @override
  String get removeLibraryFolderTitle => 'Naj odstranim mapo z knjižnico?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Želite iz knjižnice odstraniti »$name«?\n\nVaše zvočne datoteke na disku se ne bodo izbrisale.';
  }

  @override
  String get cancel => 'Prekliči';

  @override
  String get remove => 'Odstrani';

  @override
  String get albumNotFound => 'Album ni bil najden';

  @override
  String get playlistNotFound => 'Seznam predvajanja ni bil najden';

  @override
  String get selectToPlay =>
      'Izberite nekaj iz svoje knjižnice, da si to predvajate.';

  @override
  String get speed => 'Hitrost';

  @override
  String get previous => 'Prejšnja';

  @override
  String get pause => 'Premor';

  @override
  String get play => 'Igraj';

  @override
  String get next => 'Naprej';

  @override
  String get jumpBack => 'Nazaj za 15 sekund';

  @override
  String get jumpForward => 'Preskoči 15 sekund naprej';

  @override
  String get chapters => 'Poglavja';

  @override
  String get previousChapter => 'Prejšnje poglavje';

  @override
  String get nextChapter => 'Naslednje poglavje';

  @override
  String get headphones => 'Slušalke';

  @override
  String get autoRewind => 'Ob nadaljevanju previj nazaj';

  @override
  String get autoRewindHint =>
      'Po premoru vsaj ene minute se skladbe, daljše od 20 minut, nadaljujejo nekaj sekund prej.';

  @override
  String get rewindBy => 'Previj nazaj za';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Nadaljuj, ko se slušalke znova povežejo';

  @override
  String get resumeOnReconnectHint =>
      'Samo če se je predvajanje ustavilo, ker so bile slušalke odklopljene pred manj kot 10 minutami.';

  @override
  String get trackFallback => 'Proga';

  @override
  String get unknownArtist => 'Neznano';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skladb · $artist',
      one: '$count skladba · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Ponastavi bazo podatkov';

  @override
  String get resetDatabaseTitle => 'Ponastaviti bazo podatkov?';

  @override
  String get resetDatabaseBody =>
      'S tem se izbrišejo nastavitve predvajanja, priljubljene vsebine, odprta mapa, tema, jezik in izenačevalnik. Z izbrišanjem vsega se izbrišejo tudi dodane mape v knjižnici. Glasbene datoteke in seznami predvajanja na disku se ne izbrišejo.';

  @override
  String get resetDatabaseKeepFolders => 'Ohranite mape knjižnice';

  @override
  String get resetDatabaseClearEverything => 'Izbriši vse';

  @override
  String get eqManually => 'Ročno';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Visoki toni';

  @override
  String get eqVoice => 'Glas';

  @override
  String get appearance => 'Videz';

  @override
  String get themeLight => 'Svetloba';

  @override
  String get themeDark => 'Temno';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get language => 'Jezik';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get openSourceLicenses => 'Licence odprte kode';

  @override
  String get openSourceLegalese => '© 2026 Avtorji prispevkov za Retro Player';

  @override
  String get dataStorage => 'Shranjevanje podatkov';

  @override
  String get dataStorageIntro =>
      'Retro Player shranjuje nastavitve aplikacije v majhni lokalni bazi podatkov. Vaša glasba in seznami predvajanja ostanejo kot običajne datoteke v mapah, ki jih izberete.';

  @override
  String get dataStorageAppDataTitle => 'Baza podatkov aplikacij';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Datoteka: $dbFileName\nPot: $dbPath\n\nShranjuje nastavitve za korenske mape knjižnic, stanje brskanja, nadaljevanje predvajanja, ekvalizer, temo in jezik.';
  }

  @override
  String get dataStorageLibraryTitle => 'Glasbene datoteke';

  @override
  String get dataStorageLibraryBody =>
      'Zvočne datoteke se nikoli ne kopirajo v bazo podatkov aplikacije. Dodajte mape s knjižnico in Retro Player bo datoteke bral neposredno z diska.';

  @override
  String get dataStoragePlaylistsTitle => 'Datoteke s seznami predvajanja';

  @override
  String get dataStoragePlaylistsBody =>
      'Seznami predvajanja so navadne datoteke .m3u, shranjene v mapah vaše knjižnice. Urejate jih lahko v aplikaciji ali s katerim koli urejevalnikom besedil.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Podatki aplikacije so shranjeni v mapi app-support (običajno ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Podatki o aplikacijah za Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Podatki aplikacije se shranijo v mapi ~/.local/share/app.retroplayer/. Ta mapa je namenjena izključno bazi podatkov in nastavitvam.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integracija z opravilno vrstico v sistemu Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Za ikono na opravilni vrstici in v mreži aplikacij namizna okolja Linuxa zahtevajo ločene datoteke Freedesktop. Retro Player jih ob zagonu namesti iz paketa aplikacije:\n\n• ~/.local/share/applications/app.retroplayer.desktop — vnos v zaganjalniku, ki povezuje odprto okno s to aplikacijo\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikone v skladu s temo, kopirane iz paketa\n\nNikoli ne ustvari uporabniške datoteke hicolor/index.theme (kar bi prekrilo sistemsko temo in skrilo druge ikone). Ikone so vgrajene tudi v izvedljivo datoteko aplikacije. Zgoraj navedene kopije pomagajo okoljem GNOME/KDE prikazati pravo ikono v zaganjalniku namesto splošnega nadomestnega simbola.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Dovoljenja in shranjevanje v sistemu Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Aplikacija Retro Player svojo bazo podatkov shranjuje v zasebnem podpornem območju aplikacije na notranjem pomnilniku. Vaše glasbene datoteke ostanejo v mapah, ki jih izberete s sistemskim izbirnikom map.\n\nV sistemu Android lahko aplikacija zahteva dostop do avdio datotek za branje skladb ter dostop do fotografij/slik, da se lahko prikažejo naslovnice map (na primer cover.jpg). Avdio datoteke se nikoli ne kopirajo v bazo podatkov aplikacije.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Aplikacija Retro Player svojo bazo podatkov shranjuje v zasebnem podpornem območju aplikacije na notranjem pomnilniku. Vaše glasbene datoteke ostanejo v mapah, ki jih izberete s sistemskim izbirnikom map.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Predvajanje v ozadju v sistemu Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Med predvajanjem zvoka Retro Player izvaja medijsko storitev v ospredju, tako da se predvajanje nadaljuje, tudi če zaklenete telefon ali preklopite med aplikacijami, pri čemer so gumbi za upravljanje predvajanja na voljo v sistemskem obvestilu. Če aplikacijo s potegom prsta odstranite iz seznama nedavno uporabljenih aplikacij, se predvajanje ustavi in obvestilo izgine.';

  @override
  String get dataStorageIOSAccessTitle => 'Dostop do map v sistemu iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Aplikacija Retro Player shranjuje svojo bazo podatkov v zasebnem podpornem območju aplikacije v pomnilniku naprave. Vaše glasbene datoteke ostanejo v mapah, ki jih izberete s sistemskim izbirnikom map.\n\niOS omogoča dostop do izbranih map prek varnostno omejenih URL-jev. Retro Player bere datoteke neposredno s teh lokacij; vaše knjižnice ne kopira v pomnilnik aplikacije.';

  @override
  String get dataStorageIOSPlaybackTitle =>
      'Zvočni posnetek v ozadju v sistemu iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Predvajanje se lahko nadaljuje, tudi če je aplikacija v ozadju ali je zaslon zaklenjen. Mesta nadaljevanja in stanje čakalne vrste se shranijo v lokalni bazi podatkov aplikacije.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Podatki aplikacije so shranjeni v zasebnem podpornem območju aplikacije na notranjem pomnilniku.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Podatki aplikacije so shranjeni v zasebnem podpornem območju aplikacije v pomnilniku naprave.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Podatki aplikacije so shranjeni v mapi ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Podatki o aplikaciji so shranjeni v vašem imeniku za podporo aplikacij.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Podatki aplikacije so shranjeni v lokalnem pomnilniku brskalnika za to domeno.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Podatki o aplikaciji so shranjeni v območju za podporo aplikacij platforme.';

  @override
  String get loading => 'Nalaganje…';

  @override
  String get libraryIndex => 'Kazalo knjižnice';

  @override
  String get playlists => 'Seznami predvajanja';

  @override
  String get playPlaylist => 'Predvajaj seznam predvajanja';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skladbe',
      one: '1 skladba',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Ustvari seznam predvajanja';

  @override
  String get queue => 'Čakalna vrsta';

  @override
  String get saveAsPlaylist => 'Shrani kot seznam predvajanja';

  @override
  String get queueEmpty =>
      'Čakalna vrsta je prazna. Dodajte skladbe iz svoje knjižnice.';

  @override
  String get choosePlaylistFolder =>
      'Izberite mapo v knjižnici. Koren knjižnice ni mapa.';

  @override
  String get clearQueue => 'Izbriši čakalno vrsto';

  @override
  String get clearQueueTitle => 'Izbrisati čakalno vrsto?';

  @override
  String get clearQueueBody =>
      'S tem se iz čakalne vrste odstranijo vse skladbe. Avdio datoteke in shranjeni seznami predvajanja ostanejo.';

  @override
  String get newPlaylistName => 'Ime seznama predvajanja';

  @override
  String get addTracks => 'Dodaj skladbe';

  @override
  String get addSelectedTracks => 'Dodaj izbrane skladbe';

  @override
  String get save => 'Shrani';

  @override
  String get addTracksFromLibrary => 'Dodaj iz knjižnice';

  @override
  String addTracksConfirm(int count) {
    return 'Dodaj ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Izberite eno ali več skladb v svoji knjižnici.';

  @override
  String get libraryEmptyNoRoots =>
      'Najprej dodajte mapo s knjižnico, nato pa iz nje izberite skladbe.';

  @override
  String get playlistEmpty => 'Ta seznam predvajanja še nima nobenih skladb.';

  @override
  String get missingTrack => 'Manjkajoča datoteka';

  @override
  String get playlistReadOnly => 'Samo za branje';

  @override
  String get playlistSelect => 'Izberi';

  @override
  String get playlistSelectAll => 'Izberi vse';

  @override
  String get playlistDeselectAll => 'Odkleni vse';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count izbrano',
      one: '1 izbran',
      zero: 'Izberi skladbe',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ali želite odstraniti skladbe $count iz seznama predvajanja?',
      one: 'Naj se skladba odstrani iz seznama predvajanja?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S tem se ob shranjevanju izbrišejo vnosi iz datoteke s seznamom predvajanja.',
      one: 'S tem se ob shranjevanju vnos odstrani iz datoteke s seznamom predvajanja.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nove skladbe niso bile dodane. Morda so že v seznamu predvajanja.';

  @override
  String get addToQueue => 'Dodaj v čakalno vrsto';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano v čakalno vrsto: $count',
      one: 'V čakalno vrsto je bila dodana 1 skladba',
      zero: 'V čakalno vrsto ni bila dodana nobena nova skladba',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Premakni gor';

  @override
  String get moveDown => 'Premakni dol';

  @override
  String get playlistNothingToPlay =>
      'Ta seznam predvajanja ne vsebuje skladb, ki bi jih bilo mogoče predvajati.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Izbrisati seznam predvajanja?';

  @override
  String deletePlaylistBody(String name) {
    return 'Izbrisati »$name«? S tem se datoteka seznama predvajanja odstrani z diska.';
  }
}

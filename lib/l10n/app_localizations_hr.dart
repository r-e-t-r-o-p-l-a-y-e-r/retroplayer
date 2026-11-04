// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Postavke';

  @override
  String get about => 'O nama';

  @override
  String get aboutSubtitle =>
      'Samo lokalni zvuk. Bez oglasa, bez telemetrije, bez pristupa mreži.\nPodržani formati: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Verzija';

  @override
  String get aboutBuildDate => 'Vrijeme izgradnje';

  @override
  String get aboutGitBranch => 'Ogranak';

  @override
  String get aboutGitCommit => 'Izrada';

  @override
  String get equalizer => 'Equalizator';

  @override
  String get equalizerUnavailable =>
      'Equalizer nije dostupan na ovoj platformi.';

  @override
  String get bands => 'Bendovi';

  @override
  String get reset => 'Ponovno pokretanje';

  @override
  String get library => 'Knjižnica';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Playlista';

  @override
  String get nowPlaying => 'Sada svira';

  @override
  String get addFolder => 'Dodaj mapu';

  @override
  String get audioPermissionRequired =>
      'Na Androidu je potrebna dozvola za zvuk.';

  @override
  String get expandPlayer => 'Proširi igrača';

  @override
  String get showLibrary => 'Prikaži biblioteku';

  @override
  String errorMessage(String message) {
    return 'Greška: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nijedan map nije dodan. Dodirnite \"Dodaj mapu\" da biste započeli.';

  @override
  String get folderEmpty => 'Ova mapa je prazna.';

  @override
  String get librarySources => 'Bibliotečki izvori';

  @override
  String get favorites => 'Favoriti';

  @override
  String get favorite => 'Omiljeno';

  @override
  String get removeFavorite => 'Ukloni omiljeno';

  @override
  String get folders => 'Mape';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Pokreni mapu';

  @override
  String get playAlbum => 'Pusti album';

  @override
  String get removeLibraryFolderTitle => 'Ukloniti mapu biblioteke?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Ukloniti \"$name\" iz svoje biblioteke?\n\nVaše audio datoteke na disku neće biti izbrisane.';
  }

  @override
  String get cancel => 'Otkaži';

  @override
  String get remove => 'Ukloni';

  @override
  String get albumNotFound => 'Album nije pronađen';

  @override
  String get playlistNotFound => 'Playlista nije pronađena';

  @override
  String get selectToPlay =>
      'Odaberite nešto iz svoje biblioteke za reprodukciju.';

  @override
  String get speed => 'Brzina';

  @override
  String get previous => 'Prethodni';

  @override
  String get pause => 'Pauza';

  @override
  String get play => 'Pusti';

  @override
  String get next => 'Sljedeće';

  @override
  String get jumpBack => 'Povratak 15 sekundi';

  @override
  String get jumpForward => 'Pređi naprijed 15 sekundi';

  @override
  String get chapters => 'Poglavlja';

  @override
  String get previousChapter => 'Prethodno poglavlje';

  @override
  String get nextChapter => 'Sljedeće poglavlje';

  @override
  String get headphones => 'Slušalice';

  @override
  String get autoRewind => 'Premotaj unatrag pri nastavku';

  @override
  String get autoRewindHint =>
      'Nakon stanke od najmanje minutu zapisi dulji od 20 minuta nastavljaju se nekoliko sekundi ranije.';

  @override
  String get rewindBy => 'Premotaj unatrag za';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Nastavi kad se slušalice ponovno povežu';

  @override
  String get resumeOnReconnectHint =>
      'Samo ako je reprodukcija pauzirana jer su slušalice isključene prije manje od 10 minuta.';

  @override
  String get trackFallback => 'Staza';

  @override
  String get unknownArtist => 'Neznano';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pjesama · $artist',
      one: '$count pjesma · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Resetiraj bazu podataka';

  @override
  String get resetDatabaseTitle => 'Resetirati bazu podataka?';

  @override
  String get resetDatabaseBody =>
      'Ovo briše položaje reprodukcije, omiljene stavke, otvorenu mapu, temu, jezik i postavke ekvalizera. Brisanje svega također zaboravlja dodane mape biblioteke. Glazbene datoteke i playliste na disku nisu izbrisane.';

  @override
  String get resetDatabaseKeepFolders => 'Sačuvajte mape knjižnice';

  @override
  String get resetDatabaseClearEverything => 'Očisti sve';

  @override
  String get eqManually => 'Ručno';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Visoki ton';

  @override
  String get eqVoice => 'Glas';

  @override
  String get appearance => 'Izgled';

  @override
  String get themeLight => 'Lagan';

  @override
  String get themeDark => 'Mračno';

  @override
  String get themeSystem => 'Sustav';

  @override
  String get language => 'Jezik';

  @override
  String get languageSystem => 'Sustav';

  @override
  String get openSourceLicenses => 'Licence otvorenog koda';

  @override
  String get openSourceLegalese => '© 2026 suradnici Retro Playera';

  @override
  String get dataStorage => 'Pohrana podataka';

  @override
  String get dataStorageIntro =>
      'Retro Player pohranjuje postavke aplikacije u maloj lokalnoj bazi podataka. Vaša glazba i playliste ostaju kao obične datoteke u mapama koje odaberete.';

  @override
  String get dataStorageAppDataTitle => 'Baza aplikacija';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Datoteka: $dbFileName\nStaza: $dbPath\n\nPohranjuje postavke biblioteke, stanje pregledavanja, nastavak reprodukcije, ekvilajzer, temu i jezične postavke.';
  }

  @override
  String get dataStorageLibraryTitle => 'Muzičke datoteke';

  @override
  String get dataStorageLibraryBody =>
      'Audio datoteke se nikada ne kopiraju u bazu podataka aplikacije. Dodajte mape knjižnice i Retro Player reproducira datoteke izravno s diska.';

  @override
  String get dataStoragePlaylistsTitle => 'Datoteke s popisom pjesama';

  @override
  String get dataStoragePlaylistsBody =>
      'Playliste su obične .m3u datoteke pohranjene u mapama vaše biblioteke. Možete ih uređivati u aplikaciji ili bilo kojem uređivaču teksta.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Podaci aplikacije pohranjuju se u vašem direktoriju za podršku aplikacija (obično ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Podaci aplikacije za Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Podaci aplikacije ostaju u ~/.local/share/app.retroplayer/. Ta je mapa namijenjena samo za bazu podataka i postavke.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Integracija Linux trake zadataka';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Za ikonu trake zadataka i mreže aplikacija, Linux desktop okruženja očekuju odvojene Freedesktop datoteke. Retro Player ih instalira iz paketa aplikacije pri pokretanju:\n\n• ~/.local/share/applications/app.retroplayer.desktop — unos za pokretač koji povezuje aktivni prozor s ovom aplikacijom\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikone u temi kopirane iz paketa\n\nNikada ne piše korisnički hicolor/index.theme (što bi zasjenilo sustavnu temu i sakrilo druge ikone). Ikone su također ugrađene u binarnu datoteku aplikacije. Gornje kopije pomažu GNOME/KDE-u da prikaže ispravnu ikonu pokretača umjesto generičke zamjenske ikone.';

  @override
  String get dataStorageAndroidPermissionsTitle => 'Android dozvole i pohrana';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player pohranjuje svoju bazu podataka u privatnom podržanom prostoru aplikacije na internom skladištu. Vaši glazbeni datoteci ostaju u mapama koje odaberete pomoću sustavnog odabira mapa.\n\nNa Androidu aplikacija može zatražiti pristup zvuku za čitanje pjesama i pristup fotografijama/slikama kako bi se prikazivale naslovnice albuma (na primjer cover.jpg). Zvučne datoteke nikada se ne kopiraju u bazu podataka aplikacije.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player pohranjuje svoju bazu podataka u privatnom podržanom prostoru aplikacije na internom skladištu. Vaši glazbeni datoteci ostaju u mapama koje odaberete pomoću sustavnog odabira mapa.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Reprodukcija u pozadini na Androidu';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Kad se audio reproducira, Retro Player pokreće medijsku uslugu u prvom planu kako bi reprodukcija nastavila i ako zaključate telefon ili prijeđete na drugu aplikaciju, s kontrolama reprodukcije u sistemskoj obavijesti. Pomicanjem aplikacije iz popisa nedavnih reprodukcija se zaustavlja i obavijest se uklanja.';

  @override
  String get dataStorageIOSAccessTitle => 'Pristup iOS mapama';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player pohranjuje svoju bazu podataka u privatno podržano područje aplikacije na pohrani uređaja. Vaše glazbene datoteke ostaju u mapama koje odaberete pomoću sustavnog odabirača mapa.\n\niOS odobrava pristup putem URL-ova s ograničenom sigurnosnom dozvolom za mape koje odaberete. Retro Player čita datoteke izravno s tih lokacija; ne kopira vašu glazbenu zbirku u pohranu aplikacije.';

  @override
  String get dataStorageIOSPlaybackTitle =>
      'Pozadinska audio reprodukcija na iOS-u';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Reprodukcija se može nastaviti dok je aplikacija u pozadini ili dok je zaslon zaključan. Položaji za nastavak i stanje reda čekanja pohranjuju se u lokalnoj bazi podataka aplikacije.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Podaci aplikacije pohranjuju se u privatnom podržnom prostoru aplikacije na internom skladištu.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Podaci aplikacije pohranjuju se u privatnom podrškom području aplikacije na pohrani uređaja.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Podaci aplikacije pohranjuju se u ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Podaci aplikacije pohranjuju se u vašem direktoriju za podršku aplikacija.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Podaci aplikacije pohranjuju se u lokalnom spremanju preglednika za ovo podrijetlo.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Podaci aplikacije pohranjuju se u području podrške platformskoj aplikaciji.';

  @override
  String get loading => 'Učitavanje…';

  @override
  String get libraryIndex => 'Indeks knjižnice';

  @override
  String get playlists => 'Playliste';

  @override
  String get playPlaylist => 'Pusti playlistu';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count staze',
      one: '1 pjesma',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Stvori playlistu';

  @override
  String get queue => 'Red';

  @override
  String get saveAsPlaylist => 'Sačuvaj kao playlistu';

  @override
  String get queueEmpty => 'Red je prazan. Dodajte pjesme iz svoje biblioteke.';

  @override
  String get choosePlaylistFolder =>
      'Odaberite mapu u biblioteci. Korijen biblioteke nije mapa.';

  @override
  String get clearQueue => 'Očisti red';

  @override
  String get clearQueueTitle => 'Očistiti red?';

  @override
  String get clearQueueBody =>
      'Ovo uklanja svaku pjesmu iz reda za reprodukciju. Audio datoteke i spremljene playliste ostaju.';

  @override
  String get newPlaylistName => 'Naziv playliste';

  @override
  String get addTracks => 'Dodaj staze';

  @override
  String get addSelectedTracks => 'Dodaj odabrane staze';

  @override
  String get save => 'Sačuvaj';

  @override
  String get addTracksFromLibrary => 'Dodaj iz biblioteke';

  @override
  String addTracksConfirm(int count) {
    return 'Dodaj ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Odaberite jednu ili više pjesama u svojoj biblioteci.';

  @override
  String get libraryEmptyNoRoots =>
      'Prvo dodajte mapu biblioteke, a zatim iz nje odaberite pjesme.';

  @override
  String get playlistEmpty => 'Ova playlista još nema pjesama.';

  @override
  String get missingTrack => 'Fail nedostaje';

  @override
  String get playlistReadOnly => 'Samo za čitanje';

  @override
  String get playlistSelect => 'Odaberi';

  @override
  String get playlistSelectAll => 'Odaberi sve';

  @override
  String get playlistDeselectAll => 'Odaberi sve';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odabrano',
      one: '1 odabrano',
      zero: 'Odabir staza',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukloniti $count staze s playliste?',
      one: 'Ukloniti pjesmu s playliste?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ovo uklanja unose iz datoteke playliste prilikom spremanja.',
      one: 'Ovo uklanja unos iz datoteke s popisom za reprodukciju prilikom spremanja.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nije dodana nijedna nova pjesma. Moguće je da su već na popisu za reprodukciju.';

  @override
  String get addToQueue => 'Dodaj u red';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano u red: $count',
      one: '1 pjesma dodana u red',
      zero: 'Nijedna nova pjesma nije dodana u red',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Pomakni gore';

  @override
  String get moveDown => 'Pomakni dolje';

  @override
  String get playlistNothingToPlay =>
      'Ova playlista nema pjesama za reprodukciju.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Izbriši playlistu?';

  @override
  String deletePlaylistBody(String name) {
    return 'Izbriši \"$name\"? Ovo uklanja datoteku playliste s diska.';
  }
}

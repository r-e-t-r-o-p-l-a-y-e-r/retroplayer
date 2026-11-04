// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Indstillinger';

  @override
  String get about => 'Om';

  @override
  String get aboutSubtitle =>
      'Kun lokal lyd. Ingen reklamer, ingen telemetri, ingen netværksadgang.\nUnderstøttede formater: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuildDate => 'Byggetid';

  @override
  String get aboutGitBranch => 'Gren';

  @override
  String get aboutGitCommit => 'Build';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Equalizer er ikke tilgængelig på denne platform.';

  @override
  String get bands => 'Bands';

  @override
  String get reset => 'Nulstil';

  @override
  String get library => 'Bibliotek';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Afspilningsliste';

  @override
  String get nowPlaying => 'Afspilles nu';

  @override
  String get addFolder => 'Tilføj mappe';

  @override
  String get audioPermissionRequired => 'Der kræves lydtilladelse på Android';

  @override
  String get expandPlayer => 'Udvid afspiller';

  @override
  String get showLibrary => 'Vis bibliotek';

  @override
  String errorMessage(String message) {
    return 'Fejl: $message';
  }

  @override
  String get noFoldersAdded =>
      'Der er ikke tilføjet nogen mapper. Tryk på »Tilføj mappe« for at komme i gang.';

  @override
  String get folderEmpty => 'Denne mappe er tom.';

  @override
  String get librarySources => 'Bibliotekskilder';

  @override
  String get favorites => 'Favoritter';

  @override
  String get favorite => 'Favorit';

  @override
  String get removeFavorite => 'Fjern fra favoritter';

  @override
  String get folders => 'Mapper';

  @override
  String get audio => 'Lyd';

  @override
  String get playFolder => 'Afspilningsmappe';

  @override
  String get playAlbum => 'Afspil album';

  @override
  String get removeLibraryFolderTitle => 'Skal biblioteksmappen slettes?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Vil du fjerne \"$name\" fra dit bibliotek?\n\nDine lydfiler på disken slettes ikke.';
  }

  @override
  String get cancel => 'Annuller';

  @override
  String get remove => 'Fjern';

  @override
  String get albumNotFound => 'Albummet blev ikke fundet';

  @override
  String get playlistNotFound => 'Afspilningsliste ikke fundet';

  @override
  String get selectToPlay =>
      'Vælg noget fra dit bibliotek, som du vil afspille.';

  @override
  String get speed => 'Hastighed';

  @override
  String get previous => 'Forrige';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Afspil';

  @override
  String get next => 'Næste';

  @override
  String get jumpBack => '15 sekunder tilbage';

  @override
  String get jumpForward => 'Spol 15 sekunder frem';

  @override
  String get chapters => 'Kapitler';

  @override
  String get previousChapter => 'Forrige kapitel';

  @override
  String get nextChapter => 'Næste kapitel';

  @override
  String get headphones => 'Hovedtelefoner';

  @override
  String get autoRewind => 'Spol tilbage ved genoptagelse';

  @override
  String get autoRewindHint =>
      'Efter en pause på mindst et minut genoptages numre på over 20 minutter et par sekunder tidligere.';

  @override
  String get rewindBy => 'Spol tilbage med';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect =>
      'Genoptag, når hovedtelefonerne forbindes igen';

  @override
  String get resumeOnReconnectHint =>
      'Kun hvis afspilningen blev sat på pause, fordi hovedtelefonerne blev frakoblet for mindre end 10 minutter siden.';

  @override
  String get trackFallback => 'Spor';

  @override
  String get unknownArtist => 'Ukendt';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count numre · $artist',
      one: '$count nummer · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Nulstil database';

  @override
  String get resetDatabaseTitle => 'Nulstille databasen?';

  @override
  String get resetDatabaseBody =>
      'Dette sletter afspilningspositioner, favoritter, den åbne mappe, tema, sprog og equalizer-indstillinger. Hvis du vælger »Slet alt«, slettes også de tilføjede biblioteksmapper. Musikfiler og afspilningslister på disken slettes ikke.';

  @override
  String get resetDatabaseKeepFolders => 'Behold biblioteksmapperne';

  @override
  String get resetDatabaseClearEverything => 'Ryd alt';

  @override
  String get eqManually => 'Manuelt';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Diskant';

  @override
  String get eqVoice => 'Stemme';

  @override
  String get appearance => 'Udseende';

  @override
  String get themeLight => 'Lys';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Sprog';

  @override
  String get languageSystem => 'System';

  @override
  String get openSourceLicenses => 'Open source-licenser';

  @override
  String get openSourceLegalese => '© 2026 Retro Player-bidragydere';

  @override
  String get dataStorage => 'Datalagring';

  @override
  String get dataStorageIntro =>
      'Retro Player gemmer app-indstillingerne i en lille lokal database. Din musik og dine afspilningslister forbliver som almindelige filer i de mapper, du vælger.';

  @override
  String get dataStorageAppDataTitle => 'App-database';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fil: $dbFileName\nSti: $dbPath\n\nGemmer indstillinger for biblioteksrodmapper, gennemsynstilstand, genoptagelse af afspilning, equalizer, tema og sprog.';
  }

  @override
  String get dataStorageLibraryTitle => 'Musikfiler';

  @override
  String get dataStorageLibraryBody =>
      'Lydfiler kopieres aldrig til appens database. Tilføj biblioteksmapper, så læser Retro Player filerne direkte fra harddisken.';

  @override
  String get dataStoragePlaylistsTitle => 'Afspilningslistefiler';

  @override
  String get dataStoragePlaylistsBody =>
      'Afspilningslister er almindelige .m3u-filer, der er gemt i dine biblioteksmapper. Du kan redigere dem i appen eller med et hvilket som helst tekstredigeringsprogram.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platform: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'App-data gemmes i dit app-support-bibliotek (typisk ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Data fra Linux-apps';

  @override
  String get dataStorageLinuxDataBody =>
      'App-data gemmes i ~/.local/share/app.retroplayer/. Den mappe er udelukkende beregnet til databasen og indstillingerne.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integration med Linux-proceslinjen';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Til ikonet i proceslinjen og app-gitteret kræver Linux-skrivebordsmiljøer separate Freedesktop-filer. Retro Player installerer disse fra app-pakken ved opstart:\n\n• ~/.local/share/applications/app.retroplayer.desktop — en genvej, der forbinder det kørende vindue med denne app\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — temaikoner kopieret fra pakken\n\nDet skriver aldrig en bruger-hicolor/index.theme-fil (da dette ville overskygge systemtemaet og skjule andre ikoner). Ikoner er også indlejret i appens binærfil. Ovenstående kopier hjælper GNOME/KDE med at vise det korrekte startikon i stedet for en generisk pladsholder.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Android-tilladelser og lagerplads';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player gemmer sin database i appens private supportområde på det interne lager. Dine musikfiler forbliver i de mapper, du vælger via systemets mappevælger.\n\nPå Android kan appen anmode om adgang til lydfiler for at kunne læse spor samt adgang til fotos/billeder, så mappeomslag (f.eks. cover.jpg) kan vises. Lydfiler kopieres aldrig til appens database.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player gemmer sin database i appens private supportområde på det interne lager. Dine musikfiler forbliver i de mapper, du vælger via systemets mappevælger.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Afspilning i baggrunden på Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Når der afspilles lyd, kører Retro Player en medietjeneste i forgrunden, så afspilningen fortsætter, selvom du låser telefonen eller skifter mellem apps, og afspilningsknapperne vises i systemmeddelelsen. Hvis du stryger appen væk fra listen over seneste apps, stopper afspilningen, og meddelelsen fjernes.';

  @override
  String get dataStorageIOSAccessTitle => 'Adgang til mapper på iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player gemmer sin database i appens private supportområde på enhedens lagerplads. Dine musikfiler forbliver i de mapper, du vælger via systemets mappevælger.\n\niOS giver adgang via sikkerhedsbegrænsede URL’er til de mapper, du vælger. Retro Player læser filerne direkte fra disse placeringer; appen kopierer ikke dit bibliotek til appens lagerplads.';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS-baggrundslyd';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Afspilningen kan fortsætte, selvom appen kører i baggrunden, eller skærmen er låst. Afspilningspositioner og køens tilstand gemmes i appens lokale database.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Appdata gemmes i det app-specifikke supportområde på det interne lager.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Appdata gemmes i det app-specifikke supportområde på enhedens lagerplads.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'App-data gemmes i mappen ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'App-data gemmes i dit applikationsstøttebibliotek.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Appdata gemmes i browserens lokale lager for denne oprindelse.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'App-data gemmes i platformens applikationsstøtteområde.';

  @override
  String get loading => 'Indlæser…';

  @override
  String get libraryIndex => 'Biblioteksindeks';

  @override
  String get playlists => 'Afspilningslister';

  @override
  String get playPlaylist => 'Afspil afspilningsliste';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spor',
      one: '1 spor',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Opret afspilningsliste';

  @override
  String get queue => 'Kø';

  @override
  String get saveAsPlaylist => 'Gem som afspilningsliste';

  @override
  String get queueEmpty => 'Køen er tom. Tilføj numre fra dit bibliotek.';

  @override
  String get choosePlaylistFolder =>
      'Vælg en mappe i biblioteket. Bibliotekets rodmappe er ikke en mappe.';

  @override
  String get clearQueue => 'Ryd køen';

  @override
  String get clearQueueTitle => 'Rydde køen?';

  @override
  String get clearQueueBody =>
      'Dette fjerner alle numre fra køen. Lydfiler og gemte afspilningslister forbliver.';

  @override
  String get newPlaylistName => 'Navn på afspilningsliste';

  @override
  String get addTracks => 'Tilføj spor';

  @override
  String get addSelectedTracks => 'Tilføj valgte spor';

  @override
  String get save => 'Gem';

  @override
  String get addTracksFromLibrary => 'Tilføj fra biblioteket';

  @override
  String addTracksConfirm(int count) {
    return 'Tilføj ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Vælg et eller flere spor i dit bibliotek.';

  @override
  String get libraryEmptyNoRoots =>
      'Opret først en biblioteksmappe, og vælg derefter numre derfra.';

  @override
  String get playlistEmpty =>
      'Denne afspilningsliste indeholder endnu ingen numre.';

  @override
  String get missingTrack => 'Manglende fil';

  @override
  String get playlistReadOnly => 'Skrivebeskyttet';

  @override
  String get playlistSelect => 'Vælg';

  @override
  String get playlistSelectAll => 'Vælg alt';

  @override
  String get playlistDeselectAll => 'Fjern markeringen af alle';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valgt',
      one: '1 valgt',
      zero: 'Vælg numre',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skal $count-numrene fjernes fra afspilningslisten?',
      one: 'Skal sangen fjernes fra afspilningslisten?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dette fjerner posterne fra afspilningslisten, når du gemmer.',
      one: 'Dette fjerner posten fra afspilningslisten, når du gemmer.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Der er ikke blevet tilføjet nye numre. De er muligvis allerede på afspilningslisten.';

  @override
  String get addToQueue => 'Føj til kø';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spor føjet til køen',
      one: '1 spor føjet til køen',
      zero: 'Ingen nye spor blev føjet til køen',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Flyt op';

  @override
  String get moveDown => 'Flyt ned';

  @override
  String get playlistNothingToPlay =>
      'Denne afspilningsliste indeholder ingen numre, der kan afspilles.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Skal afspilningslisten slettes?';

  @override
  String deletePlaylistBody(String name) {
    return 'Skal \"$name\" slettes? Dette fjerner afspilningslistefilen fra disken.';
  }
}

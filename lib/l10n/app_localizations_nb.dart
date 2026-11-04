// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Innstillinger';

  @override
  String get about => 'Om';

  @override
  String get aboutSubtitle =>
      'Kun lokal lyd. Ingen annonser, ingen telemetri, ingen nettverkstilgang.\nStøttede formater: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versjon';

  @override
  String get aboutBuildDate => 'Byggetid';

  @override
  String get aboutGitBranch => 'Gren';

  @override
  String get aboutGitCommit => 'Bygg';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Equalizer er ikke tilgjengelig på denne plattformen.';

  @override
  String get bands => 'Bands';

  @override
  String get reset => 'Tilbakestill';

  @override
  String get library => 'Bibliotek';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Spilleliste';

  @override
  String get nowPlaying => 'Spiller nå';

  @override
  String get addFolder => 'Legg til mappe';

  @override
  String get audioPermissionRequired => 'Det kreves lydtillatelse på Android';

  @override
  String get expandPlayer => 'Vis avspilleren i full størrelse';

  @override
  String get showLibrary => 'Vis biblioteket';

  @override
  String errorMessage(String message) {
    return 'Feil: $message';
  }

  @override
  String get noFoldersAdded =>
      'Ingen mapper er lagt til. Trykk på «Legg til mappe» for å komme i gang.';

  @override
  String get folderEmpty => 'Denne mappen er tom.';

  @override
  String get librarySources => 'Bibliotekskilder';

  @override
  String get favorites => 'Favoritter';

  @override
  String get favorite => 'Favoritt';

  @override
  String get removeFavorite => 'Fjern fra favoritter';

  @override
  String get folders => 'Mapper';

  @override
  String get audio => 'Lyd';

  @override
  String get playFolder => 'Spill-mappe';

  @override
  String get playAlbum => 'Spill av albumet';

  @override
  String get removeLibraryFolderTitle => 'Skal biblioteksmappen fjernes?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Vil du fjerne «$name» fra biblioteket ditt?\n\nLydfilene dine på disken blir ikke slettet.';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get remove => 'Fjern';

  @override
  String get albumNotFound => 'Albumet ble ikke funnet';

  @override
  String get playlistNotFound => 'Spillelisten ble ikke funnet';

  @override
  String get selectToPlay =>
      'Velg noe fra biblioteket ditt som du vil spille av.';

  @override
  String get speed => 'Hastighet';

  @override
  String get previous => 'Forrige';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Spill';

  @override
  String get next => 'Neste';

  @override
  String get jumpBack => '15 sekunder tilbake';

  @override
  String get jumpForward => 'Spol frem 15 sekunder';

  @override
  String get chapters => 'Kapitler';

  @override
  String get previousChapter => 'Forrige kapittel';

  @override
  String get nextChapter => 'Neste kapittel';

  @override
  String get headphones => 'Hodetelefoner';

  @override
  String get autoRewind => 'Spol tilbake ved gjenopptak';

  @override
  String get autoRewindHint =>
      'Etter en pause på minst ett minutt gjenopptas spor over 20 minutter noen sekunder tidligere.';

  @override
  String get rewindBy => 'Spol tilbake';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect =>
      'Fortsett når hodetelefonene kobles til igjen';

  @override
  String get resumeOnReconnectHint =>
      'Bare hvis avspillingen ble satt på pause fordi hodetelefonene ble koblet fra for mindre enn 10 minutter siden.';

  @override
  String get trackFallback => 'Spor';

  @override
  String get unknownArtist => 'Ukjent';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spor · $artist',
      one: '$count spor · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Tilbakestill database';

  @override
  String get resetDatabaseTitle => 'Tilbakestille databasen?';

  @override
  String get resetDatabaseBody =>
      'Dette sletter avspillingsposisjoner, favoritter, den åpne mappen, tema, språk og equalizer-innstillinger. Hvis du sletter alt, fjernes også de lagt til biblioteksmappene. Musikkfiler og spillelister på disken blir ikke slettet.';

  @override
  String get resetDatabaseKeepFolders => 'Behold biblioteksmappene';

  @override
  String get resetDatabaseClearEverything => 'Slett alt';

  @override
  String get eqManually => 'Manuelt';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqTreble => 'Diskant';

  @override
  String get eqVoice => 'Stemme';

  @override
  String get appearance => 'Utseende';

  @override
  String get themeLight => 'Lys';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Språk';

  @override
  String get languageSystem => 'System';

  @override
  String get openSourceLicenses => 'Lisenser for åpen kildekode';

  @override
  String get openSourceLegalese => '© 2026 Bidragsytere til Retro Player';

  @override
  String get dataStorage => 'Datalagring';

  @override
  String get dataStorageIntro =>
      'Retro Player lagrer appinnstillingene i en liten lokal database. Musikkfilene og spillelistene dine forblir som vanlige filer i mappene du velger.';

  @override
  String get dataStorageAppDataTitle => 'App-database';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fil: $dbFileName\nSti: $dbPath\n\nLagrer innstillinger for biblioteksrot, bla-tilstand, gjenopptak av avspilling, equalizer, tema og språk.';
  }

  @override
  String get dataStorageLibraryTitle => 'Musikkfiler';

  @override
  String get dataStorageLibraryBody =>
      'Lydfiler kopieres aldri til appens database. Legg til bibliotekmapper, så leser Retro Player filene direkte fra disken.';

  @override
  String get dataStoragePlaylistsTitle => 'Spillelistefiler';

  @override
  String get dataStoragePlaylistsBody =>
      'Spillelister er vanlige .m3u-filer som er lagret i bibliotekmappene dine. Du kan redigere dem i appen eller med et hvilket som helst tekstredigeringsprogram.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plattform: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Appdata lagres i app-support-mappen din (vanligvis ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Data fra Linux-apper';

  @override
  String get dataStorageLinuxDataBody =>
      'Appdataene lagres i ~/.local/share/app.retroplayer/. Denne mappen er kun ment for databasen og innstillingene.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrering med Linux-oppgavelinjen';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'For ikonet i oppgavelinjen og i app-rutenettet forventer Linux-skrivebordsmiljøer separate Freedesktop-filer. Retro Player installerer disse fra app-pakken ved oppstart:\n\n• ~/.local/share/applications/app.retroplayer.desktop — startikon som knytter det aktive vinduet til denne appen\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — temaikoner kopiert fra pakken\n\nDen skriver aldri en brukerfil hicolor/index.theme (som ville overskygge systemtemaet og skjule andre ikoner). Ikoner er også innebygd i appens binærfil. Kopiene ovenfor hjelper GNOME/KDE med å vise det riktige startikonet i stedet for en generisk plassholder.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Android-tillatelser og lagringsplass';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player lagrer databasen sin i appens private støtteområde på det interne lagringsmediet. Musikkfilene dine forblir i mapper du velger ved hjelp av systemets mappevelger.\n\nPå Android kan appen be om tilgang til lyd for å lese spor, samt tilgang til bilder/grafikk slik at mappeomslag (for eksempel cover.jpg) kan vises. Lydfiler kopieres aldri inn i appens database.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player lagrer databasen sin i appens private støtteområde på det interne lagringsmediet. Musikkfilene dine forblir i mapper du velger ved hjelp av systemets mappevelger.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Avspilling i bakgrunnen på Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Når lyd spilles av, kjører Retro Player en medietjeneste i forgrunnen, slik at avspillingen fortsetter selv om du låser telefonen eller bytter mellom apper. Avspillingskontrollene vises i systemvarselet. Hvis du sveiper appen bort fra «Nylige», stoppes avspillingen og varselet fjernes.';

  @override
  String get dataStorageIOSAccessTitle => 'Tilgang til iOS-mapper';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player lagrer databasen sin i appens private støtteområde på enhetens lagringsplass. Musikkfilene dine forblir i mappene du velger ved hjelp av systemets mappevelger.\n\niOS gir tilgang via sikkerhetsbegrensede URL-er til mappene du velger. Retro Player leser filene direkte fra disse stedene; den kopierer ikke biblioteket ditt til appens lagringsplass.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Bakgrunnslyd på iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Avspillingen kan fortsette selv om appen kjører i bakgrunnen eller skjermen er låst. Gjenopptakingsposisjoner og køstatus lagres i appens lokale database.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Appdata lagres i det app-spesifikke støtteområdet på det interne lagringsmediet.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Appdata lagres i det app-spesifikke støtteområdet på enhetens lagringsplass.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Appdata lagres i mappen ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Appdata lagres i applikasjonsstøttekatalogen.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Appdata lagres i nettleserens lokale lagringsplass for denne kilden.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Appdata lagres i plattformens applikasjonsstøtteområde.';

  @override
  String get loading => 'Laster…';

  @override
  String get libraryIndex => 'Bibliotekets indeks';

  @override
  String get playlists => 'Spillelister';

  @override
  String get playPlaylist => 'Spill av spilleliste';

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
  String get createPlaylist => 'Opprett spilleliste';

  @override
  String get queue => 'Kø';

  @override
  String get saveAsPlaylist => 'Lagre som spilleliste';

  @override
  String get queueEmpty => 'Køen er tom. Legg til spor fra biblioteket ditt.';

  @override
  String get choosePlaylistFolder =>
      'Velg en mappe i biblioteket. Bibliotekets rotkatalog er ikke en mappe.';

  @override
  String get clearQueue => 'Tøm køen';

  @override
  String get clearQueueTitle => 'Tømme køen?';

  @override
  String get clearQueueBody =>
      'Dette fjerner alle spor fra køen. Lydfiler og lagrede spillelister beholdes.';

  @override
  String get newPlaylistName => 'Navn på spilleliste';

  @override
  String get addTracks => 'Legg til spor';

  @override
  String get addSelectedTracks => 'Legg til valgte spor';

  @override
  String get save => 'Lagre';

  @override
  String get addTracksFromLibrary => 'Legg til fra biblioteket';

  @override
  String addTracksConfirm(int count) {
    return 'Legg til ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Velg ett eller flere spor i biblioteket ditt.';

  @override
  String get libraryEmptyNoRoots =>
      'Legg først til en biblioteksmappe, og velg deretter spor fra den.';

  @override
  String get playlistEmpty => 'Denne spillelisten har ingen spor ennå.';

  @override
  String get missingTrack => 'Manglende fil';

  @override
  String get playlistReadOnly => 'Skrivebeskyttet';

  @override
  String get playlistSelect => 'Velg';

  @override
  String get playlistSelectAll => 'Velg alt';

  @override
  String get playlistDeselectAll => 'Fjern markeringen fra alle';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valgt',
      one: '1 valgt',
      zero: 'Velg spor',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skal sporene med $count fjernes fra spillelisten?',
      one: 'Fjerne spor fra spillelisten?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dette fjerner oppføringene fra spillelistefilen når du lagrer.',
      one: 'Dette fjerner oppføringen fra spillelistefilen når du lagrer.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Det ble ikke lagt til noen nye spor. De kan allerede være i spillelisten.';

  @override
  String get addToQueue => 'Legg til i kø';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spor lagt til i køen',
      one: '1 spor lagt til i køen',
      zero: 'Ingen nye spor ble lagt til i køen',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Flytt opp';

  @override
  String get moveDown => 'Flytt ned';

  @override
  String get playlistNothingToPlay =>
      'Denne spillelisten inneholder ingen spor som kan spilles av.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Slette spillelisten?';

  @override
  String deletePlaylistBody(String name) {
    return 'Slette «$name»? Dette fjerner spillelistefilen fra disken.';
  }
}

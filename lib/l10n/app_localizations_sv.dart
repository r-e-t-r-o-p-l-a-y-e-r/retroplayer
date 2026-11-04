// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Inställningar';

  @override
  String get about => 'Om';

  @override
  String get aboutSubtitle =>
      'Endast lokalt ljud. Inga annonser, ingen telemetri, ingen nätverksåtkomst.\nFormat som stöds: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuildDate => 'Byggtid';

  @override
  String get aboutGitBranch => 'Git-gren';

  @override
  String get aboutGitCommit => 'Bygg';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Equalizer finns inte tillgängligt på den här plattformen.';

  @override
  String get bands => 'Band';

  @override
  String get reset => 'Återställ';

  @override
  String get library => 'Bibliotek';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Spellista';

  @override
  String get nowPlaying => 'Spelas just nu';

  @override
  String get addFolder => 'Lägg till mapp';

  @override
  String get audioPermissionRequired => 'Ljudbehörighet krävs på Android';

  @override
  String get expandPlayer => 'Visa spelaren i full storlek';

  @override
  String get showLibrary => 'Visa biblioteket';

  @override
  String errorMessage(String message) {
    return 'Fel: $message';
  }

  @override
  String get noFoldersAdded =>
      'Inga mappar har lagts till. Tryck på ”Lägg till mapp” för att komma igång.';

  @override
  String get folderEmpty => 'Den här mappen är tom.';

  @override
  String get librarySources => 'Bibliotekskällor';

  @override
  String get favorites => 'Favoriter';

  @override
  String get favorite => 'Favorit';

  @override
  String get removeFavorite => 'Ta bort från favoriter';

  @override
  String get folders => 'Mappar';

  @override
  String get audio => 'Ljud';

  @override
  String get playFolder => 'Spelmapp';

  @override
  String get playAlbum => 'Spela upp albumet';

  @override
  String get removeLibraryFolderTitle => 'Ska biblioteksmappen tas bort?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Vill du ta bort ”$name” från ditt bibliotek?\n\nDina ljudfiler på hårddisken raderas inte.';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get remove => 'Ta bort';

  @override
  String get albumNotFound => 'Albumet hittades inte';

  @override
  String get playlistNotFound => 'Spellistan hittades inte';

  @override
  String get selectToPlay =>
      'Välj något från ditt bibliotek som du vill spela upp.';

  @override
  String get speed => 'Hastighet';

  @override
  String get previous => 'Föregående';

  @override
  String get pause => 'Paus';

  @override
  String get play => 'Spela';

  @override
  String get next => 'Nästa';

  @override
  String get jumpBack => '15 sekunder tillbaka';

  @override
  String get jumpForward => 'Spola fram 15 sekunder';

  @override
  String get chapters => 'Kapitel';

  @override
  String get previousChapter => 'Föregående kapitel';

  @override
  String get nextChapter => 'Nästa kapitel';

  @override
  String get headphones => 'Hörlurar';

  @override
  String get autoRewind => 'Spola tillbaka vid återupptagning';

  @override
  String get autoRewindHint =>
      'Efter en paus på minst en minut återupptas spår längre än 20 minuter några sekunder tidigare.';

  @override
  String get rewindBy => 'Spola tillbaka';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Återuppta när hörlurarna ansluts igen';

  @override
  String get resumeOnReconnectHint =>
      'Bara om uppspelningen pausades för att hörlurarna kopplades från för mindre än 10 minuter sedan.';

  @override
  String get trackFallback => 'Spår';

  @override
  String get unknownArtist => 'Okänt';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count låtar · $artist',
      one: '$count låt · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Återställ databasen';

  @override
  String get resetDatabaseTitle => 'Återställa databasen?';

  @override
  String get resetDatabaseBody =>
      'Detta raderar uppspelningspositioner, favoriter, den öppna mappen, tema, språk och equalizerinställningar. Om du väljer ”Rensa allt” raderas även de tillagda biblioteksmapparna. Musikfiler och spellistor på hårddisken raderas inte.';

  @override
  String get resetDatabaseKeepFolders => 'Behåll biblioteksmapparna';

  @override
  String get resetDatabaseClearEverything => 'Rensa allt';

  @override
  String get eqManually => 'Manuellt';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Diskant';

  @override
  String get eqVoice => 'Röst';

  @override
  String get appearance => 'Utseende';

  @override
  String get themeLight => 'Ljus';

  @override
  String get themeDark => 'Mörkt';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Språk';

  @override
  String get languageSystem => 'System';

  @override
  String get openSourceLicenses => 'Öppen källkodslicenser';

  @override
  String get openSourceLegalese => '© 2026 Retro Player-bidragare';

  @override
  String get dataStorage => 'Datalagring';

  @override
  String get dataStorageIntro =>
      'Retro Player sparar appinställningarna i en liten lokal databas. Din musik och dina spellistor förblir vanliga filer i de mappar du väljer.';

  @override
  String get dataStorageAppDataTitle => 'Appdatabas';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fil: $dbFileName\nSökväg: $dbPath\n\nHär sparas inställningar för bibliotekets rotkataloger, bläddringsläge, återuppspelning, equalizer, tema och språk.';
  }

  @override
  String get dataStorageLibraryTitle => 'Musikfiler';

  @override
  String get dataStorageLibraryBody =>
      'Ljudfiler kopieras aldrig till appens databas. Lägg till biblioteksmappar så läser Retro Player filerna direkt från hårddisken.';

  @override
  String get dataStoragePlaylistsTitle => 'Spellistfiler';

  @override
  String get dataStoragePlaylistsBody =>
      'Spellistor är vanliga .m3u-filer som lagras i dina biblioteksmappar. Du kan redigera dem i appen eller med valfri textredigerare.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plattform: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Appdata lagras i katalogen app-support (vanligtvis ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Data för Linux-appar';

  @override
  String get dataStorageLinuxDataBody =>
      'Appdata sparas i ~/.local/share/app.retroplayer/. Den mappen är endast avsedd för databasen och inställningarna.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrering med Linux-aktivitetsfältet';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'För ikonen i aktivitetsfältet och i apprutnätet kräver Linux-skrivbordsmiljöer separata Freedesktop-filer. Retro Player installerar dessa från app-paketet vid uppstart:\n\n• ~/.local/share/applications/app.retroplayer.desktop — startikon som kopplar det aktiva fönstret till denna app\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — temabaserade ikoner som kopierats från paketet\n\nProgrammet skriver aldrig en användarfil i hicolor/index.theme (vilket skulle överskugga systemtemat och dölja andra ikoner). Ikoner är också inbäddade i appens binärfil. Kopiorna ovan hjälper GNOME/KDE att visa rätt startikon istället för en generisk platshållare.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Android-behörigheter och lagringsutrymme';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player lagrar sin databas i appens privata supportområde på det interna lagringsutrymmet. Dina musikfiler förblir i de mappar du väljer med systemets mappväljare.\n\nPå Android kan appen begära åtkomst till ljudfiler för att läsa spår, samt åtkomst till foton/bilder så att omslagsbilder (till exempel cover.jpg) kan visas. Ljudfiler kopieras aldrig till appens databas.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player lagrar sin databas i appens privata supportområde på det interna lagringsutrymmet. Dina musikfiler förblir i de mappar du väljer med systemets mappväljare.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Uppspelning i bakgrunden på Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'När ljud spelas upp kör Retro Player en medietjänst i förgrunden, så att uppspelningen fortsätter även om du låser telefonen eller byter app. Kontrollerna för uppspelningen visas i systemmeddelandet. Om du sveper bort appen från listan över senaste appar avbryts uppspelningen och meddelandet försvinner.';

  @override
  String get dataStorageIOSAccessTitle => 'Åtkomst till mappar i iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player lagrar sin databas i appens privata lagringsutrymme på enhetens lagringsutrymme. Dina musikfiler sparas i de mappar du väljer med hjälp av systemets mappväljare.\n\niOS beviljar åtkomst via säkerhetsbegränsade URL:er för de mappar du väljer. Retro Player läser filerna direkt från dessa platser; appen kopierar inte ditt bibliotek till appens lagringsutrymme.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Ljud i bakgrunden på iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Uppspelningen kan fortsätta även när appen körs i bakgrunden eller när skärmen är låst. Återupptagningspositioner och köstatus sparas i appens lokala databas.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Appdata lagras i det appspecifika stödområdet på det interna lagringsutrymmet.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Appdata lagras i det appspecifika stödområdet på enhetens lagringsutrymme.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Appdata lagras i mappen ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Appdata lagras i katalogen för applikationsstöd.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Appdata lagras i webbläsarens lokala lagringsutrymme för denna källa.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Appdata lagras i plattformens applikationsstöd.';

  @override
  String get loading => 'Laddar…';

  @override
  String get libraryIndex => 'Biblioteksindex';

  @override
  String get playlists => 'Spellistor';

  @override
  String get playPlaylist => 'Spela upp spellistan';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spår',
      one: '1 spår',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Skapa en spellista';

  @override
  String get queue => 'Kö';

  @override
  String get saveAsPlaylist => 'Spara som spellista';

  @override
  String get queueEmpty => 'Kön är tom. Lägg till låtar från ditt bibliotek.';

  @override
  String get choosePlaylistFolder =>
      'Välj en mapp i biblioteket. Bibliotekets rotmapp är inte en mapp.';

  @override
  String get clearQueue => 'Rensa kö';

  @override
  String get clearQueueTitle => 'Rensa kö?';

  @override
  String get clearQueueBody =>
      'Detta tar bort alla låtar från kön. Ljudfiler och sparade spellistor finns kvar.';

  @override
  String get newPlaylistName => 'Namn på spellista';

  @override
  String get addTracks => 'Lägg till spår';

  @override
  String get addSelectedTracks => 'Lägg till valda spår';

  @override
  String get save => 'Spara';

  @override
  String get addTracksFromLibrary => 'Lägg till från biblioteket';

  @override
  String addTracksConfirm(int count) {
    return 'Lägg till ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Välj ett eller flera spår i ditt bibliotek.';

  @override
  String get libraryEmptyNoRoots =>
      'Lägg först till en biblioteksmapp och välj sedan låtar från den.';

  @override
  String get playlistEmpty => 'Den här spellistan innehåller inga låtar ännu.';

  @override
  String get missingTrack => 'Saknad fil';

  @override
  String get playlistReadOnly => 'Skrivskyddad';

  @override
  String get playlistSelect => 'Välj';

  @override
  String get playlistSelectAll => 'Markera allt';

  @override
  String get playlistDeselectAll => 'Avmarkera alla';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valt',
      one: '1 valt',
      zero: 'Välj låtar',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ska spåren $count tas bort från spellistan?',
      one: 'Ta bort låten från spellistan?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Detta tar bort posterna från spellistfilen när du sparar.',
      one: 'Detta tar bort posten från spellistfilen när du sparar.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Inga nya låtar har lagts till. De kanske redan finns i spellistan.';

  @override
  String get addToQueue => 'Lägg till i kön';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spår har lagts till i kön',
      one: '1 spår har lagts till i kön',
      zero: 'Inga nya spår lades till i kön',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Flytta upp';

  @override
  String get moveDown => 'Flytta ned';

  @override
  String get playlistNothingToPlay =>
      'Den här spellistan innehåller inga spår som går att spela upp.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Ta bort spellistan?';

  @override
  String deletePlaylistBody(String name) {
    return 'Ta bort ”$name”? Detta tar bort spellistfilen från hårddisken.';
  }
}

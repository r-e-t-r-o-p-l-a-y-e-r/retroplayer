// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Setări';

  @override
  String get about => 'Despre';

  @override
  String get aboutSubtitle =>
      'Doar audio local. Fără reclame, fără telemetrie, fără acces la rețea.\nFormate acceptate: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versiune';

  @override
  String get aboutBuildDate => 'Timpul de compilare';

  @override
  String get aboutGitBranch => 'Ramură';

  @override
  String get aboutGitCommit => 'Compilare';

  @override
  String get equalizer => 'Egalizator';

  @override
  String get equalizerUnavailable =>
      'Equalizer nu este disponibil pe această platformă.';

  @override
  String get bands => 'Trupe';

  @override
  String get reset => 'Resetare';

  @override
  String get library => 'Bibliotecă';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Listă de redare';

  @override
  String get nowPlaying => 'Se difuzează acum';

  @override
  String get addFolder => 'Adaugă folder';

  @override
  String get audioPermissionRequired =>
      'Pe Android este necesară acordarea permisiunii pentru acces la sunet';

  @override
  String get expandPlayer => 'Extinde fereastra playerului';

  @override
  String get showLibrary => 'Afișează biblioteca';

  @override
  String errorMessage(String message) {
    return 'Eroare: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nu s-au adăugat dosare. Atingeți „Adăugați un dosar” pentru a începe.';

  @override
  String get folderEmpty => 'Acest dosar este gol.';

  @override
  String get librarySources => 'Surse bibliografice';

  @override
  String get favorites => 'Preferințe';

  @override
  String get favorite => 'Preferat';

  @override
  String get removeFavorite => 'Elimină din favorite';

  @override
  String get folders => 'Dosare';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Deschide dosarul';

  @override
  String get playAlbum => 'Redă albumul';

  @override
  String get removeLibraryFolderTitle => 'Să șterg folderul „library”?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Doriți să eliminați „$name” din biblioteca dvs.?\n\nFișierele audio de pe disc nu vor fi șterse.';
  }

  @override
  String get cancel => 'Anulează';

  @override
  String get remove => 'Eliminare';

  @override
  String get albumNotFound => 'Albumul nu a fost găsit';

  @override
  String get playlistNotFound => 'Lista de redare nu a fost găsită';

  @override
  String get selectToPlay => 'Alege ceva din biblioteca ta pentru a-l reda.';

  @override
  String get speed => 'Viteză';

  @override
  String get previous => 'Anterior';

  @override
  String get pause => 'Pauză';

  @override
  String get play => 'Joacă';

  @override
  String get next => 'Următorul';

  @override
  String get jumpBack => 'Înapoi cu 15 secunde';

  @override
  String get jumpForward => 'Avansează cu 15 secunde';

  @override
  String get trackFallback => 'Pistă';

  @override
  String get unknownArtist => 'Necunoscut';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count piese · $artist';
  }

  @override
  String get resetDatabase => 'Resetare bază de date';

  @override
  String get resetDatabaseTitle => 'Să resetezi baza de date?';

  @override
  String get resetDatabaseBody =>
      'Această acțiune șterge pozițiile de redare, favoritele, folderul deschis, tema, limba și setările egalizatorului. Opțiunea „Șterge tot” elimină, de asemenea, folderele adăugate în bibliotecă. Fișierele muzicale și listele de redare de pe disc nu sunt șterse.';

  @override
  String get resetDatabaseKeepFolders => 'Păstrați folderele bibliotecii';

  @override
  String get resetDatabaseClearEverything => 'Șterge totul';

  @override
  String get eqManually => 'Manual';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Înalt';

  @override
  String get eqVoice => 'Voce';

  @override
  String get appearance => 'Aspect';

  @override
  String get themeLight => 'Lumină';

  @override
  String get themeDark => 'Întuneric';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get language => 'Limba';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get openSourceLicenses => 'Licențe open source';

  @override
  String get openSourceLegalese => '© 2026 Colaboratorii Retro Player';

  @override
  String get dataStorage => 'Stocarea datelor';

  @override
  String get dataStorageIntro =>
      'Retro Player stochează setările aplicației într-o mică bază de date locală. Melodiile și listele de redare rămân ca fișiere obișnuite în folderele pe care le alegi.';

  @override
  String get dataStorageAppDataTitle => 'Baza de date a aplicațiilor';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fișier: $dbFileName\nCale: $dbPath\n\nStochează preferințele privind rădăcinile bibliotecilor, starea de navigare, reluarea redării, egalizatorul, tema și limba.';
  }

  @override
  String get dataStorageLibraryTitle => 'Fișiere muzicale';

  @override
  String get dataStorageLibraryBody =>
      'Fișierele audio nu sunt niciodată copiate în baza de date a aplicației. Adăugați folderele din bibliotecă, iar Retro Player va citi fișierele direct de pe disc.';

  @override
  String get dataStoragePlaylistsTitle => 'Fișiere cu liste de redare';

  @override
  String get dataStoragePlaylistsBody =>
      'Listele de redare sunt fișiere simple de tip .m3u stocate în folderele bibliotecii tale. Le poți edita în aplicație sau cu orice editor de text.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platformă: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Datele aplicației sunt stocate în directorul „app-support” (de obicei ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Date despre aplicațiile Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Datele aplicației sunt stocate în ~/.local/share/app.retroplayer/. Acest dosar este destinat exclusiv bazei de date și setărilor.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrarea barei de activități în Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Pentru pictograma din bara de activități și din grila de aplicații, mediile desktop Linux necesită fișiere Freedesktop separate. Retro Player le instalează din pachetul aplicației la pornire:\n\n• ~/.local/share/applications/app.retroplayer.desktop — intrare în lansator care leagă fereastra activă de această aplicație\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — pictograme tematice copiate din pachet\n\nNu scrie niciodată un fișier hicolor/index.theme al utilizatorului (ceea ce ar suprascrie tema sistemului și ar ascunde alte pictograme). Pictogramele sunt, de asemenea, încorporate în fișierul binar al aplicației. Copiile de mai sus ajută GNOME/KDE să afișeze pictograma corectă a lansatorului în locul unui simbol generic.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Permisiunile și spațiul de stocare pe Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player își stochează baza de date în zona de suport privată a aplicației, pe spațiul de stocare intern. Fișierele tale muzicale rămân în folderele pe care le alegi cu ajutorul selectorului de foldere al sistemului.\n\nPe Android, aplicația poate solicita acces la fișiere audio pentru a citi piesele, precum și acces la fotografii/imagini, astfel încât să poată fi afișate imaginile de copertă ale folderelor (de exemplu, cover.jpg). Fișierele audio nu sunt niciodată copiate în baza de date a aplicației.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Redare în fundal pe Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Când se redă un fișier audio, Retro Player rulează un serviciu media în prim-plan, astfel încât redarea să continue chiar dacă blochezi telefonul sau comuți între aplicații, comenzile de redare fiind afișate în bara de notificări a sistemului. Dacă glisezi aplicația în afara listei „Recente”, redarea se oprește și notificarea dispare.';

  @override
  String get dataStorageIOSAccessTitle => 'Accesul la folderele iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player își stochează baza de date în zona de suport privată a aplicației, din memoria dispozitivului. Fișierele tale muzicale rămân în folderele pe care le alegi cu ajutorul selectorului de foldere al sistemului.\n\niOS acordă acces prin URL-uri cu nivel de securitate definit pentru folderele pe care le selectezi. Retro Player citește fișierele direct din acele locații; nu copiază biblioteca ta în memoria aplicației.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Sunet de fundal pe iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Redarea poate continua chiar și atunci când aplicația rulează în fundal sau ecranul este blocat. Pozițiile de reluare și starea listei de redare sunt stocate în baza de date locală a aplicației.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Datele aplicației sunt stocate în zona de suport privată a aplicației, pe spațiul de stocare intern.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Datele aplicației sunt stocate în zona de suport privată a aplicației, în spațiul de stocare al dispozitivului.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Datele aplicației sunt stocate în directorul ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Datele aplicației sunt stocate în directorul de suport al aplicației.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Datele aplicației sunt stocate în memoria locală a browserului pentru această origine.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Datele aplicației sunt stocate în zona de suport a aplicației platformei.';

  @override
  String get loading => 'Se încarcă…';

  @override
  String get libraryIndex => 'Indexul bibliotecii';

  @override
  String get playlists => 'Liste de redare';

  @override
  String get playPlaylist => 'Redă lista de redare';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piese',
      one: '1 piesă',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Creează o listă de redare';

  @override
  String get queue => 'Coadă';

  @override
  String get saveAsPlaylist => 'Salvează ca listă de redare';

  @override
  String get queueEmpty =>
      'Lista de redare este goală. Adaugă melodii din biblioteca ta.';

  @override
  String get choosePlaylistFolder =>
      'Alegeți un dosar din bibliotecă. Rădăcina bibliotecii nu este un dosar.';

  @override
  String get clearQueue => 'Șterge coada';

  @override
  String get clearQueueTitle => 'Se șterge coada?';

  @override
  String get clearQueueBody =>
      'Această acțiune elimină toate melodiile din coada de redare. Fișierele audio și listele de redare salvate rămân.';

  @override
  String get newPlaylistName => 'Numele listei de redare';

  @override
  String get addTracks => 'Adaugă piese';

  @override
  String get addSelectedTracks => 'Adaugă piesele selectate';

  @override
  String get save => 'Salvare';

  @override
  String get addTracksFromLibrary => 'Adaugă din bibliotecă';

  @override
  String addTracksConfirm(int count) {
    return 'Adăugare ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Selectează una sau mai multe piese din biblioteca ta.';

  @override
  String get libraryEmptyNoRoots =>
      'Mai întâi adaugă un folder de bibliotecă, apoi selectează melodiile din acesta.';

  @override
  String get playlistEmpty =>
      'Această listă de redare nu conține încă nicio melodie.';

  @override
  String get missingTrack => 'Fișier lipsă';

  @override
  String get playlistReadOnly => 'Numai pentru citire';

  @override
  String get playlistSelect => 'Selectează';

  @override
  String get playlistSelectAll => 'Selectează tot';

  @override
  String get playlistDeselectAll => 'Deselectează tot';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selectat',
      one: '1 selectat',
      zero: 'Selectează piesele',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Să ștergi piesele $count din lista de redare?',
      one: 'Să ștergi melodia din lista de redare?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Această acțiune elimină intrările din fișierul listei de redare atunci când salvați.',
      one: 'Această acțiune elimină intrarea din fișierul listei de redare atunci când salvați.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nu s-au adăugat melodii noi. Este posibil ca acestea să se afle deja în lista de redare.';

  @override
  String get addToQueue => 'Adaugă la coadă';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adăugate la coadă: $count',
      one: '1 piesă adăugată la coadă',
      zero: 'Nicio piesă nouă nu a fost adăugată la coadă',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Mută în sus';

  @override
  String get moveDown => 'Mută în jos';

  @override
  String get playlistNothingToPlay =>
      'Această listă de redare nu conține piese care pot fi redate.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Să ștergi lista de redare?';

  @override
  String deletePlaylistBody(String name) {
    return 'Ștergeți „$name”? Această acțiune elimină fișierul listei de redare de pe disc.';
  }
}

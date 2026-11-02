// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Configuració';

  @override
  String get about => 'Sobre';

  @override
  String get aboutSubtitle =>
      'Àudio local només. Sense anuncis, sense telemetria, sense accés a la xarxa.\nFormats admesos: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versió';

  @override
  String get aboutBuildDate => 'Temps de construcció';

  @override
  String get aboutGitBranch => 'Sucursal';

  @override
  String get aboutGitCommit => 'Compilació';

  @override
  String get equalizer => 'Equalitzador';

  @override
  String get equalizerUnavailable =>
      'L\'equalizador no està disponible en aquesta plataforma.';

  @override
  String get bands => 'Grups de música';

  @override
  String get reset => 'Restablir';

  @override
  String get library => 'Biblioteca';

  @override
  String get album => 'Àlbum';

  @override
  String get playlist => 'Llista de reproducció';

  @override
  String get nowPlaying => 'Ara sona';

  @override
  String get addFolder => 'Afegeix carpeta';

  @override
  String get audioPermissionRequired =>
      'Es requereix permís d\'àudio a Android.';

  @override
  String get expandPlayer => 'Expandir reproductor';

  @override
  String get showLibrary => 'Mostra la biblioteca';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get noFoldersAdded =>
      'No s\'ha afegit cap carpeta. Toca \"Afegeix carpeta\" per començar.';

  @override
  String get folderEmpty => 'Aquesta carpeta està buida.';

  @override
  String get librarySources => 'Fonts de la biblioteca';

  @override
  String get favorites => 'Preferits';

  @override
  String get favorite => 'Preferit';

  @override
  String get removeFavorite => 'Eliminar preferit';

  @override
  String get folders => 'Carpetes';

  @override
  String get audio => 'Àudio';

  @override
  String get playFolder => 'Reprodueix la carpeta';

  @override
  String get playAlbum => 'Reprodueix l\'àlbum';

  @override
  String get removeLibraryFolderTitle =>
      'Eliminar la carpeta de la biblioteca?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Eliminar \"$name\" de la vostra biblioteca?\n\nEls fitxers d\'àudio del disc no s\'eliminaran.';
  }

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get remove => 'Eliminar';

  @override
  String get albumNotFound => 'L\'àlbum no s\'ha trobat';

  @override
  String get playlistNotFound => 'Llista de reproducció no trobada';

  @override
  String get selectToPlay =>
      'Selecciona alguna cosa de la teva biblioteca per reproduir.';

  @override
  String get speed => 'Velocitat';

  @override
  String get previous => 'Anterior';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Reprodueix';

  @override
  String get next => 'Següent';

  @override
  String get jumpBack => 'Tornar 15 segons';

  @override
  String get jumpForward => 'Avançar 15 segons';

  @override
  String get trackFallback => 'Pista';

  @override
  String get unknownArtist => 'Desconegut';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count pistes · $artist';
  }

  @override
  String get resetDatabase => 'Restablir la base de dades';

  @override
  String get resetDatabaseTitle => 'Restablir la base de dades?';

  @override
  String get resetDatabaseBody =>
      'Això elimina les posicions de reproducció, els favorits, la carpeta oberta, el tema, l\'idioma i la configuració de l\'equalizador. Eliminar-ho tot també oblida les carpetes de biblioteca afegides. Els fitxers de música i les llistes de reproducció al disc no s\'eliminen.';

  @override
  String get resetDatabaseKeepFolders =>
      'Conservar les carpetes de la biblioteca';

  @override
  String get resetDatabaseClearEverything => 'Esborra-ho tot';

  @override
  String get eqManually => 'Manualment';

  @override
  String get eqBass => 'Baix';

  @override
  String get eqTreble => 'Agut';

  @override
  String get eqVoice => 'Veu';

  @override
  String get appearance => 'Aparença';

  @override
  String get themeLight => 'Llum';

  @override
  String get themeDark => 'Fosc';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get openSourceLicenses => 'Llicències de codi obert';

  @override
  String get openSourceLegalese => '© 2026 Col·laboradors de Retro Player';

  @override
  String get dataStorage => 'Emmagatzematge de dades';

  @override
  String get dataStorageIntro =>
      'Retro Player guarda la configuració de l\'aplicació en una petita base de dades local. La teva música i les teves llistes de reproducció es mantenen com a fitxers normals en les carpetes que triïs.';

  @override
  String get dataStorageAppDataTitle => 'Base de dades de l\'aplicació';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fitxer: $dbFileName\nCamin: $dbPath\n\nEmmagatzema les arrels de la biblioteca, l\'estat de navegació, la reproducció, la reanudació, l\'equalizador, el tema i les preferències de llenguatge.';
  }

  @override
  String get dataStorageLibraryTitle => 'Fitxers de música';

  @override
  String get dataStorageLibraryBody =>
      'Els fitxers d\'àudio mai no es copien a la base de dades de l\'aplicació. Afegeix carpetes de la biblioteca i Retro Player llegeix els fitxers directament des del disc.';

  @override
  String get dataStoragePlaylistsTitle => 'Fitxers de llista de reproducció';

  @override
  String get dataStoragePlaylistsBody =>
      'Les llistes de reproducció són fitxers .m3u senzills emmagatzemats dins de les carpetes de la teva biblioteca. Les pots editar a l\'aplicació o amb qualsevol editor de text.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plataforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Les dades de l\'aplicació s\'emmagatzemen al directori de suport d\'aplicacions (normalment ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Dades de l\'aplicació de Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Les dades de l\'aplicació es queden a ~/.local/share/app.retroplayer/. Aquesta carpeta és només per a la base de dades i la configuració.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integració de la barra de tasques de Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Per a la icona de la barra de tasques i la de la graella d\'aplicacions, els entorns d\'escriptori de Linux esperen fitxers Freedesktop separats. Retro Player els instal·la des del paquet de l\'aplicació en iniciar-se:\n\n• ~/.local/share/applications/app.retroplayer.desktop — entrada d\'iniciador que enllaça la finestra en execució a aquesta aplicació\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — icones temàtiques copiades del paquet\n\nNo escriu mai un fitxer hicolor/index.theme d\'usuari (que eclipsaria el tema del sistema i amagaria altres icones). Les icones també estan incrustades al binari de l\'aplicació. Les còpies anteriors ajuden a GNOME/KDE a mostrar la icona d\'inici correcta en lloc d\'un marcador de posició genèric.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Permisos i emmagatzematge d\'Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player emmagatzema la seva base de dades a l\'àrea de suport privada de l\'aplicació a l\'emmagatzematge intern. Els teus fitxers de música romanen a les carpetes que tries amb l\'explorador de carpetes del sistema.\n\nA Android, l\'aplicació pot sol·licitar accés a l\'àudio per llegir pistes i accés a fotos/imatges perquè es pugui mostrar la imatge de la carpeta (per exemple cover.jpg). Els fitxers d\'àudio mai no es copien a la base de dades de l\'aplicació.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Reproducció en segon pla d\'Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Quan l\'àudio està sonant, Retro Player executa un servei de mitjans en primer pla perquè la reproducció continuï si bloquejes el telèfon o canvies d\'aplicació, amb els controls de transport a la notificació del sistema. Desplaçant l\'aplicació fora de les darreres, s\'atura la reproducció i es elimina la notificació.';

  @override
  String get dataStorageIOSAccessTitle => 'Accés a les carpetes d\'iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player emmagatzema la seva base de dades a l\'àrea de suport privada de l\'aplicació, a l\'emmagatzematge del dispositiu. Els vostres fitxers de música es mantenen a les carpetes que trieu amb l\'explorador de carpetes del sistema.\n\nL\'iOS atorga accés mitjançant URL amb abast de seguretat a les carpetes que seleccioneu. Retro Player llegeix els fitxers directament des d\'aquestes ubicacions; no copia la vostra biblioteca a l\'emmagatzematge de l\'aplicació.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Àudio en segon pla d\'iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'La reproducció pot continuar mentre l\'aplicació és en segon pla o la pantalla està bloquejada. Les posicions de reproducció i l\'estat de la cua s\'emmagatzemen a la base de dades local de l\'aplicació.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Les dades de l\'aplicació s\'emmagatzemen a l\'àrea de suport privada de l\'aplicació a l\'emmagatzematge intern.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Les dades de l\'aplicació s\'emmagatzemen a l\'àrea de suport privada de l\'aplicació a l\'emmagatzematge del dispositiu.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Les dades de l\'aplicació s\'emmagatzemen a ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Les dades de l\'aplicació s\'emmagatzemen al directori de suport de la vostra aplicació.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Les dades de l\'aplicació s\'emmagatzemen en l\'emmagatzematge local del navegador per a aquesta origen.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Les dades de l\'aplicació s\'emmagatzemen a l\'àrea de suport d\'aplicacions de la plataforma.';

  @override
  String get loading => 'Carregant…';

  @override
  String get libraryIndex => 'Índex de la biblioteca';

  @override
  String get playlists => 'Llistes de reproducció';

  @override
  String get playPlaylist => 'Reprodueix la llista de reproducció';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistes',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Crea una llista de reproducció';

  @override
  String get queue => 'Fila';

  @override
  String get saveAsPlaylist => 'Desa com a llista de reproducció';

  @override
  String get queueEmpty =>
      'La cua està buida. Afegeix pistes de la teva biblioteca.';

  @override
  String get choosePlaylistFolder =>
      'Tria una carpeta a la biblioteca. La carpeta arrel de la biblioteca no és una carpeta.';

  @override
  String get clearQueue => 'Esborrar la cua';

  @override
  String get clearQueueTitle => 'Esborrar cua?';

  @override
  String get clearQueueBody =>
      'Això elimina totes les pistes de la cua. Els fitxers d\'àudio i les llistes de reproducció guardades es mantenen.';

  @override
  String get newPlaylistName => 'Nom de la llista de reproducció';

  @override
  String get addTracks => 'Afegir pistes';

  @override
  String get save => 'Desa';

  @override
  String get addTracksFromLibrary => 'Afegeix de la biblioteca';

  @override
  String addTracksConfirm(int count) {
    return 'Afegir ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Selecciona una o més pistes de la teva biblioteca.';

  @override
  String get libraryEmptyNoRoots =>
      'Afegeix primer una carpeta de biblioteca i després selecciona-ne les pistes.';

  @override
  String get playlistEmpty =>
      'Aquesta llista de reproducció encara no té cap pista.';

  @override
  String get missingTrack => 'Fitxer absent';

  @override
  String get playlistReadOnly => 'Només de lectura';

  @override
  String get playlistSelect => 'Seleccionar';

  @override
  String get playlistSelectAll => 'Selecciona-ho tot';

  @override
  String get playlistDeselectAll => 'Deselecciona-ho tot';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionat',
      one: '1 seleccionat',
      zero: 'Seleccionar pistes',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar les pistes $count de la llista de reproducció?',
      one: 'Eliminar pista de la llista de reproducció?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Això elimina les entrades del fitxer de la llista de reproducció quan deses.',
      one: 'Això elimina l\'entrada del fitxer de la llista de reproducció quan deses.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'No s\'han afegit noves pistes. Poden ser que ja estiguin a la llista de reproducció.';

  @override
  String get addToQueue => 'Afegeix a la fila';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han afegit $count pistes a la fila',
      one: 'S\'ha afegit 1 pista a la fila',
      zero: 'No s\'ha afegit cap pista nova a la fila',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Mou amunt';

  @override
  String get moveDown => 'Mou avall';

  @override
  String get playlistNothingToPlay =>
      'Aquesta llista de reproducció no té cap pista reproduïble.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Eliminar llista de reproducció?';

  @override
  String deletePlaylistBody(String name) {
    return 'Eliminar \"$name\"? Això elimina el fitxer de la llista de reproducció del disc.';
  }
}

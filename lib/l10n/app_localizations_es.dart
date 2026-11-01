// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Ajustes';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutSubtitle =>
      'Solo audio local. Sin anuncios, sin telemetría, sin acceso a la red.\nFormatos compatibles: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutBuildDate => 'Tiempo de construcción';

  @override
  String get aboutGitBranch => 'Rama';

  @override
  String get aboutGitCommit => 'Compilación';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get equalizerUnavailable =>
      'El ecualizador no está disponible en esta plataforma.';

  @override
  String get bands => 'Bandas';

  @override
  String get reset => 'Reiniciar';

  @override
  String get library => 'Biblioteca';

  @override
  String get album => 'Álbum';

  @override
  String get playlist => 'Lista de reproducción';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get addFolder => 'Añadir carpeta';

  @override
  String get audioPermissionRequired =>
      'Se requiere permiso de audio en Android';

  @override
  String get expandPlayer => 'Expandir reproductor';

  @override
  String get showLibrary => 'Mostrar biblioteca';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get noFoldersAdded =>
      'No se han añadido carpetas. Pulsa \"Añadir carpeta\" para empezar.';

  @override
  String get folderEmpty => 'Esta carpeta está vacía.';

  @override
  String get librarySources => 'Fuentes de la biblioteca';

  @override
  String get favorites => 'Favoritos';

  @override
  String get favorite => 'Favorito';

  @override
  String get removeFavorite => 'Eliminar favorito';

  @override
  String get folders => 'Carpetas';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Carpeta de reproducción';

  @override
  String get playAlbum => 'Reproducir álbum';

  @override
  String get removeLibraryFolderTitle => '¿Eliminar carpeta de biblioteca?';

  @override
  String removeLibraryFolderBody(String name) {
    return '¿Quieres eliminar «$name» de tu biblioteca?\n\nLos archivos de audio que tienes en el disco no se borrarán.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get albumNotFound => 'Álbum no encontrado';

  @override
  String get playlistNotFound => 'Lista de reproducción no encontrada';

  @override
  String get selectToPlay => 'Selecciona algo de tu biblioteca para jugar.';

  @override
  String get speed => 'Rapidez';

  @override
  String get previous => 'Anterior';

  @override
  String get pause => 'Pausar';

  @override
  String get play => 'Jugar';

  @override
  String get next => 'Siguiente';

  @override
  String get jumpBack => 'Atrás 15 segundos';

  @override
  String get jumpForward => 'Adelante 15 segundos';

  @override
  String get trackFallback => 'Pista';

  @override
  String get unknownArtist => 'Desconocido';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count pistas · $artist';
  }

  @override
  String get resetDatabase => 'Restablecer base de datos';

  @override
  String get resetDatabaseTitle => '¿Restablecer base de datos?';

  @override
  String get resetDatabaseBody =>
      'Esto borra las posiciones de reproducción, los favoritos, la carpeta abierta, el tema, el idioma y la configuración del ecualizador. Borrar todo también olvida las carpetas de biblioteca añadidas. Los archivos de música y las listas de reproducción en el disco no se eliminan.';

  @override
  String get resetDatabaseKeepFolders => 'Mantener carpetas de biblioteca';

  @override
  String get resetDatabaseClearEverything => 'Borrar todo';

  @override
  String get eqManually => 'Manualmente';

  @override
  String get eqBass => 'Bajo';

  @override
  String get eqTreble => 'Agudos';

  @override
  String get eqVoice => 'Voz';

  @override
  String get appearance => 'Aspecto';

  @override
  String get themeLight => 'Luz';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get openSourceLegalese => '© 2026 Colaboradores de Retro Player';

  @override
  String get dataStorage => 'Almacenamiento de datos';

  @override
  String get dataStorageIntro =>
      'Retro Player mantiene la configuración de la aplicación en una pequeña base de datos local. Tu música y listas de reproducción permanecen como archivos normales en las carpetas que elijas.';

  @override
  String get dataStorageAppDataTitle => 'Base de datos de aplicaciones';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Expediente: $dbFileName\nRuta: $dbPath\n\nAlmacena las raíces de la biblioteca, el estado de navegación, el currículum de reproducción, el ecualizador, el tema y las preferencias de idioma.';
  }

  @override
  String get dataStorageLibraryTitle => 'Archivos de música';

  @override
  String get dataStorageLibraryBody =>
      'Los archivos de audio nunca se copian en la base de datos de la aplicación. Agregue carpetas de biblioteca y Retro Player lee archivos directamente desde el disco.';

  @override
  String get dataStoragePlaylistsTitle => 'Archivos de lista de reproducción';

  @override
  String get dataStoragePlaylistsBody =>
      'Las listas de reproducción son archivos .m3u simples almacenados dentro de las carpetas de su biblioteca. Puedes editarlos en la aplicación o con cualquier editor de texto.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plataforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Los datos de la aplicación se almacenan en su directorio de soporte de aplicaciones (normalmente ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Datos de la aplicación Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Los datos de la aplicación permanecen en ~/.local/share/app.retroplayer/. Esa carpeta es solo para la base de datos y la configuración.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integración con la barra de tareas de Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Para el icono de la barra de tareas y la cuadrícula de aplicaciones, los entornos de escritorio de Linux esperan archivos Freedesktop separados. Retro Player los instala desde el paquete de aplicaciones al iniciar:\n\n• ~/.local/share/applications/app.retroplayer.desktop - entrada de lanzador que vincula la ventana en ejecución a esta aplicación\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — iconos temáticos copiados del paquete\n\nNunca escribe un usuario hicolor/index.theme (que sombrearía el tema del sistema y ocultaría otros iconos). Los iconos también están incrustados en el binario de la aplicación. Las copias anteriores ayudan a GNOME/KDE a mostrar el icono de iniciador correcto en lugar de un marcador de posición genérico.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Permisos y almacenamiento de Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player almacena su base de datos en el área de soporte privado de la aplicación en el almacenamiento interno. Tus archivos de música permanecen en las carpetas que elijas con el selector de carpetas del sistema.\n\nEn Android, la aplicación puede solicitar acceso de audio para leer pistas y acceso a fotos/imágenes para que se puedan mostrar ilustraciones de carpetas (por ejemplo, cover.jpg). Los archivos de audio nunca se copian en la base de datos de la aplicación.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Reproducción en segundo plano de Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Cuando se está reproduciendo audio, Retro Player ejecuta un servicio multimedia en primer plano, por lo que la reproducción continúa si bloquea el teléfono o cambia de aplicación, con controles de transporte en la notificación del sistema. Al deslizar la aplicación lejos de Recientes, se detiene la reproducción y se elimina la notificación.';

  @override
  String get dataStorageIOSAccessTitle => 'acceso a la carpeta de iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player almacena su base de datos en el área de soporte privado de la aplicación en el almacenamiento del dispositivo. Tus archivos de música permanecen en las carpetas que elijas con el selector de carpetas del sistema.\n\niOS otorga acceso a través de URL de ámbito de seguridad para las carpetas que seleccione. Retro Player lee archivos directamente desde esas ubicaciones; no copia su biblioteca en el almacenamiento de aplicaciones.';

  @override
  String get dataStorageIOSPlaybackTitle => 'audio de fondo para iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'La reproducción puede continuar mientras la aplicación está en segundo plano o la pantalla está bloqueada. Las posiciones de reanudación y el estado de la cola se almacenan en la base de datos de la aplicación local.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Los datos de la aplicación se almacenan en el área de soporte privado de la aplicación en el almacenamiento interno.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Los datos de la aplicación se almacenan en el área de soporte privado de la aplicación en el almacenamiento del dispositivo.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Los datos de la aplicación se almacenan en ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Los datos de la aplicación se almacenan en su directorio de soporte de aplicaciones.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Los datos de la aplicación se almacenan en el almacenamiento local del navegador para este origen.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Los datos de la aplicación se almacenan en el área de soporte de la aplicación de la plataforma.';

  @override
  String get loading => 'Cargando...';

  @override
  String get libraryIndex => 'Índice de la biblioteca';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get playPlaylist => 'Reproducir lista de reproducción';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count temas',
      one: '1 tema',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get queue => 'Cola';

  @override
  String get saveAsPlaylist => 'Guardar como lista de reproducción';

  @override
  String get queueEmpty => 'La cola está vacía. Añade pistas de tu biblioteca.';

  @override
  String get choosePlaylistFolder =>
      'Elija una carpeta en la biblioteca. La raíz de la biblioteca no es una carpeta.';

  @override
  String get clearQueue => 'Borrar cola';

  @override
  String get clearQueueTitle => '¿Borrar cola?';

  @override
  String get clearQueueBody =>
      'Esto elimina todas las pistas de la cola. Los archivos de audio y las listas de reproducción guardadas permanecen.';

  @override
  String get newPlaylistName => 'Nombre de la lista de reproducción';

  @override
  String get addTracks => 'Añadir pistas';

  @override
  String get save => 'Guardar';

  @override
  String get addTracksFromLibrary => 'Añadir desde la biblioteca';

  @override
  String addTracksConfirm(int count) {
    return 'Añadir ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Seleccione una o más pistas en su biblioteca.';

  @override
  String get libraryEmptyNoRoots =>
      'Añade primero una carpeta de biblioteca y luego elige pistas de ella.';

  @override
  String get playlistEmpty => 'Esta lista de reproducción aún no tiene pistas.';

  @override
  String get missingTrack => 'Falta el archivo';

  @override
  String get playlistReadOnly => 'Solo lectura';

  @override
  String get playlistSelect => 'Seleccionar';

  @override
  String get playlistSelectAll => 'Seleccionar todo';

  @override
  String get playlistDeselectAll => 'Deseleccionar todo';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionado',
      one: '1 seleccionado',
      zero: 'Seleccionar canciones',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Quieres eliminar las canciones $count de la lista de reproducción?',
      one: '¿Eliminar la canción de la lista de reproducción?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esto elimina las entradas del archivo de la lista de reproducción al guardar.',
      one: 'Esto elimina la entrada del archivo de la lista de reproducción al guardar.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'No se han añadido nuevas pistas. Es posible que ya estén en la lista de reproducción.';

  @override
  String get playlistNothingToPlay =>
      'Esta lista de reproducción no tiene pistas reproducibles.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => '¿Eliminar lista de reproducción?';

  @override
  String deletePlaylistBody(String name) {
    return '¿Eliminar \"$name\"? Esto elimina el archivo de lista de reproducción del disco.';
  }
}

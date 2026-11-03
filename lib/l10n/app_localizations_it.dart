// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Impostazioni';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutSubtitle =>
      'Solo audio locale. Nessuna pubblicità, nessuna telemetria, nessun accesso alla rete.&#10; Formati supportati: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versione';

  @override
  String get aboutBuildDate => 'TEMPO DI COSTRUZIONE';

  @override
  String get aboutGitBranch => 'Ramo';

  @override
  String get aboutGitCommit => 'Build';

  @override
  String get equalizer => 'Equalizzatore';

  @override
  String get equalizerUnavailable =>
      'Equalizzatore non è disponibile su questa piattaforma.';

  @override
  String get bands => 'Bande';

  @override
  String get reset => 'Reimposta';

  @override
  String get library => 'Libreria';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Playlist';

  @override
  String get nowPlaying => 'In riproduzione';

  @override
  String get addFolder => 'Aggiungi cartella';

  @override
  String get audioPermissionRequired =>
      'Su Android è necessaria l&#39;autorizzazione audio.';

  @override
  String get expandPlayer => 'Espandi il lettore';

  @override
  String get showLibrary => 'Mostra libreria';

  @override
  String errorMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nessuna cartella aggiunta. Tocca &quot;Aggiungi cartella&quot; per iniziare.';

  @override
  String get folderEmpty => 'La cartella è vuota';

  @override
  String get librarySources => 'Fonti della biblioteca';

  @override
  String get favorites => 'Preferiti';

  @override
  String get favorite => 'Preferito';

  @override
  String get removeFavorite => 'Rimuovi il preferito';

  @override
  String get folders => 'Cartelle';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'cartella di riproduzione';

  @override
  String get playAlbum => 'Riproduci album';

  @override
  String get removeLibraryFolderTitle =>
      'Come rimuovere la cartella della libreria?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Rimuovere \"$name\" dalla tua libreria?\n\nI file audio su disco non vengono eliminati.';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get remove => 'Rimuovi';

  @override
  String get albumNotFound => 'Album non trovato';

  @override
  String get playlistNotFound => 'Playlist non trovata';

  @override
  String get selectToPlay =>
      'Seleziona un brano dalla tua libreria da riprodurre.';

  @override
  String get speed => 'Velocità';

  @override
  String get previous => 'Indietro';

  @override
  String get pause => 'Metti in pausa';

  @override
  String get play => 'Giocare';

  @override
  String get next => 'Avanti';

  @override
  String get jumpBack => '15 secondi';

  @override
  String get jumpForward => 'Avanti di 15 secondi';

  @override
  String get chapters => 'Capitoli';

  @override
  String get previousChapter => 'Capitolo precedente';

  @override
  String get nextChapter => 'Capitolo successivo';

  @override
  String get headphones => 'Cuffie';

  @override
  String get autoRewind => 'Riavvolgi alla ripresa';

  @override
  String get autoRewindHint =>
      'Dopo una pausa di almeno un minuto, le tracce più lunghe di 20 minuti riprendono qualche secondo prima.';

  @override
  String get rewindBy => 'Riavvolgi di';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Riprendi quando le cuffie si riconnettono';

  @override
  String get resumeOnReconnectHint =>
      'Solo se la riproduzione è stata messa in pausa perché le cuffie sono state scollegate meno di 10 minuti fa.';

  @override
  String get trackFallback => 'Traccia';

  @override
  String get unknownArtist => 'Sconosciuto';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count tracce · $artist';
  }

  @override
  String get resetDatabase => 'Ripristina il database';

  @override
  String get resetDatabaseTitle => 'Reset database';

  @override
  String get resetDatabaseBody =>
      'Questo cancella le posizioni di riproduzione, i preferiti, la cartella aperta, il tema, la lingua e le impostazioni dell\'equalizzatore. Cancella tutto dimentica anche le cartelle della libreria aggiunte. I file musicali e le playlist su disco non vengono eliminati.';

  @override
  String get resetDatabaseKeepFolders => 'Mantieni le cartelle della libreria';

  @override
  String get resetDatabaseClearEverything => 'Svuota tutto';

  @override
  String get eqManually => 'Manualmente';

  @override
  String get eqBass => 'Basso';

  @override
  String get eqTreble => 'Acuti';

  @override
  String get eqVoice => 'Voce';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeLight => 'Di luce.';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get openSourceLicenses => 'Licenze open source';

  @override
  String get openSourceLegalese => '© 2026 Collaboratori di Retro Player';

  @override
  String get dataStorage => 'Memorizzazione dei dati';

  @override
  String get dataStorageIntro =>
      'Retro Player mantiene le impostazioni dell\'app in un piccolo database locale. La tua musica e le tue playlist rimangono come normali file nelle cartelle che scegli.';

  @override
  String get dataStorageAppDataTitle => 'Database delle app';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'File: $dbFileName&#10; Percorso: $dbPath&#10;&#10; Memorizza le directory principali della libreria, lo stato di navigazione, la ripresa della riproduzione, le impostazioni dell&#39;equalizzatore, del tema e della lingua.';
  }

  @override
  String get dataStorageLibraryTitle => 'File musicali';

  @override
  String get dataStorageLibraryBody =>
      'I file audio non vengono mai copiati nel database dell\'app. Aggiungi cartelle della libreria e Retro Player legge i file direttamente dal disco.';

  @override
  String get dataStoragePlaylistsTitle => 'File della scaletta';

  @override
  String get dataStoragePlaylistsBody =>
      'Le playlist sono semplici file .m3u memorizzati all\'interno delle cartelle della libreria. Puoi modificarli nell\'app o con qualsiasi editor di testo.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Piattaforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'I dati dell&#39;app vengono memorizzati nella directory di supporto dell&#39;app (in genere ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'I dati delle app rimangono in ~/.local/share/app.retroplayer/. Quella cartella è solo per il database e le impostazioni.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integrazione barra delle applicazioni Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Per l&#39;icona della barra delle applicazioni e della griglia delle app, gli ambienti desktop Linux si aspettano file Freedesktop separati. Retro Player li installa dal pacchetto dell&#39;app all&#39;avvio:\n\n• ~/.local/share/applications/app.retroplayer.desktop — voce di avvio che collega la finestra in esecuzione a questa app\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — icone a tema copiate dal bundle\n\nNon scrive mai un tema hicolor/index.theme dell\'utente (che ombreggerebbe il tema del sistema e nasconderebbe altre icone). Anche le icone sono incorporate nel binario dell\'app. Le copie sopra aiutano GNOME/KDE a mostrare l\'icona di avvio corretta invece di un segnaposto generico.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Autorizzazioni e archiviazione Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player memorizza il suo database nell&#39;area di supporto privata dell&#39;app, nella memoria interna. I tuoi file musicali rimangono nelle cartelle che selezioni tramite lo strumento di selezione cartelle del sistema.&#10;&#10; Su Android, l&#39;app potrebbe richiedere l&#39;accesso all&#39;audio per riprodurre le tracce e l&#39;accesso a foto/immagini per visualizzare le copertine delle cartelle (ad esempio cover.jpg). I file audio non vengono mai copiati nel database dell&#39;app.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Riproduzione in background Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Durante la riproduzione dell\'audio, Retro Player esegue un servizio multimediale in primo piano, quindi la riproduzione continua se si blocca il telefono o si cambia app, con i controlli di trasporto nella notifica di sistema. La rimozione dell\'app da Recenti interrompe la riproduzione e rimuove la notifica.';

  @override
  String get dataStorageIOSAccessTitle => 'Accesso alla cartella';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player memorizza il suo database nell&#39;area di supporto privata dell&#39;app sulla memoria del dispositivo. I tuoi file musicali rimangono nelle cartelle che scegli tramite il selettore di cartelle di sistema.&#10;&#10; iOS concede l&#39;accesso tramite URL con ambito di sicurezza per le cartelle selezionate. Retro Player legge i file direttamente da tali posizioni; non copia la libreria nella memoria dell&#39;app.';

  @override
  String get dataStorageIOSPlaybackTitle => 'audio di sottofondo iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'La riproduzione può continuare mentre l\'app è in background o lo schermo è bloccato. Le posizioni di ripresa e lo stato della coda sono memorizzati nel database dell\'app locale.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'I dati delle app vengono archiviati nell\'area di supporto privata dell\'app nella memoria interna.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'I dati delle app vengono archiviati nell\'area di supporto privata dell\'app sull\'archiviazione del dispositivo.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'I dati delle app sono archiviati in ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'I dati dell\'app vengono archiviati nella directory di supporto dell\'applicazione.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'I dati delle app vengono memorizzati nella memoria locale del browser per questa origine.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'I dati dell&#39;app vengono memorizzati nell&#39;area di supporto dell&#39;applicazione della piattaforma.';

  @override
  String get loading => 'Caricamento in corso...';

  @override
  String get libraryIndex => 'Indice della biblioteca';

  @override
  String get playlists => 'Playlist';

  @override
  String get playPlaylist => 'Riproduci playlist';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani',
      one: '1 brano',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Crea playlist';

  @override
  String get queue => 'Coda';

  @override
  String get saveAsPlaylist => 'Salva come playlist';

  @override
  String get queueEmpty =>
      'La coda è vuota. Aggiungi tracce dalla tua libreria.';

  @override
  String get choosePlaylistFolder =>
      'Seleziona una cartella nella libreria. La directory principale della libreria non è una cartella.';

  @override
  String get clearQueue => 'Cancella coda';

  @override
  String get clearQueueTitle => 'Cancella coda';

  @override
  String get clearQueueBody =>
      'Questa operazione rimuove tutti i brani dalla coda. I file audio e le playlist salvate rimangono.';

  @override
  String get newPlaylistName => 'Nome playlist';

  @override
  String get addTracks => 'Aggiungi tracce';

  @override
  String get addSelectedTracks => 'Aggiungi tracce selezionate';

  @override
  String get save => 'Salva';

  @override
  String get addTracksFromLibrary => 'Aggiungi dalla libreria';

  @override
  String addTracksConfirm(int count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Seleziona uno o più brani dalla tua libreria.';

  @override
  String get libraryEmptyNoRoots =>
      'Per prima cosa, crea una cartella per la libreria e poi seleziona i brani da essa.';

  @override
  String get playlistEmpty => 'Questa playlist non ha ancora tracce.';

  @override
  String get missingTrack => 'File non presente';

  @override
  String get playlistReadOnly => 'Sola lettura';

  @override
  String get playlistSelect => 'Seleziona';

  @override
  String get playlistSelectAll => 'Selezionare tutto';

  @override
  String get playlistDeselectAll => 'Deseleziona tutto';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionato',
      one: '1 selezionato',
      zero: 'Seleziona i brani',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rimuovere i brani contrassegnati con $count dalla playlist?',
      one: 'Rimuovere il brano dalla playlist?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In questo modo, al momento del salvataggio, le voci vengono rimosse dal file della playlist.',
      one: 'In questo modo, al momento del salvataggio, la voce viene rimossa dal file della playlist.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Non sono state aggiunte nuove tracce. Potrebbero già essere nella playlist.';

  @override
  String get addToQueue => 'Aggiungi alla coda';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani aggiunti alla coda',
      one: '1 brano aggiunto alla coda',
      zero: 'Nessun nuovo brano aggiunto alla coda',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Sposta su';

  @override
  String get moveDown => 'Sposta giù';

  @override
  String get playlistNothingToPlay =>
      'Questa playlist non ha tracce riproducibili.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Eliminare la playlist?';

  @override
  String deletePlaylistBody(String name) {
    return 'Eliminare \"$name\"? Questo rimuove il file della playlist dal disco.';
  }
}

// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos';

  @override
  String get aboutSubtitle =>
      'Audio local uniquement. Pas de publicité, pas de télémétrie, pas d\'accès au réseau.\nFormats pris en charge : MP3, M4A, M4B, Flac, WAV';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuildDate => 'Temps de construction';

  @override
  String get aboutGitBranch => 'Branche';

  @override
  String get aboutGitCommit => 'Compilation';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get equalizerUnavailable =>
      'L\'égaliseur n\'est pas disponible sur cette plateforme.';

  @override
  String get bands => 'Bandes';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get library => 'Bibliothèque';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Liste de lecture';

  @override
  String get nowPlaying => 'En cours de lecture';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get audioPermissionRequired =>
      'Une autorisation audio est requise sur Android';

  @override
  String get expandPlayer => 'Développer le lecteur';

  @override
  String get showLibrary => 'Afficher la bibliothèque';

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noFoldersAdded =>
      'Aucun dossier ajouté. Appuyez sur « Ajouter un dossier » pour commencer.';

  @override
  String get folderEmpty => 'Ce dossier est vide.';

  @override
  String get librarySources => 'Sources de la bibliothèque';

  @override
  String get favorites => 'Favoris';

  @override
  String get favorite => 'Favoris';

  @override
  String get removeFavorite => 'Supprimer le favori';

  @override
  String get folders => 'Dossiers';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Dossier de lecture';

  @override
  String get playAlbum => 'Lire l\'album';

  @override
  String get removeLibraryFolderTitle =>
      'Supprimer le dossier de la bibliothèque ?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Souhaitez-vous supprimer « $name » de votre bibliothèque ?\n\nVos fichiers audio présents sur le disque ne seront pas supprimés.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get remove => 'Supprimer';

  @override
  String get albumNotFound => 'Album introuvable';

  @override
  String get playlistNotFound => 'Liste de lecture introuvable';

  @override
  String get selectToPlay =>
      'Sélectionnez quelque chose de votre bibliothèque pour jouer.';

  @override
  String get speed => 'Vitesse';

  @override
  String get previous => 'Précédent';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Lecture';

  @override
  String get next => 'Suivant';

  @override
  String get jumpBack => 'Retour 15 secondes';

  @override
  String get jumpForward => 'Avancer de 15 secondes';

  @override
  String get trackFallback => 'Suivre';

  @override
  String get unknownArtist => 'Inconnu';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count piste · $artist';
  }

  @override
  String get resetDatabase => 'Réinitialiser la base de';

  @override
  String get resetDatabaseTitle => 'Réinitialiser la base de données ?';

  @override
  String get resetDatabaseBody =>
      'Cela efface les positions de lecture, les favoris, le dossier ouvert, le thème, la langue et les paramètres de l\'égaliseur. Effacer tout oublie également les dossiers de bibliothèque ajoutés. Les fichiers musicaux et les listes de lecture sur le disque ne sont pas supprimés.';

  @override
  String get resetDatabaseKeepFolders =>
      'Conserver les dossiers de la bibliothèque';

  @override
  String get resetDatabaseClearEverything => 'Tout effacer';

  @override
  String get eqManually => 'Manuellement';

  @override
  String get eqBass => 'Basse';

  @override
  String get eqTreble => 'Aigus';

  @override
  String get eqVoice => 'Voix';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeLight => 'Lumière';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get openSourceLegalese => '© 2026 Contributeurs Retro Player';

  @override
  String get dataStorage => 'Stockage des données';

  @override
  String get dataStorageIntro =>
      'Retro Player conserve les paramètres de l\'application dans une petite base de données locale. Votre musique et vos listes de lecture restent des fichiers normaux dans les dossiers de votre choix.';

  @override
  String get dataStorageAppDataTitle => 'Base de données d\'applications';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Fichier : $dbFileName\nChemin : $dbPath\n\nStocke les racines de la bibliothèque, l\'état de navigation, le CV de lecture, l\'égaliseur, le thème et les préférences de langue.';
  }

  @override
  String get dataStorageLibraryTitle => 'Fichiers de musique';

  @override
  String get dataStorageLibraryBody =>
      'Les fichiers audio ne sont jamais copiés dans la base de données de l\'application. Ajoutez des dossiers de bibliothèque et Retro Player lit les fichiers directement à partir du disque.';

  @override
  String get dataStoragePlaylistsTitle => 'Fichiers de liste de lecture';

  @override
  String get dataStoragePlaylistsBody =>
      'Les listes de lecture sont des fichiers .m3u simples stockés dans les dossiers de votre bibliothèque. Vous pouvez les modifier dans l\'application ou avec n\'importe quel éditeur de texte.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plateforme : $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Les données d\'application sont stockées dans votre répertoire de support d\'application (généralement ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Données de l\'application Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Les données de l\'application restent dans ~/.local/share/app.retroplayer/. Ce dossier est uniquement destiné à la base de données et aux paramètres.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Intégration de la barre des tâches Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Pour l\'icône de la barre des tâches et de la grille d\'applications, les environnements de bureau Linux s\'attendent à des fichiers Freedesktop distincts. Retro Player les installe à partir de l\'ensemble d\'applications au démarrage :\n\n• ~/.local/share/applications/app.retroplayer.desktop — entrée du lanceur qui relie la fenêtre en cours d\'exécution à cette application\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png - icônes à thème copiées à partir du paquet\n\nIl n\'écrit jamais un hicolor/index.theme utilisateur (qui ombrerait le thème du système et cacherait d\'autres icônes). Les icônes sont également intégrées dans le binaire de l\'application. Les copies ci-dessus aident GNOME/KDE à afficher l\'icône de lancement correcte au lieu d\'un espace réservé générique.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Autorisations et stockage Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player stocke sa base de données dans la zone d\'assistance privée de l\'application sur le stockage interne. Vos fichiers musicaux restent dans les dossiers que vous choisissez avec le sélecteur de dossiers système.\n\nSur Android, l\'application peut demander un accès audio pour lire les pistes, et l\'accès aux photos/images afin que les illustrations du dossier (par exemple cover.jpg) puissent être affichées. Les fichiers audio ne sont jamais copiés dans la base de données de l\'application.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Lecture en arrière-plan Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Lorsque l\'audio est en cours de lecture, Retro Player exécute un service multimédia de premier plan afin que la lecture se poursuive si vous verrouillez le téléphone ou changez d\'application, avec des commandes de transport dans la notification du système. En faisant glisser l\'application loin de Récents, vous arrêtez la lecture et supprimez la notification.';

  @override
  String get dataStorageIOSAccessTitle => 'accès au dossier iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player stocke sa base de données dans la zone de support privé de l\'application sur le stockage de l\'appareil. Vos fichiers musicaux restent dans les dossiers que vous choisissez avec le sélecteur de dossiers système.\n\niOS accorde l\'accès via des URL de sécurité pour les dossiers que vous sélectionnez. Retro Player lit les fichiers directement à partir de ces emplacements ; il ne copie pas votre bibliothèque dans le stockage de l\'application.';

  @override
  String get dataStorageIOSPlaybackTitle => 'audio d\'arrière-plan iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'La lecture peut continuer pendant que l\'application est en arrière-plan ou que l\'écran est verrouillé. Les positions de reprise et l\'état de la file d\'attente sont stockés dans la base de données locale de l\'application.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Les données de l\'application sont stockées dans la zone d\'assistance privée de l\'application sur le stockage interne.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Les données de l\'application sont stockées dans la zone d\'assistance privée de l\'application sur le stockage de l\'appareil.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Les données de l\'application sont stockées sous ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Les données de l\'application sont stockées dans le répertoire de support de votre application.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Les données de l\'application sont stockées dans le stockage local du navigateur pour cette origine.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Les données de l\'application sont stockées dans la zone de support de l\'application de la plateforme.';

  @override
  String get loading => 'Chargement…';

  @override
  String get libraryIndex => 'Index de la bibliothèque';

  @override
  String get playlists => 'Listes de lecture';

  @override
  String get playPlaylist => 'Lire la liste de lecture';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '1 morceau',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Créer une liste de lecture';

  @override
  String get queue => 'File d\'attente';

  @override
  String get saveAsPlaylist => 'Enregistrer comme liste de lecture';

  @override
  String get queueEmpty =>
      'La file d\'attente est vide. Ajoutez des pistes à partir de votre bibliothèque.';

  @override
  String get choosePlaylistFolder =>
      'Choisissez un dossier dans la bibliothèque. La racine de la bibliothèque n\'est pas un dossier.';

  @override
  String get clearQueue => 'Effacer la file d\'attente';

  @override
  String get clearQueueTitle => 'Effacer la file d\'attente ?';

  @override
  String get clearQueueBody =>
      'Cela supprime chaque piste de la file d\'attente. Les fichiers audio et les listes de lecture enregistrées restent.';

  @override
  String get newPlaylistName => 'Nom de la liste de lecture';

  @override
  String get addTracks => 'Ajouter des pistes';

  @override
  String get save => 'Enregistrer';

  @override
  String get addTracksFromLibrary => 'Ajouter depuis la bibliothèque';

  @override
  String addTracksConfirm(int count) {
    return 'Ajouter ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Sélectionnez une ou plusieurs pistes dans votre bibliothèque.';

  @override
  String get libraryEmptyNoRoots =>
      'Ajoutez d\'abord un dossier de bibliothèque, puis choisissez des pistes à partir de celui-ci.';

  @override
  String get playlistEmpty =>
      'Cette liste de lecture n\'a pas encore de pistes.';

  @override
  String get missingTrack => 'Fichier manquant';

  @override
  String get playlistReadOnly => 'Lecture seule';

  @override
  String get playlistSelect => 'Sélectionner';

  @override
  String get playlistSelectAll => 'Tout sélectionner';

  @override
  String get playlistDeselectAll => 'Tout désélectionner';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionné',
      one: '1 sélectionné',
      zero: 'Sélectionner des titres',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer les titres $count de la liste de lecture ?',
      one: 'Supprimer ce titre de la liste de lecture ?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cela supprime les entrées du fichier de liste de lecture lorsque vous enregistrez.',
      one: 'Cela supprime l\'entrée du fichier de liste de lecture lorsque vous enregistrez.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Aucune nouvelle piste n\'a été ajoutée. Ils sont peut-être déjà dans la liste de lecture.';

  @override
  String get addToQueue => 'Ajouter à la file d\'attente';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres ajoutés à la file d\'attente',
      one: '1 titre ajouté à la file d\'attente',
      zero: 'Aucun nouveau titre ajouté à la file d\'attente',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get playlistNothingToPlay =>
      'Cette liste de lecture n\'a pas de pistes jouables.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Supprimer la liste de lecture ?';

  @override
  String deletePlaylistBody(String name) {
    return 'Supprimer « $name » ? Cette opération supprime le fichier de la liste de lecture du disque.';
  }
}

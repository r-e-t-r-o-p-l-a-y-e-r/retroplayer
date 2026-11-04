// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle =>
      'Local audio only. No ads, no telemetry, no network access.\nSupported formats: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuildDate => 'Build time';

  @override
  String get aboutGitBranch => 'Branch';

  @override
  String get aboutGitCommit => 'Build';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get equalizerUnavailable =>
      'Equalizer is not available on this platform.';

  @override
  String get bands => 'EQ bands';

  @override
  String get reset => 'Reset bands';

  @override
  String get library => 'Library';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Playlist';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get addFolder => 'Add folder';

  @override
  String get audioPermissionRequired =>
      'Audio permission is required on Android';

  @override
  String get expandPlayer => 'Expand player';

  @override
  String get showLibrary => 'Show library';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get noFoldersAdded =>
      'No folders added. Tap \"Add folder\" to get started.';

  @override
  String get folderEmpty => 'This folder is empty.';

  @override
  String get librarySources => 'Library sources';

  @override
  String get favorites => 'Favorites';

  @override
  String get favorite => 'Favorite';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get folders => 'Folders';

  @override
  String get audio => 'Audio';

  @override
  String get playFolder => 'Play folder';

  @override
  String get playAlbum => 'Play album';

  @override
  String get removeLibraryFolderTitle => 'Remove library folder?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Remove \"$name\" from your library?\n\nYour audio files on disk are not deleted.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get albumNotFound => 'Album not found';

  @override
  String get playlistNotFound => 'Playlist not found';

  @override
  String get selectToPlay => 'Select something from your library to play.';

  @override
  String get speed => 'Speed';

  @override
  String get previous => 'Previous';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get next => 'Next';

  @override
  String get jumpBack => 'Back 15 seconds';

  @override
  String get jumpForward => 'Forward 15 seconds';

  @override
  String get chapters => 'Chapters';

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get headphones => 'Headphones';

  @override
  String get autoRewind => 'Rewind on resume';

  @override
  String get autoRewindHint =>
      'After a pause of at least a minute, tracks longer than 20 minutes resume a few seconds earlier.';

  @override
  String get rewindBy => 'Rewind by';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Resume when headphones reconnect';

  @override
  String get resumeOnReconnectHint =>
      'Only if playback paused because the headphones were disconnected less than 10 minutes ago.';

  @override
  String get trackFallback => 'Track';

  @override
  String get unknownArtist => 'Unknown';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks · $artist',
      one: '$count track · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Reset database';

  @override
  String get resetDatabaseTitle => 'Reset database?';

  @override
  String get resetDatabaseBody =>
      'This clears playback positions, favorites, the open folder, theme, language, and equalizer settings. Clear everything also forgets the added library folders. Music files and playlists on disk are not deleted.';

  @override
  String get resetDatabaseKeepFolders => 'Keep library folders';

  @override
  String get resetDatabaseClearEverything => 'Clear everything';

  @override
  String get eqManually => 'Manually';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqTreble => 'Treble';

  @override
  String get eqVoice => 'Voice';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeSystem => 'System theme';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get openSourceLegalese => '© 2026 Retro Player contributors';

  @override
  String get dataStorage => 'Data storage';

  @override
  String get dataStorageIntro =>
      'Retro Player keeps app settings in a small local database. Your music and playlists stay as normal files in folders you choose.';

  @override
  String get dataStorageAppDataTitle => 'App database';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'File: $dbFileName\nPath: $dbPath\n\nStores library roots, browse state, playback resume, equalizer, theme, and language preferences.';
  }

  @override
  String get dataStorageLibraryTitle => 'Music files';

  @override
  String get dataStorageLibraryBody =>
      'Audio files are never copied into the app database. Add library folders and Retro Player reads files directly from disk.';

  @override
  String get dataStoragePlaylistsTitle => 'Playlist files';

  @override
  String get dataStoragePlaylistsBody =>
      'Playlists are plain .m3u files stored inside your library folders. You can edit them in the app or with any text editor.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platform: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'App data is stored under your app-support directory (typically ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Linux app data';

  @override
  String get dataStorageLinuxDataBody =>
      'App data stays in ~/.local/share/app.retroplayer/. That folder is only for the database and settings.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Linux taskbar integration';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'For the taskbar and app grid icon, Linux desktop environments expect separate Freedesktop files. Retro Player installs these from the app bundle on startup:\n\n• ~/.local/share/applications/app.retroplayer.desktop — launcher entry that links the running window to this app\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — themed icons copied from the bundle\n\nIt never writes a user hicolor/index.theme (that would shadow the system theme and hide other icons). Icons are also embedded in the app binary. The copies above help GNOME/KDE show the correct launcher icon instead of a generic placeholder.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Android permissions and storage';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player stores its database in the app-private support area on internal storage. Your music files stay in folders you pick with the system folder picker.\n\nOn Android, the app may request audio access to read tracks, and photos/images access so folder artwork (for example cover.jpg) can be shown. Audio files are never copied into the app database.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player stores its database in the app-private support area on internal storage. Your music files stay in folders you pick with the system folder picker.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Android background playback';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'When audio is playing, Retro Player runs a foreground media service so playback continues if you lock the phone or switch apps, with transport controls in the system notification. Swiping the app away from Recents stops playback and removes the notification.';

  @override
  String get dataStorageIOSAccessTitle => 'iOS folder access';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player stores its database in the app-private support area on device storage. Your music files stay in folders you choose with the system folder picker.\n\niOS grants access through security-scoped URLs for folders you select. Retro Player reads files directly from those locations; it does not copy your library into app storage.';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS background audio';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Playback can continue while the app is in the background or the screen is locked. Resume positions and queue state are stored in the local app database.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'App data is stored in the app-private support area on internal storage.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'App data is stored in the app-private support area on device storage.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'App data is stored under ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'App data is stored under your application support directory.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'App data is stored in browser-local storage for this origin.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'App data is stored in the platform application support area.';

  @override
  String get loading => 'Loading…';

  @override
  String get libraryIndex => 'Alphabetical index';

  @override
  String get playlists => 'Playlists';

  @override
  String get playPlaylist => 'Play playlist';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get queue => 'Queue';

  @override
  String get saveAsPlaylist => 'Save as playlist';

  @override
  String get queueEmpty => 'The queue is empty. Add tracks from your library.';

  @override
  String get choosePlaylistFolder =>
      'Choose a folder in the library. The library root is not a folder.';

  @override
  String get clearQueue => 'Clear queue';

  @override
  String get clearQueueTitle => 'Clear queue?';

  @override
  String get clearQueueBody =>
      'This removes every track from the queue. Audio files and saved playlists stay.';

  @override
  String get newPlaylistName => 'Playlist name';

  @override
  String get addTracks => 'Add tracks';

  @override
  String get addSelectedTracks => 'Add selected tracks';

  @override
  String get save => 'Save';

  @override
  String get addTracksFromLibrary => 'Add from library';

  @override
  String addTracksConfirm(int count) {
    return 'Add ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Select one or more tracks in your library.';

  @override
  String get libraryEmptyNoRoots =>
      'Add a library folder first, then pick tracks from it.';

  @override
  String get playlistEmpty => 'This playlist has no tracks yet.';

  @override
  String get missingTrack => 'Missing file';

  @override
  String get playlistReadOnly => 'Read-only';

  @override
  String get playlistSelect => 'Select';

  @override
  String get playlistSelectAll => 'Select all';

  @override
  String get playlistDeselectAll => 'Deselect all';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'Select tracks',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count tracks from playlist?',
      one: 'Remove track from playlist?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This removes the entries from the playlist file when you save.',
      one: 'This removes the entry from the playlist file when you save.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'No new tracks were added. They may already be in the playlist.';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks added to the queue',
      one: '1 track added to the queue',
      zero: 'No new tracks added to the queue',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get playlistNothingToPlay => 'This playlist has no playable tracks.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistBody(String name) {
    return 'Delete \"$name\"? This removes the playlist file from disk.';
  }
}

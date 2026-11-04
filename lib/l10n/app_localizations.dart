// GENERATED CODE - DO NOT EDIT BY HAND

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_bs.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_mk.dart';
import 'app_localizations_mt.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sq.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('bn'),
    Locale('bs'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('ga'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('is'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('lt'),
    Locale('lv'),
    Locale('mk'),
    Locale('mt'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sq'),
    Locale('sr'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Retro Player'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local audio only. No ads, no telemetry, no network access.\nSupported formats: MP3, M4A, M4B, FLAC, WAV'**
  String get aboutSubtitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutBuildDate.
  ///
  /// In en, this message translates to:
  /// **'Build time'**
  String get aboutBuildDate;

  /// Git branch name in About (version control), not a branch office.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get aboutGitBranch;

  /// Label for the Git commit hash in About (specific build revision), not a verb or legal commitment.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get aboutGitCommit;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @equalizerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Equalizer is not available on this platform.'**
  String get equalizerUnavailable;

  /// Equalizer frequency sliders (not a music band).
  ///
  /// In en, this message translates to:
  /// **'EQ bands'**
  String get bands;

  /// Reset equalizer sliders to flat/zero (not reset database).
  ///
  /// In en, this message translates to:
  /// **'Reset bands'**
  String get reset;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @audioPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Audio permission is required on Android'**
  String get audioPermissionRequired;

  /// No description provided for @expandPlayer.
  ///
  /// In en, this message translates to:
  /// **'Expand player'**
  String get expandPlayer;

  /// No description provided for @showLibrary.
  ///
  /// In en, this message translates to:
  /// **'Show library'**
  String get showLibrary;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @noFoldersAdded.
  ///
  /// In en, this message translates to:
  /// **'No folders added. Tap \"Add folder\" to get started.'**
  String get noFoldersAdded;

  /// No description provided for @folderEmpty.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty.'**
  String get folderEmpty;

  /// No description provided for @librarySources.
  ///
  /// In en, this message translates to:
  /// **'Library sources'**
  String get librarySources;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @playFolder.
  ///
  /// In en, this message translates to:
  /// **'Play folder'**
  String get playFolder;

  /// No description provided for @playAlbum.
  ///
  /// In en, this message translates to:
  /// **'Play album'**
  String get playAlbum;

  /// No description provided for @removeLibraryFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove library folder?'**
  String get removeLibraryFolderTitle;

  /// No description provided for @removeLibraryFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your library?\n\nYour audio files on disk are not deleted.'**
  String removeLibraryFolderBody(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @albumNotFound.
  ///
  /// In en, this message translates to:
  /// **'Album not found'**
  String get albumNotFound;

  /// No description provided for @playlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Playlist not found'**
  String get playlistNotFound;

  /// No description provided for @selectToPlay.
  ///
  /// In en, this message translates to:
  /// **'Select something from your library to play.'**
  String get selectToPlay;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @jumpBack.
  ///
  /// In en, this message translates to:
  /// **'Back 15 seconds'**
  String get jumpBack;

  /// No description provided for @jumpForward.
  ///
  /// In en, this message translates to:
  /// **'Forward 15 seconds'**
  String get jumpForward;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @headphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get headphones;

  /// No description provided for @autoRewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind on resume'**
  String get autoRewind;

  /// No description provided for @autoRewindHint.
  ///
  /// In en, this message translates to:
  /// **'After a pause of at least a minute, tracks longer than 20 minutes resume a few seconds earlier.'**
  String get autoRewindHint;

  /// No description provided for @rewindBy.
  ///
  /// In en, this message translates to:
  /// **'Rewind by'**
  String get rewindBy;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @resumeOnReconnect.
  ///
  /// In en, this message translates to:
  /// **'Resume when headphones reconnect'**
  String get resumeOnReconnect;

  /// No description provided for @resumeOnReconnectHint.
  ///
  /// In en, this message translates to:
  /// **'Only if playback paused because the headphones were disconnected less than 10 minutes ago.'**
  String get resumeOnReconnectHint;

  /// No description provided for @trackFallback.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get trackFallback;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownArtist;

  /// No description provided for @tracksCountArtist.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{{count} track · {artist}} other{{count} tracks · {artist}}}'**
  String tracksCountArtist(int count, String artist);

  /// No description provided for @resetDatabase.
  ///
  /// In en, this message translates to:
  /// **'Reset database'**
  String get resetDatabase;

  /// No description provided for @resetDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset database?'**
  String get resetDatabaseTitle;

  /// No description provided for @resetDatabaseBody.
  ///
  /// In en, this message translates to:
  /// **'This clears playback positions, favorites, the open folder, theme, language, and equalizer settings. Clear everything also forgets the added library folders. Music files and playlists on disk are not deleted.'**
  String get resetDatabaseBody;

  /// No description provided for @resetDatabaseKeepFolders.
  ///
  /// In en, this message translates to:
  /// **'Keep library folders'**
  String get resetDatabaseKeepFolders;

  /// No description provided for @resetDatabaseClearEverything.
  ///
  /// In en, this message translates to:
  /// **'Clear everything'**
  String get resetDatabaseClearEverything;

  /// Equalizer preset: user-adjusted bands (adverb, not a user guide).
  ///
  /// In en, this message translates to:
  /// **'Manually'**
  String get eqManually;

  /// Short equalizer preset label: emphasize bass frequencies (not the fish).
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get eqBass;

  /// Short equalizer preset label: emphasize treble/high frequencies.
  ///
  /// In en, this message translates to:
  /// **'Treble'**
  String get eqTreble;

  /// Short equalizer preset label: vocal/spoken-word curve (equalizer context).
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get eqVoice;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Light color theme (not brightness or weight).
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get themeLight;

  /// Dark color theme.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get themeDark;

  /// Follow the operating system light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Follow the device UI language.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @openSourceLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Retro Player contributors'**
  String get openSourceLegalese;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data storage'**
  String get dataStorage;

  /// No description provided for @dataStorageIntro.
  ///
  /// In en, this message translates to:
  /// **'Retro Player keeps app settings in a small local database. Your music and playlists stay as normal files in folders you choose.'**
  String get dataStorageIntro;

  /// No description provided for @dataStorageAppDataTitle.
  ///
  /// In en, this message translates to:
  /// **'App database'**
  String get dataStorageAppDataTitle;

  /// No description provided for @dataStorageAppDataBody.
  ///
  /// In en, this message translates to:
  /// **'File: {dbFileName}\nPath: {dbPath}\n\nStores library roots, browse state, playback resume, equalizer, theme, and language preferences.'**
  String dataStorageAppDataBody(String dbFileName, String dbPath);

  /// No description provided for @dataStorageLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Music files'**
  String get dataStorageLibraryTitle;

  /// No description provided for @dataStorageLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Audio files are never copied into the app database. Add library folders and Retro Player reads files directly from disk.'**
  String get dataStorageLibraryBody;

  /// No description provided for @dataStoragePlaylistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist files'**
  String get dataStoragePlaylistsTitle;

  /// No description provided for @dataStoragePlaylistsBody.
  ///
  /// In en, this message translates to:
  /// **'Playlists are plain .m3u files stored inside your library folders. You can edit them in the app or with any text editor.'**
  String get dataStoragePlaylistsBody;

  /// No description provided for @dataStoragePlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform: {platform}'**
  String dataStoragePlatformTitle(String platform);

  /// No description provided for @dataStoragePlatformBodyLinux.
  ///
  /// In en, this message translates to:
  /// **'App data is stored under your app-support directory (typically ~/.local/share/app.retroplayer/).'**
  String get dataStoragePlatformBodyLinux;

  /// No description provided for @dataStorageLinuxDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Linux app data'**
  String get dataStorageLinuxDataTitle;

  /// No description provided for @dataStorageLinuxDataBody.
  ///
  /// In en, this message translates to:
  /// **'App data stays in ~/.local/share/app.retroplayer/. That folder is only for the database and settings.'**
  String get dataStorageLinuxDataBody;

  /// No description provided for @dataStorageLinuxTaskbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Linux taskbar integration'**
  String get dataStorageLinuxTaskbarTitle;

  /// No description provided for @dataStorageLinuxTaskbarBody.
  ///
  /// In en, this message translates to:
  /// **'For the taskbar and app grid icon, Linux desktop environments expect separate Freedesktop files. Retro Player installs these from the app bundle on startup:\n\n• ~/.local/share/applications/app.retroplayer.desktop — launcher entry that links the running window to this app\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — themed icons copied from the bundle\n\nIt never writes a user hicolor/index.theme (that would shadow the system theme and hide other icons). Icons are also embedded in the app binary. The copies above help GNOME/KDE show the correct launcher icon instead of a generic placeholder.'**
  String get dataStorageLinuxTaskbarBody;

  /// No description provided for @dataStorageAndroidPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Android permissions and storage'**
  String get dataStorageAndroidPermissionsTitle;

  /// No description provided for @dataStorageAndroidPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Retro Player stores its database in the app-private support area on internal storage. Your music files stay in folders you pick with the system folder picker.\n\nOn Android, the app may request audio access to read tracks, and photos/images access so folder artwork (for example cover.jpg) can be shown. Audio files are never copied into the app database.'**
  String get dataStorageAndroidPermissionsBody;

  /// Native Android app: no storage or media permission, folders come from the system picker.
  ///
  /// In en, this message translates to:
  /// **'Retro Player stores its database in the app-private support area on internal storage. Your music files stay in folders you pick with the system folder picker.'**
  String get dataStorageAndroidNativeBody;

  /// No description provided for @dataStorageAndroidPlaybackTitle.
  ///
  /// In en, this message translates to:
  /// **'Android background playback'**
  String get dataStorageAndroidPlaybackTitle;

  /// No description provided for @dataStorageAndroidPlaybackBody.
  ///
  /// In en, this message translates to:
  /// **'When audio is playing, Retro Player runs a foreground media service so playback continues if you lock the phone or switch apps, with transport controls in the system notification. Swiping the app away from Recents stops playback and removes the notification.'**
  String get dataStorageAndroidPlaybackBody;

  /// No description provided for @dataStorageIOSAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'iOS folder access'**
  String get dataStorageIOSAccessTitle;

  /// No description provided for @dataStorageIOSAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Retro Player stores its database in the app-private support area on device storage. Your music files stay in folders you choose with the system folder picker.\n\niOS grants access through security-scoped URLs for folders you select. Retro Player reads files directly from those locations; it does not copy your library into app storage.'**
  String get dataStorageIOSAccessBody;

  /// No description provided for @dataStorageIOSPlaybackTitle.
  ///
  /// In en, this message translates to:
  /// **'iOS background audio'**
  String get dataStorageIOSPlaybackTitle;

  /// No description provided for @dataStorageIOSPlaybackBody.
  ///
  /// In en, this message translates to:
  /// **'Playback can continue while the app is in the background or the screen is locked. Resume positions and queue state are stored in the local app database.'**
  String get dataStorageIOSPlaybackBody;

  /// No description provided for @dataStoragePlatformBodyAndroid.
  ///
  /// In en, this message translates to:
  /// **'App data is stored in the app-private support area on internal storage.'**
  String get dataStoragePlatformBodyAndroid;

  /// No description provided for @dataStoragePlatformBodyIOS.
  ///
  /// In en, this message translates to:
  /// **'App data is stored in the app-private support area on device storage.'**
  String get dataStoragePlatformBodyIOS;

  /// No description provided for @dataStoragePlatformBodyMacOS.
  ///
  /// In en, this message translates to:
  /// **'App data is stored under ~/Library/Application Support/app.retroplayer/.'**
  String get dataStoragePlatformBodyMacOS;

  /// No description provided for @dataStoragePlatformBodyWindows.
  ///
  /// In en, this message translates to:
  /// **'App data is stored under your application support directory.'**
  String get dataStoragePlatformBodyWindows;

  /// No description provided for @dataStoragePlatformBodyWeb.
  ///
  /// In en, this message translates to:
  /// **'App data is stored in browser-local storage for this origin.'**
  String get dataStoragePlatformBodyWeb;

  /// No description provided for @dataStoragePlatformBodyUnknown.
  ///
  /// In en, this message translates to:
  /// **'App data is stored in the platform application support area.'**
  String get dataStoragePlatformBodyUnknown;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Accessibility label for the A–Z jump bar in the library list.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical index'**
  String get libraryIndex;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @playPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Play playlist'**
  String get playPlaylist;

  /// No description provided for @playlistTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 track} other{{count} tracks}}'**
  String playlistTrackCount(int count);

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylist;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @saveAsPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Save as playlist'**
  String get saveAsPlaylist;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty. Add tracks from your library.'**
  String get queueEmpty;

  /// No description provided for @choosePlaylistFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder in the library. The library root is not a folder.'**
  String get choosePlaylistFolder;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get clearQueue;

  /// No description provided for @clearQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear queue?'**
  String get clearQueueTitle;

  /// No description provided for @clearQueueBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every track from the queue. Audio files and saved playlists stay.'**
  String get clearQueueBody;

  /// No description provided for @newPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get newPlaylistName;

  /// No description provided for @addTracks.
  ///
  /// In en, this message translates to:
  /// **'Add tracks'**
  String get addTracks;

  /// No description provided for @addSelectedTracks.
  ///
  /// In en, this message translates to:
  /// **'Add selected tracks'**
  String get addSelectedTracks;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addTracksFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add from library'**
  String get addTracksFromLibrary;

  /// No description provided for @addTracksConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addTracksConfirm(int count);

  /// No description provided for @addTracksNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Select one or more tracks in your library.'**
  String get addTracksNothingSelected;

  /// No description provided for @libraryEmptyNoRoots.
  ///
  /// In en, this message translates to:
  /// **'Add a library folder first, then pick tracks from it.'**
  String get libraryEmptyNoRoots;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'This playlist has no tracks yet.'**
  String get playlistEmpty;

  /// No description provided for @missingTrack.
  ///
  /// In en, this message translates to:
  /// **'Missing file'**
  String get missingTrack;

  /// No description provided for @playlistReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get playlistReadOnly;

  /// No description provided for @playlistSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get playlistSelect;

  /// No description provided for @playlistSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get playlistSelectAll;

  /// No description provided for @playlistDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get playlistDeselectAll;

  /// No description provided for @playlistSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{Select tracks} =1{1 selected} other{{count} selected}}'**
  String playlistSelectedCount(int count);

  /// No description provided for @removePlaylistTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{Remove track from playlist?} other{Remove {count} tracks from playlist?}}'**
  String removePlaylistTrackTitle(int count);

  /// No description provided for @removePlaylistTrackBody.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{This removes the entry from the playlist file when you save.} other{This removes the entries from the playlist file when you save.}}'**
  String removePlaylistTrackBody(int count);

  /// No description provided for @addTracksNothingAdded.
  ///
  /// In en, this message translates to:
  /// **'No new tracks were added. They may already be in the playlist.'**
  String get addTracksNothingAdded;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No new tracks added to the queue} =1{1 track added to the queue} other{{count} tracks added to the queue}}'**
  String addedToQueue(int count);

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @playlistNothingToPlay.
  ///
  /// In en, this message translates to:
  /// **'This playlist has no playable tracks.'**
  String get playlistNothingToPlay;

  /// No description provided for @shortcutTooltip.
  ///
  /// In en, this message translates to:
  /// **'{action} ({shortcut})'**
  String shortcutTooltip(String action, String shortcut);

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This removes the playlist file from disk.'**
  String deletePlaylistBody(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bg',
    'bn',
    'bs',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fa',
    'fi',
    'fr',
    'ga',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'is',
    'it',
    'ja',
    'ko',
    'lt',
    'lv',
    'mk',
    'mt',
    'nb',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sq',
    'sr',
    'sv',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'bn':
      return AppLocalizationsBn();
    case 'bs':
      return AppLocalizationsBs();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fa':
      return AppLocalizationsFa();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'ga':
      return AppLocalizationsGa();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'is':
      return AppLocalizationsIs();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'mk':
      return AppLocalizationsMk();
    case 'mt':
      return AppLocalizationsMt();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sq':
      return AppLocalizationsSq();
    case 'sr':
      return AppLocalizationsSr();
    case 'sv':
      return AppLocalizationsSv();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

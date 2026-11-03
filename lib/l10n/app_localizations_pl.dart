// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Ustawienia';

  @override
  String get about => 'O nas';

  @override
  String get aboutSubtitle =>
      'Tylko lokalne pliki audio. Bez reklam, bez danych telemetrycznych, bez dostępu do sieci.\nObsługiwane formaty: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Wersja';

  @override
  String get aboutBuildDate => 'Czas kompilacji';

  @override
  String get aboutGitBranch => 'Gałąź';

  @override
  String get aboutGitCommit => 'Kompilacja';

  @override
  String get equalizer => 'Korektor';

  @override
  String get equalizerUnavailable =>
      'Na tej platformie funkcja korektora dźwięku nie jest dostępna.';

  @override
  String get bands => 'Zespoły';

  @override
  String get reset => 'Resetuj';

  @override
  String get library => 'Biblioteka';

  @override
  String get album => 'Album';

  @override
  String get playlist => 'Lista odtwarzania';

  @override
  String get nowPlaying => 'Teraz leci';

  @override
  String get addFolder => 'Dodaj folder';

  @override
  String get audioPermissionRequired =>
      'W systemie Android wymagana jest zgoda na dostęp do dźwięku';

  @override
  String get expandPlayer => 'Rozwiń odtwarzacz';

  @override
  String get showLibrary => 'Pokaż bibliotekę';

  @override
  String errorMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nie dodano żadnych folderów. Naciśnij „Dodaj folder”, aby rozpocząć.';

  @override
  String get folderEmpty => 'Ten folder jest pusty.';

  @override
  String get librarySources => 'Źródła biblioteczne';

  @override
  String get favorites => 'Ulubione';

  @override
  String get favorite => 'Ulubione';

  @override
  String get removeFavorite => 'Usuń z ulubionych';

  @override
  String get folders => 'Foldery';

  @override
  String get audio => 'Dźwięk';

  @override
  String get playFolder => 'Odtwórz zawartość folderu';

  @override
  String get playAlbum => 'Odtwórz album';

  @override
  String get removeLibraryFolderTitle => 'Usunąć folder biblioteki?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Czy chcesz usunąć „$name” z biblioteki?\n\nPliki audio na dysku nie zostaną usunięte.';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get remove => 'Usuń';

  @override
  String get albumNotFound => 'Nie znaleziono albumu';

  @override
  String get playlistNotFound => 'Nie znaleziono listy odtwarzania';

  @override
  String get selectToPlay => 'Wybierz utwór z biblioteki, aby go odtworzyć.';

  @override
  String get speed => 'Prędkość';

  @override
  String get previous => 'Poprzedni';

  @override
  String get pause => 'Pauza';

  @override
  String get play => 'Zagraj';

  @override
  String get next => 'Dalej';

  @override
  String get jumpBack => 'Cofnij o 15 sekund';

  @override
  String get jumpForward => 'Przewiń o 15 sekund do przodu';

  @override
  String get chapters => 'Rozdziały';

  @override
  String get previousChapter => 'Poprzedni rozdział';

  @override
  String get nextChapter => 'Następny rozdział';

  @override
  String get headphones => 'Słuchawki';

  @override
  String get autoRewind => 'Cofnij przy wznowieniu';

  @override
  String get autoRewindHint =>
      'Po co najmniej minutowej przerwie utwory dłuższe niż 20 minut wznawiają się kilka sekund wcześniej.';

  @override
  String get rewindBy => 'Cofnij o';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get resumeOnReconnect => 'Wznów po ponownym podłączeniu słuchawek';

  @override
  String get resumeOnReconnectHint =>
      'Tylko jeśli odtwarzanie zostało wstrzymane, bo słuchawki odłączono mniej niż 10 minut temu.';

  @override
  String get trackFallback => 'Utwór';

  @override
  String get unknownArtist => 'Nieznane';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count utworów · $artist';
  }

  @override
  String get resetDatabase => 'Zresetuj bazę danych';

  @override
  String get resetDatabaseTitle => 'Czy chcesz zresetować bazę danych?';

  @override
  String get resetDatabaseBody =>
      'Spowoduje to wyczyszczenie pozycji odtwarzania, ulubionych, otwartego folderu, motywu, języka oraz ustawień korektora. Opcja „Wyczyść wszystko” powoduje również usunięcie dodanych folderów biblioteki. Pliki muzyczne i listy odtwarzania znajdujące się na dysku nie zostaną usunięte.';

  @override
  String get resetDatabaseKeepFolders => 'Zachowaj foldery biblioteki';

  @override
  String get resetDatabaseClearEverything => 'Wyczyść wszystko';

  @override
  String get eqManually => 'Ręcznie';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Wysokie tony';

  @override
  String get eqVoice => 'Głos';

  @override
  String get appearance => 'Wygląd';

  @override
  String get themeLight => 'Światło';

  @override
  String get themeDark => 'Ciemność';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'System';

  @override
  String get openSourceLicenses => 'Licencje open source';

  @override
  String get openSourceLegalese => '© 2026 Autorzy serwisu Retro Player';

  @override
  String get dataStorage => 'Przechowywanie danych';

  @override
  String get dataStorageIntro =>
      'Aplikacja Retro Player przechowuje ustawienia w niewielkiej lokalnej bazie danych. Twoja muzyka i listy odtwarzania pozostają zwykłymi plikami w wybranych przez Ciebie folderach.';

  @override
  String get dataStorageAppDataTitle => 'Baza danych aplikacji';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Plik: $dbFileName\nŚcieżka: $dbPath\n\nPrzechowuje informacje o katalogach głównych bibliotek, stanie przeglądania, wznowieniu odtwarzania, korektorze, motywie oraz ustawieniach językowych.';
  }

  @override
  String get dataStorageLibraryTitle => 'Pliki muzyczne';

  @override
  String get dataStorageLibraryBody =>
      'Pliki audio nigdy nie są kopiowane do bazy danych aplikacji. Po dodaniu folderów biblioteki Retro Player odczytuje pliki bezpośrednio z dysku.';

  @override
  String get dataStoragePlaylistsTitle => 'Pliki z listami odtwarzania';

  @override
  String get dataStoragePlaylistsBody =>
      'Listy odtwarzania to zwykłe pliki .m3u przechowywane w folderach biblioteki. Można je edytować w aplikacji lub za pomocą dowolnego edytora tekstu.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Dane aplikacji są przechowywane w katalogu app-support (zazwyczaj ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Dane aplikacji w systemie Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Dane aplikacji są przechowywane w katalogu ~/.local/share/app.retroplayer/. Ten katalog służy wyłącznie do przechowywania bazy danych i ustawień.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integracja z paskiem zadań systemu Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'W przypadku ikony na pasku zadań oraz w siatce aplikacji środowiska graficzne systemu Linux wymagają oddzielnych plików Freedesktop. Retro Player instaluje je z pakietu aplikacji podczas uruchamiania:\n\n• ~/.local/share/applications/app.retroplayer.desktop — wpis w meniu uruchamiania, który łączy uruchomione okno z tą aplikacją\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ikony tematyczne skopiowane z pakietu\n\nAplikacja nigdy nie tworzy pliku hicolor/index.theme użytkownika (co spowodowałoby zastąpienie motywu systemowego i ukrycie innych ikon). Ikony są również osadzone w pliku binarnym aplikacji. Powyższe kopie pomagają środowiskom GNOME/KDE wyświetlać prawidłową ikonę uruchamiania zamiast ogólnego symbolu zastępczego.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Uprawnienia i pamięć w systemie Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Aplikacja Retro Player przechowuje swoją bazę danych w prywatnym obszarze pomocniczym aplikacji w pamięci wewnętrznej. Pliki muzyczne pozostają w folderach wybranych za pomocą systemowego selektora folderów.\n\nW systemie Android aplikacja może zażądać dostępu do plików audio w celu odczytania utworów oraz dostępu do zdjęć/obrazów, aby można było wyświetlać okładki folderów (na przykład cover.jpg). Pliki audio nigdy nie są kopiowane do bazy danych aplikacji.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Odtwarzanie w tle w systemie Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Podczas odtwarzania dźwięku aplikacja Retro Player uruchamia usługę multimedialną działającą w tle, dzięki czemu odtwarzanie jest kontynuowane nawet po zablokowaniu telefonu lub przełączeniu się do innej aplikacji, a elementy sterujące odtwarzaniem są widoczne w powiadomieniu systemowym. Przesunięcie aplikacji poza listę ostatnio używanych aplikacji powoduje zatrzymanie odtwarzania i usunięcie powiadomienia.';

  @override
  String get dataStorageIOSAccessTitle => 'Dostęp do folderów w systemie iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'Aplikacja Retro Player przechowuje swoją bazę danych w prywatnym obszarze pomocniczym aplikacji w pamięci urządzenia. Pliki muzyczne pozostają w folderach wybranych za pomocą systemowego selektora folderów.\n\nSystem iOS zapewnia dostęp do wybranych folderów za pośrednictwem adresów URL z ograniczeniami bezpieczeństwa. Aplikacja Retro Player odczytuje pliki bezpośrednio z tych lokalizacji; nie kopiuje biblioteki do pamięci aplikacji.';

  @override
  String get dataStorageIOSPlaybackTitle => 'Dźwięk w tle w systemie iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Odtwarzanie może trwać, nawet gdy aplikacja działa w tle lub ekran jest zablokowany. Pozycje wznowienia oraz stan kolejki są zapisywane w lokalnej bazie danych aplikacji.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Dane aplikacji są przechowywane w prywatnym obszarze pomocniczym aplikacji w pamięci wewnętrznej.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Dane aplikacji są przechowywane w prywatnym obszarze pomocniczym aplikacji w pamięci urządzenia.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Dane aplikacji są przechowywane w katalogu ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Dane aplikacji są przechowywane w katalogu „application support”.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Dane aplikacji są przechowywane w lokalnej pamięci przeglądarki dla tego źródła.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Dane aplikacji są przechowywane w obszarze wsparcia aplikacji platformy.';

  @override
  String get loading => 'Ładowanie…';

  @override
  String get libraryIndex => 'Indeks biblioteki';

  @override
  String get playlists => 'Listy odtwarzania';

  @override
  String get playPlaylist => 'Odtwórz listę odtwarzania';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utwory',
      one: '1 utwór',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Utwórz listę odtwarzania';

  @override
  String get queue => 'Kolejka';

  @override
  String get saveAsPlaylist => 'Zapisz jako playlistę';

  @override
  String get queueEmpty =>
      'Lista odtwarzania jest pusta. Dodaj utwory z biblioteki.';

  @override
  String get choosePlaylistFolder =>
      'Wybierz folder w bibliotece. Katalog główny biblioteki nie jest folderem.';

  @override
  String get clearQueue => 'Wyczyść kolejkę';

  @override
  String get clearQueueTitle => 'Wyczyścić kolejkę?';

  @override
  String get clearQueueBody =>
      'Spowoduje to usunięcie wszystkich utworów z kolejki. Pliki audio i zapisane listy odtwarzania pozostaną.';

  @override
  String get newPlaylistName => 'Nazwa listy odtwarzania';

  @override
  String get addTracks => 'Dodaj utwory';

  @override
  String get addSelectedTracks => 'Dodaj wybrane utwory';

  @override
  String get save => 'Zapisz';

  @override
  String get addTracksFromLibrary => 'Dodaj z biblioteki';

  @override
  String addTracksConfirm(int count) {
    return 'Dodaj ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Zaznacz jeden lub więcej utworów w swojej bibliotece.';

  @override
  String get libraryEmptyNoRoots =>
      'Najpierw dodaj folder z biblioteką, a następnie wybierz z niego utwory.';

  @override
  String get playlistEmpty =>
      'Ta playlista nie zawiera jeszcze żadnych utworów.';

  @override
  String get missingTrack => 'Brakujący plik';

  @override
  String get playlistReadOnly => 'Tylko do odczytu';

  @override
  String get playlistSelect => 'Wybierz';

  @override
  String get playlistSelectAll => 'Zaznacz wszystko';

  @override
  String get playlistDeselectAll => 'Odznacz wszystko';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zaznaczone',
      one: '1 wybrany',
      zero: 'Wybierz utwory',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Czy chcesz usunąć utwory oznaczone symbolem $count z listy odtwarzania?',
      one: 'Usunąć utwór z listy odtwarzania?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spowoduje to usunięcie wpisów z pliku listy odtwarzania podczas zapisywania.',
      one: 'Spowoduje to usunięcie tego wpisu z pliku listy odtwarzania po zapisaniu.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Nie dodano żadnych nowych utworów. Być może znajdują się one już na liście odtwarzania.';

  @override
  String get addToQueue => 'Dodaj do kolejki';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano do kolejki: $count',
      one: 'Dodano 1 utwór do kolejki',
      zero: 'Nie dodano nowych utworów do kolejki',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Przenieś w górę';

  @override
  String get moveDown => 'Przenieś w dół';

  @override
  String get playlistNothingToPlay =>
      'Ta playlista nie zawiera żadnych utworów, które można odtworzyć.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Usunąć playlistę?';

  @override
  String deletePlaylistBody(String name) {
    return 'Usunąć „$name”? Spowoduje to usunięcie pliku listy odtwarzania z dysku.';
  }
}

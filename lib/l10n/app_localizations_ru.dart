// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О нас';

  @override
  String get aboutSubtitle =>
      'Только локальное аудио. Без рекламы, без телеметрии, без доступа к сети.\nПоддерживаемые форматы: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Версия';

  @override
  String get aboutBuildDate => 'Время сборки';

  @override
  String get aboutGitBranch => 'Ветка';

  @override
  String get aboutGitCommit => 'Сборка';

  @override
  String get equalizer => 'Эквалайзер';

  @override
  String get equalizerUnavailable => 'Эквалайзер недоступен на этой платформе.';

  @override
  String get bands => 'Диапазоны';

  @override
  String get reset => 'Сбросить';

  @override
  String get library => 'Библиотека';

  @override
  String get album => 'Альбом';

  @override
  String get playlist => 'Плейлист';

  @override
  String get nowPlaying => 'Сейчас воспроизводится';

  @override
  String get addFolder => 'Добавить папку';

  @override
  String get audioPermissionRequired =>
      'Требуется разрешение на воспроизведение аудио на Android';

  @override
  String get expandPlayer => 'Развернуть плеер';

  @override
  String get showLibrary => 'Показать библиотеку';

  @override
  String errorMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get noFoldersAdded =>
      'Папки не добавлены. Нажмите «Добавить папку», чтобы начать.';

  @override
  String get folderEmpty => 'Эта папка пуста.';

  @override
  String get librarySources => 'Библиотечные источники';

  @override
  String get favorites => 'Избранное';

  @override
  String get favorite => 'Избранное';

  @override
  String get removeFavorite => 'Удалить избранное';

  @override
  String get folders => 'Папки';

  @override
  String get audio => 'Аудио';

  @override
  String get playFolder => 'Папка воспроизведения';

  @override
  String get playAlbum => 'Воспроизвести альбом';

  @override
  String get removeLibraryFolderTitle => 'Удалить папку библиотеки?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Удалить \"$name\" из вашей библиотеки?\n\nВаши аудиофайлы на диске не удаляются.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get remove => 'Удалить';

  @override
  String get albumNotFound => 'Альбом не найден';

  @override
  String get playlistNotFound => 'Плейлист не найден';

  @override
  String get selectToPlay =>
      'Выберите что-то из своей библиотеки для воспроизведения.';

  @override
  String get speed => 'Скорость';

  @override
  String get previous => 'Предыдущий';

  @override
  String get pause => 'Пауза';

  @override
  String get play => 'Играть';

  @override
  String get next => 'Далее';

  @override
  String get jumpBack => 'Назад на 15 секунд';

  @override
  String get jumpForward => 'Вперед на 15 секунд';

  @override
  String get chapters => 'Главы';

  @override
  String get previousChapter => 'Предыдущая глава';

  @override
  String get nextChapter => 'Следующая глава';

  @override
  String get headphones => 'Наушники';

  @override
  String get autoRewind => 'Перематывать назад при возобновлении';

  @override
  String get autoRewindHint =>
      'После паузы не менее минуты треки длиннее 20 минут продолжаются на несколько секунд раньше.';

  @override
  String get rewindBy => 'Перемотать назад на';

  @override
  String secondsShort(int seconds) {
    return '$seconds с';
  }

  @override
  String get resumeOnReconnect =>
      'Возобновлять при повторном подключении наушников';

  @override
  String get resumeOnReconnectHint =>
      'Только если воспроизведение остановилось из-за отключения наушников менее 10 минут назад.';

  @override
  String get trackFallback => 'Трек';

  @override
  String get unknownArtist => 'Неизвестно';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков · $artist',
      one: '$count трек · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Сбросить базу данных';

  @override
  String get resetDatabaseTitle => 'Сбросить базу данных?';

  @override
  String get resetDatabaseBody =>
      'Это очищает позиции воспроизведения, избранное, открытую папку, тему, язык и настройки эквалайзера. Очистка всего также удаляет добавленные папки библиотеки. Музыкальные файлы и плейлисты на диске не удаляются.';

  @override
  String get resetDatabaseKeepFolders => 'Сохраняйте папки библиотеки.';

  @override
  String get resetDatabaseClearEverything => 'Полная очистка';

  @override
  String get eqManually => 'Вручную';

  @override
  String get eqBass => 'Низкие частоты';

  @override
  String get eqTreble => 'Высокие частоты';

  @override
  String get eqVoice => 'Голос';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get themeLight => 'Свет';

  @override
  String get themeDark => 'Темный';

  @override
  String get themeSystem => 'классификации';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'классификации';

  @override
  String get openSourceLicenses => 'Лицензии открытого ПО';

  @override
  String get openSourceLegalese => '© 2026 Участники проекта Retro Player';

  @override
  String get dataStorage => 'Хранение данных';

  @override
  String get dataStorageIntro =>
      'Retro Player хранит настройки приложения в небольшой локальной базе данных. Ваша музыка и плейлисты остаются в виде обычных файлов в выбранных вами папках.';

  @override
  String get dataStorageAppDataTitle => 'база данных приложений';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Файл: $dbFileName\n Путь: $dbPath\n\n Сохраняет корневые каталоги библиотеки, состояние просмотра, возобновление воспроизведения, эквалайзер, тему оформления и языковые настройки.';
  }

  @override
  String get dataStorageLibraryTitle => 'Музыкальные файлы:';

  @override
  String get dataStorageLibraryBody =>
      'Аудиофайлы никогда не копируются в базу данных приложения. Добавьте папки библиотеки, и Retro Player будет считывать файлы непосредственно с диска.';

  @override
  String get dataStoragePlaylistsTitle => 'Playlist files:';

  @override
  String get dataStoragePlaylistsBody =>
      'Плейлисты — это обычные файлы .m3u, хранящиеся в папках вашей библиотеки. Вы можете редактировать их в приложении или с помощью любого текстового редактора.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Платформа $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Данные приложения хранятся в каталоге поддержки приложения (обычно ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'данные приложения Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Данные приложения хранятся в папке ~/.local/share/app.retroplayer/. Эта папка предназначена только для базы данных и настроек.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Интеграция панели задач Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Для значков на панели задач и в сетке приложений среды рабочего стола Linux ожидаются отдельные файлы Freedesktop. Retro Player устанавливает их из пакета приложения при запуске:\n\n• ~/.local/share/applications/app.retroplayer.desktop — запись запуска, которая связывает окно запуска с этим приложением\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — тематические иконки, скопированные из пакета\n\nПриложение никогда не создает пользовательский файл hicolor/index.theme (это бы заслонило системную тему и скрыло другие значки). Значки также встраиваются в исполняемый файл приложения. Приведенные выше копии помогают GNOME/KDE отображать правильный значок запуска вместо стандартного заполнителя.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Разрешения и хранилище Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player хранит свою базу данных в закрытой области приложения на внутренней памяти. Ваши музыкальные файлы остаются в папках, которые вы выбираете с помощью системного средства выбора папок.\n\n На Android приложение может запрашивать доступ к аудиофайлам для чтения треков, а также доступ к фотографиям/изображениям для отображения обложек папок (например, cover.jpg). Аудиофайлы никогда не копируются в базу данных приложения.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player хранит свою базу данных в закрытой области приложения на внутренней памяти. Ваши музыкальные файлы остаются в папках, которые вы выбираете с помощью системного средства выбора папок.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Воспроизведение фона Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Во время воспроизведения аудио Retro Player запускает фоновую медиаслужбу, поэтому воспроизведение продолжается, даже если вы заблокируете телефон или переключитесь на другое приложение, при этом элементы управления воспроизведением отображаются в системном уведомлении. Если вы проведете пальцем по приложению, чтобы удалить его из списка последних приложений, воспроизведение остановится, а уведомление исчезнет.';

  @override
  String get dataStorageIOSAccessTitle => 'Доступ к папке';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player хранит свою базу данных в закрытой области поддержки приложения во внутренней памяти устройства. Ваши музыкальные файлы остаются в папках, которые вы выбираете с помощью системного средства выбора папок.\n\n iOS предоставляет доступ к выбранным вами папкам через URL-адреса с ограниченным доступом. Retro Player считывает файлы непосредственно из этих мест; он не копирует вашу библиотеку в хранилище приложений.';

  @override
  String get dataStorageIOSPlaybackTitle => 'фоновое аудио iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Воспроизведение может продолжаться, пока приложение находится в фоновом режиме или экран заблокирован. Позиции резюме и состояние очереди хранятся в локальной базе данных приложения.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Данные приложения хранятся в области приватной поддержки приложения на внутреннем хранилище.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Данные приложения хранятся в области приватной поддержки приложения на устройстве хранения.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Данные приложения хранятся в каталоге ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Данные приложения хранятся в каталоге поддержки вашего приложения.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Данные приложения хранятся в локальном хранилище браузера для данного источника.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Данные приложения хранятся в области поддержки приложений платформы.';

  @override
  String get loading => 'Загрузка…';

  @override
  String get libraryIndex => 'Указатель библиотеки';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get playPlaylist => 'Воспроизвести плейлист';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков',
      one: '1 трек',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Создать плейлист';

  @override
  String get queue => 'Очередь';

  @override
  String get saveAsPlaylist => 'Сохранить как плейлист';

  @override
  String get queueEmpty => 'Очередь пуста. Добавьте треки из своей библиотеки.';

  @override
  String get choosePlaylistFolder =>
      'Выберите папку в библиотеке. Корневая папка библиотеки не является папкой.';

  @override
  String get clearQueue => 'Очистить очередь';

  @override
  String get clearQueueTitle => 'Очистить очередь';

  @override
  String get clearQueueBody =>
      'Это удалит все треки из очереди воспроизведения. Аудиофайлы и сохраненные плейлисты останутся.';

  @override
  String get newPlaylistName => 'Имя Плейлиста';

  @override
  String get addTracks => 'Добавить треки';

  @override
  String get addSelectedTracks => 'Добавить выбранные треки';

  @override
  String get save => 'Сохранить';

  @override
  String get addTracksFromLibrary => 'Загрузить из библиотеки';

  @override
  String addTracksConfirm(int count) {
    return 'Добавить $count';
  }

  @override
  String get addTracksNothingSelected =>
      'Выберите один или несколько треков из вашей библиотеки.';

  @override
  String get libraryEmptyNoRoots =>
      'Сначала создайте папку библиотеки, а затем выбирайте треки из неё.';

  @override
  String get playlistEmpty => 'В этом плейлисте пока нет треков.';

  @override
  String get missingTrack => 'Отсутствующий файл';

  @override
  String get playlistReadOnly => 'Только чтение';

  @override
  String get playlistSelect => 'Выбрать';

  @override
  String get playlistSelectAll => 'Выбрать все';

  @override
  String get playlistDeselectAll => 'Отмените выбор всех';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выбрано',
      one: '1 выбран',
      zero: 'Выбрать треки',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить треки $count из плейлиста?',
      one: 'Удалить трек из плейлиста?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'При этом при сохранении записи удаляются из файла плейлиста.',
      one: 'При этом при сохранении запись удаляется из файла плейлиста.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Новые треки не добавлены. Возможно, они уже есть в плейлисте.';

  @override
  String get addToQueue => 'Добавить в очередь';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено в очередь: $count',
      one: '1 трек добавлен в очередь',
      zero: 'Новые треки не добавлены в очередь',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Переместить вверх';

  @override
  String get moveDown => 'Переместить вниз';

  @override
  String get playlistNothingToPlay =>
      'В этом плейлисте нет воспроизводимых треков.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Удалить плейлист?';

  @override
  String deletePlaylistBody(String name) {
    return 'Удалить \"$name\"? Файл списка воспроизведения будет удален с диска.';
  }
}

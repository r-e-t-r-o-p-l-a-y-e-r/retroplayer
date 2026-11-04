// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Подешавања';

  @override
  String get about => 'О';

  @override
  String get aboutSubtitle =>
      'Само локални аудио. Без реклама, без телеметрије, без мрежног приступа.\nПодржани формати: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Верзија';

  @override
  String get aboutBuildDate => 'Време изградње';

  @override
  String get aboutGitBranch => 'Огранак';

  @override
  String get aboutGitCommit => 'Изградња';

  @override
  String get equalizer => 'Еквилајзер';

  @override
  String get equalizerUnavailable =>
      'Изједначивач није доступан на овој платформи.';

  @override
  String get bands => 'Бендови';

  @override
  String get reset => 'Ресетовати';

  @override
  String get library => 'Библиотека';

  @override
  String get album => 'Албум';

  @override
  String get playlist => 'Плејлиста';

  @override
  String get nowPlaying => 'Сада се пушта';

  @override
  String get addFolder => 'Додај фасциклу';

  @override
  String get audioPermissionRequired =>
      'За аудио је потребна дозвола на Android-у.';

  @override
  String get expandPlayer => 'Прошири плеер';

  @override
  String get showLibrary => 'Прикажи библиотеку';

  @override
  String errorMessage(String message) {
    return 'Грешка: $message';
  }

  @override
  String get noFoldersAdded =>
      'Ниједан фасцикл није додатан. Додирните \"Додај фасцикл\" да бисте започели.';

  @override
  String get folderEmpty => 'Овај фасцикл је празан.';

  @override
  String get librarySources => 'Библиотечки извори';

  @override
  String get favorites => 'Фаворити';

  @override
  String get favorite => 'Омиљено';

  @override
  String get removeFavorite => 'Уклони омиљено';

  @override
  String get folders => 'Фолдери';

  @override
  String get audio => 'Аудио';

  @override
  String get playFolder => 'Плеј фасцикла';

  @override
  String get playAlbum => 'Пусти албум';

  @override
  String get removeLibraryFolderTitle => 'Уклонити фасциклу библиотеке?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Уклонити \"$name\" из библиотеке?\n\nВаши аудио фајлови на диску неће бити избрисани.';
  }

  @override
  String get cancel => 'Откажи';

  @override
  String get remove => 'Уклони';

  @override
  String get albumNotFound => 'Албум није пронађен';

  @override
  String get playlistNotFound => 'Плејлиста није пронађена';

  @override
  String get selectToPlay =>
      'Изаберите нешто из своје библиотеке за репродукцију.';

  @override
  String get speed => 'Брзина';

  @override
  String get previous => 'Претходни';

  @override
  String get pause => 'Пауза';

  @override
  String get play => 'Пуни';

  @override
  String get next => 'Следеће';

  @override
  String get jumpBack => 'Назад 15 секунди';

  @override
  String get jumpForward => 'Премотај за 15 секунди';

  @override
  String get chapters => 'Поглавља';

  @override
  String get previousChapter => 'Претходно поглавље';

  @override
  String get nextChapter => 'Следеће поглавље';

  @override
  String get headphones => 'Слушалице';

  @override
  String get autoRewind => 'Премотај уназад при наставку';

  @override
  String get autoRewindHint =>
      'После паузе од најмање минут нумере дуже од 20 минута настављају се неколико секунди раније.';

  @override
  String get rewindBy => 'Премотај уназад за';

  @override
  String secondsShort(int seconds) {
    return '$seconds с';
  }

  @override
  String get resumeOnReconnect => 'Настави када се слушалице поново повежу';

  @override
  String get resumeOnReconnectHint =>
      'Само ако је репродукција паузирана јер су слушалице искључене пре мање од 10 минута.';

  @override
  String get trackFallback => 'Стаза';

  @override
  String get unknownArtist => 'Непознато';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трака · $artist',
      one: '$count трака · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'Ресетовати базу података';

  @override
  String get resetDatabaseTitle => 'Ресетовати базу података?';

  @override
  String get resetDatabaseBody =>
      'Ово брише положаје репродукције, омиљене, отворену фасциклу, тему, језик и подешавања еквилајзера. Брисање свега такође заборавља додате фасцикле библиотеке. Музичке датотеке и плејлисте на диску нису избрисане.';

  @override
  String get resetDatabaseKeepFolders => 'Чувајте фасцикле библиотеке';

  @override
  String get resetDatabaseClearEverything => 'Избриши све';

  @override
  String get eqManually => 'Ручно';

  @override
  String get eqBass => 'Бас';

  @override
  String get eqTreble => 'Високи тон';

  @override
  String get eqVoice => 'Глас';

  @override
  String get appearance => 'Изглед';

  @override
  String get themeLight => 'Лагано';

  @override
  String get themeDark => 'Тамно';

  @override
  String get themeSystem => 'Систем';

  @override
  String get language => 'Језик';

  @override
  String get languageSystem => 'Систем';

  @override
  String get openSourceLicenses => 'Лиценце отвореног кода';

  @override
  String get openSourceLegalese => '© 2026 доприносиоци Retro Player-а';

  @override
  String get dataStorage => 'Складиштење података';

  @override
  String get dataStorageIntro =>
      'Retro Player чува подешавања апликације у малој локалној бази података. Ваша музика и плејлисте остају као обични фајлови у фасциклама које изаберете.';

  @override
  String get dataStorageAppDataTitle => 'База података апликације';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Датотека: $dbFileName\nСтаза: $dbPath\n\nЧува корене библиотеке, стање прегледања, наставak репродукције, еквилајзер, тему и језичке преференције.';
  }

  @override
  String get dataStorageLibraryTitle => 'Музички фајлови';

  @override
  String get dataStorageLibraryBody =>
      'Аудио датотеке се никада не копирају у базу података апликације. Додајте фолдере библиотеке и Retro Player чита датотеке директно са диска.';

  @override
  String get dataStoragePlaylistsTitle => 'Датотеке плејлисте';

  @override
  String get dataStoragePlaylistsBody =>
      'Плејлисте су обичне .m3u датотеке које се налазе у фасциклама ваше библиотеке. Можете их уређивати у апликацији или у било ком уређивачу текста.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Платформа: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Подаци апликације се чувају у директоријуму app-support (обично ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Подаци апликације за Линукс';

  @override
  String get dataStorageLinuxDataBody =>
      'Подаци апликације се чувају у ~/.local/share/app.retroplayer/. Тај фолдер је само за базу података и подешавања.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Интеграција Линукс траке задатака';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'За икону траке задатака и мреже апликација, Linux десктоп окружења очекују одвојене Freedesktop фајлове. Retro Player инсталира ове фајлове из пакета апликације при покретању:\n\n• ~/.local/share/applications/app.retroplayer.desktop — унос за покретач који повезује активни прозор са овом апликацијом\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — иконе у одговарајућем темату копиране из пакета\n\nНикада не пише кориснички фајл hicolor/index.theme (што би засенило системску тему и сакрило друге иконе). Иконе су такође уграђене у бинарну датотеку апликације. Горе наведене копије помажу GNOME/KDE-у да прикаже исправну икону покретача уместо генеричког заменског места.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Андроид дозволе и складиштење';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player чува своју базу података у приватном подршном простору апликације на унутрашњој меморији. Ваши музички фајлови остају у фасциклама које изаберете помоћу системског избирача фасцикли.\n\nНа Android-у апликација може затражити приступ звуку за читање трака и приступ фотографијама/сликама како би се приказивала корица албума (на пример cover.jpg). Аудио датотеке никада се не копирају у базу података апликације.';

  @override
  String get dataStorageAndroidNativeBody =>
      'Retro Player чува своју базу података у приватном подршном простору апликације на унутрашњој меморији. Ваши музички фајлови остају у фасциклама које изаберете помоћу системског избирача фасцикли.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Плејање у позадини Андроида';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Када се аудио репродукује, Retro Player покреће медијску услугу у предњем плану тако да репродукција наставља и ако закључате телефон или пређете у другу апликацију, са контролама транспорта у системској извештајној траци. Повлачењем апликације из листе Недавно коришћених зауставља се репродукција и уклања се извештај.';

  @override
  String get dataStorageIOSAccessTitle => 'Приступ фасцикли на iOS-у';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player чува своју базу података у приватној подршци апликације на складишту уређаја. Ваши музички фајлови остају у фасциклама које изаберете помоћу системског избирача фасцикли.\n\niOS омогућава приступ преко URL адреса са ограниченим безбедносним оквиром за фасцикле које изаберете. Retro Player чита фајлове директно са тих локација; он не копира вашу библиотеку у складиште апликације.';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS позадински аудио';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Пуштање се може наставити док је апликација у позадини или док је екран закључан. Позиције за наставak и стање редоследа се чувају у локалној бази података апликације.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Подаци апликације се чувају у приватном подржавајућем простору апликације на унутрашњој меморији.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Подаци апликације се чувају у приватном подржавајућем простору апликације на меморији уређаја.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Подаци апликације се чувају у ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Подаци апликације се чувају у директоријуму за подршку апликација.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Подаци апликације се чувају у локалном складишту прегледача за овај извор.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Подаци апликације се чувају у области платформе за подршку апликацијама.';

  @override
  String get loading => 'Учитавање…';

  @override
  String get libraryIndex => 'Индекс библиотеке';

  @override
  String get playlists => 'Плејлисте';

  @override
  String get playPlaylist => 'Пусти плејлисту';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count траке',
      one: '1 трак',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Креирај плејлисту';

  @override
  String get queue => 'Ред';

  @override
  String get saveAsPlaylist => 'Сачувај као плејлисту';

  @override
  String get queueEmpty =>
      'Ред је празан. Додајте тракове из своје библиотеке.';

  @override
  String get choosePlaylistFolder =>
      'Изаберите фасциклу у библиотеци. Корен библиотеке није фасцикла.';

  @override
  String get clearQueue => 'Очисти ред';

  @override
  String get clearQueueTitle => 'Очистити ред?';

  @override
  String get clearQueueBody =>
      'Ово уклања сваки трак из реда. Аудио датотеке и сачуване плејлисте остају.';

  @override
  String get newPlaylistName => 'Назив плејлисте';

  @override
  String get addTracks => 'Додај траке';

  @override
  String get addSelectedTracks => 'Додај изабране траке';

  @override
  String get save => 'Сачувај';

  @override
  String get addTracksFromLibrary => 'Додај из библиотеке';

  @override
  String addTracksConfirm(int count) {
    return 'Додај ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Изаберите једну или више нумера у својој библиотеци.';

  @override
  String get libraryEmptyNoRoots =>
      'Прво додајте фасциклу библиотеке, а затим изаберите траке из ње.';

  @override
  String get playlistEmpty => 'Ова плејлиста још нема нумера.';

  @override
  String get missingTrack => 'Недостајућа датотека';

  @override
  String get playlistReadOnly => 'Само за читање';

  @override
  String get playlistSelect => 'Изабери';

  @override
  String get playlistSelectAll => 'Изабери све';

  @override
  String get playlistDeselectAll => 'Одузети све';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изабрано',
      one: '1 изабрано',
      zero: 'Изабери траке',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Уклонити $count тракове са плејлисте?',
      one: 'Уклонити песму са плејлисте?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ово уклања записе из датотеке плејлисте када сачувате.',
      one: 'Ово уклања унос из датотеке плејлисте када сачувате.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Није додата ниједна нова песма. Могуће је да су већ на плејлисти.';

  @override
  String get addToQueue => 'Додај у ред';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додато у ред: $count',
      one: '1 песма је додата у ред',
      zero: 'Ниједна нова песма није додата у ред',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Помери нагоре';

  @override
  String get moveDown => 'Помери надоле';

  @override
  String get playlistNothingToPlay =>
      'Ова плејлиста нема песме за репродукцију.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Избриши плејлисту?';

  @override
  String deletePlaylistBody(String name) {
    return 'Избришите \"$name\"? Ово уклања фајл плејлисте са диска.';
  }
}

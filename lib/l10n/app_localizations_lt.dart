// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Nustatymai';

  @override
  String get about => 'Apie';

  @override
  String get aboutSubtitle =>
      'Tik vietinis garso įrašas. Be reklamų, be telemetrijos, be prieigos prie tinklo.\nPalaikomi formatai: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versija';

  @override
  String get aboutBuildDate => 'Kūrimo trukmė';

  @override
  String get aboutGitBranch => 'Šaka';

  @override
  String get aboutGitCommit => 'Kompiliacija';

  @override
  String get equalizer => 'Ekvivalizatorius';

  @override
  String get equalizerUnavailable =>
      'Šioje platformoje ekvalaizeris nėra prieinamas.';

  @override
  String get bands => 'Grupės';

  @override
  String get reset => 'Atstatyti';

  @override
  String get library => 'Biblioteka';

  @override
  String get album => 'Albumas';

  @override
  String get playlist => 'Grojaraštis';

  @override
  String get nowPlaying => 'Šiuo metu groja';

  @override
  String get addFolder => 'Pridėti aplanką';

  @override
  String get audioPermissionRequired =>
      '„Android“ sistemoje reikalingas garso leidimas';

  @override
  String get expandPlayer => 'Išskleisti grotuvą';

  @override
  String get showLibrary => 'Rodyti biblioteką';

  @override
  String errorMessage(String message) {
    return 'Klaida: $message';
  }

  @override
  String get noFoldersAdded =>
      'Aplankų nepridėta. Norėdami pradėti, bakstelėkite „Pridėti aplanką“.';

  @override
  String get folderEmpty => 'Ši aplankas yra tuščias.';

  @override
  String get librarySources => 'Bibliotekos šaltiniai';

  @override
  String get favorites => 'Mėgstamiausi';

  @override
  String get favorite => 'Mėgstamiausias';

  @override
  String get removeFavorite => 'Pašalinti iš mėgstamiausių';

  @override
  String get folders => 'Aplankai';

  @override
  String get audio => 'Garso įrašas';

  @override
  String get playFolder => 'Atsisiųsti aplanką';

  @override
  String get playAlbum => 'Klausyti albumą';

  @override
  String get removeLibraryFolderTitle => 'Ar pašalinti bibliotekos aplanką?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Ar norite pašalinti „$name“ iš savo bibliotekos?\n\nJūsų garso failai diske nebus ištrinti.';
  }

  @override
  String get cancel => 'Atšaukti';

  @override
  String get remove => 'Pašalinti';

  @override
  String get albumNotFound => 'Albumo nerasta';

  @override
  String get playlistNotFound => 'Grojaraštis nerastas';

  @override
  String get selectToPlay =>
      'Pasirinkite ką nors iš savo bibliotekos ir paleiskite.';

  @override
  String get speed => 'Greitis';

  @override
  String get previous => 'Ankstesnis';

  @override
  String get pause => 'Pauzė';

  @override
  String get play => 'Žaisti';

  @override
  String get next => 'Toliau';

  @override
  String get jumpBack => 'Atgal 15 sekundžių';

  @override
  String get jumpForward => 'Pereiti 15 sekundžių į priekį';

  @override
  String get trackFallback => 'Takelis';

  @override
  String get unknownArtist => 'Nežinoma';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count įrašų · $artist';
  }

  @override
  String get resetDatabase => 'Atkurti duomenų bazę';

  @override
  String get resetDatabaseTitle => 'Atkurti duomenų bazę?';

  @override
  String get resetDatabaseBody =>
      'Tai ištrina atkūrimo pozicijas, mėgstamus elementus, atidarytą aplanką, temą, kalbą ir ekvalaizerio nustatymus. Pasirinkus „Ištrinti viską“, taip pat bus pamiršti pridėti bibliotekos aplankai. Muzikos failai ir grojaraščiai diske nebus ištrinti.';

  @override
  String get resetDatabaseKeepFolders => 'Išsaugoti bibliotekos aplankus';

  @override
  String get resetDatabaseClearEverything => 'Išvalyti viską';

  @override
  String get eqManually => 'Rankiniu būdu';

  @override
  String get eqBass => 'Bosas';

  @override
  String get eqTreble => 'Aukštieji dažniai';

  @override
  String get eqVoice => 'Balsas';

  @override
  String get appearance => 'Išvaizda';

  @override
  String get themeLight => 'Šviesa';

  @override
  String get themeDark => 'Tamsus';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Kalba';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get openSourceLicenses => 'Atvirojo kodo licencijos';

  @override
  String get openSourceLegalese => '© 2026 „Retro Player“ autoriai';

  @override
  String get dataStorage => 'Duomenų saugojimas';

  @override
  String get dataStorageIntro =>
      '„Retro Player“ saugo programos nustatymus nedidelėje vietinėje duomenų bazėje. Jūsų muzika ir grojaraščiai išlieka kaip įprasti failai jūsų pasirinktose aplankose.';

  @override
  String get dataStorageAppDataTitle => 'Programėlių duomenų bazė';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Failas: $dbFileName\nKelias: $dbPath\n\nČia saugomi bibliotekų katalogų šaknys, naršymo būsena, atkūrimo tęsimas, ekvalaizerio, temos ir kalbos nustatymai.';
  }

  @override
  String get dataStorageLibraryTitle => 'Muzikos failai';

  @override
  String get dataStorageLibraryBody =>
      'Garso failai niekada nėra kopijuojami į programos duomenų bazę. Pridėkite bibliotekos aplankus, ir „Retro Player“ skaitys failus tiesiogiai iš disko.';

  @override
  String get dataStoragePlaylistsTitle => 'Grojaraščių failai';

  @override
  String get dataStoragePlaylistsBody =>
      'Grojaraščiai yra paprasti .m3u failai, saugomi jūsų bibliotekos aplankuose. Juos galite redaguoti programoje arba bet kokiu teksto redaktoriumi.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Platforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Programos duomenys saugomi jūsų „app-support“ kataloge (paprastai ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => '„Linux“ programų duomenys';

  @override
  String get dataStorageLinuxDataBody =>
      'Programos duomenys saugomi kataloge ~/.local/share/app.retroplayer/. Šis katalogas skirtas tik duomenų bazei ir nustatymams.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      '„Linux“ užduočių juostos integravimas';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Dėl užduočių juostos ir programų tinklelio piktogramų „Linux“ darbalaukio aplinkose reikalaujama atskirų „Freedesktop“ failų. „Retro Player“ juos įdiegia iš programos paketo paleidimo metu:\n\n• ~/.local/share/applications/app.retroplayer.desktop — paleidimo įrašas, susiejantis veikiantį langą su šia programa\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — iš programų rinkinio nukopijuotos teminės piktogramos\n\nJi niekada nekuria vartotojo „hicolor/index.theme“ failo (nes tai užgožtų sistemos temą ir paslėptų kitas piktogramas). Piktogramos taip pat yra įterptos į programos vykdomąjį failą. Minėtos kopijos padeda „GNOME“ ir „KDE“ rodyti teisingą paleidimo piktogramą, o ne bendrąją vietos užpildymo piktogramą.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      '„Android“ leidimai ir saugykla';

  @override
  String get dataStorageAndroidPermissionsBody =>
      '„Retro Player“ savo duomenų bazę saugo vidinėje atmintyje esančioje programai skirtoje srityje. Jūsų muzikos failai išlieka aplankuose, kuriuos pasirenkate naudodami sistemos aplankų pasirinkimo priemonę.\n\n„Android“ sistemoje programėlė gali prašyti leidimo naudotis garso įrašais, kad galėtų skaityti takelius, bei leidimo naudotis nuotraukomis ir vaizdais, kad būtų galima rodyti aplankų iliustracijas (pavyzdžiui, „cover.jpg“). Garso failai niekada nėra kopijuojami į programėlės duomenų bazę.';

  @override
  String get dataStorageAndroidPlaybackTitle => '„Android“ grojimas fone';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Kai grojamas garso įrašas, „Retro Player“ paleidžia medijos paslaugą pirmame plane, todėl grojimas tęsiasi, net jei užrakinsite telefoną ar pereisite į kitą programėlę, o grojimo valdymo mygtukai rodomi sistemos pranešime. Nušluostydami programėlę iš „Neseniai naudotų“ sąrašo, sustabdysite grojimą ir pašalinsite pranešimą.';

  @override
  String get dataStorageIOSAccessTitle => 'Prieiga prie „iOS“ aplankų';

  @override
  String get dataStorageIOSAccessBody =>
      '„Retro Player“ savo duomenų bazę saugo įrenginio atmintyje esančioje privačioje programos palaikymo srityje. Jūsų muzikos failai saugomi aplankuose, kuriuos pasirenkate naudodami sistemos aplankų pasirinkimo priemonę.\n\n„iOS“ suteikia prieigą prie jūsų pasirinktų aplankų per saugumo sritį apibrėžiančius URL adresus. „Retro Player“ failus skaito tiesiogiai iš tų vietų; jis nekopijuoja jūsų bibliotekos į programos saugyklą.';

  @override
  String get dataStorageIOSPlaybackTitle => '„iOS“ foninis garso įrašas';

  @override
  String get dataStorageIOSPlaybackBody =>
      'Atkūrimas gali tęstis, net jei programa veikia fone arba ekranas užrakintas. Atkūrimo pozicijos ir eilės būsena saugomos vietinėje programos duomenų bazėje.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Programos duomenys saugomi vidinėje atmintyje esančioje programai skirtoje pagalbinėje srityje.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Programos duomenys saugomi įrenginio atmintyje esančioje programai skirtoje pagalbinėje srityje.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Programos duomenys saugomi kataloge ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Programos duomenys saugomi jūsų programos pagalbinėje aplankoje.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Programėlės duomenys saugomi šios kilmės vietos naršyklės vietinėje saugykloje.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Programos duomenys saugomi platformos programų palaikymo srityje.';

  @override
  String get loading => 'Įkeliama…';

  @override
  String get libraryIndex => 'Bibliotekos rodyklė';

  @override
  String get playlists => 'Grojaraščiai';

  @override
  String get playPlaylist => 'Paleisti grojaraštį';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count takeliai',
      one: '1 takelis',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Sukurti grojaraštį';

  @override
  String get queue => 'Eilė';

  @override
  String get saveAsPlaylist => 'Išsaugoti kaip grojaraštį';

  @override
  String get queueEmpty =>
      'Eilė tuščia. Įtraukite į ją kūrinius iš savo bibliotekos.';

  @override
  String get choosePlaylistFolder =>
      'Pasirinkite aplanką bibliotekoje. Bibliotekos šaknis nėra aplankas.';

  @override
  String get clearQueue => 'Išvalyti eilę';

  @override
  String get clearQueueTitle => 'Išvalyti eilę?';

  @override
  String get clearQueueBody =>
      'Tai pašalina visus įrašus iš eilės. Garso failai ir išsaugoti grojaraščiai lieka.';

  @override
  String get newPlaylistName => 'Grojaraščio pavadinimas';

  @override
  String get addTracks => 'Pridėti takelius';

  @override
  String get save => 'Išsaugoti';

  @override
  String get addTracksFromLibrary => 'Pridėti iš bibliotekos';

  @override
  String addTracksConfirm(int count) {
    return 'Pridėti ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Pasirinkite vieną ar daugiau įrašų iš savo bibliotekos.';

  @override
  String get libraryEmptyNoRoots =>
      'Pirmiausia pridėkite bibliotekos aplanką, tada iš jo pasirinkite įrašus.';

  @override
  String get playlistEmpty => 'Šiame grojaraštyje kol kas nėra jokių įrašų.';

  @override
  String get missingTrack => 'Trūksta failo';

  @override
  String get playlistReadOnly => 'Tik skaityti';

  @override
  String get playlistSelect => 'Pasirinkite';

  @override
  String get playlistSelectAll => 'Pažymėti viską';

  @override
  String get playlistDeselectAll => 'Atžymėti viską';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasirinkta',
      one: '1 pasirinktas',
      zero: 'Pasirinkite kūrinius',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ar pašalinti $count įrašus iš grojaraščio?',
      one: 'Pašalinti kūrinį iš grojaraščio?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tai pašalina įrašus iš grojaraščio failo, kai jį išsaugote.',
      one: 'Tai pašalina įrašą iš grojaraščio failo, kai jį išsaugote.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Naujų kūrinių nebuvo pridėta. Galbūt jie jau yra grojaraštyje.';

  @override
  String get addToQueue => 'Pridėti į eilę';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pridėta į eilę: $count',
      one: 'Į eilę pridėtas 1 takelis',
      zero: 'Į eilę nepridėta naujų takelių',
    );
    return '$_temp0';
  }

  @override
  String get playlistNothingToPlay => 'Šiame grojaraštyje nėra grojamų įrašų.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Ištrinti grojaraštį?';

  @override
  String deletePlaylistBody(String name) {
    return 'Ištrinti „$name“? Tai pašalins grojaraščio failą iš disko.';
  }
}

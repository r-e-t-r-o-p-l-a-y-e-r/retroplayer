// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'সেটিংস';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get aboutSubtitle =>
      'শুধুমাত্র স্থানীয় অডিও । কোনও বিজ্ঞাপন নেই, কোনও টেলিমেট্রি নেই, কোনও নেটওয়ার্ক অ্যাক্সেস নেই ।\nসমর্থিত ফরম্যাট: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'সংস্করণ';

  @override
  String get aboutBuildDate => 'সময় তৈরি করুন';

  @override
  String get aboutGitBranch => 'শাখা';

  @override
  String get aboutGitCommit => 'বিল্ড';

  @override
  String get equalizer => 'ইকুয়ালাইজার';

  @override
  String get equalizerUnavailable =>
      'এই প্ল্যাটফর্মে ইকুয়ালাইজার পাওয়া যায় না ।';

  @override
  String get bands => 'ব্যান্ড';

  @override
  String get reset => 'রিসেট করুন';

  @override
  String get library => 'গ্রন্থাগার';

  @override
  String get album => 'অ্যালবাম';

  @override
  String get playlist => 'প্লেলিস্ট';

  @override
  String get nowPlaying => 'এখন চলছে';

  @override
  String get addFolder => 'ফোল্ডার যোগ করুন';

  @override
  String get audioPermissionRequired => 'Android-এ অডিও অনুমতি প্রয়োজন';

  @override
  String get expandPlayer => 'প্লেয়ার প্রসারিত করুন';

  @override
  String get showLibrary => 'লাইব্রেরি দেখান';

  @override
  String errorMessage(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String get noFoldersAdded =>
      'কোনও ফোল্ডার যোগ করা হয়নি । শুরু করতে \"ফোল্ডার যোগ করুন\" -এ ট্যাপ করুন ।';

  @override
  String get folderEmpty => 'এই ফোল্ডারটি খালি ।';

  @override
  String get librarySources => 'গ্রন্থাগারের উৎস';

  @override
  String get favorites => 'প্রিয়';

  @override
  String get favorite => 'প্রিয়';

  @override
  String get removeFavorite => 'প্রিয়টি সরান';

  @override
  String get folders => 'ফোল্ডার';

  @override
  String get audio => 'অডিও';

  @override
  String get playFolder => 'ফোল্ডার চালান';

  @override
  String get playAlbum => 'অ্যালবাম চালান';

  @override
  String get removeLibraryFolderTitle => 'লাইব্রেরির ফোল্ডারটি সরাবেন?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'আপনার লাইব্রেরি থেকে \"$name\" সরান?\n\nডিস্কে থাকা আপনার অডিও ফাইলগুলি মুছে ফেলা হবে না।';
  }

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get remove => 'সরান';

  @override
  String get albumNotFound => 'অ্যালবাম পাওয়া যায়নি';

  @override
  String get playlistNotFound => 'প্লেলিস্ট পাওয়া যায়নি';

  @override
  String get selectToPlay => 'খেলার জন্য আপনার লাইব্রেরি থেকে কিছু বেছে নিন ।';

  @override
  String get speed => 'গতি';

  @override
  String get previous => 'পূর্ববর্তী';

  @override
  String get pause => 'বিরতি';

  @override
  String get play => 'খেলুন';

  @override
  String get next => 'পরবর্তী';

  @override
  String get jumpBack => '15 সেকেন্ড পিছনে';

  @override
  String get jumpForward => '15 সেকেন্ড এগিয়ে যান';

  @override
  String get chapters => 'অধ্যায়';

  @override
  String get previousChapter => 'আগের অধ্যায়';

  @override
  String get nextChapter => 'পরের অধ্যায়';

  @override
  String get headphones => 'হেডফোন';

  @override
  String get autoRewind => 'আবার চালু করলে পিছিয়ে দিন';

  @override
  String get autoRewindHint =>
      'অন্তত এক মিনিট বিরতির পর, 20 মিনিটের বেশি দীর্ঘ ট্র্যাক কয়েক সেকেন্ড আগে থেকে চলে।';

  @override
  String get rewindBy => 'এতটা পিছিয়ে দিন';

  @override
  String secondsShort(int seconds) {
    return '$seconds সে.';
  }

  @override
  String get resumeOnReconnect => 'হেডফোন আবার যুক্ত হলে চালিয়ে যান';

  @override
  String get resumeOnReconnectHint =>
      'শুধু যদি 10 মিনিটের কম আগে হেডফোন বিচ্ছিন্ন হওয়ার কারণে প্লেব্যাক থেমে থাকে।';

  @override
  String get trackFallback => 'ট্র্যাক';

  @override
  String get unknownArtist => 'অজানা';

  @override
  String tracksCountArtist(int count, String artist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ট্র্যাক · $artist',
      one: '$count ট্র্যাক · $artist',
    );
    return '$_temp0';
  }

  @override
  String get resetDatabase => 'ডাটাবেস রিসেট করুন';

  @override
  String get resetDatabaseTitle => 'ডাটাবেস রিসেট করবেন?';

  @override
  String get resetDatabaseBody =>
      'এটি প্লেব্যাক পজিশন, ফেভারিট, ওপেন ফোল্ডার, থিম, ভাষা এবং ইকুয়ালাইজার সেটিংস পরিষ্কার করে । সবকিছু পরিষ্কার করুন এছাড়াও যোগ করা লাইব্রেরি ফোল্ডার ভুলে যায় । ডিস্কে সঙ্গীত ফাইল এবং প্লেলিস্ট মুছে ফেলা হয় না ।';

  @override
  String get resetDatabaseKeepFolders => 'লাইব্রেরির ফোল্ডারগুলি রাখুন';

  @override
  String get resetDatabaseClearEverything => 'সবকিছু পরিষ্কার করুন';

  @override
  String get eqManually => 'ম্যানুয়ালি';

  @override
  String get eqBass => 'বাস';

  @override
  String get eqTreble => 'ট্রেবল';

  @override
  String get eqVoice => 'কণ্ঠস্বর';

  @override
  String get appearance => 'চেহারা';

  @override
  String get themeLight => 'আলো';

  @override
  String get themeDark => 'অন্ধকার';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get language => 'ভাষা';

  @override
  String get languageSystem => 'সিস্টেম';

  @override
  String get openSourceLicenses => 'ওপেন সোর্স লাইসেন্স';

  @override
  String get openSourceLegalese => '© 2026 রেট্রো প্লেয়ার কন্ট্রিবিউটর';

  @override
  String get dataStorage => 'ডেটা স্টোরেজ';

  @override
  String get dataStorageIntro =>
      'রেট্রো প্লেয়ার একটি ছোট স্থানীয় ডাটাবেসে অ্যাপ সেটিংস রাখে । আপনার সঙ্গীত এবং প্লেলিস্টগুলি আপনার বেছে নেওয়া ফোল্ডারে স্বাভাবিক ফাইল হিসাবে থাকে ।';

  @override
  String get dataStorageAppDataTitle => 'অ্যাপ ডেটাবেস';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'ফাইল: $dbFileName\nপথ: $dbPath\n\nস্টোর লাইব্রেরির শিকড়, ব্রাউজ স্টেট, প্লেব্যাক সারসংকলন, ইকুয়ালাইজার, থিম এবং ভাষার পছন্দ ।';
  }

  @override
  String get dataStorageLibraryTitle => 'মিউজিক ফাইল';

  @override
  String get dataStorageLibraryBody =>
      'অডিও ফাইলগুলি কখনই অ্যাপ ডেটাবেসে অনুলিপি করা হয় না । লাইব্রেরি ফোল্ডার যোগ করুন এবং রেট্রো প্লেয়ার ডিস্ক থেকে সরাসরি ফাইল পড়ে ।';

  @override
  String get dataStoragePlaylistsTitle => 'প্লেলিস্ট ফাইল';

  @override
  String get dataStoragePlaylistsBody =>
      'প্লেলিস্টগুলি আপনার লাইব্রেরি ফোল্ডারের মধ্যে সংরক্ষিত প্লেইন .m3u ফাইল । আপনি এগুলি অ্যাপে বা যে কোনও টেক্সট এডিটর দিয়ে এডিট করতে পারেন ।';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'প্ল্যাটফর্ম: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'অ্যাপ ডেটা আপনার অ্যাপ-সহায়তা ডিরেক্টরির অধীনে সংরক্ষণ করা হয় (সাধারণত ~/.local/share/app.retroplayer/) ।';

  @override
  String get dataStorageLinuxDataTitle => 'লিনাক্স অ্যাপ ডেটা';

  @override
  String get dataStorageLinuxDataBody =>
      'অ্যাপ ডেটা ~/.local/share/app.retroplayer/ এ থাকে । সেই ফোল্ডারটি শুধুমাত্র ডাটাবেস এবং সেটিংসের জন্য ।';

  @override
  String get dataStorageLinuxTaskbarTitle => 'লিনাক্স টাস্কবার ইন্টিগ্রেশন';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'টাস্কবার এবং অ্যাপ গ্রিড আইকনের জন্য, লিনাক্স ডেস্কটপ এনভায়রনমেন্টগুলি পৃথক Freedesktop ফাইল আশা করে । রেট্রো প্লেয়ার স্টার্টআপে অ্যাপ বান্ডেল থেকে এগুলি ইনস্টল করে:\n\n• ~/.local/share/applications/app.retroplayer.desktop — লঞ্চার এন্ট্রি যা এই অ্যাপের চলমান উইন্ডোর সাথে লিঙ্ক করে\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — বান্ডিল থেকে কপি করা থিমযুক্ত আইকন\n\nএটি কখনই কোনও ব্যবহারকারীর হিকোলার/index.theme লিখবে না (এটি সিস্টেমের থিমকে ছায়া দেবে এবং অন্যান্য আইকনগুলি আড়াল করবে) । আইকনগুলি অ্যাপ বাইনারিতেও এমবেড করা আছে । উপরের কপিগুলি জিনোম/কেডিএকে জেনেরিক প্লেসহোল্ডারের পরিবর্তে সঠিক লঞ্চার আইকন দেখায় ।';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'অ্যান্ড্রয়েডের অনুমতি এবং স্টোরেজ';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'রেট্রো প্লেয়ার অভ্যন্তরীণ স্টোরেজে অ্যাপ-প্রাইভেট সাপোর্ট এরিয়াতে তার ডাটাবেস সংরক্ষণ করে । আপনার মিউজিক ফাইলগুলি সিস্টেম ফোল্ডার পিকারের সাথে আপনার বেছে নেওয়া ফোল্ডারে থাকে ।\n\nঅ্যান্ড্রয়েডে, অ্যাপটি ট্র্যাকগুলি পড়ার জন্য অডিও অ্যাক্সেসের অনুরোধ করতে পারে এবং ফটো/চিত্রগুলি অ্যাক্সেস করতে পারে যাতে ফোল্ডার আর্টওয়ার্ক (উদাহরণস্বরূপ cover.jpg) দেখানো যায় । অডিও ফাইলগুলি কখনই অ্যাপ ডেটাবেসে অনুলিপি করা হয় না ।';

  @override
  String get dataStorageAndroidNativeBody =>
      'রেট্রো প্লেয়ার অভ্যন্তরীণ স্টোরেজে অ্যাপ-প্রাইভেট সাপোর্ট এরিয়াতে তার ডাটাবেস সংরক্ষণ করে । আপনার মিউজিক ফাইলগুলি সিস্টেম ফোল্ডার পিকারের সাথে আপনার বেছে নেওয়া ফোল্ডারে থাকে ।';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'অ্যান্ড্রয়েড ব্যাকগ্রাউন্ড প্লেব্যাক';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'অডিও বাজানোর সময়, রেট্রো প্লেয়ার একটি অগ্রভূমির মিডিয়া পরিষেবা চালায় তাই আপনি যদি ফোন লক করেন বা সিস্টেম বিজ্ঞপ্তিতে পরিবহন নিয়ন্ত্রণ সহ অ্যাপ্লিকেশনগুলি স্যুইচ করেন তবে প্লেব্যাক চলতে থাকে । রিডেন্টস থেকে অ্যাপটিকে দূরে সোয়াইপ করা প্লেব্যাক বন্ধ করে দেয় এবং বিজ্ঞপ্তি সরিয়ে দেয় ।';

  @override
  String get dataStorageIOSAccessTitle => 'iOS ফোল্ডার অ্যাক্সেস';

  @override
  String get dataStorageIOSAccessBody =>
      'রেট্রো প্লেয়ার ডিভাইস স্টোরেজে অ্যাপ-প্রাইভেট সাপোর্ট এরিয়াতে তার ডাটাবেস সংরক্ষণ করে । আপনার মিউজিক ফাইলগুলি সিস্টেম ফোল্ডার পিকারের সাথে আপনার বেছে নেওয়া ফোল্ডারে থাকে ।\n\niOS আপনার বেছে নেওয়া ফোল্ডারগুলির জন্য নিরাপত্তা-স্কপ করা URL-এর মাধ্যমে অ্যাক্সেস মঞ্জুর করে । রেট্রো প্লেয়ার সরাসরি সেই অবস্থানগুলি থেকে ফাইলগুলি পড়ে; এটি আপনার লাইব্রেরিকে অ্যাপ স্টোরেজে অনুলিপি করে না ।';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS ব্যাকগ্রাউন্ড অডিও';

  @override
  String get dataStorageIOSPlaybackBody =>
      'অ্যাপটি ব্যাকগ্রাউন্ডে থাকা অবস্থায় বা স্ক্রিন লক থাকা অবস্থায় প্লেব্যাক চলতে পারে । পুনরায় শুরু করার অবস্থান এবং সারির অবস্থা স্থানীয় অ্যাপ ডাটাবেসে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'অ্যাপের ডেটা অভ্যন্তরীণ স্টোরেজে অ্যাপ-প্রাইভেট সাপোর্ট এরিয়াতে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyIOS =>
      'অ্যাপ ডেটা ডিভাইস স্টোরেজে অ্যাপ-প্রাইভেট সাপোর্ট এরিয়াতে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'অ্যাপ ডেটা ~/লাইব্রেরি/অ্যাপ্লিকেশন সাপোর্ট/app.retroplayer/ এর অধীনে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyWindows =>
      'অ্যাপ ডেটা আপনার অ্যাপ্লিকেশন সাপোর্ট ডিরেক্টরির অধীনে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyWeb =>
      'এই উত্সের জন্য অ্যাপ ডেটা ব্রাউজার-স্থানীয় স্টোরেজে সংরক্ষণ করা হয় ।';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'অ্যাপ ডেটা প্ল্যাটফর্ম অ্যাপ্লিকেশন সাপোর্ট এলাকায় সংরক্ষণ করা হয় ।';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get libraryIndex => 'লাইব্রেরি ইনডেক্স';

  @override
  String get playlists => 'প্লেলিস্ট';

  @override
  String get playPlaylist => 'প্লেলিস্ট';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ট্র্যাক',
      one: 'একটি ট্র্যাক',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'প্লেলিস্ট তৈরি করুন';

  @override
  String get queue => 'সারি';

  @override
  String get saveAsPlaylist => 'প্লেলিস্ট হিসাবে সংরক্ষণ করুন';

  @override
  String get queueEmpty =>
      'সারি খালি । আপনার লাইব্রেরি থেকে ট্র্যাক যোগ করুন ।';

  @override
  String get choosePlaylistFolder =>
      'লাইব্রেরিতে একটি ফোল্ডার নির্বাচন করুন । গ্রন্থাগারের মূল একটি ফোল্ডার নয় ।';

  @override
  String get clearQueue => 'সারি সাফ করুন';

  @override
  String get clearQueueTitle => 'সারি সাফ করবেন?';

  @override
  String get clearQueueBody =>
      'এটি সারি থেকে প্রতিটি ট্র্যাক সরিয়ে দেয় । অডিও ফাইল এবং সংরক্ষিত প্লেলিস্ট থাকা ।';

  @override
  String get newPlaylistName => 'প্লেলিস্টের নাম';

  @override
  String get addTracks => 'ট্র্যাক যোগ করুন';

  @override
  String get addSelectedTracks => 'নির্বাচিত ট্র্যাক যোগ করুন';

  @override
  String get save => 'সেভ করুন';

  @override
  String get addTracksFromLibrary => 'লাইব্রেরি থেকে যোগ করুন';

  @override
  String addTracksConfirm(int count) {
    return '($count) যোগ করুন';
  }

  @override
  String get addTracksNothingSelected =>
      'আপনার লাইব্রেরিতে এক বা একাধিক ট্র্যাক নির্বাচন করুন ।';

  @override
  String get libraryEmptyNoRoots =>
      'প্রথমে একটি লাইব্রেরি ফোল্ডার যোগ করুন, তারপরে এটি থেকে ট্র্যাকগুলি বেছে নিন ।';

  @override
  String get playlistEmpty => 'এই প্লেলিস্টে এখনও কোনও ট্র্যাক নেই ।';

  @override
  String get missingTrack => 'অনুপস্থিত ফাইল';

  @override
  String get playlistReadOnly => 'শুধুমাত্র পঠনযোগ্য';

  @override
  String get playlistSelect => 'নির্বাচন করুন';

  @override
  String get playlistSelectAll => 'সবগুলো নির্বাচন করুন';

  @override
  String get playlistDeselectAll => 'সবগুলো অনির্বাচন করুন';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count নির্বাচিত',
      one: '১টি নির্বাচিত',
      zero: 'ট্র্যাকগুলো নির্বাচন করুন',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'প্লেলিস্ট থেকে $count ট্র্যাকগুলো সরান?',
      one: 'প্লেলিস্ট থেকে ট্র্যাক সরান?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এটি যখন আপনি সংরক্ষণ করেন, প্লেলিস্ট ফাইল থেকে এন্ট্রিগুলো মুছে ফেলে।',
      one:
          'এটি আপনি সংরক্ষণ করার সময় প্লেলিস্ট ফাইল থেকে এন্ট্রিটি মুছে ফেলে।',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'কোনও নতুন ট্র্যাক যোগ করা হয়নি । তারা ইতিমধ্যে প্লেলিস্টে থাকতে পারে ।';

  @override
  String get addToQueue => 'সারিতে যোগ করুন';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সারিতে $countটি ট্র্যাক যোগ হয়েছে',
      one: 'সারিতে একটি ট্র্যাক যোগ হয়েছে',
      zero: 'সারিতে নতুন কোনো ট্র্যাক যোগ হয়নি',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'উপরে সরান';

  @override
  String get moveDown => 'নিচে সরান';

  @override
  String get playlistNothingToPlay =>
      'এই প্লেলিস্টে কোনও প্লেযোগ্য ট্র্যাক নেই ।';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'প্লেলিস্ট মুছবেন?';

  @override
  String deletePlaylistBody(String name) {
    return '\"$name\" মুছুন? এটি ডিস্ক থেকে প্লেলিস্ট ফাইলটি সরিয়ে দেয় ।';
  }
}

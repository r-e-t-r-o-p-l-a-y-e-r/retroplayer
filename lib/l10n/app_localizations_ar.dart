// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'الإعدادات';

  @override
  String get about => 'حول';

  @override
  String get aboutSubtitle =>
      'الصوت المحلي فقط. لا إعلانات، لا قياس عن بعد، لا وصول إلى الشبكة.\nالتنسيقات المدعومة: MP3 و M4A و M4B و FLAC و WAV';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutBuildDate => 'وقت البناء';

  @override
  String get aboutGitBranch => 'فرع';

  @override
  String get aboutGitCommit => 'البناء';

  @override
  String get equalizer => 'المعادل';

  @override
  String get equalizerUnavailable => 'المعادل غير متوفر على هذه المنصة.';

  @override
  String get bands => 'العصابات';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get library => 'المكتبة';

  @override
  String get album => 'الألبوم';

  @override
  String get playlist => 'قائمة التشغيل';

  @override
  String get nowPlaying => 'قيد التشغيل الآن';

  @override
  String get addFolder => 'إضافة مجلد';

  @override
  String get audioPermissionRequired => 'يلزم الحصول على إذن صوتي على Android';

  @override
  String get expandPlayer => 'توسيع المشغل';

  @override
  String get showLibrary => 'عرض المكتبة';

  @override
  String errorMessage(String message) {
    return 'الخطأ: $message';
  }

  @override
  String get noFoldersAdded =>
      'لم تتم إضافة أي مجلدات. اضغط على \"إضافة مجلد\" للبدء.';

  @override
  String get folderEmpty => 'هذا المجلد فارغ.';

  @override
  String get librarySources => 'مصادر المكتبة';

  @override
  String get favorites => 'المفضلة';

  @override
  String get favorite => 'المفضلة';

  @override
  String get removeFavorite => 'إزالة المفضلة';

  @override
  String get folders => 'المجلدات';

  @override
  String get audio => 'الصوت';

  @override
  String get playFolder => 'تشغيل المجلد';

  @override
  String get playAlbum => 'تشغيل الألبوم';

  @override
  String get removeLibraryFolderTitle => 'هل تريد إزالة مجلد المكتبة ؟';

  @override
  String removeLibraryFolderBody(String name) {
    return 'هل تريد إزالة \"$name\" من مكتبتك؟\n\nلن يتم حذف ملفاتك الصوتية الموجودة على القرص.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'إزالة';

  @override
  String get albumNotFound => 'لم يتم العثور على الألبوم';

  @override
  String get playlistNotFound => 'لم يتم العثور على قائمة التشغيل';

  @override
  String get selectToPlay => 'اختر شيئًا من مكتبتك لتشغيله.';

  @override
  String get speed => 'السرعة';

  @override
  String get previous => 'السابق';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get play => 'تشغيل';

  @override
  String get next => 'التالي';

  @override
  String get jumpBack => 'رجوع 15 ثانية';

  @override
  String get jumpForward => 'إلى الأمام 15 ثانية';

  @override
  String get trackFallback => 'المسار';

  @override
  String get unknownArtist => 'غير معروف';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count مسار · $artist';
  }

  @override
  String get resetDatabase => 'إعادة تعيين قاعدة البيانات';

  @override
  String get resetDatabaseTitle => 'إعادة تعيين قاعدة البيانات ؟';

  @override
  String get resetDatabaseBody =>
      'يؤدي هذا إلى مسح مواضع التشغيل والمفضلة والمجلد المفتوح والقالب واللغة وإعدادات المعادل. مسح كل شيء ينسى أيضًا مجلدات المكتبة المضافة. لا يتم حذف ملفات الموسيقى وقوائم التشغيل على القرص.';

  @override
  String get resetDatabaseKeepFolders => 'الاحتفاظ بمجلدات المكتبة';

  @override
  String get resetDatabaseClearEverything => 'مسح كل شيء';

  @override
  String get eqManually => 'يدويًّا';

  @override
  String get eqBass => 'جهير';

  @override
  String get eqTreble => 'ثلاثة أضعاف';

  @override
  String get eqVoice => 'الصوت';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeLight => 'الضوء';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'النظام';

  @override
  String get openSourceLicenses => 'تراخيص مفتوحة المصدر';

  @override
  String get openSourceLegalese => '© 2026 مساهمو Retro Player';

  @override
  String get dataStorage => 'تخزين البيانات';

  @override
  String get dataStorageIntro =>
      'يحتفظ Retro Player بإعدادات التطبيق في قاعدة بيانات محلية صغيرة. تبقى الموسيقى وقوائم التشغيل الخاصة بك كملفات عادية في المجلدات التي تختارها.';

  @override
  String get dataStorageAppDataTitle => 'قاعدة بيانات التطبيق';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'الملف: $dbFileName\nالمسار: $dbPath\n\nيخزن جذور المكتبة، وحالة التصفح، والسيرة الذاتية للتشغيل، والمعادل، والموضوع، وتفضيلات اللغة.';
  }

  @override
  String get dataStorageLibraryTitle => 'ملفات الموسيقى';

  @override
  String get dataStorageLibraryBody =>
      'لا يتم نسخ الملفات الصوتية أبدًا في قاعدة بيانات التطبيق. أضف مجلدات المكتبة وسيقوم Retro Player بقراءة الملفات مباشرة من القرص.';

  @override
  String get dataStoragePlaylistsTitle => 'ملفات قائمة التشغيل';

  @override
  String get dataStoragePlaylistsBody =>
      'قوائم التشغيل عبارة عن ملفات .m3u عادية مخزنة داخل مجلدات مكتبتك. يمكنك تعديلها في التطبيق أو باستخدام أي محرر نصوص.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'المنصة: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'يتم تخزين بيانات التطبيق ضمن دليل دعم التطبيق الخاص بك (عادةً ~/ .local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'بيانات تطبيق Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'تبقى بيانات التطبيق في ~/ .local/share/app.retroplayer/. هذا المجلد مخصص لقاعدة البيانات والإعدادات فقط.';

  @override
  String get dataStorageLinuxTaskbarTitle => 'تكامل شريط مهام Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'بالنسبة لشريط المهام وأيقونة شبكة التطبيق، تتوقع بيئات سطح مكتب Linux ملفات Freedesktop منفصلة. يقوم Retro Player بتثبيت هذه من حزمة التطبيق عند بدء التشغيل:\n\n•~/ .local/share/applications/app.retroplayer.desktop — إدخال المشغل الذي يربط نافذة التشغيل بهذا التطبيق\n•~/ .local/share/icons/hicolor /*/ apps/app.retroplayer.png - الرموز ذات السمات المنسوخة من الحزمة\n\nلا تكتب أبدًا hicolor/index.theme للمستخدم (من شأنه أن يحجب سمة النظام ويخفي الرموز الأخرى). يتم تضمين الأيقونات أيضًا في ثنائي التطبيق. تساعد النسخ أعلاه GNOME/KDE على إظهار رمز المشغل الصحيح بدلاً من عنصر نائب عام.';

  @override
  String get dataStorageAndroidPermissionsTitle => 'أذونات Android والتخزين';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'يقوم Retro Player بتخزين قاعدة بياناته في منطقة الدعم الخاصة بالتطبيق على وحدة التخزين الداخلية. تبقى ملفات الموسيقى الخاصة بك في المجلدات التي تختارها باستخدام منتقي مجلدات النظام.\n\nعلى Android، قد يطلب التطبيق الوصول إلى الصوت لقراءة المسارات، والوصول إلى الصور/الصور بحيث يمكن عرض العمل الفني للمجلد (على سبيل المثال cover.jpg). لا يتم نسخ الملفات الصوتية أبدًا في قاعدة بيانات التطبيق.';

  @override
  String get dataStorageAndroidPlaybackTitle => 'تشغيل خلفية أندرويد';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'عند تشغيل الصوت، يقوم Retro Player بتشغيل خدمة وسائط أمامية حتى يستمر التشغيل إذا قمت بقفل الهاتف أو تبديل التطبيقات، مع وجود عناصر تحكم النقل في إشعار النظام. يؤدي تمرير التطبيق بعيدًا عن Recents إلى إيقاف التشغيل وإزالة الإشعار.';

  @override
  String get dataStorageIOSAccessTitle => 'الوصول إلى مجلد iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'يقوم Retro Player بتخزين قاعدة بياناته في منطقة الدعم الخاصة بالتطبيق على تخزين الجهاز. تبقى ملفات الموسيقى الخاصة بك في المجلدات التي تختارها باستخدام منتقي مجلدات النظام.\n\nيمنح iOS الوصول من خلال عناوين URL ذات النطاق الأمني للمجلدات التي تحددها. يقرأ Retro Player الملفات مباشرة من تلك المواقع ؛ ولا يقوم بنسخ مكتبتك إلى تخزين التطبيق.';

  @override
  String get dataStorageIOSPlaybackTitle => 'صوت خلفية iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'يمكن متابعة التشغيل أثناء وجود التطبيق في الخلفية أو أثناء قفل الشاشة. يتم تخزين مواضع السيرة الذاتية وحالة قائمة الانتظار في قاعدة بيانات التطبيق المحلية.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'يتم تخزين بيانات التطبيق في منطقة الدعم الخاصة بالتطبيق على وحدة التخزين الداخلية.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'يتم تخزين بيانات التطبيق في منطقة الدعم الخاصة بالتطبيق على تخزين الجهاز.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'يتم تخزين بيانات التطبيق تحت ~/ Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'يتم تخزين بيانات التطبيق ضمن دليل دعم التطبيق الخاص بك.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'يتم تخزين بيانات التطبيق في التخزين المحلي للمتصفح لهذا الأصل.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'يتم تخزين بيانات التطبيق في منطقة دعم تطبيق المنصة.';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get libraryIndex => 'فهرس المكتبة';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get playPlaylist => 'تشغيل قائمة التشغيل';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقطوعات',
      one: '1 أغنية',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'إنشاء قائمة تشغيل';

  @override
  String get queue => 'قائمة الانتظار';

  @override
  String get saveAsPlaylist => 'حفظ كقائمة تشغيل';

  @override
  String get queueEmpty => 'قائمة الانتظار فارغة. إضافة مسارات من مكتبتك.';

  @override
  String get choosePlaylistFolder =>
      'اختر مجلدًا في المكتبة. جذر المكتبة ليس مجلدًا.';

  @override
  String get clearQueue => 'مسح قائمة الانتظار';

  @override
  String get clearQueueTitle => 'هل تريد مسح قائمة الانتظار ؟';

  @override
  String get clearQueueBody =>
      'يؤدي هذا إلى إزالة كل مسار من قائمة الانتظار. تبقى ملفات الصوت وقوائم التشغيل المحفوظة.';

  @override
  String get newPlaylistName => 'اسم قائمة التشغيل';

  @override
  String get addTracks => 'إضافة مسارات';

  @override
  String get save => 'حفظ';

  @override
  String get addTracksFromLibrary => 'إضافة من المكتبة';

  @override
  String addTracksConfirm(int count) {
    return 'إضافة ($count)';
  }

  @override
  String get addTracksNothingSelected => 'حدد مسارًا واحدًا أو أكثر في مكتبتك.';

  @override
  String get libraryEmptyNoRoots =>
      'أضف مجلد المكتبة أولاً، ثم اختر المسارات منه.';

  @override
  String get playlistEmpty => 'لا تحتوي قائمة التشغيل هذه على مسارات حتى الآن.';

  @override
  String get missingTrack => 'ملف مفقود';

  @override
  String get playlistReadOnly => 'للقراءة فقط';

  @override
  String get playlistSelect => 'تحديد';

  @override
  String get playlistSelectAll => 'تحديد الكل';

  @override
  String get playlistDeselectAll => 'إلغاء تحديد الكل';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تم تحديده',
      one: '1 تم اختياره',
      zero: 'اختر المقطوعات',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'هل تريد إزالة مقاطع $count من قائمة التشغيل؟',
      one: 'هل تريد إزالة الأغنية من قائمة التشغيل؟',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يؤدي هذا إلى حذف العناصر من ملف قائمة التشغيل عند الحفظ.',
      one: 'يؤدي هذا إلى حذف العنصر من ملف قائمة التشغيل عند الحفظ.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'لم تتم إضافة أي مسارات جديدة. قد يكونوا موجودين بالفعل في قائمة التشغيل.';

  @override
  String get addToQueue => 'إضافة إلى قائمة الانتظار';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت الإضافة إلى قائمة الانتظار: $count',
      one: 'تمت إضافة مسار واحد إلى قائمة الانتظار',
      zero: 'لم تتم إضافة مسارات جديدة إلى قائمة الانتظار',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'نقل لأعلى';

  @override
  String get moveDown => 'نقل لأسفل';

  @override
  String get playlistNothingToPlay =>
      'لا تحتوي قائمة التشغيل هذه على مسارات قابلة للتشغيل.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'هل تريد حذف قائمة التشغيل ؟';

  @override
  String deletePlaylistBody(String name) {
    return 'هل تريد حذف \"$name\"؟ سيؤدي ذلك إلى إزالة ملف قائمة التشغيل من القرص.';
  }
}

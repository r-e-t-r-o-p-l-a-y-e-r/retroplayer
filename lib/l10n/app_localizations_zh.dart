// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get aboutSubtitle =>
      '仅限本地音频。无广告、无遥测、无网络访问。\n支持的格式： MP3、M4A、M4B、FLAC、WAV';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutBuildDate => '构建时间';

  @override
  String get aboutGitBranch => '分支';

  @override
  String get aboutGitCommit => '构建';

  @override
  String get equalizer => '均衡器';

  @override
  String get equalizerUnavailable => '此平台上不提供均衡器。';

  @override
  String get bands => '波段';

  @override
  String get reset => '重置';

  @override
  String get library => '库';

  @override
  String get album => '相册';

  @override
  String get playlist => '播放列表';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get addFolder => '添加文件夹';

  @override
  String get audioPermissionRequired => 'Android需要音频权限';

  @override
  String get expandPlayer => '展开播放器';

  @override
  String get showLibrary => '显示库';

  @override
  String errorMessage(String message) {
    return '错误： $message';
  }

  @override
  String get noFoldersAdded => '未添加文件夹。点击“添加文件夹”即可开始。';

  @override
  String get folderEmpty => '此文件夹为空。';

  @override
  String get librarySources => '库源';

  @override
  String get favorites => '收藏夹';

  @override
  String get favorite => '收藏';

  @override
  String get removeFavorite => '移除收藏夹';

  @override
  String get folders => '文件夹';

  @override
  String get audio => '音频';

  @override
  String get playFolder => '播放文件夹';

  @override
  String get playAlbum => '播放相册';

  @override
  String get removeLibraryFolderTitle => '删除库文件夹？';

  @override
  String removeLibraryFolderBody(String name) {
    return '要从库中删除“$name”吗？\n\n磁盘上的音频文件不会被删除。';
  }

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get albumNotFound => '未找到相册';

  @override
  String get playlistNotFound => '未找到播放列表';

  @override
  String get selectToPlay => '从您的资料库中选择要播放的内容。';

  @override
  String get speed => '速度';

  @override
  String get previous => '上一个';

  @override
  String get pause => '暂停';

  @override
  String get play => '播放';

  @override
  String get next => '下一步';

  @override
  String get jumpBack => '后退15秒';

  @override
  String get jumpForward => '前进15秒';

  @override
  String get trackFallback => '跟踪';

  @override
  String get unknownArtist => '未知';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count首曲目· $artist';
  }

  @override
  String get resetDatabase => '重置数据库';

  @override
  String get resetDatabaseTitle => '重置数据库？';

  @override
  String get resetDatabaseBody =>
      '这将清除播放位置、收藏夹、打开的文件夹、主题、语言和均衡器设置。 清除所有内容也会忘记添加的库文件夹。 磁盘上的音乐文件和播放列表不会被删除。';

  @override
  String get resetDatabaseKeepFolders => '保留库文件夹';

  @override
  String get resetDatabaseClearEverything => '清除所有内容';

  @override
  String get eqManually => '手动';

  @override
  String get eqBass => '低音';

  @override
  String get eqTreble => '高音';

  @override
  String get eqVoice => '语音';

  @override
  String get appearance => '外观';

  @override
  String get themeLight => '亮';

  @override
  String get themeDark => '暗';

  @override
  String get themeSystem => '系统';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '系统';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get openSourceLegalese => '© 2026 Retro Player贡献者';

  @override
  String get dataStorage => '数据存储';

  @override
  String get dataStorageIntro =>
      'Retro Player将应用设置保存在一个小型本地数据库中。 音乐和播放列表与您选择的文件夹中的普通文件保持一致。';

  @override
  String get dataStorageAppDataTitle => '应用程序数据库';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return '文件： $dbFileName\n路径： $dbPath\n\n存储库根、浏览状态、播放恢复、均衡器、主题和语言首选项。';
  }

  @override
  String get dataStorageLibraryTitle => '音乐文件';

  @override
  String get dataStorageLibraryBody =>
      '音频文件永远不会复制到应用程序数据库中。 添加库文件夹， Retro Player直接从磁盘读取文件。';

  @override
  String get dataStoragePlaylistsTitle => '播放列表文件';

  @override
  String get dataStoragePlaylistsBody =>
      '播放列表是存储在库文件夹中的普通.m3u文件。 您可以在应用程序中或使用任何文本编辑器进行编辑。';

  @override
  String dataStoragePlatformTitle(String platform) {
    return '平台： $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      '应用程序数据存储在app-support目录下（通常为~/.local/share/app.retroplayer/ ）。';

  @override
  String get dataStorageLinuxDataTitle => 'Linux应用数据';

  @override
  String get dataStorageLinuxDataBody =>
      '应用程序数据保留在~/.local/share/app.retroplayer/。 该文件夹仅用于数据库和设置。';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Linux任务栏集成';

  @override
  String get dataStorageLinuxTaskbarBody =>
      '对于任务栏和应用程序网格图标， Linux桌面环境需要单独的Freedesktop文件。Retro Player在启动时从应用捆绑包安装这些内容：\n\n• ~/.local/share/applications/app.retroplayer.desktop —将运行窗口链接到此应用程序的启动器条目\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png —从捆绑包中复制的主题图标\n\n它永远不会写入用户hicolor/index.theme （这会遮挡系统主题并隐藏其他图标）。图标也嵌入到应用程序二进制文件中。上面的副本帮助GNOME/KDE显示正确的启动器图标，而不是通用的占位符。';

  @override
  String get dataStorageAndroidPermissionsTitle => 'Android权限和存储';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Player将其数据库存储在内部存储的应用私有支持区域中。 您的音乐文件保留在您使用系统文件夹选取器选取的文件夹中。\n\n在安卓系统上，应用程序可能会请求对读取曲目的音频访问权限，以及对照片/图像的访问权限，以便显示文件夹插图（例如cover.jpg ）。 音频文件永远不会复制到应用程序数据库中。';

  @override
  String get dataStorageAndroidPlaybackTitle => '安卓后台播放';

  @override
  String get dataStorageAndroidPlaybackBody =>
      '播放音频时， Retro Player会运行前台媒体服务，因此，如果您锁定手机或切换应用程序，系统通知中会包含传输控件，则播放将继续。 从“近期”中滑动应用可停止播放并删除通知。';

  @override
  String get dataStorageIOSAccessTitle => 'iOS文件夹访问权限';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Player将其数据库存储在设备存储的应用私有支持区域。 使用系统文件夹选取器，您的音乐文件将保留在您选择的文件夹中。\n\niOS通过安全范围内的URL为您选择的文件夹授予访问权限。 Retro Player直接从这些位置读取文件；它不会将库复制到应用程序存储中。';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOS背景音频';

  @override
  String get dataStorageIOSPlaybackBody =>
      '当应用程序处于后台或屏幕锁定时，可以继续播放。 简历位置和队列状态存储在本地应用数据库中。';

  @override
  String get dataStoragePlatformBodyAndroid => '应用程序数据存储在内部存储的应用程序私有支持区域。';

  @override
  String get dataStoragePlatformBodyIOS => '应用程序数据存储在设备存储上的应用程序私有支持区域。';

  @override
  String get dataStoragePlatformBodyMacOS =>
      '应用程序数据存储在~/Library/Application Support/app.retroplayer/。';

  @override
  String get dataStoragePlatformBodyWindows => '应用程序数据存储在您的应用程序支持目录下。';

  @override
  String get dataStoragePlatformBodyWeb => '应用程序数据存储在此来源的浏览器本地存储中。';

  @override
  String get dataStoragePlatformBodyUnknown => '应用数据存储在平台应用支持区域。';

  @override
  String get loading => '正在加载…';

  @override
  String get libraryIndex => '库索引';

  @override
  String get playlists => '播放列表';

  @override
  String get playPlaylist => '播放播放列表';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 曲目',
      one: '1 首曲目',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => '创建播放列表';

  @override
  String get queue => '队列';

  @override
  String get saveAsPlaylist => '另存为播放列表';

  @override
  String get queueEmpty => '队列为空。 从库中添加曲目。';

  @override
  String get choosePlaylistFolder => '在库中选择一个文件夹。 库根目录不是文件夹。';

  @override
  String get clearQueue => '清除队列';

  @override
  String get clearQueueTitle => '清除队列？';

  @override
  String get clearQueueBody => '这将从队列中删除每个轨道。 保留音频文件和已保存的播放列表。';

  @override
  String get newPlaylistName => '播放列表名称';

  @override
  String get addTracks => '添加曲目';

  @override
  String get addSelectedTracks => '添加所选曲目';

  @override
  String get save => '保存';

  @override
  String get addTracksFromLibrary => '从库中添加';

  @override
  String addTracksConfirm(int count) {
    return '添加($count)';
  }

  @override
  String get addTracksNothingSelected => '在库中选择一个或多个曲目。';

  @override
  String get libraryEmptyNoRoots => '首先添加库文件夹，然后从中选择曲目。';

  @override
  String get playlistEmpty => '此播放列表还没有曲目。';

  @override
  String get missingTrack => '缺少文件';

  @override
  String get playlistReadOnly => '只读';

  @override
  String get playlistSelect => '选择';

  @override
  String get playlistSelectAll => '全选';

  @override
  String get playlistDeselectAll => '取消全选';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 已选中',
      one: '已选中 1 个',
      zero: '选择曲目',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '从播放列表中删除 $count 歌曲？',
      one: '从播放列表中删除这首歌曲？',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这会在您保存时从播放列表文件中删除这些条目。',
      one: '这会在您保存时从播放列表文件中删除该条目。',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded => '未添加新曲目。 它们可能已经在播放列表中。';

  @override
  String get addToQueue => '添加到队列';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 首曲目添加到队列',
      one: '已将 1 首曲目添加到队列',
      zero: '没有新曲目添加到队列',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get playlistNothingToPlay => '此播放列表没有可播放的曲目。';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => '删除播放列表？';

  @override
  String deletePlaylistBody(String name) {
    return '删除“$name” ？这将从磁盘中删除播放列表文件。';
  }
}

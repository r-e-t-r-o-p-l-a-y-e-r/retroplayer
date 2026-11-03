// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => '設定';

  @override
  String get about => '詳細';

  @override
  String get aboutSubtitle =>
      'ローカル音声のみ。広告なし、テレメトリなし、ネットワークアクセスなし。&#10;対応フォーマット：MP3、M4A、M4B、FLAC、WAV';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutBuildDate => '建設時間';

  @override
  String get aboutGitBranch => 'ブランチ';

  @override
  String get aboutGitCommit => 'ビルド';

  @override
  String get equalizer => 'イコライザー';

  @override
  String get equalizerUnavailable => 'このプラットフォームではイコライザーは利用できません。';

  @override
  String get bands => '-';

  @override
  String get reset => 'リセット';

  @override
  String get library => 'ライブラリ';

  @override
  String get album => 'アルバム';

  @override
  String get playlist => 'プレイリスト';

  @override
  String get nowPlaying => '再生中';

  @override
  String get addFolder => 'フォルダを追加する';

  @override
  String get audioPermissionRequired => 'Androidでは音声権限が必要です';

  @override
  String get expandPlayer => 'プレーヤーを展開する';

  @override
  String get showLibrary => 'ライブラリを表示';

  @override
  String errorMessage(String message) {
    return 'エラー：$message';
  }

  @override
  String get noFoldersAdded => 'フォルダーが追加されていません。「フォルダーを追加」をタップして開始してください。';

  @override
  String get folderEmpty => 'このフォルダは空です。';

  @override
  String get librarySources => '図書館資料';

  @override
  String get favorites => 'お気に入り';

  @override
  String get favorite => 'お気に入り';

  @override
  String get removeFavorite => 'お気に入りから削除';

  @override
  String get folders => 'フォルダのみ';

  @override
  String get audio => 'オーディオ';

  @override
  String get playFolder => '再生フォルダ';

  @override
  String get playAlbum => 'アルバムを再生';

  @override
  String get removeLibraryFolderTitle => 'ライブラリフォルダを削除しますか？';

  @override
  String removeLibraryFolderBody(String name) {
    return 'ライブラリから「$name」を削除しますか？&#10;&#10;ディスク上の音声ファイルは削除されません。';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get remove => '削除する';

  @override
  String get albumNotFound => 'アルバムが見つかりません';

  @override
  String get playlistNotFound => 'プレイリストが見つかりません';

  @override
  String get selectToPlay => 'ライブラリから再生したいものを選んでください。';

  @override
  String get speed => '速度';

  @override
  String get previous => '前へ';

  @override
  String get pause => '一時停止';

  @override
  String get play => '再生';

  @override
  String get next => '次へ';

  @override
  String get jumpBack => '15秒';

  @override
  String get jumpForward => '15秒進む';

  @override
  String get chapters => 'チャプター';

  @override
  String get previousChapter => '前のチャプター';

  @override
  String get nextChapter => '次のチャプター';

  @override
  String get headphones => 'ヘッドホン';

  @override
  String get autoRewind => '再開時に巻き戻す';

  @override
  String get autoRewindHint => '1 分以上一時停止した後、20 分を超えるトラックは数秒前から再開します。';

  @override
  String get rewindBy => '巻き戻す秒数';

  @override
  String secondsShort(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get resumeOnReconnect => 'ヘッドホン再接続時に再開';

  @override
  String get resumeOnReconnectHint => 'ヘッドホンが外れて一時停止してから 10 分以内の場合のみ。';

  @override
  String get trackFallback => 'トラック';

  @override
  String get unknownArtist => '不明';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count トラック · $artist';
  }

  @override
  String get resetDatabase => 'データベースをリセット';

  @override
  String get resetDatabaseTitle => 'データベースをリセット';

  @override
  String get resetDatabaseBody =>
      'これにより、再生位置、お気に入り、開いているフォルダー、テーマ、言語、イコライザー設定がクリアされます。「すべてクリア」を選択すると、追加したライブラリフォルダーも削除されます。ディスク上の音楽ファイルとプレイリストは削除されません。';

  @override
  String get resetDatabaseKeepFolders => 'ライブラリフォルダを保管する';

  @override
  String get resetDatabaseClearEverything => 'すべてクリア';

  @override
  String get eqManually => '手動で';

  @override
  String get eqBass => '低音';

  @override
  String get eqTreble => '高音';

  @override
  String get eqVoice => '音声';

  @override
  String get appearance => '外観';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get openSourceLegalese => '© 2026 Retro Player寄稿者';

  @override
  String get dataStorage => 'データ保存';

  @override
  String get dataStorageIntro =>
      'Retro Playerはアプリの設定を小さなローカルデータベースに保存します。音楽ファイルやプレイリストは、選択したフォルダに通常のファイルとして保存されます。';

  @override
  String get dataStorageAppDataTitle => 'アプリデータベース';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'ファイル: $dbFileName&#10;パス: $dbPath&#10;&#10;ライブラリのルート、ブラウズ状態、再生再開、イコライザー、テーマ、言語設定を保存します。';
  }

  @override
  String get dataStorageLibraryTitle => '音楽ファイル';

  @override
  String get dataStorageLibraryBody =>
      'オーディオファイルがアプリデータベースにコピーされることはありません。ライブラリフォルダを追加すると、Retro Playerはディスクから直接ファイルを読み取ります。';

  @override
  String get dataStoragePlaylistsTitle => 'プレイリストファイル';

  @override
  String get dataStoragePlaylistsBody =>
      'プレイリストは、ライブラリフォルダ内に保存されているプレーンな.m 3 uファイルです。アプリまたは任意のテキストエディターで編集できます。';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'プラットフォーム：$platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'アプリデータは、アプリサポートディレクトリ（通常は〜/.local/share/app.retroplayer/ ）に保存されます。';

  @override
  String get dataStorageLinuxDataTitle => 'Linuxアプリデータ';

  @override
  String get dataStorageLinuxDataBody =>
      'アプリデータは~/.local/share/app.retroplayer/にあります。 そのフォルダはデータベースと設定のためだけのものです。';

  @override
  String get dataStorageLinuxTaskbarTitle => 'Linuxタスクバーの統合';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'タスクバーとアプリグリッドのアイコンについては、Linuxデスクトップ環境ではFreedesktopの別ファイルが必要になります。Retro Playerは起動時にアプリバンドルからこれらのファイルをインストールします。\n\n•~/.local/share/applications/app.retroplayer.desktop —実行中のウィンドウをこのアプリにリンクするランチャーエントリ\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — バンドルからコピーされたテーマアイコン\n\nユーザーのhicolor/index.themeファイルは決して書き込まれません（システムテーマを上書きし、他のアイコンを隠してしまうため）。アイコンはアプリのバイナリにも埋め込まれています。上記のコピーは、GNOME/KDEが汎用プレースホルダーではなく、正しいランチャーアイコンを表示するのに役立ちます。';

  @override
  String get dataStorageAndroidPermissionsTitle => 'Androidの権限とストレージ';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'Retro Playerは、データベースを内部ストレージのアプリ専用サポート領域に保存します。音楽ファイルは、システムフォルダ選択ツールで選択したフォルダに保存されます。&#10;&#10; Android版アプリでは、トラックを読み込むために音声へのアクセス権限、フォルダのアートワーク（例：cover.jpg）を表示するために写真／画像へのアクセス権限を要求する場合があります。音声ファイルがアプリのデータベースにコピーされることは一切ありません。';

  @override
  String get dataStorageAndroidPlaybackTitle => 'Androidのバックグラウンド再生';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Retro Playerは音声再生中にフォアグラウンドメディアサービスを実行するため、スマートフォンをロックしたりアプリを切り替えたりしても再生が継続され、システム通知に再生コントロールが表示されます。最近使用したアプリ一覧からアプリをスワイプして消すと、再生が停止し、通知も消えます。';

  @override
  String get dataStorageIOSAccessTitle => 'フォルダアクセス';

  @override
  String get dataStorageIOSAccessBody =>
      'Retro Playerは、データベースをデバイスストレージ上のアプリ専用サポート領域に保存します。音楽ファイルは、システムフォルダ選択ツールで選択したフォルダに保存されます。&#10;&#10; iOSは、ユーザーが選択したフォルダに対して、セキュリティスコープ付きのURLを通じてアクセスを許可します。Retro Playerは、これらの場所からファイルを直接読み込み、ライブラリをアプリストレージにコピーすることはありません。';

  @override
  String get dataStorageIOSPlaybackTitle => 'iOSのバックグラウンドオーディオ';

  @override
  String get dataStorageIOSPlaybackBody =>
      'アプリがバックグラウンドで動作しているときや画面がロックされているときでも、再生は継続できます。再生位置と再生キューの状態は、アプリのローカルデータベースに保存されます。';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'アプリデータは、内部ストレージのアプリ専用サポート領域に保存されます。';

  @override
  String get dataStoragePlatformBodyIOS =>
      'アプリデータは、デバイスストレージ上のアプリ専用サポート領域に保存されます。';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'アプリのデータは ~/Library/Application Support/app.retroplayer/ に保存されます。';

  @override
  String get dataStoragePlatformBodyWindows =>
      'アプリデータは、アプリケーションサポートディレクトリに保存されます。';

  @override
  String get dataStoragePlatformBodyWeb =>
      'アプリデータは、このオリジンの場合、ブラウザのローカルストレージに保存されます。';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'アプリデータは、プラットフォームアプリケーションサポートエリアに格納されます。';

  @override
  String get loading => '読み込み中…';

  @override
  String get libraryIndex => '図書館索引';

  @override
  String get playlists => 'プレイリスト';

  @override
  String get playPlaylist => 'プレイリストを再生';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count トラック',
      one: '1曲',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'プレイリストの作成';

  @override
  String get queue => 'キュー処理';

  @override
  String get saveAsPlaylist => 'プレイリストとして保存';

  @override
  String get queueEmpty => 'キューは空です。ライブラリからトラックを追加してください。';

  @override
  String get choosePlaylistFolder =>
      'ライブラリ内のフォルダを選択してください。ライブラリのルートはフォルダではありません。';

  @override
  String get clearQueue => 'キューをクリア';

  @override
  String get clearQueueTitle => 'キューをクリアしますか？';

  @override
  String get clearQueueBody =>
      'これにより、キューからすべてのトラックが削除されます。 オーディオファイルと保存されたプレイリストはそのまま残ります。';

  @override
  String get newPlaylistName => 'プレイリスト名';

  @override
  String get addTracks => 'トラックを追加';

  @override
  String get addSelectedTracks => '選択したトラックを追加';

  @override
  String get save => '保存';

  @override
  String get addTracksFromLibrary => 'ライブラリから追加';

  @override
  String addTracksConfirm(int count) {
    return '($count) を追加';
  }

  @override
  String get addTracksNothingSelected => 'ライブラリ内の1つ以上のトラックを選択します。';

  @override
  String get libraryEmptyNoRoots => 'まずライブラリフォルダを追加し、そこからトラックを選択します。';

  @override
  String get playlistEmpty => 'このプレイリストにはまだトラックがありません。';

  @override
  String get missingTrack => 'ファイルがありません';

  @override
  String get playlistReadOnly => '読み取り専用';

  @override
  String get playlistSelect => '選択';

  @override
  String get playlistSelectAll => 'すべて選択';

  @override
  String get playlistDeselectAll => 'すべての選択を解除';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count が選択されました',
      one: '1件選択されました',
      zero: 'トラックを選択',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'プレイリストから$countのトラックを削除しますか？',
      one: 'プレイリストからトラックを削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'これにより、保存時にプレイリストファイルからエントリが削除されます。',
      one: 'これにより、保存時にプレイリストファイルからそのエントリが削除されます。',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      '新しい楽曲は追加されていません。既にプレイリストに含まれている可能性があります。';

  @override
  String get addToQueue => 'キューに追加';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count曲をキューに追加しました',
      one: '1曲をキューに追加しました',
      zero: 'キューに追加された新しい曲はありません',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => '上に移動';

  @override
  String get moveDown => '下に移動';

  @override
  String get playlistNothingToPlay => 'このプレイリストには再生可能なトラックがありません。';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'プレイリストの削除';

  @override
  String deletePlaylistBody(String name) {
    return '「$name」を削除しますか？これは、ディスクからプレイリストファイルを削除します。';
  }
}

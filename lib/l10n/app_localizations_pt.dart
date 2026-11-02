// GENERATED CODE - DO NOT EDIT BY HAND

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Retro Player';

  @override
  String get settings => 'Definições';

  @override
  String get about => 'Sobre';

  @override
  String get aboutSubtitle =>
      'Apenas áudio local. Sem anúncios, sem telemetria, sem acesso à rede.\nFormatos suportados: MP3, M4A, M4B, FLAC, WAV';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutBuildDate => 'Tempo de construção';

  @override
  String get aboutGitBranch => 'Ramo';

  @override
  String get aboutGitCommit => 'Compilação';

  @override
  String get equalizer => 'Equalizador';

  @override
  String get equalizerUnavailable =>
      'O equalizador não está disponível nesta plataforma.';

  @override
  String get bands => 'Bandas';

  @override
  String get reset => 'Redefinir';

  @override
  String get library => 'Biblioteca';

  @override
  String get album => 'Álbum';

  @override
  String get playlist => 'Lista de reprodução';

  @override
  String get nowPlaying => 'A jogar agora';

  @override
  String get addFolder => 'Adicionar pasta';

  @override
  String get audioPermissionRequired =>
      'É necessária permissão de áudio no Android';

  @override
  String get expandPlayer => 'Expandir jogador';

  @override
  String get showLibrary => 'Mostrar biblioteca';

  @override
  String errorMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get noFoldersAdded =>
      'Nenhuma pasta adicionada. Toque em \"Adicionar pasta\" para começar.';

  @override
  String get folderEmpty => 'Esta pasta está vazia.';

  @override
  String get librarySources => 'Fontes da biblioteca';

  @override
  String get favorites => 'Favoritos';

  @override
  String get favorite => 'Favorito';

  @override
  String get removeFavorite => 'Remover favorito';

  @override
  String get folders => 'Pastas';

  @override
  String get audio => 'Áudio';

  @override
  String get playFolder => 'Pasta de reprodução';

  @override
  String get playAlbum => 'Reproduzir álbum';

  @override
  String get removeLibraryFolderTitle => 'Remover pasta da biblioteca?';

  @override
  String removeLibraryFolderBody(String name) {
    return 'Remover \"$name\" da sua biblioteca?\n\nOs seus ficheiros de áudio no disco não são eliminados.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get albumNotFound => 'Álbum não encontrado';

  @override
  String get playlistNotFound => 'Lista de reprodução não encontrada';

  @override
  String get selectToPlay =>
      'Selecione algo da sua biblioteca para reproduzir.';

  @override
  String get speed => 'Velocidade';

  @override
  String get previous => 'Anterior';

  @override
  String get pause => 'Pausa';

  @override
  String get play => 'Reproduzir';

  @override
  String get next => 'Próximo';

  @override
  String get jumpBack => 'Voltar 15 segundos';

  @override
  String get jumpForward => 'Avançar 15 segundos';

  @override
  String get trackFallback => 'Faixa';

  @override
  String get unknownArtist => 'Desconhecido';

  @override
  String tracksCountArtist(int count, String artist) {
    return '$count faixas · $artist';
  }

  @override
  String get resetDatabase => 'Redefinir base de dados';

  @override
  String get resetDatabaseTitle => 'Redefinir base de dados?';

  @override
  String get resetDatabaseBody =>
      'Isso limpa as posições de reprodução, os favoritos, a pasta aberta, o tema, o idioma e as configurações do equalizador. Limpar tudo também esquece as pastas da biblioteca adicionadas. Os arquivos de música e as listas de reprodução no disco não são excluídos.';

  @override
  String get resetDatabaseKeepFolders => 'Manter pastas da biblioteca';

  @override
  String get resetDatabaseClearEverything => 'Limpar tudo';

  @override
  String get eqManually => 'Manualmente';

  @override
  String get eqBass => 'Baixo';

  @override
  String get eqTreble => 'Agudos';

  @override
  String get eqVoice => 'Voz';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeLight => 'Luz';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get openSourceLicenses => 'Licenças de código aberto';

  @override
  String get openSourceLegalese => '© 2026 Colaboradores do Retro Player';

  @override
  String get dataStorage => 'Armazenamento DE dados';

  @override
  String get dataStorageIntro =>
      'O Retro Player mantém as definições da aplicação numa pequena base de dados local. As suas músicas e listas de reprodução permanecem como ficheiros normais nas pastas que escolher.';

  @override
  String get dataStorageAppDataTitle => 'Base de dados da aplicação';

  @override
  String dataStorageAppDataBody(String dbFileName, String dbPath) {
    return 'Ficha: $dbFileName\nCaminho: $dbPath\n\nArmazena raízes da biblioteca, estado de navegação, currículo de reprodução, equalizador, tema e preferências de idioma.';
  }

  @override
  String get dataStorageLibraryTitle => 'Ficheiros de música';

  @override
  String get dataStorageLibraryBody =>
      'Os ficheiros de áudio nunca são copiados para a base de dados da aplicação. Adicione pastas de biblioteca e o Retro Player lê arquivos diretamente do disco.';

  @override
  String get dataStoragePlaylistsTitle => 'Ficheiros da lista de reprodução';

  @override
  String get dataStoragePlaylistsBody =>
      'As listas de reprodução são arquivos .m3u simples armazenados dentro das pastas da biblioteca. Pode editá-los na aplicação ou com qualquer editor de texto.';

  @override
  String dataStoragePlatformTitle(String platform) {
    return 'Plataforma: $platform';
  }

  @override
  String get dataStoragePlatformBodyLinux =>
      'Os dados da aplicação são armazenados no diretório de suporte da aplicação (normalmente ~/.local/share/app.retroplayer/).';

  @override
  String get dataStorageLinuxDataTitle => 'Dados da aplicação Linux';

  @override
  String get dataStorageLinuxDataBody =>
      'Os dados da aplicação permanecem em ~/.local/share/app.retroplayer/. Essa pasta é apenas para a base de dados e definições.';

  @override
  String get dataStorageLinuxTaskbarTitle =>
      'Integração da barra de tarefas do Linux';

  @override
  String get dataStorageLinuxTaskbarBody =>
      'Para a barra de tarefas e o ícone de grade do aplicativo, os ambientes de desktop Linux esperam arquivos Freedesktop separados. O Retro Player os instala a partir do pacote de aplicativos na inicialização:\n\n• ~/.local/share/applications/app.retroplayer.desktop - entrada do inicializador que vincula a janela em execução a este aplicativo\n• ~/.local/share/icons/hicolor/*/apps/app.retroplayer.png — ícones temáticos copiados do pacote\n\nEle nunca escreve um usuário hicolor/index.theme (que sombrearia o tema do sistema e ocultaria outros ícones). Os ícones também são incorporados no binário do aplicativo. As cópias acima ajudam o GNOME/KDE a mostrar o ícone correto do inicializador em vez de um espaço reservado genérico.';

  @override
  String get dataStorageAndroidPermissionsTitle =>
      'Permissões e armazenamento para Android';

  @override
  String get dataStorageAndroidPermissionsBody =>
      'O Retro Player armazena seu banco de dados na área de suporte privado do aplicativo no armazenamento interno. Os seus ficheiros de música permanecem nas pastas que escolher com o seletor de pastas do sistema.\n\nNo Android, o aplicativo pode solicitar acesso de áudio para ler faixas e acesso a fotos/imagens para que a arte da pasta (por exemplo, cover.jpg) possa ser mostrada. Os ficheiros de áudio nunca são copiados para a base de dados da aplicação.';

  @override
  String get dataStorageAndroidPlaybackTitle =>
      'Reprodução de plano de fundo do Android';

  @override
  String get dataStorageAndroidPlaybackBody =>
      'Quando o áudio está sendo reproduzido, o Retro Player executa um serviço de mídia em primeiro plano para que a reprodução continue se você bloquear o telefone ou trocar de aplicativo, com controles de transporte na notificação do sistema. Deslizar o aplicativo para longe de Recentes interrompe a reprodução e remove a notificação.';

  @override
  String get dataStorageIOSAccessTitle => 'acesso à pasta iOS';

  @override
  String get dataStorageIOSAccessBody =>
      'O Retro Player armazena seu banco de dados na área de suporte privada do aplicativo no armazenamento do dispositivo. Os seus ficheiros de música permanecem nas pastas que escolher com o seletor de pastas do sistema.\n\no iOS concede acesso por meio de URLs com escopo de segurança para as pastas selecionadas. O Retro Player lê arquivos diretamente desses locais; ele não copia sua biblioteca para o armazenamento do aplicativo.';

  @override
  String get dataStorageIOSPlaybackTitle => 'áudio de fundo para iOS';

  @override
  String get dataStorageIOSPlaybackBody =>
      'A reprodução pode continuar enquanto a aplicação estiver em segundo plano ou o ecrã estiver bloqueado. As posições dos currículos e o estado da fila são armazenados no banco de dados local do aplicativo.';

  @override
  String get dataStoragePlatformBodyAndroid =>
      'Os dados da aplicação são armazenados na área de suporte privada da aplicação no armazenamento interno.';

  @override
  String get dataStoragePlatformBodyIOS =>
      'Os dados da aplicação são armazenados na área de suporte privada da aplicação no armazenamento do dispositivo.';

  @override
  String get dataStoragePlatformBodyMacOS =>
      'Os dados da aplicação são armazenados em ~/Library/Application Support/app.retroplayer/.';

  @override
  String get dataStoragePlatformBodyWindows =>
      'Os dados da aplicação são armazenados no diretório de suporte da aplicação.';

  @override
  String get dataStoragePlatformBodyWeb =>
      'Os dados da aplicação são armazenados no armazenamento local do navegador para esta origem.';

  @override
  String get dataStoragePlatformBodyUnknown =>
      'Os dados da aplicação são armazenados na área de suporte da aplicação da plataforma.';

  @override
  String get loading => 'A carregar…';

  @override
  String get libraryIndex => 'Índice DA biblioteca';

  @override
  String get playlists => 'Listas de reprodução';

  @override
  String get playPlaylist => 'Playlist';

  @override
  String playlistTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faixas $count',
      one: '1 faixa',
    );
    return '$_temp0';
  }

  @override
  String get createPlaylist => 'Criar lista de reprodução';

  @override
  String get queue => 'Fila';

  @override
  String get saveAsPlaylist => 'Guardar como lista de reprodução';

  @override
  String get queueEmpty =>
      'A fila está vazia. Adicione faixas da sua biblioteca.';

  @override
  String get choosePlaylistFolder =>
      'Escolha uma pasta na biblioteca. A raiz da biblioteca não é uma pasta.';

  @override
  String get clearQueue => 'Limpar fila';

  @override
  String get clearQueueTitle => 'Limpar fila?';

  @override
  String get clearQueueBody =>
      'Isso remove todas as faixas da fila. Os arquivos de áudio e as listas de reprodução salvas permanecem.';

  @override
  String get newPlaylistName => 'Nome da lista de reprodução';

  @override
  String get addTracks => 'Adicionar faixas';

  @override
  String get save => 'Guardar';

  @override
  String get addTracksFromLibrary => 'Adicionar da biblioteca';

  @override
  String addTracksConfirm(int count) {
    return 'Adicionar ($count)';
  }

  @override
  String get addTracksNothingSelected =>
      'Selecione uma ou mais faixas na sua biblioteca.';

  @override
  String get libraryEmptyNoRoots =>
      'Adicione uma pasta da biblioteca primeiro e, em seguida, escolha faixas dela.';

  @override
  String get playlistEmpty => 'Esta lista de reprodução ainda não tem faixas.';

  @override
  String get missingTrack => 'Ficheiro em falta';

  @override
  String get playlistReadOnly => 'Somente leitura';

  @override
  String get playlistSelect => 'Selecionar';

  @override
  String get playlistSelectAll => 'Selecionar tudo';

  @override
  String get playlistDeselectAll => 'Desmarcar tudo';

  @override
  String playlistSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionado',
      one: '1 selecionado',
      zero: 'Selecionar faixas',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deseja remover as faixas $count da lista de reprodução?',
      one: 'Remover a faixa da lista de reprodução?',
    );
    return '$_temp0';
  }

  @override
  String removePlaylistTrackBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Isto remove as entradas do ficheiro da lista de reprodução quando guardares.',
      one: 'Isto remove a entrada do ficheiro da lista de reprodução quando guardares.',
    );
    return '$_temp0';
  }

  @override
  String get addTracksNothingAdded =>
      'Não foram adicionadas novas faixas. Eles podem já estar na lista de reprodução.';

  @override
  String get addToQueue => 'Adicionar à fila';

  @override
  String addedToQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count faixas adicionadas à fila',
      one: '1 faixa adicionada à fila',
      zero: 'Nenhuma faixa nova adicionada à fila',
    );
    return '$_temp0';
  }

  @override
  String get moveUp => 'Mover para cima';

  @override
  String get moveDown => 'Mover para baixo';

  @override
  String get playlistNothingToPlay =>
      'Esta lista de reprodução não tem faixas reproduzíveis.';

  @override
  String shortcutTooltip(String action, String shortcut) {
    return '$action ($shortcut)';
  }

  @override
  String get deletePlaylistTitle => 'Eliminar lista de reprodução?';

  @override
  String deletePlaylistBody(String name) {
    return 'Eliminar \"$name\"? Isto remove o ficheiro da lista de reprodução do disco.';
  }
}

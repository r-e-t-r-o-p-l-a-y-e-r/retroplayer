import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:audio_service/audio_service.dart' as audsvc;
import 'package:audio_service_mpris/audio_service_mpris.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/app_branding.dart';
import 'package:retroplayer/data/db/app_database_flutter.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/repositories/playback_repository.dart';
import 'package:retroplayer/data/services/album_art_cache.dart';
import 'package:retroplayer/data/services/app_data_paths.dart';
import 'package:retroplayer/data/services/audio_playback_service.dart';
import 'package:retroplayer/data/services/external_playback_route_gate.dart';
import 'package:retroplayer/data/services/equalizer_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/data/services/linux_playback_startup.dart';
import 'package:retroplayer/data/services/local_only_media_kit.dart';
import 'package:retroplayer/data/services/metadata_service.dart';
import 'package:retroplayer/data/services/android_audio_service_config.dart';
import 'package:retroplayer/data/services/android_recents_playback_bridge.dart';
import 'package:retroplayer/data/services/retro_audio_handler.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';
import 'package:retroplayer/data/services/resolve_cover_art.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/core/app_session_bootstrap.dart';
import 'package:retroplayer/ui/core/cold_start_ui.dart';
import 'package:retroplayer/ui/core/keyboard/keyboard_registry.dart';
import 'package:retroplayer/ui/core/mobile_layout.dart';
import 'package:retroplayer/ui/core/playback_lifecycle.dart';
import 'package:retroplayer/ui/core/system_back_ownership.dart';
import 'package:retroplayer/ui/core/theme.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/locale_view_model.dart';
import 'package:retroplayer/ui/features/settings/view_models/theme_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['Retro Player'], license);
  });

  if (!kIsWeb && Platform.isLinux) {
    await prepareLinuxPlaybackBackend();
  } else if (!kIsWeb && Platform.isIOS) {
    configureLocalOnlyMediaKit();
    JustAudioMediaKit.ensureInitialized(iOS: true);
  }

  final session = await AudioSession.instance;
  // Media/playback session so audio keeps running when the UI is backgrounded
  // or the screen locks. Avoid speech()'s androidWillPauseWhenDucked, which
  // pauses too eagerly on transient focus loss when switching apps.
  await session.configure(const AudioSessionConfiguration.music());

  ExternalPlaybackRouteGate? playbackRouteGate;
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    playbackRouteGate = ExternalPlaybackRouteGate(
      getOutputDevices: () => session.getDevices(includeInputs: false),
      devicesChanged: session.devicesChangedEventStream,
      activateAudioSession: () => session.setActive(true),
    );
  }

  final db = await openAppDatabase();
  final storage = LibraryStorageService(db);
  final playbackService = JustAudioPlaybackService(
    externalPlaybackRouteGate: playbackRouteGate,
  );
  final equalizerService = EqualizerService(
    storage,
    playbackService: playbackService,
  );
  final metadataService = MetadataService();
  final albumArtCache = AlbumArtCache(
    Directory('${await AppDataPaths.applicationSupportDirectory()}/album_art'),
  );
  final resolveCoverArt = ResolveCoverArt(
    readEmbeddedArtwork: metadataService.readEmbeddedArtwork,
    cache: albumArtCache,
  );
  final libraryRepository = createLibraryRepository(
    storage,
    resolveCoverArt: resolveCoverArt,
  );
  final playbackRepository = PlaybackRepository(
    playbackService: playbackService,
    storageService: storage,
  );
  // Cold start always opens the library shell; browse path, album detail and
  // playback are restored by AppSessionBootstrap.
  final router = AppRouter.create();
  final equalizerSettings = await storage.getEqualizerSettings();
  final coldStartUi = await ColdStartUi.load(
    storage: storage,
    playbackRepository: playbackRepository,
  );

  await _initAudioService(
    playbackService,
    playbackRepository,
    activateAudioSession: () => session.setActive(true),
  );

  final audioSessionSubscription = playbackService.androidAudioSessionIdStream
      .listen((sessionId) {
        if (sessionId != null) {
          unawaited(equalizerService.reapplyLast());
        }
      });

  runApp(
    RetroPlayerApp(
      libraryRepository: libraryRepository,
      playbackRepository: playbackRepository,
      equalizerService: equalizerService,
      storageService: storage,
      resolveCoverArt: resolveCoverArt,
      router: router,
      initialEqualizerSettings: equalizerSettings,
      audioSessionSubscription: audioSessionSubscription,
      coldStartUi: coldStartUi,
    ),
  );
}

Future<void> _initAudioService(
  AudioPlaybackService playbackService,
  PlaybackRepository playbackRepository, {
  required Future<bool> Function() activateAudioSession,
}) async {
  if (playbackService is! JustAudioPlaybackService) return;
  if (!kIsWeb && Platform.isLinux) {
    AudioServiceMpris.registerWith();
    return;
  }
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }
  RetroAudioHandler? retroHandler;
  try {
    // Requires MainActivity to extend AudioServiceActivity on Android.
    await audsvc.AudioService.init(
      builder: () {
        retroHandler = RetroAudioHandler(
          playbackService,
          onRecentsDismiss:
              playbackRepository.stopPlaybackForRecentsDismiss,
          activateAudioSession: activateAudioSession,
        );
        return retroHandler!;
      },
      config: retroPlayerAndroidAudioServiceConfig(),
    );
    final handler = retroHandler;
    if (handler != null) {
      playbackRepository.mediaSessionHandler = handler;
      playbackRepository.activateAudioSession = activateAudioSession;
      AndroidRecentsPlaybackBridge.install(
        playbackRepository: playbackRepository,
        idleMediaSession: handler.idleMediaSession,
      );
    }
  } catch (e, st) {
    developer.log(
      'AudioService.init failed: $e\n$st',
      name: 'retroplayer.audio',
      level: 1000,
    );
  }
}

class RetroPlayerApp extends StatelessWidget {
  const RetroPlayerApp({
    super.key,
    required this.libraryRepository,
    required this.playbackRepository,
    required this.equalizerService,
    required this.storageService,
    required this.resolveCoverArt,
    required this.router,
    required this.initialEqualizerSettings,
    this.audioSessionSubscription,
    required this.coldStartUi,
  });

  final LibraryRepository libraryRepository;
  final PlaybackRepository playbackRepository;
  final EqualizerService equalizerService;
  final LibraryStorageService storageService;
  final ResolveCoverArt resolveCoverArt;
  final GoRouter router;
  final EqualizerSettings initialEqualizerSettings;
  final StreamSubscription<int?>? audioSessionSubscription;
  final ColdStartUi coldStartUi;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: libraryRepository),
        Provider.value(value: playbackRepository),
        Provider.value(value: equalizerService),
        ChangeNotifierProvider(
          create: (_) => LibraryViewModel(libraryRepository: libraryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ColdStartUi.createPlayerViewModel(
            playbackRepository: playbackRepository,
            coldStart: coldStartUi,
            resolveCoverArt: resolveCoverArt,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ColdStartUi.createPanelViewModel(
            coldStart: coldStartUi,
          ),
        ),
        ChangeNotifierProvider(create: (_) => KeyboardRegistry()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => EqualizerViewModel(
            equalizerService: equalizerService,
            initialSettings: initialEqualizerSettings,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(storageService: storageService)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LocaleViewModel(storageService: storageService)..load(),
        ),
      ],
      child: AppSessionBootstrap(
        child: PlaybackLifecycle(
          playbackRepository: playbackRepository,
          storageService: storageService,
          audioSessionSubscription: audioSessionSubscription,
          child: Consumer2<ThemeViewModel, LocaleViewModel>(
            builder: (context, themeVm, localeVm, _) {
              return MaterialApp.router(
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context).appTitle,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocaleCatalog.supportedLocales,
                locale: localeVm.locale,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeVm.themeMode,
                routerConfig: router,
                onNavigationNotification: claimSystemBack,
                builder: (context, child) {
                  return MobileLayout(child: child ?? const SizedBox.shrink());
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

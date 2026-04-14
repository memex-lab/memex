import 'dart:async';
import 'dart:typed_data';
import 'package:logging/logging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:memex/config/dependencies.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/ui/user_setup/widgets/user_setup_screen.dart';
import 'package:memex/ui/app_lock/widgets/lock_screen_page.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/themes/app_theme.dart';
import 'dart:io';
import 'package:memex/ui/main_screen/widgets/radial_menu.dart';
import 'package:memex/domain/models/shortcut_item.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui';
import 'package:memex/ui/main_screen/widgets/input_sheet.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/publish_timestamp_service.dart';
import 'package:memex/data/services/health_service.dart';
import 'package:memex/data/services/health_strategies.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/data/services/streaming_transcriber.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:workmanager/workmanager.dart';
import 'package:health/health.dart';
import 'package:memex/domain/models/timeline_card_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/ui/agent_activity/widgets/agent_activity_widget.dart';
import 'package:memex/ui/main_screen/widgets/ai_core_button.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/local_server_service.dart';
import 'package:go_router/go_router.dart';
import 'package:memex/routing/router.dart';
import 'package:memex/data/services/onboarding_service.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/ui/core/widgets/demo_overlay.dart';
import 'package:memex/ui/main_screen/widgets/share_intent_handler.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<RootShellState> rootShellKey = GlobalKey<RootShellState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor from platform (set by --flavor flag)
  AppFlavor.init(appFlavor);

  await setupLogger();

  // Initialize l10n
  await UserStorage.initL10n();

  // Initialize Workmanager (for background tasks)
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Cancel any previously registered pedometer background tasks on iOS
  // (iOS now uses HealthKit only, not CMPedometer)
  if (Platform.isIOS) {
    await Workmanager().cancelAll();
  }

  // MemexRouter is provided via config/dependencies.dart and created on first read

  // Start local HTTP server
  await LocalServerService.start();

  // Set status bar style & enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final appRouter =
      createAppRouter(rootNavigatorKey, () => RootShell(key: rootShellKey));
  runApp(MultiProvider(
    providers: dependencyProviders,
    child: MemexApp(router: appRouter),
  ));
}

/// Root route content: user check then loading / UserSetupScreen / MainScreen (Compass-style).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
  bool _hasUser = false;
  bool _onboardingComplete = false;
  bool _isChecking = true;
  bool _isLoadingFromICloud = false;
  int _mainScreenEpoch =
      0; // incremented to force full rebuild on storage switch

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final hasUser = await UserStorage.hasUser();
    var onboardingDone = await OnboardingService.isOnboardingComplete();

    // Migration: existing users who set up before the onboarding flag was added
    // should be treated as onboarding-complete.
    if (hasUser && !onboardingDone) {
      final configs = await UserStorage.getLLMConfigs();
      final hasValidConfig = configs.any((c) => c.isValid);
      if (hasValidConfig) {
        await OnboardingService.markOnboardingComplete();
        onboardingDone = true;
      }
    }

    if (mounted) {
      setState(() {
        _hasUser = hasUser;
        _onboardingComplete = onboardingDone;
        _isChecking = false;
      });
    }
  }

  void _onUserCreated() async {
    // Check iCloud BEFORE any other awaits to avoid timing issues
    final userId = await UserStorage.getUserId();
    bool isICloud = false;
    if (userId != null) {
      final loc = await UserStorage.getWorkspaceStorageLocation(userId);
      isICloud = loc == StorageLocation.icloud;
    }

    await OnboardingService.markOnboardingComplete();

    if (isICloud && mounted) {
      setState(() => _isLoadingFromICloud = true);
      // Wait for the loading UI to actually render before starting heavy work
      await Future.delayed(const Duration(milliseconds: 100));
      await MemexRouter().applyWorkspaceStorageChange();
      if (mounted) {
        setState(() {
          _isLoadingFromICloud = false;
          _hasUser = true;
          _onboardingComplete = true;
        });
      }
    } else if (mounted) {
      setState(() {
        _hasUser = true;
        _onboardingComplete = true;
      });
    }
  }

  /// Reset state and re-check user. Called after account deletion or storage switch.
  void resetAndRecheck() {
    setState(() {
      _hasUser = false;
      _onboardingComplete = false;
      _isChecking = true;
      _mainScreenEpoch++;
    });
    _checkUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: AgentLogoLoading()),
      );
    }
    if (_isLoadingFromICloud) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AgentLogoLoading(),
              const SizedBox(height: 16),
              Text(
                UserStorage.l10n.loadingFromICloud,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!_hasUser || !_onboardingComplete) {
      return UserSetupScreen(onUserCreated: _onUserCreated);
    }
    return MultiProvider(
      key: ValueKey(_mainScreenEpoch),
      providers: [
        ChangeNotifierProvider<TimelineViewModel>(
          create: (c) =>
              TimelineViewModel(router: c.read<MemexRouter>())..init(),
        ),
        ChangeNotifierProvider<InsightViewModel>(
          create: (c) =>
              InsightViewModel(router: c.read<MemexRouter>())..loadData(),
        ),
        ChangeNotifierProvider<KnowledgeBaseViewModel>(
          create: (c) => KnowledgeBaseViewModel(router: c.read<MemexRouter>())
            ..fetchData(),
        ),
      ],
      child: const MainScreen(),
    );
  }
}

class MemexApp extends StatefulWidget {
  const MemexApp({super.key, required this.router});

  final GoRouter router;

  @override
  State<MemexApp> createState() => _MemexAppState();
}

class _MemexAppState extends State<MemexApp> with WidgetsBindingObserver {
  bool _hasUser = false;
  bool _isLocked = true; // Default to locked on start
  bool _requiresAuth = true; // Whether actual authentication is required
  DateTime? _lastPausedTime; // Track when app was paused

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUser();
    _checkLockSettings();
  }

  Future<void> _checkLockSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    if (mounted) {
      setState(() {
        // If lock is strictly required only when enabled, we update _isLocked.
        // Default _isLocked is true. If disabled, we unlock immediately.
        if (!isLockEnabled) {
          _isLocked = false;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
      _checkLockSettingsBeforeLocking();
    } else if (state == AppLifecycleState.resumed) {
      _checkGracePeriod();
    }
  }

  Future<void> _checkLockSettingsBeforeLocking() async {
    final prefs = await SharedPreferences.getInstance();
    final isLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    if (isLockEnabled && mounted) {
      setState(() {
        _isLocked = true;
        _requiresAuth = false; // Just show privacy screen initially
      });
    }
  }

  Future<void> _checkGracePeriod() async {
    if (!_isLocked) return;

    if (_lastPausedTime != null) {
      final difference = DateTime.now().difference(_lastPausedTime!);
      // If less than 5 minutes, unlock automatically
      if (difference.inMinutes < 5) {
        if (mounted) {
          setState(() {
            _isLocked = false;
          });
        }
      } else {
        // More than 5 minutes, require auth
        if (mounted) {
          setState(() {
            _requiresAuth = true;
          });
        }
      }
    } else {
      // No pause time recorded (e.g. cold start), require auth
      if (mounted) {
        setState(() {
          _requiresAuth = true;
        });
      }
    }
  }

  Future<void> _checkUser() async {
    final hasUser = await UserStorage.hasUser();
    if (mounted) {
      setState(() {
        _hasUser = hasUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memex',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.light, // Unified light mode, disabling adaptive dark mode
      routerConfig: widget.router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_isLocked && _hasUser)
              _requiresAuth
                  ? LockScreen(
                      onUnlock: () {
                        setState(() {
                          _isLocked = false;
                        });
                      },
                    )
                  : const PrivacyScreen(),
          ],
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentTab = 0;
  bool _isInputOpen = false;
  final GlobalKey<TimelineScreenState> _timelineKey =
      GlobalKey<TimelineScreenState>();
  final GlobalKey<KnowledgeBaseScreenState> _knowledgeBaseKey =
      GlobalKey<KnowledgeBaseScreenState>();
  final MemexRouter _memexRouter = MemexRouter();
  final EventBusService _eventBus = EventBusService.instance;
  Timer? _memoryButtonTapTimer;
  int _memoryButtonTapCount = 0;
  Timer? _knowledgeBaseButtonTapTimer;
  int _knowledgeBaseButtonTapCount = 0;
  final Logger _logger = getLogger('MainScreen');

  // Radial Menu & Recording State
  bool _isRadialMenuOpen = false;
  List<ShortcutItem> _shortcuts = [];
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  StreamingTranscriber? _quickTranscriber;
  StreamSubscription<Uint8List>? _quickAudioSub;
  final List<int> _quickPcmBuffer = [];
  String _quickTranscribedText = '';
  bool _isQuickCalibrating = false;
  Offset _centerButtonCenter = Offset.zero;
  final GlobalKey<RadialMenuState> _radialMenuKey =
      GlobalKey<RadialMenuState>();
  final GlobalKey _aiButtonKey = GlobalKey();
  final GlobalKey _mainStackKey = GlobalKey();
  bool _isInvalidConfigDialogShowing = false;
  bool _isErrorNotificationDialogShowing = false;
  late final ShareIntentHandler _shareIntentHandler;
  InputData? _sharedDraft;

  // Agent Button Position - REMOVED (Moved to Main App)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DemoService.instance.addListener(_onDemoChanged);
    // Init event bus connection and local DB (delay to ensure token is loaded)
    Future.delayed(const Duration(seconds: 1), () async {
      final userId = await UserStorage.getUserId();
      if (userId != null && !AppDatabase.isInitialized) {
        await AppDatabase.init(userId);
      }
      _eventBus.connect();

      // Start onboarding demo on first launch
      if (userId != null) {
        DemoService.instance.start(userId);
      }
    });

    // Check and report all health data
    _logger.info('initState: Starting comprehensive health check...');
    _checkAndReportHealthData().catchError((error, stackTrace) {
      _logger.severe(
          '❌ Error in _checkAndReportHealthData: $error', error, stackTrace);
    });

    // Start auto input collection and quantity check
    _logger.info('initState: Starting Auto Input collection check...');

    _eventBus.addHandler(
        EventBusMessageType.invalidModelConfig, _handleInvalidModelConfig);
    _eventBus.addHandler(
        EventBusMessageType.errorNotification, _handleErrorNotification);

    _shareIntentHandler = ShareIntentHandler(
      logger: _logger,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      onSharedDraft: (data) {
        if (!mounted) return;
        setState(() {
          _sharedDraft = data;
          _isInputOpen = true;
        });
      },
    )..init();
  }

  void _handleInvalidModelConfig(EventBusMessage message) {
    if (!mounted) return;
    if (message is! InvalidModelConfigMessage) return;

    // Check if dialog is already showing to prevent stacking
    if (_isInvalidConfigDialogShowing) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    setState(() => _isInvalidConfigDialogShowing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.warning),
        content: Text(UserStorage.l10n
            .invalidModelConfigDetailed(message.agentId, message.configKey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted)
                setState(() => _isInvalidConfigDialogShowing = false);
            },
            child: Text(UserStorage.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted)
                setState(() => _isInvalidConfigDialogShowing = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModelConfigListPage(),
                ),
              );
            },
            child: Text(UserStorage.l10n.modelConfig),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _isInvalidConfigDialogShowing = false);
    });
  }

  void _handleErrorNotification(EventBusMessage message) {
    if (!mounted) return;
    if (message is! ErrorNotificationMessage) return;
    if (_isErrorNotificationDialogShowing) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    setState(() => _isErrorNotificationDialogShowing = true);

    final isAuthError = message.errorCategory == 'authenticationError';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.llmErrorDialogTitle),
        content: Text(message.errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted)
                setState(() => _isErrorNotificationDialogShowing = false);
            },
            child: Text(UserStorage.l10n.cancel),
          ),
          if (isAuthError)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted)
                  setState(() => _isErrorNotificationDialogShowing = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModelConfigListPage(),
                  ),
                );
              },
              child: Text(UserStorage.l10n.goToModelConfig),
            ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _isErrorNotificationDialogShowing = false);
    });
  }

  void _onDemoChanged() {
    if (!mounted) return;
    final demo = DemoService.instance;

    // When demo advances to tapKnowledgeTab, refresh the knowledge base
    // so the demo-written guide file appears.
    if (demo.currentStep == DemoStep.tapKnowledgeTab) {
      _knowledgeBaseKey.currentState?.scrollToTopAndRefresh();
    }

    setState(() {});
  }

  Future<void> _handleAICoreButtonTap() async {
    // No LLM config check — users can submit records without AI configured.

    if (mounted) {
      // Prefill text during demo
      if (DemoService.instance.currentStep == DemoStep.tapSend) {
        setState(() {
          _sharedDraft = InputData(text: DemoService.instance.prefillText);
          _isInputOpen = true;
        });
      } else {
        setState(() => _isInputOpen = true);
      }
    }
  }

  void _handleAICoreButtonLongPressStart() {
    // Determine button center for RadialMenu using GlobalKey
    final RenderBox? buttonBox =
        _aiButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackBox =
        _mainStackKey.currentContext?.findRenderObject() as RenderBox?;

    if (buttonBox != null && stackBox != null) {
      final buttonSize = buttonBox.size;
      final buttonPosition =
          stackBox.globalToLocal(buttonBox.localToGlobal(Offset.zero));
      _centerButtonCenter =
          buttonPosition + Offset(buttonSize.width / 2, buttonSize.height / 2);
    } else {
      // Fallback
      final size = MediaQuery.of(context).size;
      _centerButtonCenter = Offset(size.width / 2, size.height - 24 - 32);
    }

    setState(() {
      _isRadialMenuOpen = true;
    });
    _startRecording();
    HapticFeedback.mediumImpact();
  }

  void _handleAICoreButtonLongPressMoveUpdate(
      LongPressMoveUpdateDetails details) {
    if (_isRadialMenuOpen) {
      // coordinates in 'details' are local to the AICoreButton (64x64).
      // We need to transform them to be relative to the same space as _centerButtonCenter (the Stack).
      final touchPosInStack =
          _centerButtonCenter + (details.localPosition - const Offset(32, 32));
      _radialMenuKey.currentState?.handleUpdate(touchPosInStack);
    }
  }

  void _handleAICoreButtonLongPressEnd(LongPressEndDetails details) {
    if (_isRadialMenuOpen) {
      _radialMenuKey.currentState?.handleRelease();
    }
  }

  /// Check and report health data
  ///
  /// Flow:
  /// 1. Iterate all supported health data types
  /// 2. Check if report conditions are met (e.g. 30/60 min interval, permission, new data)
  /// 3. If met, aggregate data into dailySummary
  /// 4. If any new data, call API to report aggregated data
  /// 5. On success, update last report date for each type
  Future<void> _checkAndReportHealthData() async {
    try {
      _logger.info('=== Starting comprehensive health check ===');

      // Detect if previous pedometer access crashed the app — skip this launch only
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('pedometer_attempting') == true) {
        _logger.warning(
            'Pedometer crash detected from previous launch, skipping this session');
        await prefs.remove('pedometer_attempting');
        // Set in-memory flag only — will retry on next app launch
        PedometerFetcher.skipThisSession = true;
      }

      final healthService = HealthService();
      Map<String, Map<String, dynamic>> dailySummary = {};

      // Use only the types registered in HealthService (Android: STEPS only,
      // iOS: all types). This respects the platform-specific strategy config.
      final typesToCheck = healthService.registeredTypes;

      // Skip health data collection if fitness permission is not granted
      // (permissions are now requested via System Authorization page)
      final fitnessStatus = Platform.isIOS
          ? await Permission.sensors.status
          : await Permission.activityRecognition.status;
      _logger.info('Fitness permission status: $fitnessStatus');
      if (!fitnessStatus.isGranted && !fitnessStatus.isLimited) {
        _logger.info(
            'Fitness permission not granted, skipping health data collection');
        return;
      }

      _logger
          .info('Types to check: ${typesToCheck.map((t) => t.name).toList()}');
      Map<HealthDataType, dynamic> newlyFetchedData = {};

      for (var type in typesToCheck) {
        _logger.info('Checking and preparing $type...');
        final data = await healthService.checkAndPrepareData(type);
        if (data != null) {
          if (data is Map && data.isNotEmpty) {
            newlyFetchedData[type] = data;

            // Merge into dailySummary
            data.forEach((dateStr, val) {
              if (!dailySummary.containsKey(dateStr)) {
                dailySummary[dateStr] = {};
              }

              // Custom merging logic depends on the shape of data
              final typeName = type.name;
              if (val is Map) {
                // If it's already a map (like heart rate min/max), merge directly or nest
                if (type == HealthDataType.HEART_RATE ||
                    type == HealthDataType.RESTING_HEART_RATE) {
                  dailySummary[dateStr]![typeName.toLowerCase()] = val;
                } else if (type == HealthDataType.BLOOD_OXYGEN) {
                  dailySummary[dateStr]!['blood_oxygen'] = val;
                } else if (type == HealthDataType.SLEEP_ASLEEP) {
                  dailySummary[dateStr]!['sleep'] = val;
                } else {
                  dailySummary[dateStr]![typeName.toLowerCase()] = val;
                }
              } else if (val is List) {
                if (type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC ||
                    type == HealthDataType.BLOOD_PRESSURE_DIASTOLIC) {
                  // Merge systolic and diastolic into a single 'blood_pressure' array based on the 'time' key
                  dailySummary[dateStr]!['blood_pressure'] ??= [];
                  List existing = dailySummary[dateStr]!['blood_pressure'];
                  for (var item in val) {
                    var found =
                        existing.where((e) => e['time'] == item['time']);
                    if (found.isNotEmpty) {
                      found.first.addAll(item);
                    } else {
                      existing.add(Map<String, dynamic>.from(item));
                    }
                  }
                } else if (type == HealthDataType.WORKOUT) {
                  dailySummary[dateStr]!['workout'] = val;
                } else {
                  dailySummary[dateStr]![typeName.toLowerCase()] = val;
                }
              } else {
                // primitive like int/double
                dailySummary[dateStr]![typeName.toLowerCase()] = val;
              }
            });
          }
        }
      }

      if (dailySummary.isEmpty) {
        _logger.info('No new health data to report');
        return;
      }

      _logger.info(
          'Reporting health summary to server for ${dailySummary.length} days...');
      final success = await _memexRouter.reportDailyHealthSummary(dailySummary);

      if (success) {
        _logger.info('✅ Successfully reported health summary.');
        // Mark success for all types that were fetched
        for (var entry in newlyFetchedData.entries) {
          await healthService.markReportSuccess(entry.key, entry.value);
        }
      } else {
        _logger.warning(
            '❌ Failed to report health summary to server, will retry next time');
      }
    } catch (e, stackTrace) {
      _logger.severe(
          '❌ Failed to check and report health data: $e', e, stackTrace);
    }
  }

  @override
  void dispose() {
    DemoService.instance.removeListener(_onDemoChanged);
    WidgetsBinding.instance.removeObserver(this);
    _memoryButtonTapTimer?.cancel();
    _knowledgeBaseButtonTapTimer?.cancel();
    _shareIntentHandler.dispose();
    _eventBus.removeHandler(
        EventBusMessageType.invalidModelConfig, _handleInvalidModelConfig);
    _eventBus.removeHandler(
        EventBusMessageType.errorNotification, _handleErrorNotification);
    // Note: do not disconnect event bus here; other screens may still use it
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Check if speech model is downloaded
      if (!await WhisperService.instance.isModelDownloaded()) {
        setState(() => _isRadialMenuOpen = false);
        if (!mounted) return;
        _showSpeechModelDownloadDialog();
        return;
      }

      if (await Permission.microphone.request().isGranted) {
        // Initialize streaming transcriber
        _quickTranscribedText = '';
        _quickPcmBuffer.clear();
        _quickTranscriber = StreamingTranscriber(
          onTextChanged: (fullText) {
            _quickTranscribedText = fullText;
            if (mounted) setState(() {});
          },
        );
        await _quickTranscriber!.init();

        // Start streaming PCM recording
        final audioStream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        _quickAudioSub = audioStream.listen((chunk) {
          _quickPcmBuffer.addAll(chunk);
          _quickTranscriber?.addAudioChunk(chunk);
        });

        _recordingPath = 'streaming'; // marker that recording is active
      }
    } catch (e) {
      _logger.severe('Error starting recording: $e', e);
    }
  }

  void _showSpeechModelDownloadDialog() {
    final sizeMB = WhisperService.modelSizeMB.toInt();

    // CN flavor: single download button
    if (AppFlavor.isCN) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(UserStorage.l10n.speechModelDownloadTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(UserStorage.l10n.speechModelDownloadDesc(sizeMB)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _downloadSpeechModel(useChineseMirror: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(UserStorage.l10n.speechModelStartDownload),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(UserStorage.l10n.cancel),
            ),
          ],
        ),
      );
      return;
    }

    // Global flavor: two source options
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.speechModelDownloadTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UserStorage.l10n.speechModelDownloadDesc(sizeMB)),
            const SizedBox(height: 20),
            Text(
              UserStorage.l10n.speechModelChooseSource,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadSpeechModel(useChineseMirror: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(UserStorage.l10n.speechModelChinaMirror),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadSpeechModel(useChineseMirror: false);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(UserStorage.l10n.speechModelGithub),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(UserStorage.l10n.cancel),
          ),
        ],
      ),
    );
  }

  double _speechDownloadProgress = 0;
  StateSetter? _speechDownloadSetState;

  Future<void> _downloadSpeechModel({required bool useChineseMirror}) async {
    final l10n = UserStorage.l10n;
    _speechDownloadProgress = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          _speechDownloadSetState = setDialogState;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(l10n.speechModelDownloading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: _speechDownloadProgress > 0
                      ? _speechDownloadProgress
                      : null,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _speechDownloadProgress > 0
                      ? '${(_speechDownloadProgress * 100).toInt()}%'
                      : l10n.speechModelConnecting,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await WhisperService.instance.downloadModel(
        useChineseMirror: useChineseMirror,
        onProgress: (p) {
          _speechDownloadSetState?.call(() {
            _speechDownloadProgress = p;
          });
        },
      );
    } catch (e) {
      _logger.severe('Speech model download failed: $e');
    } finally {
      _speechDownloadProgress = 0;
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    try {
      await _quickAudioSub?.cancel();
      _quickAudioSub = null;
      await _audioRecorder.stop();

      _quickTranscriber?.dispose();
      _quickTranscriber = null;

      if (cancel) {
        _quickPcmBuffer.clear();
        _quickTranscribedText = '';
        _recordingPath = null;
        return;
      }

      // Final calibration from accumulated PCM
      if (_quickPcmBuffer.isNotEmpty) {
        final aligned = Uint8List.fromList(_quickPcmBuffer);
        final int16Data = Int16List.view(aligned.buffer);
        final samples = Float32List(int16Data.length);
        for (int i = 0; i < int16Data.length; i++) {
          samples[i] = int16Data[i] / 32768.0;
        }
        final calibrated =
            await WhisperService.instance.transcribeSamples(samples);
        if (calibrated != null && calibrated.isNotEmpty) {
          _quickTranscribedText = calibrated;
        }
        _quickPcmBuffer.clear();
      }
    } catch (e) {
      _logger.severe('Error stopping recording: $e', e);
    }
  }

  void _handleShortcutSelect(ShortcutItem? item) async {
    final hasRecording = _recordingPath != null;

    if (item != null) {
      if (mounted) setState(() => _isRadialMenuOpen = false);
      _handleInputSubmit(InputData(text: item.content));
    } else if (hasRecording) {
      // Show calibrating state — keep menu open
      if (mounted) setState(() => _isQuickCalibrating = true);

      await _stopRecording(cancel: false);

      // Now dismiss and submit
      if (mounted) {
        setState(() {
          _isRadialMenuOpen = false;
          _isQuickCalibrating = false;
        });
      }
      if (_quickTranscribedText.isNotEmpty) {
        _handleInputSubmit(InputData(text: _quickTranscribedText));
      }
      _quickTranscribedText = '';
      _recordingPath = null;
    } else {
      if (mounted) setState(() => _isRadialMenuOpen = false);
    }
  }

  void _handleRadialCancel() async {
    await _stopRecording(cancel: true);
    if (mounted) {
      setState(() => _isRadialMenuOpen = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // when app enters foreground, ensure event bus is connected
    if (state == AppLifecycleState.resumed) {
      if (!_eventBus.isConnected) {
        _eventBus.connect();
      }
    }
  }

  Future<void> _handleInputSubmit(InputData data) async {
    // During demo: advance tapSend → tapCard first, so the overlay
    // immediately shows a blocking scrim (cardReady is still false).
    DemoService.instance.tryAdvance(DemoStep.tapSend);

    // Close input sheet immediately
    if (mounted) {
      setState(() {
        _isInputOpen = false;
        _sharedDraft = null;
      });
    }

    // Show loading in timeline
    if (mounted) context.read<TimelineViewModel>().setSubmitting(true);

    try {
      // Call API
      final response = await _memexRouter.submitInput(
        text: data.text,
        images: data.images,
        audioPath: data.audioPath,
        textHash: data.textHash,
        imageHashes: data.imageHashes,
        audioHash: data.audioHash,
      );

      // Parse response and add card to timeline
      if (response.containsKey('card')) {
        final card = TimelineCardModel.fromJson(response['card']);

        // Add card to timeline
        if (mounted) context.read<TimelineViewModel>().addCard(card);

        // update last publish timestamp
        await PublishTimestampService.saveLastPublishTimestamp(
          DateTime.now().millisecondsSinceEpoch,
        );

        // During demo: write preset completed card with insight/comment
        if (DemoService.instance.isActive) {
          final userId = await UserStorage.getUserId();
          if (userId != null) {
            DemoService.instance.handleDemoSubmit(
              userId,
              response['fact_id'] as String,
              data.text ?? '',
            );
          }
        }
      }

      // Show success message
      if (mounted) {
        ToastHelper.showSuccess(
            context, UserStorage.l10n.recordSubmittedAiProcessing);
      }

      // Refresh auto-input count after manual input
      // since the manual input might have consumed items that were pending auto-publish.
    } catch (e) {
      // Hide loading on error
      if (mounted) context.read<TimelineViewModel>().setSubmitting(false);

      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            key: _mainStackKey,
            children: [
              // Main content wrapped in SafeArea
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: _currentTab,
                        children: [
                          TimelineScreen(
                            key: _timelineKey,
                            viewModel: context.watch<TimelineViewModel>(),
                            insightViewModel: context.watch<InsightViewModel>(),
                            onInputTap: () {
                              setState(() {
                                _isInputOpen = true;
                              });
                            },
                          ),
                          KnowledgeBaseScreen(
                            key: _knowledgeBaseKey,
                            viewModel: context.watch<KnowledgeBaseViewModel>(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floating bottom bar overlay
              _buildBottomBar(),

              Positioned(
                bottom: 164,
                left: 0,
                right: 0,
                child: Center(
                  child: AgentActivityWidget(navigatorKey: null),
                ),
              ),

              // Input sheet
              InputSheet(
                isOpen: _isInputOpen,
                initialData: _sharedDraft,
                onClose: () {
                  setState(() {
                    _isInputOpen = false;
                    _sharedDraft = null;
                  });
                },
                onSubmit: _handleInputSubmit,
              ),

              if (_isRadialMenuOpen)
                RadialMenu(
                  key: _radialMenuKey,
                  items: _shortcuts,
                  center: _centerButtonCenter,
                  visible: _isRadialMenuOpen,
                  onItemSelected: _handleShortcutSelect,
                  onCancel: _handleRadialCancel,
                  transcriptText: _quickTranscribedText.isNotEmpty
                      ? _quickTranscribedText
                      : null,
                  isCalibrating: _isQuickCalibrating,
                ),

              // Onboarding demo overlay
              const DemoOverlay(),
            ],
          ),
        ));
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The 393x120.5 Figma Canvas scaled flawlessly to screen width
          FittedBox(
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 393,
              // PNG bounding box height: 120.5 (includes 20px top shadow + 80.5px white shape)
              height: 120.5,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Painted Native Vector Overlay
                  // Completely removing dependencies on Figma PNG/SVG transparent paddings!
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NavBarPainter(),
                    ),
                  ),

                  // Shadow occluder mask
                  // The Figma export's shadow has a giant blur that leaks downward.
                  // Placed OVER the image at exactly y=100.0 (where the white shape ends)
                  // It completely masks out the grey blur and extends solidly into the Safe Area.
                  Positioned(
                    top: 100.0,
                    bottom: -100.0,
                    left: 0,
                    right: 0,
                    child: Container(color: Colors.white),
                  ),

                  // Center Action Button (88x88 widget, 68x68 nested circle)
                  // Dialed down to -16.0 for a more subdued hover gap.
                  Positioned(
                    top: -16.0,
                    left: 156.0,
                    child: AICoreButton(
                      key: DemoService.instance.isActive
                          ? DemoService.instance.addButtonKey
                          : _aiButtonKey,
                      onTap: () {
                        // Advance first so _handleAICoreButtonTap sees tapSend step for prefill
                        DemoService.instance.tryAdvance(DemoStep.tapAddButton);
                        _handleAICoreButtonTap();
                      },
                      onLongPress: _handleAICoreButtonLongPressStart,
                      onLongPressMoveUpdate:
                          _handleAICoreButtonLongPressMoveUpdate,
                      onLongPressEnd: _handleAICoreButtonLongPressEnd,
                    ),
                  ),

                  // Timeline Icon
                  Positioned(
                    top: 46.63, // 26.63 local + 20px shadow
                    left: 64.17,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleTimelineTabTap,
                      child: SvgPicture.asset(
                        'assets/icons/tab_timeline_active.svg',
                        width: 22,
                        height: 23,
                        colorFilter: ColorFilter.mode(
                          _currentTab == 0
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFF99A1AF),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  // Timeline Text
                  Positioned(
                    top: 76.0,
                    left: 25.17,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleTimelineTabTap,
                      child: SizedBox(
                        width:
                            100, // Widened from strict 58 to permit iOS text expansion
                        // Removed strict height boundary to prevent vertical ascender clipping
                        child: Text(
                          UserStorage.l10n.bottomNavTimeline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _currentTab == 0
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFF99A1AF),
                            letterSpacing: 0.14,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Library — single widget for both icon + text so the
                  // demo spotlight key covers the whole tab area.
                  Positioned(
                    top: 47.02,
                    left: 299.58,
                    child: GestureDetector(
                      key: DemoService.instance.knowledgeTabKey,
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _handleLibraryTabTap();
                        DemoService.instance
                            .tryAdvance(DemoStep.tapKnowledgeTab);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/tab_library_inactive.svg',
                            width: 25.06,
                            height: 21.15,
                            colorFilter: ColorFilter.mode(
                              _currentTab == 1
                                  ? const Color(0xFF1F1F1F)
                                  : const Color(0xFF99A1AF),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: 76.0 - 47.02 - 21.15),
                          Text(
                            UserStorage.l10n.bottomNavLibrary,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: _currentTab == 1
                                  ? const Color(0xFF1F1F1F)
                                  : const Color(0xFF99A1AF),
                              letterSpacing: 0.14,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTimelineTabTap() {
    _memoryButtonTapCount++;
    if (_memoryButtonTapCount == 1) {
      setState(() => _currentTab = 0);
      _memoryButtonTapTimer?.cancel();
      _memoryButtonTapTimer = Timer(const Duration(milliseconds: 300), () {
        _memoryButtonTapCount = 0;
      });
    } else if (_memoryButtonTapCount == 2) {
      _memoryButtonTapTimer?.cancel();
      _memoryButtonTapCount = 0;
      if (_currentTab == 0) {
        _timelineKey.currentState?.scrollToTopAndRefresh();
      }
    }
  }

  void _handleLibraryTabTap() {
    _knowledgeBaseButtonTapCount++;
    if (_knowledgeBaseButtonTapCount == 1) {
      setState(() => _currentTab = 1);
      _knowledgeBaseButtonTapTimer?.cancel();
      _knowledgeBaseButtonTapTimer =
          Timer(const Duration(milliseconds: 300), () {
        _knowledgeBaseButtonTapCount = 0;
      });
    } else if (_knowledgeBaseButtonTapCount == 2) {
      _knowledgeBaseButtonTapTimer?.cancel();
      _knowledgeBaseButtonTapCount = 0;
      if (_currentTab == 1) {
        _knowledgeBaseKey.currentState?.scrollToTopAndRefresh();
      }
    }
  }
}

class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, 20);
    path.lineTo(142.528, 20);
    path.cubicTo(148.501, 20, 153.977, 23.3275, 156.729, 28.6293);
    path.lineTo(164.497, 43.5965);
    path.cubicTo(179.426, 72.3609, 220.574, 72.3609, 235.503, 43.5966);
    path.lineTo(243.271, 28.6293);
    path.cubicTo(246.023, 23.3275, 251.499, 20, 257.472, 20);
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    path.close();

    // Custom drop shadow that doesn't bleed weirdly
    // We clip the bottom so the shadow never goes below the nav bar visually
    canvas.save();
    canvas
        .clipRect(Rect.fromLTWH(-50, -50, size.width + 100, size.height + 50));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

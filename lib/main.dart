import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:memex/config/dependencies.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/ui/knowledge/widgets/knowledge_base_screen.dart';
import 'package:memex/ui/user_setup/widgets/user_setup_screen.dart';
import 'package:memex/ui/app_lock/widgets/lock_screen_page.dart';
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
import 'package:memex/ui/core/widgets/coach_mark_overlay.dart';
import 'package:memex/ui/main_screen/widgets/share_intent_handler.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLogger();

  // Initialize l10n
  await UserStorage.initL10n();

  // Initialize Workmanager (for background tasks)
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

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

  final appRouter = createAppRouter(rootNavigatorKey, () => const RootShell());
  runApp(MultiProvider(
    providers: dependencyProviders,
    child: MemexApp(router: appRouter),
  ));
}

/// Root route content: user check then loading / UserSetupScreen / MainScreen (Compass-style).
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  bool _hasUser = false;
  bool _onboardingComplete = false;
  bool _isChecking = true;

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

  void _onUserCreated() {
    OnboardingService.markOnboardingComplete();
    setState(() {
      _hasUser = true;
      _onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasUser || !_onboardingComplete) {
      return UserSetupScreen(onUserCreated: _onUserCreated);
    }
    return MultiProvider(
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
  Offset _centerButtonCenter = Offset.zero;
  final GlobalKey<RadialMenuState> _radialMenuKey =
      GlobalKey<RadialMenuState>();
  final GlobalKey _aiButtonKey = GlobalKey();
  final GlobalKey _mainStackKey = GlobalKey();
  bool _isInvalidConfigDialogShowing = false;
  bool _showFirstPostCoachMark = false;
  late final ShareIntentHandler _shareIntentHandler;
  InputData? _sharedDraft;

  // Agent Button Position - REMOVED (Moved to Main App)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Init event bus connection and local DB (delay to ensure token is loaded)
    Future.delayed(const Duration(seconds: 1), () async {
      final userId = await UserStorage.getUserId();
      if (userId != null && !AppDatabase.isInitialized) {
        await AppDatabase.init(userId);
      }
      _eventBus.connect();
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

    // Check onboarding state for first post coach mark
    _checkFirstPostOnboarding();
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

  Future<void> _handleAICoreButtonTap() async {
    // Check if model is configured before opening input
    final configs = await UserStorage.getLLMConfigs();
    final hasValidConfig = configs.any((c) => c.isValid);
    if (!hasValidConfig && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(UserStorage.l10n.configureNow),
          content: Text(UserStorage.l10n.modelNotConfiguredBanner),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(UserStorage.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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
      );
      return;
    }

    // Skip auto-publish, go directly to input_sheet
    if (mounted) {
      setState(() {
        _isInputOpen = true;
      });
    }
    // Dismiss coach mark if showing
    if (_showFirstPostCoachMark) {
      _dismissFirstPostCoachMark();
    }
  }

  Future<void> _checkFirstPostOnboarding() async {
    // Check first post onboarding
    final done = await OnboardingService.isFirstPostDone();
    if (!done && mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _showFirstPostCoachMark = true);
    }
  }

  void _dismissFirstPostCoachMark() {
    setState(() => _showFirstPostCoachMark = false);
    OnboardingService.markFirstPostDone();
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
      final healthService = HealthService();
      Map<String, Map<String, dynamic>> dailySummary = {};

      final typesToCheck = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.BLOOD_GLUCOSE,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.WEIGHT,
        HealthDataType.WORKOUT,
      ];

      // Skip health data collection if fitness permission is not granted
      // (permissions are now requested via System Authorization page)
      final fitnessStatus = Platform.isIOS
          ? await Permission.sensors.status
          : await Permission.activityRecognition.status;
      if (!fitnessStatus.isGranted && !fitnessStatus.isLimited) {
        _logger.info(
            'Fitness permission not granted, skipping health data collection');
        return;
      }

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
    WidgetsBinding.instance.removeObserver(this);
    _memoryButtonTapTimer?.cancel();
    _knowledgeBaseButtonTapTimer?.cancel();
    _shareIntentHandler.dispose();
    _eventBus.removeHandler(
        EventBusMessageType.invalidModelConfig, _handleInvalidModelConfig);
    // Note: do not disconnect event bus here; other screens may still use it
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        _recordingPath = path;
      }
    } catch (e) {
      _logger.severe('Error starting recording: $e', e);
    }
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    try {
      final path = await _audioRecorder.stop();
      if (cancel && path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
        _recordingPath = null;
      }
    } catch (e) {
      _logger.severe('Error stopping recording: $e', e);
    }
  }

  void _handleShortcutSelect(ShortcutItem? item) async {
    // In the new simplified radial menu, item will be null for "Release to Send"
    final path = _recordingPath;

    if (mounted) {
      setState(() => _isRadialMenuOpen = false);
    }

    if (item != null) {
      // This path is for legacy shortcuts if they ever return
      _handleInputSubmit(InputData(text: item.content));
    } else if (path != null) {
      // Audio selected (released elsewhere)
      await _stopRecording(cancel: false);
      _handleInputSubmit(InputData(audioPath: path));
      _recordingPath = null;
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
    // Close input sheet immediately
    if (mounted) {
      setState(() {
        _isInputOpen = false;
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
                bottom: 134,
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
                ),

              // First post onboarding coach mark
              if (_showFirstPostCoachMark)
                CoachMarkOverlay(
                  targetKey: _aiButtonKey,
                  message: UserStorage.l10n.coachMarkFirstPost,
                  onDismiss: _dismissFirstPostCoachMark,
                ),
            ],
          ),
        ));
  }

  Widget _buildBottomBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barBottom = bottomPadding > 0 ? bottomPadding + 8.0 : 24.0;
    return Positioned(
      bottom: barBottom,
      left: 24,
      right: 24,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // background layer (frosted glass and side icons)
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMemoryTabButton(),
                      // space for raised center button
                      const SizedBox(width: 64),
                      _buildKnowledgeTabButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // floating AI button on top (allow glow overflow and raise)
          Positioned(
            top: -24, // float above
            child: AICoreButton(
              key: _aiButtonKey,
              onTap: _handleAICoreButtonTap,
              onLongPress: _handleAICoreButtonLongPressStart,
              onLongPressMoveUpdate: _handleAICoreButtonLongPressMoveUpdate,
              onLongPressEnd: _handleAICoreButtonLongPressEnd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryTabButton() {
    final isActive = _currentTab == 0;
    final activeColor = const Color(0xFF6366F1);
    final inactiveColor = const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: () {
        _memoryButtonTapCount++;
        if (_memoryButtonTapCount == 1) {
          setState(() {
            _currentTab = 0;
          });
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
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              'Timeline',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeTabButton() {
    final isActive = _currentTab == 1;
    final activeColor = const Color(0xFF6366F1);
    final inactiveColor = const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: () {
        _knowledgeBaseButtonTapCount++;
        if (_knowledgeBaseButtonTapCount == 1) {
          setState(() {
            _currentTab = 1;
          });
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
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              'Library',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

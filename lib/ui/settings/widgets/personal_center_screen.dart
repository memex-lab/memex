import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:memex/routing/routes.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/ui/settings/widgets/system_authorization_page.dart';
import 'package:memex/ui/settings/widgets/debug_settings_page.dart';
import 'package:memex/ui/settings/widgets/settings_page.dart';
import 'package:memex/utils/permission_utils.dart';
import 'package:memex/ui/core/widgets/avatar_picker.dart';

/// Personal center screen
class PersonalCenterScreen extends StatefulWidget {
  const PersonalCenterScreen({super.key});

  @override
  State<PersonalCenterScreen> createState() => _PersonalCenterScreenState();
}

class _PersonalCenterScreenState extends State<PersonalCenterScreen> {
  final MemexRouter _memexRouter = MemexRouter();
  final Logger _logger = getLogger('PersonalCenterScreen');
  String? _userId;
  String? _userEmail;

  bool _isReprocessingCards = false;
  bool _isReprocessingComments = false;
  bool _showAuthBadge = false;
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkPermissionBadge();
  }

  Future<void> _checkPermissionBadge() async {
    final granted = await PermissionUtils.isFitnessPermissionGranted();
    if (mounted) {
      setState(() => _showAuthBadge = !granted);
    }
  }

  Future<void> _loadUserInfo() async {
    final userId = await UserStorage.getUserId();
    final avatar = await UserStorage.getUserAvatar();
    if (mounted) {
      setState(() {
        _userId = userId ?? UserStorage.l10n.notSet;
        _userEmail = userId != null ? '$userId@memex.local' : null;
        _userAvatar = avatar;
      });
    }
  }

  Future<void> _changeAvatar() async {
    final picked = await showAvatarPicker(context, _userAvatar ?? '👤');
    if (picked != null && mounted) {
      await UserStorage.saveUserAvatar(picked);
      setState(() => _userAvatar = picked);
    }
  }

  Future<void> _clearToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.confirmClear),
        content: Text(UserStorage.l10n.confirmClearTokenMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(UserStorage.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await UserStorage.clearUser();
        // Reset user-related globals so next login re-inits (DB, router, task executor).
        _memexRouter.resetForLogout();
        if (mounted) {
          ToastHelper.showSuccessWithKey(
              _scaffoldMessengerKey, UserStorage.l10n.tokenCleared);
          // navigate to setup screen
          context.go(AppRoutes.userSetup);
        }
      } catch (e) {
        if (mounted) {
          ToastHelper.showErrorWithKey(_scaffoldMessengerKey,
              UserStorage.l10n.clearTokenFailed(e.toString()));
        }
      }
    }
  }

  Future<void> _reprocessCards() async {
    if (_isReprocessingCards) return;

    // show dialog for user to choose params
    DateTime? dateFrom;
    DateTime? dateTo;
    int? limit;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(UserStorage.l10n.reprocessCards),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UserStorage.l10n.selectDateRangeOptional),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(UserStorage.l10n.startDate),
                  trailing: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dateFrom = date;
                        });
                      }
                    },
                    child: Text(dateFrom == null
                        ? UserStorage.l10n.select
                        : '${dateFrom!.year}-${dateFrom!.month.toString().padLeft(2, '0')}-${dateFrom!.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                ListTile(
                  title: Text(UserStorage.l10n.endDate),
                  trailing: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateTo ?? DateTime.now(),
                        firstDate: dateFrom ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dateTo = date;
                        });
                      }
                    },
                    child: Text(dateTo == null
                        ? UserStorage.l10n.select
                        : '${dateTo!.year}-${dateTo!.month.toString().padLeft(2, '0')}-${dateTo!.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.processLimitOptional,
                    hintText: UserStorage.l10n.leaveEmptyForAll,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    limit = int.tryParse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(UserStorage.l10n.startProcessing),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isReprocessingCards = true;
    });

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        if (mounted) {
          setState(() {
            _isReprocessingCards = false;
          });
          ToastHelper.showErrorWithKey(
              _scaffoldMessengerKey, UserStorage.l10n.userIdNotFound);
        }
        return;
      }

      // build payload
      final payload = <String, dynamic>{};
      final dateFromValue = dateFrom;
      if (dateFromValue != null) {
        payload['date_from'] = dateFromValue.toIso8601String().substring(0, 10);
      }
      final dateToValue = dateTo;
      if (dateToValue != null) {
        payload['date_to'] = dateToValue.toIso8601String().substring(0, 10);
      }
      final limitValue = limit;
      if (limitValue != null && limitValue > 0) {
        payload['limit'] = limitValue;
      }

      // enqueue task
      await _memexRouter.enqueueTask(
        taskType: 'reprocess_cards_task',
        payload: payload,
        bizId: 'reprocess_cards_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        setState(() {
          _isReprocessingCards = false;
        });
        ToastHelper.showSuccessWithKey(
          _scaffoldMessengerKey,
          UserStorage.l10n.reprocessCardsTaskCreated,
        );
      }
    } catch (e) {
      _logger.severe('Error reprocessing cards: $e', e);
      if (mounted) {
        setState(() {
          _isReprocessingCards = false;
        });
        ToastHelper.showErrorWithKey(
            _scaffoldMessengerKey, UserStorage.l10n.createTaskFailed(e));
      }
    }
  }

  Future<void> _reprocessComments() async {
    if (_isReprocessingComments) return;

    // show dialog for user to choose params
    DateTime? dateFrom;
    DateTime? dateTo;
    int? limit;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(UserStorage.l10n.regenerateComments),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(UserStorage.l10n.selectDateRangeOptional),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(UserStorage.l10n.startDate),
                  trailing: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dateFrom = date;
                        });
                      }
                    },
                    child: Text(dateFrom == null
                        ? UserStorage.l10n.select
                        : '${dateFrom!.year}-${dateFrom!.month.toString().padLeft(2, '0')}-${dateFrom!.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                ListTile(
                  title: Text(UserStorage.l10n.endDate),
                  trailing: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dateTo ?? DateTime.now(),
                        firstDate: dateFrom ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setDialogState(() {
                          dateTo = date;
                        });
                      }
                    },
                    child: Text(dateTo == null
                        ? UserStorage.l10n.select
                        : '${dateTo!.year}-${dateTo!.month.toString().padLeft(2, '0')}-${dateTo!.day.toString().padLeft(2, '0')}'),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.processLimitOptional,
                    hintText: UserStorage.l10n.leaveEmptyForAll,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    limit = int.tryParse(value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(UserStorage.l10n.startProcessing),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isReprocessingComments = true;
    });

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        if (mounted) {
          setState(() {
            _isReprocessingComments = false;
          });
          ToastHelper.showErrorWithKey(
              _scaffoldMessengerKey, UserStorage.l10n.userIdNotFound);
        }
        return;
      }

      // build payload
      final payload = <String, dynamic>{};
      final dateFromValue = dateFrom;
      if (dateFromValue != null) {
        payload['date_from'] = dateFromValue.toIso8601String().substring(0, 10);
      }
      final dateToValue = dateTo;
      if (dateToValue != null) {
        payload['date_to'] = dateToValue.toIso8601String().substring(0, 10);
      }
      final limitValue = limit;
      if (limitValue != null && limitValue > 0) {
        payload['limit'] = limitValue;
      }

      // enqueue task
      await _memexRouter.enqueueTask(
        taskType: 'reprocess_comments_task',
        payload: payload,
        bizId: 'reprocess_comments_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        setState(() {
          _isReprocessingComments = false;
        });
        ToastHelper.showSuccessWithKey(
          _scaffoldMessengerKey,
          UserStorage.l10n.regenerateCommentsTaskCreated,
        );
      }
    } catch (e) {
      _logger.severe('Error reprocessing comments: $e', e);
      if (mounted) {
        setState(() {
          _isReprocessingComments = false;
        });
        ToastHelper.showErrorWithKey(
            _scaffoldMessengerKey, UserStorage.l10n.createTaskFailed(e));
      }
    }
  }

  bool _isClearingData = false;

  Future<void> _clearData() async {
    if (_isClearingData) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.clearData),
        content: Text(
          '${UserStorage.l10n.confirmClearDataMessage}\n'
          '${UserStorage.l10n.confirmClearDataKeepFactsMessage}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(UserStorage.l10n.confirmClear),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearingData = true;
    });

    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        throw Exception(UserStorage.l10n.userIdNotFound);
      }

      // use MemexRouter to clear all data
      await _memexRouter.clearData();

      // Clear cached agent data
      await UserStorage.saveCachedAgentData('pkm', null);
      await UserStorage.saveCachedAgentData('card', null);

      if (mounted) {
        ToastHelper.showSuccessWithKey(
            _scaffoldMessengerKey, UserStorage.l10n.dataClearedSuccess);
      }
    } catch (e, stack) {
      _logger.severe('Clear data failed: $e', e, stack);
      if (mounted) {
        ToastHelper.showErrorWithKey(
            _scaffoldMessengerKey, UserStorage.l10n.clearDataFailed(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearingData = false;
        });
      }
    }
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            UserStorage.l10n.personalCenter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // User Profile Section
                    Column(
                      children: [
                        // Avatar (tappable to change)
                        GestureDetector(
                          onTap: _changeAvatar,
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _userAvatar ?? '👤',
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFF8FAFC),
                                        width: 2),
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          _userId ?? UserStorage.l10n.notSet,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // User Email
                        if (_userEmail != null)
                          Text(
                            _userEmail!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Functional Tabs
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildFunctionTab(
                            icon: Icons.security_outlined,
                            title: UserStorage.l10n.systemAuthorization,
                            showBadge: _showAuthBadge,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SystemAuthorizationPage(),
                                ),
                              ).then((_) => _checkPermissionBadge());
                            },
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.settings_input_component_outlined,
                            title: UserStorage.l10n.modelConfig,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ModelConfigListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.people_outline,
                            title: UserStorage.l10n.agentConfig,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AgentConfigListPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.memory,
                            title: UserStorage.l10n.memoryTitle,
                            onTap: () => context.push(AppRoutes.memory),
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.psychology,
                            title: UserStorage.l10n.aiCharacterConfig,
                            onTap: () =>
                                context.push(AppRoutes.characterConfig),
                            isLoading: false,
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.settings_outlined,
                            title: UserStorage.l10n.settings,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              ).then((_) {
                                if (mounted) setState(() {});
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.bug_report_outlined,
                            title: 'Debugging',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DebugSettingsPage(
                                    onClearToken: () async => _clearToken(),
                                    onClearData: () async => _clearData(),
                                    onReprocessCards: () async =>
                                        _reprocessCards(),
                                    onReprocessComments: () async =>
                                        _reprocessComments(),
                                    isClearingData: _isClearingData,
                                    isReprocessingCards: _isReprocessingCards,
                                    isReprocessingComments:
                                        _isReprocessingComments,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFunctionTab({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLoading = false,
    bool showBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF6366F1),
                    size: 24,
                  ),
                  if (showBadge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isLoading ? Colors.grey[400] : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

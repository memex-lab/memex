import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memex/routing/routes.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/system_authorization_page.dart';
import 'package:memex/ui/settings/widgets/debug_settings_screen.dart';
import 'package:memex/ui/settings/widgets/settings_page.dart';
import 'package:memex/ui/settings/widgets/settings_search_screen.dart';
import 'package:memex/ui/settings/view_models/settings_search_viewmodel.dart';
import 'package:memex/ui/settings/widgets/experimental_lab_page.dart';
import 'package:memex/utils/permission_utils.dart';
import 'package:memex/ui/core/widgets/avatar_picker.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/data/services/media_service.dart';

/// Personal center screen
class PersonalCenterScreen extends StatefulWidget {
  const PersonalCenterScreen({super.key});

  @override
  State<PersonalCenterScreen> createState() => _PersonalCenterScreenState();
}

class _PersonalCenterScreenState extends State<PersonalCenterScreen> {
  final MemexRouter _memexRouter = MemexRouter();
  String? _userId;
  String? _userEmail;

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
    final avatar = await _memexRouter.getUserAvatar();
    if (mounted) {
      setState(() {
        _userId = userId ?? UserStorage.l10n.notSet;
        _userEmail = userId != null ? '$userId@memex.local' : null;
        _userAvatar = avatar;
      });
    }
  }

  Future<void> _changeAvatar() async {
    final picked = await showAvatarPicker(
      context,
      _userAvatar ?? UserStorage.defaultAvatarSeed,
      onPickGallery: _pickUserAvatarFromGallery,
    );
    if (picked != null && mounted) {
      await _memexRouter.updateUserAvatar(picked);
      final resolvedAvatar = await _memexRouter.getUserAvatar();
      if (!mounted) return;
      setState(() => _userAvatar = resolvedAvatar);
    }
  }

  Future<String?> _pickUserAvatarFromGallery() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return null;

    final pickedPath = await pickAvatarImageFromGallery();
    if (pickedPath == null) return null;

    final imported = await MediaService.instance.importImage(
      userId: userId,
      sourcePath: pickedPath,
    );
    return imported.relativePath;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(20),
                  topEnd: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsSearchScreen(
                                    viewModel: SettingsSearchViewModel(
                                      router: _memexRouter,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: Color(0xFF94A3B8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    UserStorage.l10n.settingsSearchPlaceholder,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: const Color(0xFF64748B),
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
                                child: CharacterAvatar(
                                  avatar: _userAvatar ??
                                      UserStorage.defaultAvatarSeed,
                                  name: _userId ?? '',
                                  size: 80,
                                ),
                              ),
                              PositionedDirectional(
                                end: 0,
                                bottom: 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF7F8FA),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 13,
                                    color: Colors.white,
                                  ),
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
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
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
                          _buildFunctionTab(
                            icon: Icons.auto_awesome_rounded,
                            title: UserStorage.l10n.aiModelHubTitle,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AiServiceSetupPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildFunctionTab(
                            icon: Icons.science_outlined,
                            title: UserStorage.l10n.experimentalLab,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ExperimentalLabPage(router: _memexRouter),
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
                                  builder: (context) =>
                                      DebugSettingsScreen.forRouter(
                                    router: _memexRouter,
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
                color: const Color(0xFF64748B).withValues(alpha: 0.08),
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
                  Icon(icon, color: const Color(0xFF6366F1), size: 24),
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
                    color: isLoading
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

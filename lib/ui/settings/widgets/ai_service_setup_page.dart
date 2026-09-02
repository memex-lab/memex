import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memex/config/app_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/view_models/ai_service_setup_viewmodel.dart';
import 'package:memex/ui/settings/widgets/memex_auth_section.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

class AiServiceSetupPage extends StatefulWidget {
  const AiServiceSetupPage({
    super.key,
    this.onComplete,
    this.onboardingMode = false,
    this.viewModel,
  });

  final VoidCallback? onComplete;
  final bool onboardingMode;
  final AiServiceSetupViewModel? viewModel;

  @override
  State<AiServiceSetupPage> createState() => _AiServiceSetupPageState();
}

class _AiServiceSetupPageState extends State<AiServiceSetupPage> {
  late final AiServiceSetupViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? AiServiceSetupViewModel(router: MemexRouter());
    unawaited(_viewModel.loadModelRoles(showLoading: _ownsViewModel));
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _openOfficialService() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MemexOfficialServicePage(
          viewModel: _viewModel,
          onboardingMode: widget.onboardingMode,
          onComplete: _completeSetup,
        ),
      ),
    );
    if (mounted) {
      await _viewModel.loadModelRoles(showLoading: false);
    }
  }

  Future<void> _openCustomService() async {
    final validCustomConfigs = _viewModel.llmConfigs
        .where(
          (config) => config.type != LLMConfig.typeMemex && config.isValid,
        )
        .toList();
    final savedConfigKey = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelConfigListPage(
          autoOpenFirstConfig: true,
          simpleSetupMode: true,
          popOnConfigSaved:
              widget.onboardingMode || validCustomConfigs.length <= 1,
        ),
      ),
    );
    if (!mounted) return;

    await _viewModel.loadModelRoles(showLoading: false);
    if (savedConfigKey != null) {
      await _viewModel.setTextModel(savedConfigKey);
      if (widget.onboardingMode && mounted) {
        _completeSetup();
      }
    }
  }

  void _completeSetup() {
    widget.onComplete?.call();
    if (widget.onComplete == null && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _skip() {
    widget.onComplete?.call();
    if (widget.onComplete == null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return _AiServicePageScaffold(
          title: widget.onboardingMode ? null : l10n.aiModelHubTitle,
          automaticallyImplyLeading: !widget.onboardingMode,
          actions: [
            if (widget.onboardingMode)
              TextButton(
                onPressed: _viewModel.isSaving ? null : _skip,
                child: Text(l10n.skipForNow),
              ),
          ],
          children: [
            _AiServiceHeader(
              icon: Icons.auto_awesome_rounded,
              title: l10n.aiModelHubTitle,
              description: l10n.aiModelHubSubtitle,
            ),
            const SizedBox(height: 18),
            _buildStatusCard(),
            const SizedBox(height: 18),
            _AiServiceSectionHeader(
              title: l10n.aiSetupChooseConnectionTitle,
              description: l10n.aiSetupChooseConnectionDescription,
            ),
            const SizedBox(height: 12),
            if (AppConfig.enableMemexModelService) ...[
              _AiServiceRouteCard(
                key: const ValueKey('ai-service-official-route-card'),
                icon: Icons.verified_outlined,
                iconColor: AppColors.primary,
                title: l10n.aiServiceMemexRouteTitle,
                description: l10n.aiSetupOfficialRouteDescription,
                onTap: _openOfficialService,
              ),
              const SizedBox(height: 12),
            ],
            _AiServiceRouteCard(
              key: const ValueKey('ai-service-custom-route-card'),
              icon: Icons.key_rounded,
              iconColor: AppColors.success,
              title: l10n.aiServiceCustomApiRouteTitle,
              description: l10n.aiSetupCustomRouteDescription,
              onTap: _openCustomService,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard() {
    final activeConfig = _viewModel.textConfig;
    final connectionMode = _viewModel.connectionMode;
    final hasConfiguredConnection =
        connectionMode != AiServiceConnectionMode.notConfigured;
    return _AiServiceOptionCard(
      icon: Icons.radio_button_checked_rounded,
      iconColor: _statusColor(connectionMode),
      title: UserStorage.l10n.aiSetupCurrentStatusTitle,
      description: connectionMode == AiServiceConnectionMode.memexOfficial
          ? _statusTitle(connectionMode)
          : activeConfig?.isValid == true
              ? activeConfig!.key
              : _statusTitle(connectionMode),
      child: hasConfiguredConnection
          ? const SizedBox.shrink()
          : Text(
              _statusDescription(connectionMode),
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
    );
  }

  Color _statusColor(AiServiceConnectionMode mode) {
    switch (mode) {
      case AiServiceConnectionMode.memexOfficial:
        return AppColors.primary;
      case AiServiceConnectionMode.customProvider:
        return AppColors.success;
      case AiServiceConnectionMode.notConfigured:
        return AppColors.warning;
    }
  }

  String _statusTitle(AiServiceConnectionMode mode) {
    final l10n = UserStorage.l10n;
    switch (mode) {
      case AiServiceConnectionMode.memexOfficial:
        return l10n.aiSetupStatusMemexTitle;
      case AiServiceConnectionMode.customProvider:
        return l10n.aiSetupStatusCustomTitle;
      case AiServiceConnectionMode.notConfigured:
        return l10n.aiSetupStatusNotConfiguredTitle;
    }
  }

  String _statusDescription(AiServiceConnectionMode mode) {
    final l10n = UserStorage.l10n;
    switch (mode) {
      case AiServiceConnectionMode.memexOfficial:
        return l10n.aiSetupStatusMemexDescription;
      case AiServiceConnectionMode.customProvider:
        return l10n.aiSetupStatusCustomDescription;
      case AiServiceConnectionMode.notConfigured:
        return l10n.aiSetupStatusNotConfiguredDescription;
    }
  }
}

class MemexOfficialServicePage extends StatefulWidget {
  const MemexOfficialServicePage({
    super.key,
    this.onComplete,
    this.onboardingMode = false,
    this.viewModel,
  });

  final VoidCallback? onComplete;
  final bool onboardingMode;
  final AiServiceSetupViewModel? viewModel;

  @override
  State<MemexOfficialServicePage> createState() =>
      _MemexOfficialServicePageState();
}

class _MemexOfficialServicePageState extends State<MemexOfficialServicePage> {
  late final AiServiceSetupViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? AiServiceSetupViewModel(router: MemexRouter());
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMemexService({
    bool finish = true,
    bool showToast = true,
  }) async {
    if (!_viewModel.hasReadyCredentials || _viewModel.isSaving) return;
    try {
      final saved = await _viewModel.saveMemexService();
      if (!saved) return;
      if (!mounted) return;
      if (showToast) {
        ToastHelper.showSuccess(context, UserStorage.l10n.aiServiceReadyToast);
      }
      if (!finish) return;
      _finishSetup();
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
  }

  Future<void> _clearMemexService() async {
    try {
      await _viewModel.clearMemexService();
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
  }

  Future<void> _showMemexServiceSetup() async {
    try {
      await _viewModel.showMemexServiceSetup();
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
  }

  void _finishSetup() {
    if (widget.onComplete != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
      widget.onComplete?.call();
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _skip() {
    if (widget.onComplete != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(false);
      }
      widget.onComplete?.call();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return _AiServicePageScaffold(
          title: l10n.aiServiceMemexRouteTitle,
          actions: [
            if (widget.onboardingMode)
              TextButton(
                onPressed: _viewModel.isSaving ? null : _skip,
                child: Text(l10n.skipForNow),
              ),
          ],
          children: [
            _AiServiceHeader(
              icon: Icons.verified_outlined,
              title: l10n.aiServiceMemexRouteTitle,
              description: l10n.aiServiceSettingsDescription,
            ),
            const SizedBox(height: 18),
            _buildMemexServiceCard(),
          ],
        );
      },
    );
  }

  Widget _buildMemexServiceCard() {
    final l10n = UserStorage.l10n;
    return _AiServiceOptionCard(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.primary,
      title: l10n.aiServiceMemexRouteTitle,
      description: l10n.aiServiceSettingsDescription,
      showIntro: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_viewModel.showMemexSetup) ...[
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    (_viewModel.isSaving || _viewModel.isMemexConfigLoading)
                        ? null
                        : _showMemexServiceSetup,
                iconAlignment: IconAlignment.end,
                icon: _viewModel.isMemexConfigLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(l10n.enableAiService),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ] else ...[
            MemexAuthSection(
              topUpConfig: _viewModel.memexTopUpConfig,
              onCredentialsReady: (baseUrl, apiKey, models) {
                _viewModel.setMemexCredentials(baseUrl, apiKey, models);
                unawaited(_saveMemexService(finish: false, showToast: false));
              },
              onLoginStateChanged: (isLoggedIn) {
                _viewModel.setMemexLoginState(isLoggedIn);
              },
              onLogout: _clearMemexService,
            ),
            if (_viewModel.isMemexLoggedIn ||
                _viewModel.hasReadyCredentials ||
                _viewModel.isSaving) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _viewModel.hasReadyCredentials && !_viewModel.isSaving
                          ? _saveMemexService
                          : null,
                  iconAlignment: IconAlignment.end,
                  icon: _viewModel.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 22),
                  label: Text(l10n.setupModelConfigComplete),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFE2E2E5),
                    disabledForegroundColor: AppColors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AiServicePageScaffold extends StatelessWidget {
  const _AiServicePageScaffold({
    required this.children,
    this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
  });

  final String? title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: title == null ? null : Text(title!),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _AiServiceHeader extends StatelessWidget {
  const _AiServiceHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiServiceSectionHeader extends StatelessWidget {
  const _AiServiceSectionHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiServiceRouteCard extends StatelessWidget {
  const _AiServiceRouteCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: _AiServiceOptionCard(
          icon: icon,
          iconColor: iconColor,
          title: title,
          description: description,
          trailing: const Icon(Icons.chevron_right_rounded),
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _AiServiceOptionCard extends StatelessWidget {
  const _AiServiceOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.child,
    this.trailing,
    this.showIntro = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget child;
  final Widget? trailing;
  final bool showIntro;

  @override
  Widget build(BuildContext context) {
    final hasChild = child is! SizedBox || (child as SizedBox).child != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIntro) ...[
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            if (hasChild) const SizedBox(height: 16),
          ],
          if (hasChild) child,
        ],
      ),
    );
  }
}

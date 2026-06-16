import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memex/config/app_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/view_models/ai_service_setup_viewmodel.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/location_context_settings_page.dart';
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
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomAiServiceSetupPage(
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
    return _AiServiceOptionCard(
      icon: Icons.radio_button_checked_rounded,
      iconColor: _statusColor(_viewModel.connectionMode),
      title: UserStorage.l10n.aiSetupCurrentStatusTitle,
      description: _statusTitle(_viewModel.connectionMode),
      child: Text(
        _statusDescription(_viewModel.connectionMode),
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

class CustomAiServiceSetupPage extends StatefulWidget {
  const CustomAiServiceSetupPage({
    super.key,
    this.onComplete,
    this.onboardingMode = false,
    this.viewModel,
  });

  final VoidCallback? onComplete;
  final bool onboardingMode;
  final AiServiceSetupViewModel? viewModel;

  @override
  State<CustomAiServiceSetupPage> createState() =>
      _CustomAiServiceSetupPageState();
}

class _CustomAiServiceSetupPageState extends State<CustomAiServiceSetupPage> {
  static const String _manualMimoSpeechConfigKey = '__manual_mimo_asr__';

  late final AiServiceSetupViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _speechAppIdController;
  late final TextEditingController _speechSecretIdController;
  late final TextEditingController _speechSecretKeyController;
  late final TextEditingController _speechMimoApiKeyController;
  late final TextEditingController _speechMimoBaseUrlController;
  bool _isSyncingSpeechControllers = false;
  SpeechRecognitionConfig? _lastSyncedSpeechConfig;

  @override
  void initState() {
    super.initState();
    _speechAppIdController = TextEditingController();
    _speechSecretIdController = TextEditingController();
    _speechSecretKeyController = TextEditingController();
    _speechMimoApiKeyController = TextEditingController();
    _speechMimoBaseUrlController = TextEditingController();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? AiServiceSetupViewModel(router: MemexRouter());
    _viewModel.addListener(_syncSpeechControllersFromViewModel);
    _syncSpeechControllersFromViewModel();
    unawaited(_viewModel.loadModelRoles(showLoading: _ownsViewModel));
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncSpeechControllersFromViewModel);
    _speechAppIdController.dispose();
    _speechSecretIdController.dispose();
    _speechSecretKeyController.dispose();
    _speechMimoApiKeyController.dispose();
    _speechMimoBaseUrlController.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _syncSpeechControllersFromViewModel() {
    final config = _viewModel.speechRecognitionConfig;
    if (config == _lastSyncedSpeechConfig) return;
    _lastSyncedSpeechConfig = config;
    _isSyncingSpeechControllers = true;
    _speechAppIdController.text = config.tencentCloud.appId;
    _speechSecretIdController.text = config.tencentCloud.secretId;
    _speechSecretKeyController.text = config.tencentCloud.secretKey;
    _speechMimoApiKeyController.text = config.xiaomiMimo.apiKey;
    _speechMimoBaseUrlController.text = config.xiaomiMimo.baseUrl;
    _isSyncingSpeechControllers = false;
  }

  Future<void> _openAdvancedConfig() async {
    final configured = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelConfigListPage(
          popOnConfigSaved: widget.onboardingMode,
          autoOpenFirstConfig: true,
        ),
      ),
    );
    if (mounted) {
      await _viewModel.loadModelRoles(showLoading: false);
    }
    if (configured == true && mounted && widget.onboardingMode) {
      _finishSetup();
    }
  }

  Future<void> _openAdvancedAgentConfig() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const AgentConfigListPage()),
    );
    if (mounted) {
      await _viewModel.loadModelRoles(showLoading: false);
    }
  }

  Future<void> _openLocationSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationContextSettingsPage(),
      ),
    );
  }

  Future<void> _updateTextModel(String? configKey) async {
    if (configKey == null || _viewModel.isUpdatingTextModel) return;
    try {
      await _viewModel.setTextModel(configKey);
      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.modelSlotUpdated);
      }
    } catch (e) {
      if (mounted) ToastHelper.showError(context, e);
    }
  }

  Future<void> _updateVisionModel(String? configKey) async {
    if (configKey == null || _viewModel.isUpdatingVisionModel) return;
    try {
      await _viewModel.setVisionModel(configKey);
      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.modelSlotUpdated);
      }
    } catch (e) {
      if (mounted) ToastHelper.showError(context, e);
    }
  }

  Future<void> _updateSpeechRecognitionProvider(
    SpeechRecognitionProvider provider,
  ) async {
    try {
      await _viewModel.setSpeechRecognitionProvider(provider);
    } catch (e) {
      if (mounted) ToastHelper.showError(context, e);
    }
  }

  Future<void> _persistTencentCloudSpeechConfig({String? engineType}) async {
    if (_isSyncingSpeechControllers) return;
    try {
      await _viewModel.saveTencentCloudSpeechConfig(
        appId: _speechAppIdController.text,
        secretId: _speechSecretIdController.text,
        secretKey: _speechSecretKeyController.text,
        engineType: engineType ??
            _viewModel.speechRecognitionConfig.tencentCloud.engineType,
      );
    } catch (e) {
      if (mounted) ToastHelper.showError(context, e);
    }
  }

  Future<void> _persistXiaomiMimoSpeechConfig({
    String? llmConfigKey,
    String? model,
    String? language,
  }) async {
    if (_isSyncingSpeechControllers) return;
    final config = _viewModel.speechRecognitionConfig.xiaomiMimo;
    try {
      await _viewModel.saveXiaomiMimoSpeechConfig(
        llmConfigKey: llmConfigKey ?? config.llmConfigKey,
        apiKey: _speechMimoApiKeyController.text,
        baseUrl: _speechMimoBaseUrlController.text,
        model: model ?? config.model,
        language: language ?? config.language,
      );
    } catch (e) {
      if (mounted) ToastHelper.showError(context, e);
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

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return _AiServicePageScaffold(
          title: l10n.aiSetupCustomPageTitle,
          children: [
            _AiServiceHeader(
              icon: Icons.key_rounded,
              title: l10n.aiSetupCustomPageTitle,
              description: l10n.aiSetupCustomPageSubtitle,
            ),
            const SizedBox(height: 18),
            _buildProviderSection(),
            const SizedBox(height: 14),
            _buildModelRolesSection(),
            const SizedBox(height: 14),
            _buildServiceCapabilitiesSection(),
            const SizedBox(height: 14),
            _buildAdvancedAgentSection(),
          ],
        );
      },
    );
  }

  Widget _buildProviderSection() {
    final l10n = UserStorage.l10n;
    return _AiServiceOptionCard(
      icon: Icons.vpn_key_outlined,
      iconColor: AppColors.success,
      title: l10n.aiSetupProviderCredentialsTitle,
      description: l10n.aiSetupProviderCredentialsDescription,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton.icon(
          key: const ValueKey('ai-model-custom-config-button'),
          onPressed: _openAdvancedConfig,
          iconAlignment: IconAlignment.end,
          label: Text(l10n.advancedModelConfiguration),
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
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
    );
  }

  Widget _buildModelRolesSection() {
    if (_viewModel.isRoleLoading || _viewModel.roleSelection == null) {
      return _AiServiceOptionCard(
        icon: Icons.tune_rounded,
        iconColor: AppColors.primary,
        title: UserStorage.l10n.modelRolesTitle,
        description: UserStorage.l10n.modelRolesDescription,
        child: const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final selection = _viewModel.roleSelection!;

    return _AiServiceOptionCard(
      icon: Icons.tune_rounded,
      iconColor: AppColors.primary,
      title: UserStorage.l10n.modelRolesTitle,
      description: UserStorage.l10n.modelRolesDescription,
      child: Column(
        children: [
          _buildModelRolePicker(
            key: const ValueKey('ai-model-text-slot'),
            dropdownKey: const ValueKey('ai-model-text-slot-dropdown'),
            icon: Icons.notes_rounded,
            title: UserStorage.l10n.textModelRoleTitle,
            description: UserStorage.l10n.textModelRoleDescription,
            value: _viewModel.textConfig?.key,
            isUpdating: _viewModel.isUpdatingTextModel,
            onChanged: _updateTextModel,
          ),
          const SizedBox(height: 14),
          _buildModelRolePicker(
            key: const ValueKey('ai-model-vision-slot'),
            dropdownKey: const ValueKey('ai-model-vision-slot-dropdown'),
            icon: Icons.photo_library_outlined,
            title: UserStorage.l10n.visionModelRoleTitle,
            description: UserStorage.l10n.visionModelRoleDescription,
            value: selection.visionConfigKey ??
                AiServiceSetupViewModel.followTextSelectionValue,
            includeFollowText: true,
            isUpdating: _viewModel.isUpdatingVisionModel,
            onChanged: _updateVisionModel,
          ),
          if (_viewModel.shouldWarnVision) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    UserStorage.l10n.visionModelNonMultimodalWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!_viewModel.hasConfiguredModelOptions) ...[
            const SizedBox(height: 10),
            Text(
              UserStorage.l10n.noConfiguredModelOptions,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelRolePicker({
    required Key key,
    required Key dropdownKey,
    required IconData icon,
    required String title,
    required String description,
    required String? value,
    required bool isUpdating,
    required ValueChanged<String?> onChanged,
    bool includeFollowText = false,
  }) {
    final dropdownValue = _dropdownValueFor(value, includeFollowText);

    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUpdating)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: dropdownKey,
            initialValue: dropdownValue,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: _buildModelRoleDropdownItems(includeFollowText),
            onChanged: _viewModel.hasSelectableModels && !isUpdating
                ? onChanged
                : null,
          ),
        ],
      ),
    );
  }

  String? _dropdownValueFor(String? value, bool includeFollowText) {
    if (includeFollowText &&
        value == AiServiceSetupViewModel.followTextSelectionValue) {
      return AiServiceSetupViewModel.followTextSelectionValue;
    }
    if (value != null &&
        _viewModel.llmConfigs.any((config) => config.key == value)) {
      return value;
    }
    if (includeFollowText) {
      return AiServiceSetupViewModel.followTextSelectionValue;
    }
    if (_viewModel.llmConfigs.isEmpty) return null;
    return _viewModel.llmConfigs.first.key;
  }

  List<DropdownMenuItem<String>> _buildModelRoleDropdownItems(
    bool includeFollowText,
  ) {
    final items = <DropdownMenuItem<String>>[];
    if (includeFollowText) {
      items.add(
        DropdownMenuItem<String>(
          value: AiServiceSetupViewModel.followTextSelectionValue,
          child: Text(UserStorage.l10n.followTextModel),
        ),
      );
    }

    for (final config in _viewModel.llmConfigs) {
      items.add(
        DropdownMenuItem<String>(
          value: config.key,
          enabled: config.isValid,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _modelConfigLabel(config),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (LLMConfig.isKnownMultimodal(config.type, config.modelId))
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    UserStorage.l10n.visionBadge,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!config.isValid)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return items;
  }

  String _modelConfigLabel(LLMConfig config) {
    final provider = LLMConfig.displayName(config.type);
    return '${config.key} / $provider / ${config.modelId}';
  }

  Widget _buildServiceCapabilitiesSection() {
    return _AiServiceOptionCard(
      icon: Icons.hub_outlined,
      iconColor: AppColors.primary,
      title: UserStorage.l10n.aiSetupServiceCapabilitiesTitle,
      description: UserStorage.l10n.aiSetupServiceCapabilitiesDescription,
      child: Column(
        children: [
          _AiServiceActionTile(
            icon: Icons.my_location_outlined,
            title: UserStorage.l10n.locationProviderSettings,
            subtitle: UserStorage.l10n.locationContextDescription,
            onTap: _openLocationSettings,
          ),
          const Divider(height: 18),
          _buildSpeechRecognitionSettings(),
        ],
      ),
    );
  }

  Widget _buildSpeechRecognitionSettings() {
    final l10n = UserStorage.l10n;
    final speechConfig = _viewModel.speechRecognitionConfig;
    final selectedProvider = speechConfig.provider;

    return Container(
      key: const ValueKey('ai-service-speech-recognition-section'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.speechProviderSettings,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _speechProviderDescription(selectedProvider),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Color(0xFF5F6272),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SpeechRecognitionProvider>(
              key: const ValueKey('ai-service-speech-provider-segments'),
              segments: [
                ButtonSegment<SpeechRecognitionProvider>(
                  value: SpeechRecognitionProvider.local,
                  icon: const Icon(Icons.phone_iphone_rounded, size: 18),
                  label: Text(l10n.speechRecognitionProviderLocal),
                ),
                ButtonSegment<SpeechRecognitionProvider>(
                  value: SpeechRecognitionProvider.tencentCloud,
                  icon: const Icon(Icons.cloud_outlined, size: 18),
                  label: Text(l10n.speechRecognitionProviderTencentCloud),
                ),
                ButtonSegment<SpeechRecognitionProvider>(
                  value: SpeechRecognitionProvider.xiaomiMimo,
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: Text(l10n.speechRecognitionProviderXiaomiMimo),
                ),
              ],
              selected: {selectedProvider},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                final provider = selection.firstOrNull;
                if (provider == null) return;
                unawaited(_updateSpeechRecognitionProvider(provider));
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildSpeechCapabilityTags(selectedProvider),
          const SizedBox(height: 10),
          _buildInfoNote(_speechRecognitionNote(selectedProvider)),
          if (selectedProvider == SpeechRecognitionProvider.tencentCloud) ...[
            const SizedBox(height: 14),
            _buildTencentCloudSpeechForm(speechConfig),
          ] else if (selectedProvider ==
              SpeechRecognitionProvider.xiaomiMimo) ...[
            const SizedBox(height: 14),
            _buildXiaomiMimoSpeechForm(speechConfig),
          ],
        ],
      ),
    );
  }

  String _speechProviderDescription(SpeechRecognitionProvider provider) {
    final l10n = UserStorage.l10n;
    return switch (provider) {
      SpeechRecognitionProvider.local => l10n.speechRecognitionLocalDescription,
      SpeechRecognitionProvider.tencentCloud =>
        l10n.speechRecognitionTencentDescription,
      SpeechRecognitionProvider.xiaomiMimo =>
        l10n.speechRecognitionXiaomiMimoDescription,
    };
  }

  String _speechRecognitionNote(SpeechRecognitionProvider provider) {
    final l10n = UserStorage.l10n;
    return switch (provider) {
      SpeechRecognitionProvider.xiaomiMimo =>
        l10n.speechRecognitionXiaomiMimoPreviewNote,
      _ => l10n.speechRecognitionPreviewNote,
    };
  }

  Widget _buildSpeechCapabilityTags(SpeechRecognitionProvider provider) {
    final l10n = UserStorage.l10n;
    final realtimeLabel = provider == SpeechRecognitionProvider.xiaomiMimo
        ? l10n.speechRecognitionRealtimeUnavailable
        : l10n.speechRecognitionRealtimeAvailable;
    final privacyLabel = provider == SpeechRecognitionProvider.local
        ? l10n.speechRecognitionLocalOnly
        : l10n.speechRecognitionAudioLeavesDevice;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildCapabilityTag(Icons.graphic_eq_rounded, realtimeLabel),
        _buildCapabilityTag(
          Icons.audio_file_outlined,
          l10n.speechRecognitionImportedAudio,
        ),
        _buildCapabilityTag(Icons.privacy_tip_outlined, privacyLabel),
      ],
    );
  }

  Widget _buildCapabilityTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTencentCloudSpeechForm(SpeechRecognitionConfig speechConfig) {
    final l10n = UserStorage.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tencentAsrConfigTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        _buildCompactTextField(
          key: const ValueKey('ai-service-speech-tencent-app-id-field'),
          controller: _speechAppIdController,
          labelText: l10n.tencentAsrAppIdLabel,
          keyboardType: TextInputType.number,
          onChanged: (_) => unawaited(_persistTencentCloudSpeechConfig()),
        ),
        const SizedBox(height: 10),
        _buildCompactTextField(
          key: const ValueKey('ai-service-speech-tencent-secret-id-field'),
          controller: _speechSecretIdController,
          labelText: l10n.tencentAsrSecretIdLabel,
          onChanged: (_) => unawaited(_persistTencentCloudSpeechConfig()),
        ),
        const SizedBox(height: 10),
        _buildCompactTextField(
          key: const ValueKey('ai-service-speech-tencent-secret-key-field'),
          controller: _speechSecretKeyController,
          labelText: l10n.tencentAsrSecretKeyLabel,
          obscureText: true,
          onChanged: (_) => unawaited(_persistTencentCloudSpeechConfig()),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('ai-service-speech-tencent-engine-dropdown'),
          initialValue: speechConfig.tencentCloud.engineType,
          isExpanded: true,
          decoration: _compactInputDecoration(l10n.tencentAsrEngineModelLabel),
          items: TencentCloudAsrConfig.supportedEngineTypes
              .map(
                (model) => DropdownMenuItem<String>(
                  value: model,
                  child: Text(_tencentEngineModelLabel(model)),
                ),
              )
              .toList(),
          onChanged: (model) {
            if (model == null) return;
            unawaited(_persistTencentCloudSpeechConfig(engineType: model));
          },
        ),
      ],
    );
  }

  Widget _buildXiaomiMimoSpeechForm(SpeechRecognitionConfig speechConfig) {
    final l10n = UserStorage.l10n;
    final mimoConfig = speechConfig.xiaomiMimo;
    final linkedConfigs = _viewModel.mimoModelConfigs;
    final hasLinkedSelection = linkedConfigs.any(
      (config) => config.key == mimoConfig.llmConfigKey,
    );
    final sourceValue = hasLinkedSelection
        ? mimoConfig.llmConfigKey
        : _manualMimoSpeechConfigKey;
    final usesManual = sourceValue == _manualMimoSpeechConfigKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mimoAsrConfigTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('ai-service-speech-mimo-source-dropdown'),
          initialValue: sourceValue,
          isExpanded: true,
          decoration: _compactInputDecoration(l10n.mimoAsrConfigSourceLabel),
          items: [
            ...linkedConfigs.map(
              (config) => DropdownMenuItem<String>(
                value: config.key,
                child: Text(_mimoConfigLabel(config)),
              ),
            ),
            DropdownMenuItem<String>(
              value: _manualMimoSpeechConfigKey,
              child: Text(l10n.mimoAsrManualConfig),
            ),
          ],
          onChanged: (value) {
            final nextKey =
                value == _manualMimoSpeechConfigKey ? '' : value ?? '';
            unawaited(_persistXiaomiMimoSpeechConfig(llmConfigKey: nextKey));
          },
        ),
        if (usesManual) ...[
          const SizedBox(height: 10),
          _buildCompactTextField(
            key: const ValueKey('ai-service-speech-mimo-api-key-field'),
            controller: _speechMimoApiKeyController,
            labelText: l10n.mimoAsrApiKeyLabel,
            obscureText: true,
            onChanged: (_) => unawaited(_persistXiaomiMimoSpeechConfig()),
          ),
          const SizedBox(height: 10),
          _buildCompactTextField(
            key: const ValueKey('ai-service-speech-mimo-base-url-field'),
            controller: _speechMimoBaseUrlController,
            labelText: l10n.mimoAsrBaseUrlLabel,
            keyboardType: TextInputType.url,
            onChanged: (_) => unawaited(_persistXiaomiMimoSpeechConfig()),
          ),
        ] else ...[
          const SizedBox(height: 10),
          _buildInfoNote(l10n.mimoAsrLinkedConfigNote),
        ],
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('ai-service-speech-mimo-model-dropdown'),
          initialValue: mimoConfig.model,
          isExpanded: true,
          decoration: _compactInputDecoration(l10n.mimoAsrModelLabel),
          items: XiaomiMimoAsrConfig.supportedModels
              .map(
                (model) => DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                ),
              )
              .toList(),
          onChanged: (model) {
            if (model == null) return;
            unawaited(_persistXiaomiMimoSpeechConfig(model: model));
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: const ValueKey('ai-service-speech-mimo-language-dropdown'),
          initialValue: mimoConfig.language,
          isExpanded: true,
          decoration: _compactInputDecoration(l10n.mimoAsrLanguageLabel),
          items: XiaomiMimoAsrConfig.supportedLanguages
              .map(
                (language) => DropdownMenuItem<String>(
                  value: language,
                  child: Text(_mimoAsrLanguageLabel(language)),
                ),
              )
              .toList(),
          onChanged: (language) {
            if (language == null) return;
            unawaited(_persistXiaomiMimoSpeechConfig(language: language));
          },
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required Key key,
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      decoration: _compactInputDecoration(labelText),
      onChanged: onChanged,
    );
  }

  InputDecoration _compactInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  String _tencentEngineModelLabel(String model) {
    final l10n = UserStorage.l10n;
    return switch (model) {
      '16k_zh' => l10n.tencentAsrEngine16kZh,
      _ => l10n.tencentAsrEngine16kZhEn,
    };
  }

  String _mimoAsrLanguageLabel(String language) {
    final l10n = UserStorage.l10n;
    return switch (language) {
      'zh' => l10n.mimoAsrLanguageZh,
      'en' => l10n.mimoAsrLanguageEn,
      _ => l10n.mimoAsrLanguageAuto,
    };
  }

  String _mimoConfigLabel(LLMConfig config) {
    final model = config.modelId.trim().isEmpty ? config.key : config.modelId;
    return '${config.key} · $model';
  }

  Widget _buildAdvancedAgentSection() {
    return _AiServiceOptionCard(
      icon: Icons.manage_accounts_outlined,
      iconColor: AppColors.warning,
      title: UserStorage.l10n.aiSetupAdvancedCustomizationTitle,
      description: UserStorage.l10n.aiSetupAdvancedCustomizationDescription,
      child: _AiServiceActionTile(
        icon: Icons.people_outline,
        title: UserStorage.l10n.advancedAgentModelAssignments,
        subtitle: UserStorage.l10n.openAdvancedAgentModelAssignments,
        onTap: _openAdvancedAgentConfig,
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
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget child;
  final Widget? trailing;

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
          if (hasChild) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }
}

class _AiServiceActionTile extends StatelessWidget {
  const _AiServiceActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

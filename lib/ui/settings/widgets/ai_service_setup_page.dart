import 'package:flutter/material.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/widgets/memex_auth_section.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

class AiServiceSetupPage extends StatefulWidget {
  const AiServiceSetupPage({
    super.key,
    this.onComplete,
    this.onboardingMode = false,
  });

  final VoidCallback? onComplete;
  final bool onboardingMode;

  @override
  State<AiServiceSetupPage> createState() => _AiServiceSetupPageState();
}

class _AiServiceSetupPageState extends State<AiServiceSetupPage> {
  String _baseUrl = '';
  String _apiKey = '';
  List<String> _models = const [];
  bool _isSaving = false;
  bool _isMemexLoggedIn = false;
  bool _showMemexSetup = false;

  bool get _hasReadyCredentials =>
      _baseUrl.trim().isNotEmpty && _apiKey.trim().isNotEmpty;

  Future<void> _saveMemexService({
    bool finish = true,
    bool showToast = true,
  }) async {
    if (!_hasReadyCredentials || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final router = MemexRouter();
      final configs = await router.getLLMConfigs();
      final modelId = _models.isNotEmpty
          ? _models.first
          : LLMConfig.recommendedModels(LLMConfig.typeMemex).firstOrNull ??
              'memex-default';
      final memexConfig = LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeMemex,
        modelId: modelId,
        apiKey: _apiKey,
        baseUrl: _baseUrl,
        maxTokens: 65536,
      );

      final nextConfigs = [...configs];
      final index =
          nextConfigs.indexWhere((c) => c.key == LLMConfig.defaultClientKey);
      if (index >= 0) {
        nextConfigs[index] = memexConfig;
      } else {
        nextConfigs.insert(0, memexConfig);
      }
      await router.saveLLMConfigs(nextConfigs);
      await router.setDefaultLLMConfigKey(LLMConfig.defaultClientKey);

      if (!mounted) return;
      if (showToast) {
        ToastHelper.showSuccess(context, UserStorage.l10n.aiServiceReadyToast);
      }
      if (!finish) return;
      widget.onComplete?.call();
      if (widget.onComplete == null && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _clearMemexService() async {
    setState(() {
      _baseUrl = '';
      _apiKey = '';
      _models = const [];
      _isMemexLoggedIn = false;
    });

    try {
      final router = MemexRouter();
      final configs = await router.getLLMConfigs();
      final nextConfigs = [...configs];
      final index =
          nextConfigs.indexWhere((c) => c.key == LLMConfig.defaultClientKey);
      if (index < 0 || nextConfigs[index].type != LLMConfig.typeMemex) {
        return;
      }

      nextConfigs[index] = LLMConfig.createDefaultClientConfig();
      await router.saveLLMConfigs(nextConfigs);

      final fallback = nextConfigs
          .where((c) => c.key != LLMConfig.defaultClientKey && c.isValid)
          .firstOrNull;
      if (fallback != null) {
        await router.setDefaultLLMConfigKey(fallback.key);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
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
    if (configured == true && mounted && widget.onboardingMode) {
      widget.onComplete?.call();
      if (widget.onComplete == null) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _skip() {
    widget.onComplete?.call();
    if (widget.onComplete == null) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FC),
        surfaceTintColor: const Color(0xFFF9F9FC),
        elevation: 0,
        automaticallyImplyLeading: !widget.onboardingMode,
        title: widget.onboardingMode ? null : Text(l10n.aiService),
        actions: [
          if (widget.onboardingMode)
            TextButton(
              onPressed: _isSaving ? null : _skip,
              child: Text(l10n.skipForNow),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: [
                _buildSetupHeader(),
                const SizedBox(height: 22),
                _buildSetupOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupHeader() {
    final l10n = UserStorage.l10n;
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
            child: const Icon(
              Icons.memory_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.setupModelConfigTitle,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.setupModelConfigSubtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFF454655),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupOptions() {
    return Column(
      children: [
        _buildCustomModelCard(),
        const SizedBox(height: 14),
        _buildMemexServiceCard(),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
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
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF454655),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomModelCard() {
    final l10n = UserStorage.l10n;
    return _buildOptionCard(
      icon: Icons.key_rounded,
      iconColor: const Color(0xFF006397),
      title: l10n.aiServiceCustomApiRouteTitle,
      description: l10n.aiServiceCustomModelDescription,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton.icon(
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

  Widget _buildMemexServiceCard() {
    final l10n = UserStorage.l10n;
    return _buildOptionCard(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.primary,
      title: l10n.aiServiceMemexRouteTitle,
      description: l10n.aiServiceSettingsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_showMemexSetup) ...[
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSaving
                    ? null
                    : () => setState(() => _showMemexSetup = true),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
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
              onCredentialsReady: (baseUrl, apiKey, models) {
                setState(() {
                  _baseUrl = baseUrl;
                  _apiKey = apiKey;
                  _models = models;
                });
                _saveMemexService(finish: false, showToast: false);
              },
              onLoginStateChanged: (isLoggedIn) {
                if (mounted) {
                  setState(() => _isMemexLoggedIn = isLoggedIn);
                }
              },
              onLogout: _clearMemexService,
            ),
            if (_isMemexLoggedIn || _hasReadyCredentials || _isSaving) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _hasReadyCredentials && !_isSaving
                      ? _saveMemexService
                      : null,
                  iconAlignment: IconAlignment.end,
                  icon: _isSaving
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
                    disabledForegroundColor: const Color(0xFF757687),
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

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

  void _openAdvancedConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ModelConfigListPage()),
    );
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
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 300),
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 26),
                    _buildIllustration(),
                    const SizedBox(height: 30),
                    _buildIntroCopy(),
                    const SizedBox(height: 32),
                    _buildCustomModelCard(),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildPinnedAuthSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.memory_rounded, size: 30, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Memex',
            style: TextStyle(
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFE8E8EA),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-52, -6),
            child: Transform.rotate(
              angle: -0.11,
              child: _buildMemoryCard(
                width: 138,
                height: 104,
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFF757687),
                lineWidths: const [52],
                opacity: 0.78,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(52, -2),
            child: Transform.rotate(
              angle: 0.11,
              child: _buildMemoryCard(
                width: 138,
                height: 104,
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF757687),
                lineWidths: const [68],
                opacity: 0.78,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 26),
            child: _buildMemoryCard(
              width: 160,
              height: 124,
              icon: Icons.psychology_alt_rounded,
              iconColor: AppColors.primary,
              iconBackground: AppColors.primary.withValues(alpha: 0.12),
              lineWidths: const [86, 58],
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard({
    required double width,
    required double height,
    required IconData icon,
    required Color iconColor,
    required List<double> lineWidths,
    Color? iconBackground,
    double opacity = 1,
    double elevation = 2,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFC6C5D8).withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, elevation == 2 ? 0.05 : 0.16),
              blurRadius: elevation,
              offset: Offset(0, elevation == 2 ? 1 : 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconBackground == null ? 0 : 44,
              height: iconBackground == null ? 0 : 44,
              decoration: iconBackground == null
                  ? null
                  : BoxDecoration(
                      color: iconBackground,
                      shape: BoxShape.circle,
                    ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            if (iconBackground == null) Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 14),
            for (final width in lineWidths) ...[
              Container(
                width: width,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2E5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCopy() {
    final l10n = UserStorage.l10n;
    return Column(
      children: [
        Text(
          l10n.aiServiceTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 32,
            height: 1.18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.aiServiceLongDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.72,
            color: Color(0xFF454655),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomModelCard() {
    final l10n = UserStorage.l10n;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.api_rounded, color: Color(0xFF006397)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.aiServiceCustomModelTitle,
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
          const SizedBox(height: 14),
          Text(
            l10n.aiServiceCustomModelDescription,
            style: const TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF454655),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _openAdvancedConfig,
            iconAlignment: IconAlignment.end,
            label: Text(l10n.advancedModelConfiguration),
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: const Color(0xFF006397),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedAuthSection() {
    final l10n = UserStorage.l10n;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E2E5))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(0, 12, 0, 10),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  if (_isMemexLoggedIn ||
                      _hasReadyCredentials ||
                      _isSaving) ...[
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
                        label: Text(l10n.enableAiService),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

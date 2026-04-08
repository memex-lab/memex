import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/services/gemini_auth_service.dart';
import 'package:memex/data/services/model_list_service.dart';
import 'package:memex/ui/core/widgets/searchable_dropdown.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/config/app_config.dart';
import 'package:memex/llm_client/gemma_model_manager.dart';

class SetupModelConfigPage extends StatefulWidget {
  final LLMConfig config;
  final VoidCallback onComplete;

  const SetupModelConfigPage({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<SetupModelConfigPage> createState() => _SetupModelConfigPageState();
}

class _SetupModelConfigPageState extends State<SetupModelConfigPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _modelDropdownKey = GlobalKey<SearchableDropdownState>();

  late TextEditingController _modelIdController;
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _bedrockAccessKeyController;
  late TextEditingController _bedrockSecretKeyController;
  late TextEditingController _bedrockRegionController;

  String _selectedType = '';
  bool _isObscureApiKey = true;
  bool _isSubmitting = false;
  Map<String, dynamic>? _openAiTokens;
  Map<String, dynamic>? _geminiTokens;
  bool _isAuthDialogShowing = false;
  bool _authFlowCompleted = false;
  bool _appResumedDuringAuth = false;

  List<String> _fetchedModels = [];
  bool _isFetchingModels = false;

  // Gemma local model download state
  bool? _gemmaModelInstalled;
  bool _gemmaDownloading = false;
  int _gemmaDownloadProgress = 0;
  String? _gemmaDownloadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final config = widget.config;
    _modelIdController = TextEditingController(text: config.modelId);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _baseUrlController = TextEditingController(text: config.baseUrl);
    _bedrockAccessKeyController = TextEditingController(
        text: config.extra['accessKeyId'] as String? ?? '');
    _bedrockSecretKeyController = TextEditingController(
        text: config.extra['secretAccessKey'] as String? ?? '');
    _bedrockRegionController = TextEditingController(
        text: config.extra['region'] as String? ?? 'us-west-2');
    _selectedType = config.type;
    if (_selectedType == LLMConfig.typeOpenAiOauth) {
      _loadOpenAiTokens();
    } else if (_selectedType == LLMConfig.typeGeminiOauth) {
      _loadGeminiTokens();
    }
    if (LLMConfig.supportsModelListing(_selectedType) &&
        _baseUrlController.text.isNotEmpty &&
        (!LLMConfig.requiresApiKey(_selectedType) ||
            _apiKeyController.text.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchModels());
    }
  }

  Future<void> _loadOpenAiTokens() async {
    final tokens = await OpenAiAuthService.getSavedTokens();
    if (mounted) {
      setState(() {
        _openAiTokens = tokens;
      });
    }
  }

  Future<void> _loadGeminiTokens() async {
    final tokens = await GeminiAuthService.getSavedTokens();
    if (mounted) {
      setState(() {
        _geminiTokens = tokens;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isAuthDialogShowing) {
      _appResumedDuringAuth = true;
      Future.delayed(const Duration(seconds: 10), () {
        if (_isAuthDialogShowing &&
            !_authFlowCompleted &&
            _appResumedDuringAuth &&
            mounted) {
          _dismissAuthDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    UserStorage.l10n.authFailed('Authorization cancelled'))),
          );
        }
      });
    }
  }

  void _dismissAuthDialog() {
    if (_isAuthDialogShowing && mounted) {
      _isAuthDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<bool> _confirmAndroidOAuthHint() async {
    if (!Platform.isAndroid) return true;
    final l10n = UserStorage.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.oauthHintTitle),
        content: Text(l10n.oauthHintMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.startUsing),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _startOpenAiAuth() async {
    if (!await _confirmAndroidOAuthHint()) return;
    _authFlowCompleted = false;
    _appResumedDuringAuth = false;
    OpenAiAuthService.startAuthFlow(
      onStart: () {
        _isAuthDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(UserStorage.l10n.authorizing,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ).then((_) {
          // Dialog was dismissed (e.g. by back button or programmatically)
          _isAuthDialogShowing = false;
        });
      },
      onSuccess: (accountId) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authorized successfully')),
          );
          _loadOpenAiTokens();
        }
      },
      onError: (error) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(UserStorage.l10n.authFailed(error.toString()))),
          );
        }
      },
    );
  }

  void _startGeminiAuth() async {
    if (!await _confirmAndroidOAuthHint()) return;
    _authFlowCompleted = false;
    _appResumedDuringAuth = false;
    GeminiAuthService.startAuthFlow(
      onStart: () {
        _isAuthDialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(UserStorage.l10n.authorizing,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ).then((_) {
          _isAuthDialogShowing = false;
        });
      },
      onSuccess: (email) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authorized as $email')),
          );
          _loadGeminiTokens();
        }
      },
      onError: (error) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(UserStorage.l10n.authFailed(error.toString()))),
          );
        }
      },
    );
  }

  Widget _buildOpenAiAuthSection() {
    final bool isAuthorized = _openAiTokens != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAuthorized ? Icons.check_circle : Icons.info_outline,
                color: isAuthorized ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAuthorized ? 'Authorized' : 'Not authorized',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAuthorized ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startOpenAiAuth,
              icon: const Icon(Icons.login),
              label:
                  Text(isAuthorized ? 'Re-authorize' : 'Authorize with OpenAI'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAuthorized ? Colors.white : AppColors.primary,
                foregroundColor: isAuthorized ? Colors.black87 : Colors.white,
                elevation: 0,
                side:
                    isAuthorized ? BorderSide(color: Colors.grey[300]!) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (isAuthorized)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await OpenAiAuthService.clearTokens();
                    _loadOpenAiTokens();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: Text(
                    UserStorage.l10n.clearAuth,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeminiAuthSection() {
    final bool isAuthorized = _geminiTokens != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAuthorized ? Icons.check_circle : Icons.info_outline,
                color: isAuthorized ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isAuthorized ? 'Authorized' : 'Not authorized',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isAuthorized ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startGeminiAuth,
              icon: const Icon(Icons.login),
              label:
                  Text(isAuthorized ? 'Re-authorize' : 'Authorize with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAuthorized ? Colors.white : AppColors.primary,
                foregroundColor: isAuthorized ? Colors.black87 : Colors.white,
                elevation: 0,
                side:
                    isAuthorized ? BorderSide(color: Colors.grey[300]!) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (isAuthorized)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await GeminiAuthService.clearTokens();
                    _loadGeminiTokens();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: Text(
                    UserStorage.l10n.clearAuth,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isProModel(String model) => LLMConfig.isChatgptProModel(model);

  List<String> _getRecommendedModels(String type) =>
      LLMConfig.recommendedModels(type);

  List<String> _modelOptions() {
    if (_fetchedModels.isNotEmpty) return _fetchedModels;
    return _getRecommendedModels(_selectedType);
  }

  bool get _modelSelectorDisabled {
    if (!LLMConfig.requiresApiKey(_selectedType)) return false;
    return _apiKeyController.text.trim().isEmpty;
  }

  Future<void> _fetchModels() async {
    if (_isFetchingModels) return;
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (baseUrl.isEmpty) return;

    setState(() => _isFetchingModels = true);
    try {
      final models = await ModelListService.fetchModels(
        type: _selectedType,
        baseUrl: baseUrl,
        apiKey: apiKey,
      );
      if (mounted) {
        setState(() {
          _fetchedModels = models;
          _isFetchingModels = false;
        });
        if (models.isNotEmpty && _modelIdController.text.isEmpty) {
          _modelIdController.text = models.first;
          _modelDropdownKey.currentState?.setText(models.first);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isFetchingModels = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dismiss auth dialog if still showing when page is disposed
    if (_isAuthDialogShowing) {
      _isAuthDialogShowing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      });
    }
    _modelIdController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _bedrockAccessKeyController.dispose();
    _bedrockSecretKeyController.dispose();
    _bedrockRegionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final Map<String, dynamic> extra =
        _selectedType == LLMConfig.typeBedrockClaude
            ? {
                'accessKeyId': _bedrockAccessKeyController.text,
                'secretAccessKey': _bedrockSecretKeyController.text,
                'region': _bedrockRegionController.text.isNotEmpty
                    ? _bedrockRegionController.text
                    : 'us-west-2',
              }
            : widget.config.extra;

    final newConfig = widget.config.copyWith(
      type: _selectedType,
      modelId: _modelIdController.text,
      apiKey: (_selectedType == LLMConfig.typeBedrockClaude ||
              _selectedType == LLMConfig.typeGemmaLocal)
          ? ''
          : _apiKeyController.text,
      baseUrl: (_selectedType == LLMConfig.typeBedrockClaude ||
              _selectedType == LLMConfig.typeOpenAiOauth ||
              _selectedType == LLMConfig.typeGemmaLocal)
          ? ''
          : _baseUrlController.text,
      extra: extra,
    );

    if (!newConfig.isValid) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(UserStorage.l10n.warning),
          content: Text(UserStorage.l10n.invalidConfigurationWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(UserStorage.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(UserStorage.l10n.confirm),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }
    }

    try {
      final configs = await MemexRouter().getLLMConfigs();

      // Check LLM data sharing consent before saving a valid config
      // Skip consent for on-device models (data never leaves the device)
      if (newConfig.isValid && _selectedType != LLMConfig.typeGemmaLocal) {
        final hasConsent =
            await UserStorage.hasLLMConsent(providerType: _selectedType);
        if (!hasConsent && mounted) {
          final l10n = UserStorage.l10n;
          final providerName = _selectedType.isNotEmpty
              ? LLMConfig.providerDisplayName(_selectedType)
              : 'AI Provider';
          final consentGiven = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.llmConsentTitle),
              content: SingleChildScrollView(
                child: Text(l10n.llmConsentMessage(providerName)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.llmConsentDecline),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.llmConsentAgree),
                ),
              ],
            ),
          );
          if (consentGiven != true) {
            setState(() => _isSubmitting = false);
            return;
          }
          await UserStorage.saveLLMConsent(true, providerType: _selectedType);
        }
      }

      final index = configs.indexWhere((c) => c.key == widget.config.key);
      if (index != -1) {
        configs[index] = newConfig;
      } else {
        configs.add(newConfig);
      }

      await MemexRouter().saveLLMConfigs(configs);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving config: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _skip() {
    widget.onComplete();
  }

  /// Check if the currently selected Gemma model is installed on device.
  Future<void> _checkGemmaModelStatus() async {
    if (_selectedType != LLMConfig.typeGemmaLocal) return;
    final modelId = _modelIdController.text;
    if (modelId.isEmpty || !GemmaModelManager.isKnownModel(modelId)) {
      setState(() => _gemmaModelInstalled = null);
      return;
    }
    final installed = await GemmaModelManager.isModelInstalled(modelId);
    if (mounted) setState(() => _gemmaModelInstalled = installed);
  }

  /// Start downloading the selected Gemma model.
  Future<void> _downloadGemmaModel() async {
    final modelId = _modelIdController.text;
    if (modelId.isEmpty) return;
    setState(() {
      _gemmaDownloading = true;
      _gemmaDownloadProgress = 0;
      _gemmaDownloadError = null;
    });
    try {
      await GemmaModelManager.downloadModel(
        modelId,
        onProgress: (progress) {
          if (mounted) setState(() => _gemmaDownloadProgress = progress);
        },
      );
      if (mounted) {
        setState(() {
          _gemmaDownloading = false;
          _gemmaModelInstalled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gemmaDownloading = false;
          _gemmaDownloadError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              UserStorage.l10n.skipForNow,
              style: GoogleFonts.inter(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.memory,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                Text(
                  UserStorage.l10n.setupModelConfigTitle,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  UserStorage.l10n.setupModelConfigSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Data sharing notice banner — not shown for on-device models
                if (_selectedType.isNotEmpty &&
                    _selectedType != LLMConfig.typeGemmaLocal)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFBBF24)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            UserStorage.l10n.llmConsentDataShareNote(
                                LLMConfig.providerDisplayName(_selectedType)),
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Fields
                _buildProviderDropdown(),
                const SizedBox(height: 20),

                // Base URL (before API key — needed for model fetching)
                if (_selectedType != LLMConfig.typeBedrockClaude &&
                    _selectedType != LLMConfig.typeOpenAiOauth &&
                    _selectedType != LLMConfig.typeGeminiOauth &&
                    _selectedType != LLMConfig.typeGemmaLocal) ...[
                  _buildTextField(
                    controller: _baseUrlController,
                    label: UserStorage.l10n.baseUrlLabel,
                    icon: Icons.link,
                  ),
                  const SizedBox(height: 20),
                ],

                // API Key / Auth / Bedrock Section
                if (_selectedType == LLMConfig.typeOpenAiOauth) ...[
                  _buildOpenAiAuthSection(),
                  const SizedBox(height: 20),
                ] else if (_selectedType == LLMConfig.typeGeminiOauth) ...[
                  _buildGeminiAuthSection(),
                  const SizedBox(height: 20),
                ] else if (_selectedType == LLMConfig.typeBedrockClaude) ...[
                  _buildBedrockFields(),
                  const SizedBox(height: 20),
                ] else if (_selectedType == LLMConfig.typeOllama) ...[
                  // Ollama doesn't need an API key
                ] else if (_selectedType == LLMConfig.typeGemmaLocal) ...[
                  // Gemma Local runs on-device, no API key needed
                ] else ...[
                  _buildApiKeyField(),
                  const SizedBox(height: 20),
                ],

                // Model ID
                if (_modelSelectorDisabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      UserStorage.l10n.enterApiKeyFirst,
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange[700], height: 1.3),
                    ),
                  ),
                AbsorbPointer(
                  absorbing: _modelSelectorDisabled,
                  child: Opacity(
                    opacity: _modelSelectorDisabled ? 0.5 : 1.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SearchableDropdown(
                            key: _modelDropdownKey,
                            options: _modelOptions(),
                            initialValue: _modelIdController.text,
                            onChanged: (value) {
                              _modelIdController.text = value;
                              setState(() {});
                              if (_selectedType == LLMConfig.typeGemmaLocal) {
                                _checkGemmaModelStatus();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: UserStorage.l10n.modelIdLabel,
                              hintText: _isFetchingModels
                                  ? UserStorage.l10n.fetchingModels
                                  : UserStorage.l10n.modelIdHelper,
                              prefixIcon: const Icon(Icons.api),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return UserStorage.l10n.required;
                              }
                              return null;
                            },
                            optionBuilder: (option, _) {
                              final isPro =
                                  _selectedType == LLMConfig.typeOpenAiOauth &&
                                      _isProModel(option);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(option)),
                                    if (isPro)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF7ED),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: const Color(0xFFFBBF24),
                                              width: 0.5),
                                        ),
                                        child: const Text(
                                          'Pro/Plus',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFD97706),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (LLMConfig.supportsModelListing(_selectedType) &&
                            !_modelSelectorDisabled)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: IconButton(
                              icon: _isFetchingModels
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.refresh),
                              tooltip: UserStorage.l10n.fetchModelsButton,
                              onPressed:
                                  _isFetchingModels ? null : _fetchModels,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_selectedType == LLMConfig.typeOpenAiOauth &&
                    _isProModel(_modelIdController.text))
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            UserStorage.l10n.proModelHint,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD97706),
                                height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 48),

                // Gemma model download section
                if (_selectedType == LLMConfig.typeGemmaLocal &&
                    _modelIdController.text.isNotEmpty)
                  _buildGemmaDownloadSection(),

                // Complete Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          UserStorage.l10n.setupModelConfigComplete,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderDropdown() {
    final available = AppConfig.availableProviders;
    final l10n = UserStorage.l10n;

    String displayName(String type) {
      switch (type) {
        case LLMConfig.typeChatCompletion:
          return l10n.providerOpenAiApiKey;
        case LLMConfig.typeResponses:
          return l10n.providerOpenAiResponses;
        case LLMConfig.typeOpenAiOauth:
          return l10n.providerChatGptOauth;
        case LLMConfig.typeClaude:
          return l10n.providerClaudeApiKey;
        case LLMConfig.typeBedrockClaude:
          return l10n.providerBedrockSecret;
        case LLMConfig.typeGemini:
          return l10n.providerGemini;
        case LLMConfig.typeGeminiOauth:
          return l10n.providerGeminiOauth;
        case LLMConfig.typeKimi:
          return l10n.providerKimi;
        case LLMConfig.typeQwen:
          return l10n.providerQwen;
        case LLMConfig.typeSeed:
          return l10n.providerSeed;
        case LLMConfig.typeZhipu:
          return l10n.providerZhipu;
        case LLMConfig.typeMimo:
          return l10n.providerMimo;
        case LLMConfig.typeOpenRouter:
          return l10n.providerOpenRouter;
        case LLMConfig.typeOllama:
          return l10n.providerOllama;
        case LLMConfig.typeGemmaLocal:
          return l10n.providerGemmaLocal;
        default:
          return LLMConfig.providerDisplayName(type);
      }
    }

    final groups = <String, List<String>>{
      l10n.providerGroupOpenAi: [
        LLMConfig.typeChatCompletion,
        LLMConfig.typeResponses,
        LLMConfig.typeOpenAiOauth,
      ],
      l10n.providerGroupAnthropic: [
        LLMConfig.typeClaude,
        LLMConfig.typeBedrockClaude,
      ],
      l10n.providerGroupGoogle: [
        LLMConfig.typeGemini,
        LLMConfig.typeGeminiOauth,
        LLMConfig.typeGemmaLocal,
      ],
      l10n.providerGroupOthers: [
        LLMConfig.typeKimi,
        LLMConfig.typeQwen,
        LLMConfig.typeSeed,
        LLMConfig.typeZhipu,
        LLMConfig.typeMimo,
        LLMConfig.typeOpenRouter,
        LLMConfig.typeOllama,
      ],
    };

    // Filter out gemma_local on iOS (flutter_gemma not yet supported)
    final filteredAvailable = available.where((t) {
      if (t == LLMConfig.typeGemmaLocal && !Platform.isAndroid) return false;
      return true;
    }).toSet();

    final items = <DropdownMenuItem<String>>[];
    final selectedItems = <Widget>[];
    var headerIdx = 0;

    for (final entry in groups.entries) {
      final groupProviders =
          entry.value.where((t) => filteredAvailable.contains(t)).toList();
      if (groupProviders.isEmpty) continue;

      items.add(DropdownMenuItem<String>(
        enabled: false,
        value: '__header_${headerIdx++}__',
        child: Padding(
          padding: EdgeInsets.only(top: items.isEmpty ? 0 : 4),
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ),
      ));
      selectedItems.add(const SizedBox.shrink());

      for (final type in groupProviders) {
        items.add(DropdownMenuItem(
          value: type,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(displayName(type),
                style: TextStyle(color: Colors.grey[800])),
          ),
        ));
        selectedItems.add(Text(displayName(type)));
      }
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedType.isEmpty ? null : _selectedType,
      hint: Text(l10n.select),
      decoration: InputDecoration(
        labelText: l10n.clientLabel,
        prefixIcon: const Icon(Icons.cloud_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      selectedItemBuilder: (context) => selectedItems,
      items: items,
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.required;
        return null;
      },
      onChanged: (value) {
        setState(() => _selectedType = value ?? '');
        _fetchedModels = [];
        if (value != null && value.isNotEmpty) {
          final recommended = _getRecommendedModels(value);
          // For gemma_local, don't pre-fill so user can see all options in dropdown
          final defaultModel = value == LLMConfig.typeGemmaLocal
              ? ''
              : (recommended.isNotEmpty ? recommended.first : '');
          _modelIdController.text = defaultModel;
          _modelDropdownKey.currentState?.setText(defaultModel);
          _apiKeyController.text = '';
          _baseUrlController.text = LLMConfig.defaultBaseUrl(value);
          _bedrockAccessKeyController.text = '';
          _bedrockSecretKeyController.text = '';
          _bedrockRegionController.text = 'us-west-2';
          if (value == LLMConfig.typeOpenAiOauth) {
            _loadOpenAiTokens();
          } else if (value == LLMConfig.typeGeminiOauth) {
            _loadGeminiTokens();
          }
          if (!LLMConfig.requiresApiKey(value)) _fetchModels();
          if (value == LLMConfig.typeGemmaLocal) _checkGemmaModelStatus();
        }
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return UserStorage.l10n.required;
        return null;
      },
    );
  }

  Widget _buildBedrockFields() {
    return Column(
      children: [
        TextFormField(
          controller: _bedrockAccessKeyController,
          decoration: InputDecoration(
            labelText: 'Access Key ID',
            prefixIcon: const Icon(Icons.vpn_key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return UserStorage.l10n.required;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bedrockSecretKeyController,
          decoration: InputDecoration(
            labelText: 'Secret Access Key',
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(
                _isObscureApiKey ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () =>
                  setState(() => _isObscureApiKey = !_isObscureApiKey),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          obscureText: _isObscureApiKey,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return UserStorage.l10n.required;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bedrockRegionController,
          decoration: InputDecoration(
            labelText: 'Region',
            hintText: 'us-west-2',
            prefixIcon: const Icon(Icons.public),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyField() {
    return TextFormField(
      controller: _apiKeyController,
      decoration: InputDecoration(
        labelText: UserStorage.l10n.apiKeyLabel,
        prefixIcon: const Icon(Icons.key),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscureApiKey ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _isObscureApiKey = !_isObscureApiKey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      obscureText: _isObscureApiKey,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildGemmaDownloadSection() {
    final modelId = _modelIdController.text;
    final sizeDesc = GemmaModelManager.getModelSize(modelId) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            children: [
              Icon(
                _gemmaModelInstalled == true
                    ? Icons.check_circle
                    : Icons.download_outlined,
                color:
                    _gemmaModelInstalled == true ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _gemmaModelInstalled == true
                      ? 'Model ready'
                      : _gemmaModelInstalled == false
                          ? 'Model not downloaded ($sizeDesc)'
                          : 'Checking model status...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _gemmaModelInstalled == true
                        ? Colors.green
                        : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),

          // Download progress
          if (_gemmaDownloading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _gemmaDownloadProgress / 100.0,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Downloading... $_gemmaDownloadProgress%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],

          // Error message
          if (_gemmaDownloadError != null) ...[
            const SizedBox(height: 8),
            Text(
              _gemmaDownloadError!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],

          // Download button (only if not installed and not downloading)
          if (_gemmaModelInstalled == false && !_gemmaDownloading) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloadGemmaModel,
                icon: const Icon(Icons.download),
                label: Text('Download Model ($sizeDesc)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

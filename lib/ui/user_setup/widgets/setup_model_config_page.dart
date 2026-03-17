import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/services/gemini_auth_service.dart';
import 'package:memex/data/services/model_list_service.dart';
import 'package:memex/ui/core/widgets/searchable_dropdown.dart';

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
                        AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
                        AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
                    isAuthorized ? Colors.white : const Color(0xFF6366F1),
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
                    isAuthorized ? Colors.white : const Color(0xFF6366F1),
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
      apiKey: _selectedType == LLMConfig.typeBedrockClaude
          ? ''
          : _apiKeyController.text,
      baseUrl: (_selectedType == LLMConfig.typeBedrockClaude ||
              _selectedType == LLMConfig.typeOpenAiOauth)
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              UserStorage.l10n.skipForNow,
              style: TextStyle(
                color: Colors.grey[600],
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
                      color: const Color(0xFF6366F1), // Indigo
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
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  UserStorage.l10n.setupModelConfigSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form Fields
                _buildProviderDropdown(),
                const SizedBox(height: 20),

                // Base URL (before API key — needed for model fetching)
                if (_selectedType != LLMConfig.typeBedrockClaude &&
                    _selectedType != LLMConfig.typeOpenAiOauth &&
                    _selectedType != LLMConfig.typeGeminiOauth) ...[
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
                ] else ...[
                  _buildApiKeyField(),
                  const SizedBox(height: 20),
                ],

                // Model ID
                if (_modelSelectorDisabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
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
                                    color: Color(0xFF6366F1), width: 2),
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

                // Complete Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
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
                          style: const TextStyle(
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
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedType.isEmpty ? null : _selectedType,
      hint: Text(UserStorage.l10n.select),
      decoration: InputDecoration(
        labelText: UserStorage.l10n.clientLabel,
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
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      selectedItemBuilder: (context) {
        final l10n = UserStorage.l10n;
        return [
          // OpenAI group header
          const SizedBox.shrink(),
          Text(l10n.providerOpenAiApiKey),
          Text(l10n.providerOpenAiResponses),
          Text(l10n.providerChatGptOauth),
          // Anthropic group header
          const SizedBox.shrink(),
          Text(l10n.providerClaudeApiKey),
          Text(l10n.providerBedrockSecret),
          // Google group header
          const SizedBox.shrink(),
          Text(l10n.providerGemini),
          Text(l10n.providerGeminiOauth),
          // Chinese LLM group header
          const SizedBox.shrink(),
          Text(l10n.providerKimi),
          Text(l10n.providerQwen),
          Text(l10n.providerSeed),
          Text(l10n.providerZhipu),
          Text(l10n.providerMinimax),
          Text(l10n.providerOpenRouter),
          Text(l10n.providerOllama),
        ];
      },
      items: [
        // ── OpenAI Group ──
        DropdownMenuItem<String>(
          enabled: false,
          value: '__openai_header__',
          child: Text(
            UserStorage.l10n.providerGroupOpenAi,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeChatCompletion,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerOpenAiApiKey,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeResponses,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerOpenAiResponses,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeOpenAiOauth,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerChatGptOauth,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        // ── Anthropic Group ──
        DropdownMenuItem<String>(
          enabled: false,
          value: '__anthropic_header__',
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              UserStorage.l10n.providerGroupAnthropic,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeClaude,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerClaudeApiKey,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeBedrockClaude,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerBedrockSecret,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        // ── Google Group ──
        DropdownMenuItem<String>(
          enabled: false,
          value: '__google_header__',
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              UserStorage.l10n.providerGroupGoogle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
            value: LLMConfig.typeGemini,
            child: Text(UserStorage.l10n.providerGemini)),
        DropdownMenuItem(
            value: LLMConfig.typeGeminiOauth,
            child: Text(UserStorage.l10n.providerGeminiOauth)),
        // ── Others ──
        DropdownMenuItem<String>(
          enabled: false,
          value: '__others_header__',
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              UserStorage.l10n.providerGroupOthers,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeKimi,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerKimi,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeQwen,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerQwen,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeSeed,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerSeed,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeZhipu,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerZhipu,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeMinimax,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerMinimax,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeOpenRouter,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerOpenRouter,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
        DropdownMenuItem(
          value: LLMConfig.typeOllama,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(UserStorage.l10n.providerOllama,
                style: TextStyle(color: Colors.grey[800])),
          ),
        ),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return UserStorage.l10n.required;
        }
        return null;
      },
      onChanged: (value) {
        setState(() => _selectedType = value ?? '');
        _fetchedModels = [];
        if (value != null && value.isNotEmpty) {
          final recommended = _getRecommendedModels(value);
          _modelIdController.text =
              recommended.isNotEmpty ? recommended.first : '';
          _modelDropdownKey.currentState?.setText(_modelIdController.text);
          _apiKeyController.text = '';
          _baseUrlController.text = LLMConfig.defaultBaseUrl(value);
          if (value == LLMConfig.typeOpenAiOauth) {
            _loadOpenAiTokens();
          } else if (value == LLMConfig.typeGeminiOauth) {
            _loadGeminiTokens();
          }
          if (!LLMConfig.requiresApiKey(value)) {
            _fetchModels();
          }
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
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
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
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      obscureText: _isObscureApiKey,
      onChanged: (_) => setState(() {}),
    );
  }
}

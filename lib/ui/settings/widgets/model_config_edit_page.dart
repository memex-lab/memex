import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/services/gemini_auth_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/ui/core/widgets/searchable_dropdown.dart';

class ModelConfigEditPage extends StatefulWidget {
  final LLMConfig? config;

  const ModelConfigEditPage({super.key, this.config});

  @override
  State<ModelConfigEditPage> createState() => _ModelConfigEditPageState();
}

class _ModelConfigEditPageState extends State<ModelConfigEditPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _modelDropdownKey = GlobalKey<SearchableDropdownState>();

  late TextEditingController _keyController;
  late TextEditingController _modelIdController;
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _proxyUrlController;
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;
  late TextEditingController _topPController;
  late TextEditingController _extraController;
  late TextEditingController _bedrockAccessKeyController;
  late TextEditingController _bedrockSecretKeyController;
  late TextEditingController _bedrockRegionController;

  String _selectedType = '';
  bool _isObscureApiKey = true;
  Map<String, dynamic>? _openAiTokens;
  Map<String, dynamic>? _geminiTokens;
  bool _isAuthDialogShowing = false;
  bool _authFlowCompleted = false;
  bool _appResumedDuringAuth = false;

  bool _hasChanges = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final config = widget.config;
    _keyController = TextEditingController(text: config?.key ?? '');
    _modelIdController = TextEditingController(text: config?.modelId ?? '');
    _apiKeyController = TextEditingController(text: config?.apiKey ?? '');
    _baseUrlController = TextEditingController(text: config?.baseUrl ?? '');
    _proxyUrlController = TextEditingController(text: config?.proxyUrl ?? '');
    _temperatureController =
        TextEditingController(text: config?.temperature?.toString() ?? '');
    _maxTokensController =
        TextEditingController(text: config?.maxTokens?.toString() ?? '');
    _topPController = TextEditingController(
        text: config?.topP?.toString() ?? ''); // Fixed line

    _bedrockAccessKeyController = TextEditingController(
        text: config?.extra['accessKeyId'] as String? ?? '');
    _bedrockSecretKeyController = TextEditingController(
        text: config?.extra['secretAccessKey'] as String? ?? '');
    _bedrockRegionController = TextEditingController(
        text: config?.extra['region'] as String? ?? 'us-west-2');

    String extraJson = '{}';
    if (config != null && config.extra.isNotEmpty) {
      try {
        extraJson = const JsonEncoder.withIndent('  ').convert(config.extra);
      } catch (e) {
        extraJson = '{}';
      }
    }
    _extraController = TextEditingController(text: extraJson);

    if (config != null) {
      _selectedType = config.type;
      if (_selectedType == LLMConfig.typeOpenAiOauth) {
        _loadOpenAiTokens();
      } else if (_selectedType == LLMConfig.typeGeminiOauth) {
        _loadGeminiTokens();
      }
    }

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _keyController.addListener(_checkChanges);
    _modelIdController.addListener(_checkChanges);
    _apiKeyController.addListener(_checkChanges);
    _baseUrlController.addListener(_checkChanges);
    _proxyUrlController.addListener(_checkChanges);
    _temperatureController.addListener(_checkChanges);
    _maxTokensController.addListener(_checkChanges);
    _topPController.addListener(_checkChanges);
    _extraController.addListener(_checkChanges);
    _bedrockAccessKeyController.addListener(_checkChanges);
    _bedrockSecretKeyController.addListener(_checkChanges);
    _bedrockRegionController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final config = widget.config;
    bool changed = false;
    if (config == null) {
      changed = _keyController.text.isNotEmpty ||
          _selectedType.isNotEmpty ||
          _modelIdController.text.isNotEmpty ||
          _apiKeyController.text.isNotEmpty ||
          _baseUrlController.text.isNotEmpty ||
          _proxyUrlController.text.isNotEmpty ||
          _temperatureController.text.isNotEmpty ||
          _maxTokensController.text.isNotEmpty ||
          _topPController.text.isNotEmpty ||
          _extraController.text != '{}' ||
          _bedrockAccessKeyController.text.isNotEmpty ||
          _bedrockSecretKeyController.text.isNotEmpty ||
          (_bedrockRegionController.text.isNotEmpty &&
              _bedrockRegionController.text != 'us-west-2');
    } else {
      String extraJson = '{}';
      if (config.extra.isNotEmpty) {
        try {
          extraJson = const JsonEncoder.withIndent('  ').convert(config.extra);
        } catch (_) {}
      }

      changed = _keyController.text != config.key ||
          _selectedType != config.type ||
          _modelIdController.text != config.modelId ||
          _apiKeyController.text != config.apiKey ||
          _baseUrlController.text != config.baseUrl ||
          _proxyUrlController.text != (config.proxyUrl ?? '') ||
          _temperatureController.text !=
              (config.temperature?.toString() ?? '') ||
          _maxTokensController.text != (config.maxTokens?.toString() ?? '') ||
          _topPController.text != (config.topP?.toString() ?? '') ||
          _extraController.text != extraJson;
    }

    if (_hasChanges != changed) {
      setState(() {
        _hasChanges = changed;
        if (_hasChanges) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.reset();
          _animationController.stop();
        }
      });
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
      // Start a generous timeout — if auth callbacks don't fire within 10s
      // after resume, the user likely cancelled manually.
      Future.delayed(const Duration(seconds: 10), () {
        if (_isAuthDialogShowing &&
            !_authFlowCompleted &&
            _appResumedDuringAuth &&
            mounted) {
          _dismissAuthDialog();
          ToastHelper.showError(
              context, UserStorage.l10n.authFailed('Authorization cancelled'));
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
                  const CircularProgressIndicator(),
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
      onSuccess: (accountId) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ToastHelper.showSuccess(context, 'Authorized successfully');
          _loadOpenAiTokens();
        }
      },
      onError: (error) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ToastHelper.showError(
              context, UserStorage.l10n.authFailed(error.toString()));
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
                  const CircularProgressIndicator(),
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
          ToastHelper.showSuccess(context, 'Authorized as $email');
          _loadGeminiTokens();
        }
      },
      onError: (error) {
        _authFlowCompleted = true;
        _dismissAuthDialog();
        if (mounted) {
          ToastHelper.showError(
              context, UserStorage.l10n.authFailed(error.toString()));
        }
      },
    );
  }

  Widget _buildOpenAiAuthSection() {
    final bool isAuthorized = _openAiTokens != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
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
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    UserStorage.l10n.clearAuth,
                    style: const TextStyle(color: Colors.red),
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
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
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    UserStorage.l10n.clearAuth,
                    style: const TextStyle(color: Colors.red),
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
    _keyController.dispose();
    _modelIdController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _proxyUrlController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    _topPController.dispose();
    _extraController.dispose();
    _bedrockAccessKeyController.dispose();
    _bedrockSecretKeyController.dispose();
    _bedrockRegionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate JSON
    Map<String, dynamic> extraMap = {};
    try {
      if (_extraController.text.isNotEmpty) {
        extraMap = jsonDecode(_extraController.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserStorage.l10n.invalidJsonInExtraField)),
      );
      return;
    }

    // For Bedrock, pack credentials into extra
    if (_selectedType == LLMConfig.typeBedrockClaude) {
      extraMap['accessKeyId'] = _bedrockAccessKeyController.text;
      extraMap['secretAccessKey'] = _bedrockSecretKeyController.text;
      extraMap['region'] = _bedrockRegionController.text.isNotEmpty
          ? _bedrockRegionController.text
          : 'us-west-2';
    }

    // Check Key Uniqueness if new
    if (widget.config == null && await _isKeyExists(_keyController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserStorage.l10n.keyAlreadyExists)),
      );
      return;
    }

    final newConfig = LLMConfig(
      key: _keyController.text,
      type: _selectedType,
      modelId: _modelIdController.text,
      apiKey: _selectedType == LLMConfig.typeBedrockClaude
          ? ''
          : _apiKeyController.text,
      baseUrl: _selectedType == LLMConfig.typeBedrockClaude
          ? ''
          : _baseUrlController.text,
      proxyUrl:
          _proxyUrlController.text.isEmpty ? null : _proxyUrlController.text,
      extra: extraMap,
      temperature: double.tryParse(_temperatureController.text),
      maxTokens: int.tryParse(_maxTokensController.text),
      topP: double.tryParse(_topPController.text), // Fixed line
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

      if (confirmed != true) return;
    }

    final configs = await MemexRouter().getLLMConfigs();
    if (widget.config != null) {
      // Update
      final index = configs.indexWhere((c) => c.key == widget.config!.key);
      if (index != -1) {
        configs[index] = newConfig;
      }
    } else {
      // Add
      configs.add(newConfig);
    }

    await MemexRouter().saveLLMConfigs(configs);
    if (mounted) Navigator.pop(context, true);
  }

  Future<bool> _isKeyExists(String key) async {
    final configs = await MemexRouter().getLLMConfigs();
    return configs.any((c) => c.key == key);
  }

  Future<void> _resetToDefault() async {
    if (widget.config == null || !widget.config!.isDefault) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.resetConfigurationTitle),
        content: Text(UserStorage.l10n.resetConfigurationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(UserStorage.l10n.resetButton,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final defaultKey = widget.config!.key;
    final defaultType = widget.config!.type;
    final defaultLLMConfig =
        LLMConfig.createDefaultConfig(defaultKey, defaultType);

    setState(() {
      _modelIdController.text = defaultLLMConfig.modelId;
      _modelDropdownKey.currentState?.setText(defaultLLMConfig.modelId);
      _apiKeyController.text = defaultLLMConfig.apiKey;
      _baseUrlController.text = defaultLLMConfig.baseUrl;
      _proxyUrlController.text = defaultLLMConfig.proxyUrl ?? '';
      _temperatureController.text =
          defaultLLMConfig.temperature?.toString() ?? '';
      _maxTokensController.text = defaultLLMConfig.maxTokens?.toString() ?? '';
      _topPController.text = defaultLLMConfig.topP?.toString() ?? '';
      _bedrockAccessKeyController.text =
          defaultLLMConfig.extra['accessKeyId'] as String? ?? '';
      _bedrockSecretKeyController.text =
          defaultLLMConfig.extra['secretAccessKey'] as String? ?? '';
      _bedrockRegionController.text =
          defaultLLMConfig.extra['region'] as String? ?? 'us-west-2';

      String extraJson = '{}';
      if (defaultLLMConfig.extra.isNotEmpty) {
        try {
          extraJson = const JsonEncoder.withIndent('  ')
              .convert(defaultLLMConfig.extra);
        } catch (e) {
          extraJson = '{}';
        }
      }
      _extraController.text = extraJson;
      _selectedType = defaultLLMConfig.type;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(UserStorage.l10n.configurationResetPressSave)),
      );
    }
  }

  Future<bool> _showDiscardDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.discardChangesTitle),
        content: Text(UserStorage.l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(UserStorage.l10n.discardButton,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = widget.config?.isDefault ?? false;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.config == null
              ? UserStorage.l10n.addConfiguration
              : UserStorage.l10n.editConfiguration),
          actions: [
            if (isDefault)
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: UserStorage.l10n.resetToDefaults,
                onPressed: _resetToDefault,
              ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _hasChanges
                      ? 1.0 + (_animationController.value * 0.2)
                      : 1.0,
                  child: IconButton(
                    icon: Icon(Icons.save,
                        color: _hasChanges ? Colors.blue.shade700 : null),
                    onPressed: _save,
                  ),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Key
              TextFormField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: UserStorage.l10n.keyIdLabel,
                  helperText: UserStorage.l10n.keyIdHelper,
                  border: const OutlineInputBorder(),
                ),
                enabled: !isDefault, // Default keys cannot be changed
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return UserStorage.l10n.required;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedType.isEmpty ? null : _selectedType,
                hint: Text(UserStorage.l10n.select),
                decoration: InputDecoration(
                  labelText: UserStorage.l10n.clientLabel,
                  border: const OutlineInputBorder(),
                ),
                selectedItemBuilder: (context) {
                  return [
                    const SizedBox.shrink(),
                    const Text('OpenAI (API Key)'),
                    const Text('OpenAI (API Key - Responses)'),
                    const Text('OpenAI (ChatGPT Pro/Plus)'),
                    const SizedBox.shrink(),
                    const Text('Anthropic (API Key)'),
                    const Text('Anthropic (Bedrock Secret)'),
                    const SizedBox.shrink(),
                    const Text('Gemini'),
                    const Text('Gemini (Google OAuth)'),
                  ];
                },
                items: [
                  // ── OpenAI Group ──
                  DropdownMenuItem<String>(
                    enabled: false,
                    value: '__openai_header__',
                    child: Text(
                      'OpenAI',
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
                      child: Text('API Key',
                          style: TextStyle(color: Colors.grey[800])),
                    ),
                  ),
                  DropdownMenuItem(
                    value: LLMConfig.typeResponses,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text('API Key (Responses)',
                          style: TextStyle(color: Colors.grey[800])),
                    ),
                  ),
                  DropdownMenuItem(
                    value: LLMConfig.typeOpenAiOauth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text('ChatGPT Pro/Plus',
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
                        'Anthropic',
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
                      child: Text('API Key',
                          style: TextStyle(color: Colors.grey[800])),
                    ),
                  ),
                  DropdownMenuItem(
                    value: LLMConfig.typeBedrockClaude,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text('Bedrock Secret',
                          style: TextStyle(color: Colors.grey[800])),
                    ),
                  ),
                  // ── Others Group ──
                  DropdownMenuItem<String>(
                    enabled: false,
                    value: '__others_header__',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Others',
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
                      value: LLMConfig.typeGemini, child: const Text('Gemini')),
                  DropdownMenuItem(
                      value: LLMConfig.typeGeminiOauth,
                      child: const Text('Gemini (Google OAuth)')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return UserStorage.l10n.required;
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() => _selectedType = value ?? '');
                  _checkChanges();
                  if (value != null && value.isNotEmpty) {
                    // Reset Model ID
                    final recommended = _getRecommendedModels(value);
                    _modelIdController.text =
                        recommended.isNotEmpty ? recommended.first : '';
                    _modelDropdownKey.currentState
                        ?.setText(_modelIdController.text);
                    // Reset API Key
                    _apiKeyController.text = '';

                    _baseUrlController.text = LLMConfig.defaultBaseUrl(value);
                    if (value == LLMConfig.typeOpenAiOauth) {
                      _loadOpenAiTokens();
                    } else if (value == LLMConfig.typeGeminiOauth) {
                      _loadGeminiTokens();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Model ID
              SearchableDropdown(
                key: _modelDropdownKey,
                options: _getRecommendedModels(_selectedType),
                initialValue: _modelIdController.text,
                onChanged: (value) {
                  _modelIdController.text = value;
                  _checkChanges();
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: UserStorage.l10n.modelIdLabel,
                  helperText: UserStorage.l10n.modelIdHelper,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return UserStorage.l10n.required;
                  }
                  return null;
                },
                optionBuilder: (option, _) {
                  final isPro = _selectedType == LLMConfig.typeOpenAiOauth &&
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
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFFBBF24), width: 0.5),
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
              const SizedBox(height: 16),

              // API Key / Auth / Bedrock Section
              if (_selectedType == LLMConfig.typeOpenAiOauth) ...[
                _buildOpenAiAuthSection(),
              ] else if (_selectedType == LLMConfig.typeGeminiOauth) ...[
                _buildGeminiAuthSection(),
              ] else if (_selectedType == LLMConfig.typeBedrockClaude) ...[
                // Bedrock-specific fields
                TextFormField(
                  controller: _bedrockAccessKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Access Key ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return UserStorage.l10n.required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bedrockSecretKeyController,
                  decoration: InputDecoration(
                    labelText: 'Secret Access Key',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscureApiKey
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _isObscureApiKey = !_isObscureApiKey),
                    ),
                  ),
                  obscureText: _isObscureApiKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return UserStorage.l10n.required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bedrockRegionController,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    hintText: 'us-west-2',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.apiKeyLabel,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscureApiKey
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _isObscureApiKey = !_isObscureApiKey),
                    ),
                  ),
                  obscureText: _isObscureApiKey,
                ),
              ],
              const SizedBox(height: 16),

              // Base URL (hidden for Bedrock - it does not use baseUrl)
              if (_selectedType != LLMConfig.typeBedrockClaude &&
                  _selectedType != LLMConfig.typeOpenAiOauth &&
                  _selectedType != LLMConfig.typeGeminiOauth) ...[
                TextFormField(
                  controller: _baseUrlController,
                  decoration: InputDecoration(
                    labelText: UserStorage.l10n.baseUrlLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return UserStorage.l10n.required;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Advanced Settings
              ExpansionTile(
                title: Text(UserStorage.l10n.advancedSettings),
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _proxyUrlController,
                    decoration: InputDecoration(
                      labelText: UserStorage.l10n.proxyUrlOptional,
                      helperText: UserStorage.l10n.proxyUrlHelper,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _temperatureController,
                          decoration: InputDecoration(
                            labelText: UserStorage.l10n.temperatureLabel,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _topPController,
                          decoration: InputDecoration(
                            labelText: UserStorage.l10n.topPLabel,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxTokensController,
                    decoration: InputDecoration(
                      labelText: UserStorage.l10n.maxTokensLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _extraController,
                    decoration: InputDecoration(
                      labelText: UserStorage.l10n.extraParamsJson,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        try {
                          jsonDecode(value);
                        } catch (e) {
                          return UserStorage.l10n.invalidJson;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

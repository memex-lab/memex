import 'package:flutter/material.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

class AgentConfigListPage extends StatefulWidget {
  const AgentConfigListPage({super.key});

  @override
  State<AgentConfigListPage> createState() => _AgentConfigListPageState();
}

class _AgentConfigListPageState extends State<AgentConfigListPage> {
  List<LLMConfig> _llmConfigs = [];
  Map<String, AgentConfig> _agentConfigs = {};
  bool _isLoading = true;

  final List<String> _agentIds = [
    AgentDefinitions.pkmAgent,
    AgentDefinitions.cardAgent,
    AgentDefinitions.profileAgent,
    AgentDefinitions.knowledgeInsightAgent,
    AgentDefinitions.commentAgent,
    AgentDefinitions.chatAgent,
    AgentDefinitions.analyzeAssets,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final configs = await MemexRouter().getLLMConfigs();
      final agentConfigs = <String, AgentConfig>{};

      for (var agentId in _agentIds) {
        agentConfigs[agentId] = await MemexRouter().getAgentConfig(agentId);
      }

      if (mounted) {
        setState(() {
          _llmConfigs = configs;
          _agentConfigs = agentConfigs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          UserStorage.l10n.loadDataFailed(e.toString()),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAgentConfig(String agentId, AgentConfig config) async {
    try {
      await MemexRouter().saveAgentConfig(agentId, config);
      setState(() {
        _agentConfigs[agentId] = config;
      });
      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.updateSuccess);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          UserStorage.l10n.saveConfigFailed(e.toString()),
        );
      }
    }
  }

  Future<void> _updateAgentModelConfig(
    String agentId,
    String? llmConfigKey,
  ) async {
    final newConfig = (_agentConfigs[agentId] ?? const AgentConfig()).copyWith(
      llmConfigKey: llmConfigKey,
    );
    await _saveAgentConfig(agentId, newConfig);
  }

  bool get _isZh => UserStorage.l10n.localeName == 'zh';

  String get _visionBadgeText => _isZh ? '视觉' : 'Vision';

  String get _mediaModelWarning => _isZh
      ? '媒体分析需要多模态模型。当前模型未标记为可读图，可能会忽略图片内容。'
      : 'Media analysis needs a multimodal model. The current model is not marked as vision-capable and may ignore images.';

  String get _defaultModelPrefix => _isZh ? '默认使用' : 'Default';

  LLMConfig? _findConfig(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final config in _llmConfigs) {
      if (config.key == key) return config;
    }
    return null;
  }

  LLMConfig? _effectiveConfig(String? selectedKey) =>
      _findConfig(selectedKey) ?? _findConfig(LLMConfig.defaultClientKey);

  bool _isKnownMultimodalConfig(LLMConfig config) =>
      LLMConfig.isKnownMultimodal(config.type, config.modelId);

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.agentConfiguration),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_page),
            tooltip: UserStorage.l10n.resetToDefaults,
            onPressed: () async {
              final l10n = UserStorage.l10n;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(l10n.resetAllAgentConfigurationsTitle),
                  content: Text(l10n.resetAllAgentConfigurationsMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        l10n.resetButton,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                setState(() => _isLoading = true);
                try {
                  await MemexRouter().resetAllAgentConfigs();
                  await _loadData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          UserStorage.l10n.agentConfigurationsReset,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          UserStorage.l10n.resetFailed(e.toString()),
                        ),
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AgentLogoLoading())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _agentIds.length,
              itemBuilder: (context, index) {
                final agentId = _agentIds[index];
                final displayName =
                    AgentDefinitions.displayNames[agentId] ?? agentId;
                final currentConfig =
                    _agentConfigs[agentId] ?? const AgentConfig();
                final selectedKey = currentConfig.llmConfigKey;
                final effectiveConfig = _effectiveConfig(selectedKey);
                final showMediaWarning =
                    agentId == AgentDefinitions.analyzeAssets &&
                    effectiveConfig != null &&
                    !_isKnownMultimodalConfig(effectiveConfig);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        UserStorage.l10n.selectLlmClient,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (selectedKey == null && effectiveConfig != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$_defaultModelPrefix: ${effectiveConfig.key} / ${effectiveConfig.modelId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'agent-model-$agentId-${selectedKey ?? ''}',
                        ),
                        initialValue: selectedKey,
                        isExpanded: true,
                        decoration: _dropdownDecoration(),
                        hint: const Text(''),
                        items: [
                          ..._llmConfigs.map((config) {
                            return DropdownMenuItem<String>(
                              value: config.key,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${config.key} / ${config.modelId}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (_isKnownMultimodalConfig(config))
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _visionBadgeText,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != selectedKey) {
                            _updateAgentModelConfig(agentId, newValue);
                          }
                        },
                      ),
                      if (showMediaWarning) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.visibility_off_outlined,
                              size: 15,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _mediaModelWarning,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD97706),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

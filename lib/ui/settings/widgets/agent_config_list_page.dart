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
  static const String _defaultSelectionValue = '__memex_default_llm_config__';

  List<LLMConfig> _llmConfigs = [];
  Map<String, AgentConfig> _agentConfigs = {};
  String _defaultConfigKey = LLMConfig.defaultClientKey;
  bool _isLoading = true;

  final List<String> _agentIds = AgentDefinitions.configurableAgentIds;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final router = MemexRouter();
      final configs = await router.getLLMConfigs();
      final defaultConfigKey = await router.getDefaultLLMConfigKey();
      final agentConfigs = <String, AgentConfig>{};

      for (var agentId in _agentIds) {
        agentConfigs[agentId] = await router.getAgentConfig(agentId);
      }

      if (mounted) {
        setState(() {
          _llmConfigs = configs;
          _defaultConfigKey = defaultConfigKey;
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

  String get _visionBadgeText => UserStorage.l10n.visionBadge;

  String get _defaultModelPrefix => UserStorage.l10n.defaultModelPrefix;

  LLMConfig? _findConfig(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final config in _llmConfigs) {
      if (config.key == key) return config;
    }
    return null;
  }

  LLMConfig? _effectiveConfig(String? selectedKey) =>
      _findConfig(selectedKey) ??
      _findConfig(_defaultConfigKey) ??
      _findConfig(LLMConfig.defaultClientKey);

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
                final selectedConfig = _findConfig(selectedKey);
                final usesDefault =
                    selectedKey == null || selectedConfig == null;
                final effectiveConfig = _effectiveConfig(selectedKey);
                final dropdownValue =
                    usesDefault ? _defaultSelectionValue : selectedKey;

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
                      if (usesDefault && effectiveConfig != null) ...[
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
                          'agent-model-$agentId-$dropdownValue-$_defaultConfigKey',
                        ),
                        initialValue: dropdownValue,
                        isExpanded: true,
                        decoration: _dropdownDecoration(),
                        hint: const Text(''),
                        items: [
                          DropdownMenuItem<String>(
                            value: _defaultSelectionValue,
                            child: Text(
                              effectiveConfig == null
                                  ? UserStorage.l10n.defaultLabel
                                  : '$_defaultModelPrefix: ${effectiveConfig.key} / ${effectiveConfig.modelId}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
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
                          final effectiveValue =
                              newValue == _defaultSelectionValue
                                  ? null
                                  : newValue;
                          if (effectiveValue != selectedKey) {
                            _updateAgentModelConfig(agentId, effectiveValue);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

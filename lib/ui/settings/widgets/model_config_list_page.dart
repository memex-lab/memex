import 'package:flutter/material.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'model_config_edit_page.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

import 'package:memex/domain/models/agent_definitions.dart';

class ModelConfigListPage extends StatefulWidget {
  const ModelConfigListPage({super.key});

  @override
  State<ModelConfigListPage> createState() => _ModelConfigListPageState();
}

class _ModelConfigListPageState extends State<ModelConfigListPage> {
  List<LLMConfig> _configs = [];
  bool _isLoading = true;

  String _providerDisplayName(String type) {
    final l10n = UserStorage.l10n;
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
      case LLMConfig.typeMinimax:
        return l10n.providerMinimax;
      case LLMConfig.typeOpenRouter:
        return l10n.providerOpenRouter;
      case LLMConfig.typeOllama:
        return l10n.providerOllama;
      default:
        return type;
    }
  }

  String get _visionBadgeText => UserStorage.l10n.visionBadge;

  bool _isKnownMultimodalConfig(LLMConfig config) =>
      LLMConfig.isKnownMultimodal(config.type, config.modelId);

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    final configs = await MemexRouter().getLLMConfigs();
    setState(() {
      _configs = configs;
      _isLoading = false;
    });
  }

  Future<List<String>> _getAgentsUsingConfig(String configKey) async {
    final usedByagents = <String>[];
    for (var agentId in AgentDefinitions.displayNames.keys) {
      final config = await MemexRouter().getAgentConfig(agentId);
      if (config.llmConfigKey == configKey) {
        usedByagents.add(AgentDefinitions.displayNames[agentId] ?? agentId);
      }
    }
    return usedByagents;
  }

  Future<bool> _confirmDeleteConfig(LLMConfig config) async {
    final l10n = UserStorage.l10n;
    if (config.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteDefaultConfiguration)),
      );
      return false;
    }

    final usingAgents = await _getAgentsUsingConfig(config.key);
    if (usingAgents.isNotEmpty) {
      if (!mounted) return false;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(l10n.cannotDeleteConfigurationTitle),
          content: Text(l10n.configUsedByAgentsMessage(usingAgents.join('\n'))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return false;
    }

    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(l10n.deleteConfigurationTitle),
            content: Text(l10n.confirmDeleteConfigMessage(config.key)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteConfig(LLMConfig config) async {
    if (await _confirmDeleteConfig(config)) {
      setState(() {
        _configs.removeWhere((item) => item.key == config.key);
      });
      await MemexRouter().saveLLMConfigs(_configs);
    }
  }

  void _editConfig(LLMConfig? config, {LLMConfig? duplicateSource}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelConfigEditPage(
          config: config,
          duplicateSource: duplicateSource,
        ),
      ),
    );

    if (result == true) {
      _loadConfigs();
    }
  }

  void _duplicateConfig(LLMConfig config) {
    final duplicated = config.duplicate(
      existingKeys: _configs.map((c) => c.key).toList(),
    );
    _editConfig(null, duplicateSource: duplicated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.modelConfiguration),
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
                  title: Text(l10n.resetAllConfigurationsTitle),
                  content: Text(l10n.resetAllModelConfigurationsMessage),
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
                  await MemexRouter().resetLLMConfigs();
                  await _loadConfigs();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          UserStorage.l10n.modelConfigurationsReset,
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
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _configs.length,
                    itemBuilder: (context, index) {
                      final config = _configs[index];

                      return Dismissible(
                        key: Key(config.key),
                        direction: config.isDefault
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return _confirmDeleteConfig(config);
                        },
                        onDismissed: (direction) async {
                          setState(() {
                            _configs.removeWhere(
                              (item) => item.key == config.key,
                            );
                          });
                          await MemexRouter().saveLLMConfigs(_configs);
                        },
                        child: ListTile(
                          title: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  config.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (config.isDefault)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    UserStorage.l10n.defaultLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
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
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _visionBadgeText,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '${_providerDisplayName(config.type)} / ${config.modelId}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    config.isValid
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_rounded,
                                    size: 14,
                                    color: config.isValid
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    config.isValid
                                        ? UserStorage.l10n.configured
                                        : UserStorage.l10n.apiKeyNotSet,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: config.isValid
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).moreButtonTooltip,
                            onSelected: (value) {
                              if (value == 'duplicate') {
                                _duplicateConfig(config);
                              } else if (value == 'delete') {
                                _deleteConfig(config);
                              }
                            },
                            itemBuilder: (context) {
                              final l10n = UserStorage.l10n;
                              return [
                                PopupMenuItem<String>(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.copy_outlined, size: 20),
                                      const SizedBox(width: 8),
                                      Text(l10n.duplicate),
                                    ],
                                  ),
                                ),
                                if (!config.isDefault)
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.delete,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ];
                            },
                          ),
                          onTap: () => _editConfig(config),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editConfig(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

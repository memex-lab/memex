import 'package:flutter/material.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'model_config_edit_page.dart';

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

  Future<void> _deleteConfig(int index) async {
    final config = _configs[index];
    final l10n = UserStorage.l10n;
    if (config.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteDefaultConfiguration)),
      );
      return;
    }

    final usingAgents = await _getAgentsUsingConfig(config.key);
    if (usingAgents.isNotEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.cannotDeleteConfigurationTitle),
          content: Text(
            l10n.configUsedByAgentsMessage(usingAgents.join('\n')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfigurationTitle),
        content: Text(l10n.confirmDeleteConfigMessage(config.key)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _configs.removeAt(index);
      });
      await MemexRouter().saveLLMConfigs(_configs);
    }
  }

  void _editConfig(LLMConfig? config) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModelConfigEditPage(config: config),
      ),
    );

    if (result == true) {
      _loadConfigs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.modelConfiguration),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_page),
            tooltip: UserStorage.l10n.resetToDefaults,
            onPressed: () async {
              final l10n = UserStorage.l10n;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.resetAllConfigurationsTitle),
                  content: Text(l10n.resetAllModelConfigurationsMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.resetButton,
                          style: const TextStyle(color: Colors.red)),
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
                          content:
                              Text(UserStorage.l10n.modelConfigurationsReset)),
                    );
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(UserStorage.l10n.resetFailed(e.toString()))),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          if (config.isDefault) return false;

                          final usingAgents =
                              await _getAgentsUsingConfig(config.key);
                          if (usingAgents.isNotEmpty) {
                            if (!context.mounted) return false;
                            final l10n = UserStorage.l10n;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                    Text(l10n.cannotDeleteConfigurationTitle),
                                content: Text(
                                  l10n.configUsedByAgentsMessage(
                                      usingAgents.join('\n')),
                                ),
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

                          if (!context.mounted) return false;

                          final l10n = UserStorage.l10n;
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteConfigurationTitle),
                              content: Text(
                                  l10n.confirmDeleteConfigMessage(config.key)),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          setState(() {
                            _configs.removeAt(index);
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
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (config.isDefault)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.blue.withOpacity(0.5)),
                                  ),
                                  child: Text(UserStorage.l10n.defaultLabel,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.blue)),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!config.isDefault)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () => _deleteConfig(index),
                                ),
                              const Icon(Icons.chevron_right),
                            ],
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

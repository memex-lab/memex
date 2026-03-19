import 'package:flutter/material.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

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
            context, UserStorage.l10n.loadDataFailed(e.toString()));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAgentConfig(String agentId, String? llmConfigKey) async {
    try {
      final newConfig = (_agentConfigs[agentId] ?? const AgentConfig())
          .copyWith(llmConfigKey: llmConfigKey);

      await MemexRouter().saveAgentConfig(agentId, newConfig);

      setState(() {
        _agentConfigs[agentId] = newConfig;
      });

      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.updateSuccess);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.saveConfigFailed(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.agentConfiguration),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_page),
            tooltip: UserStorage.l10n.resetToDefaults,
            onPressed: () async {
              final l10n = UserStorage.l10n;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.resetAllAgentConfigurationsTitle),
                  content: Text(l10n.resetAllAgentConfigurationsMessage),
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
                  await MemexRouter().resetAllAgentConfigs();
                  await _loadData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(UserStorage.l10n.agentConfigurationsReset)),
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
          ? Center(child: AgentLogoLoading())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _agentIds.length,
              itemBuilder: (context, index) {
                final agentId = _agentIds[index];
                final displayName =
                    AgentDefinitions.displayNames[agentId] ?? agentId;
                final currentConfig = _agentConfigs[agentId];
                final selectedKey = currentConfig?.llmConfigKey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          UserStorage.l10n.selectLlmClient,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedKey,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          hint: const Text(''),
                          items: [
                            ..._llmConfigs.map((config) {
                              return DropdownMenuItem<String>(
                                value: config.key,
                                child: Text(
                                  config.key,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != selectedKey) {
                              _updateAgentConfig(agentId, newValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

class CustomAgentConfigPage extends StatefulWidget {
  const CustomAgentConfigPage({super.key});

  @override
  State<CustomAgentConfigPage> createState() => _CustomAgentConfigPageState();
}

class _CustomAgentConfigPageState extends State<CustomAgentConfigPage> {
  List<CustomAgentConfig> _configs = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    final configs = await CustomAgentConfigService.instance.loadAll(userId);
    if (mounted) {
      setState(() {
        _userId = userId;
        _configs = configs;
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(String agentName) async {
    final l10n = UserStorage.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAgent),
        content: Text(l10n.deleteAgentConfirm(agentName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(l10n.deleted, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && _userId != null) {
      await CustomAgentConfigService.instance
          .deleteAndReload(_userId!, agentName);
      await _load();
      if (mounted) ToastHelper.showSuccess(context, l10n.deleted);
    }
  }

  Future<void> _toggleEnabled(CustomAgentConfig config) async {
    if (_userId == null) return;
    final updated = config.copyWith(enabled: !config.enabled);
    await CustomAgentConfigService.instance.saveAndReload(_userId!, updated);
    await _load();
  }

  Future<void> _openEditor({CustomAgentConfig? existing}) async {
    final result = await Navigator.push<CustomAgentConfig>(
      context,
      MaterialPageRoute(
        builder: (_) => _CustomAgentEditPage(
          existing: existing,
          existingNames: _configs.map((c) => c.agentName).toSet(),
        ),
      ),
    );
    if (result != null && _userId != null) {
      if (existing != null && existing.agentName != result.agentName) {
        await CustomAgentConfigService.instance
            .delete(_userId!, existing.agentName);
      }
      await CustomAgentConfigService.instance.saveAndReload(_userId!, result);
      await _load();
      if (mounted) ToastHelper.showSuccess(context, UserStorage.l10n.saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customAgents),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _configs.isEmpty
              ? Center(child: Text(l10n.noCustomAgents))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _configs.length,
                  itemBuilder: (context, index) {
                    final c = _configs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(c.agentName),
                        subtitle: Text(
                          '${c.hostAgentType.name} · ${c.eventType} · '
                          '${c.executionMode == ExecutionMode.async_ ? l10n.executionModeAsync : l10n.executionModeSync}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: c.enabled,
                              onChanged: (_) => _toggleEnabled(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _openEditor(existing: c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              onPressed: () => _delete(c.agentName),
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

// ---------------------------------------------------------------------------
// Edit / Create form
// ---------------------------------------------------------------------------

const String _defaultSkillDirPrefix = '~/_UserSettings/skills/';
const String _defaultWorkDirPrefix = '~/';

/// A TextEditingController that renders a fixed prefix in a different color.
class _PrefixStyledController extends TextEditingController {
  final String prefix;

  _PrefixStyledController({
    required this.prefix,
    String? text,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final color = Theme.of(context).colorScheme.outline;
    final fullText = text;
    if (fullText.startsWith(prefix)) {
      return TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: style?.copyWith(color: color),
          ),
          TextSpan(
            text: fullText.substring(prefix.length),
            style: style,
          ),
        ],
      );
    }
    return TextSpan(text: fullText, style: style);
  }
}

class _CustomAgentEditPage extends StatefulWidget {
  final CustomAgentConfig? existing;
  final Set<String> existingNames;

  const _CustomAgentEditPage({this.existing, required this.existingNames});

  @override
  State<_CustomAgentEditPage> createState() => _CustomAgentEditPageState();
}

class _CustomAgentEditPageState extends State<_CustomAgentEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late _PrefixStyledController _skillDirCtrl;
  late _PrefixStyledController _workDirCtrl;
  late TextEditingController _priorityCtrl;
  late TextEditingController _maxRetriesCtrl;
  late TextEditingController _systemPromptCtrl;

  HostAgentType _hostType = HostAgentType.pure;
  String _eventType = SystemEventTypes.userInputSubmitted;
  ExecutionMode _execMode = ExecutionMode.async_;
  String? _llmConfigKey;
  bool _enabled = true;
  List<String> _selectedDeps = [];
  String? _selectedSerializer;

  List<LLMConfig> _llmConfigs = [];
  List<String> _availableSerializers = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _isEditing = e != null;

    _nameCtrl = TextEditingController(text: e?.agentName ?? '');

    // Skill dir controller holds the full path; prefix is protected from deletion.
    final existingPath = e?.skillDirectoryPath ?? '_UserSettings/skills/';
    final initialSkillDir = '~/$existingPath';
    _skillDirCtrl = _PrefixStyledController(
      prefix: _defaultSkillDirPrefix,
      text: initialSkillDir,
    );
    _skillDirCtrl.addListener(_protectSkillDirPrefix);

    // Working dir controller: prefix '~/' represents user workspace root.
    final existingWorkDir = e?.workingDirectory ?? '';
    final initialWorkDir = '$_defaultWorkDirPrefix$existingWorkDir';
    _workDirCtrl = _PrefixStyledController(
      prefix: _defaultWorkDirPrefix,
      text: initialWorkDir,
    );
    _workDirCtrl.addListener(_protectWorkDirPrefix);

    _priorityCtrl = TextEditingController(text: (e?.priority ?? 0).toString());
    _maxRetriesCtrl =
        TextEditingController(text: (e?.maxRetries ?? 10).toString());
    _systemPromptCtrl = TextEditingController(text: e?.systemPrompt ?? '');

    if (e != null) {
      _hostType = e.hostAgentType;
      _eventType = e.eventType;
      _execMode = e.executionMode;
      _llmConfigKey = e.llmConfigKey;
      _enabled = e.enabled;
      _selectedDeps = List.from(e.dependsOn);
      _selectedSerializer = e.eventSerializerName;
    }
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final configs = await UserStorage.getLLMConfigs();
    final serializers = getRegisteredSerializerNames();
    if (mounted) {
      setState(() {
        _llmConfigs = configs;
        _availableSerializers = serializers;
      });
    }
  }

  /// Get available dependency IDs filtered by current execution mode.
  List<String> _getFilteredDeps() {
    final bus = GlobalEventBus.instance;
    final Set<String> ids;
    if (_execMode == ExecutionMode.async_) {
      ids = bus.getAsyncSubscriptionIds();
    } else {
      ids = bus.getSyncSubscriptionIds();
    }
    return ids.toList()..sort();
  }

  /// Prevent user from deleting the fixed prefix in the skill dir field.
  void _protectSkillDirPrefix() {
    final text = _skillDirCtrl.text;
    if (!text.startsWith(_defaultSkillDirPrefix)) {
      _skillDirCtrl.removeListener(_protectSkillDirPrefix);
      _skillDirCtrl.text = _defaultSkillDirPrefix;
      _skillDirCtrl.selection = TextSelection.collapsed(
        offset: _defaultSkillDirPrefix.length,
      );
      _skillDirCtrl.addListener(_protectSkillDirPrefix);
    } else if (_skillDirCtrl.selection.start < _defaultSkillDirPrefix.length) {
      _skillDirCtrl.selection = TextSelection.collapsed(
        offset: _defaultSkillDirPrefix.length,
      );
    }
  }

  /// Prevent user from deleting the fixed prefix in the working dir field.
  void _protectWorkDirPrefix() {
    final text = _workDirCtrl.text;
    if (!text.startsWith(_defaultWorkDirPrefix)) {
      _workDirCtrl.removeListener(_protectWorkDirPrefix);
      _workDirCtrl.text = _defaultWorkDirPrefix;
      _workDirCtrl.selection = TextSelection.collapsed(
        offset: _defaultWorkDirPrefix.length,
      );
      _workDirCtrl.addListener(_protectWorkDirPrefix);
    } else if (_workDirCtrl.selection.start < _defaultWorkDirPrefix.length) {
      _workDirCtrl.selection = TextSelection.collapsed(
        offset: _defaultWorkDirPrefix.length,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skillDirCtrl.dispose();
    _workDirCtrl.dispose();
    _priorityCtrl.dispose();
    _maxRetriesCtrl.dispose();
    _systemPromptCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    // Strip the visual '~/' prefix to get the relative path for storage.
    final fullSkillDir = _skillDirCtrl.text.trim();
    final skillRelative = fullSkillDir.startsWith('~/')
        ? fullSkillDir.substring(2)
        : fullSkillDir;
    final skillPath =
        skillRelative.isEmpty ? '_UserSettings/skills/' : skillRelative;

    final fullWorkDir = _workDirCtrl.text.trim();
    final workDirRelative =
        fullWorkDir.startsWith('~/') ? fullWorkDir.substring(2) : fullWorkDir;

    final config = CustomAgentConfig(
      agentName: name,
      hostAgentType: _hostType,
      skillDirectoryPath: skillPath,
      workingDirectory: workDirRelative,
      llmConfigKey: _llmConfigKey,
      eventType: _eventType,
      executionMode: _execMode,
      dependsOn: _selectedDeps,
      enabled: _enabled,
      priority: int.tryParse(_priorityCtrl.text) ?? 0,
      maxRetries: int.tryParse(_maxRetriesCtrl.text) ?? 10,
      systemPrompt: _systemPromptCtrl.text.trim().isEmpty
          ? null
          : _systemPromptCtrl.text.trim(),
      eventSerializerName: _selectedSerializer,
    );

    Navigator.pop(context, config);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAgent : l10n.newAgent),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Agent Name
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.agentName,
                hintText: l10n.agentNameHint,
                border: const OutlineInputBorder(),
              ),
              enabled: !_isEditing,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.agentNameRequired;
                }
                if (!CustomAgentConfig.isValidAgentName(v.trim())) {
                  return l10n.agentNameInvalid;
                }
                if (!_isEditing && widget.existingNames.contains(v.trim())) {
                  return l10n.agentNameExists;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Host Agent Type
            DropdownButtonFormField<HostAgentType>(
              initialValue: _hostType,
              decoration: InputDecoration(
                labelText: l10n.hostAgentType,
                border: const OutlineInputBorder(),
              ),
              style: bodyStyle,
              items: HostAgentType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t == HostAgentType.pure ? 'Pure' : 'Memex',
                          style: bodyStyle,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _hostType = v!),
            ),
            const SizedBox(height: 16),

            // Skill Directory (full path, prefix protected from deletion)
            TextFormField(
              controller: _skillDirCtrl,
              decoration: InputDecoration(
                labelText: l10n.skillDirectory,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (!text.startsWith(_defaultSkillDirPrefix)) {
                  return l10n.skillDirInvalid;
                }
                final suffix =
                    text.substring(_defaultSkillDirPrefix.length).trim();
                if (suffix.isNotEmpty &&
                    (suffix.startsWith('/') || suffix.contains('..'))) {
                  return l10n.skillDirInvalid;
                }
                return null;
              },
              onTap: () {
                // Ensure cursor stays after the prefix.
                if (_skillDirCtrl.selection.start <
                    _defaultSkillDirPrefix.length) {
                  _skillDirCtrl.selection = TextSelection.collapsed(
                    offset: _defaultSkillDirPrefix.length,
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Working Directory (prefix-protected, relative to workspace root)
            TextFormField(
              controller: _workDirCtrl,
              decoration: InputDecoration(
                labelText: l10n.workingDirectory,
                hintText: l10n.workingDirectoryHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (!text.startsWith(_defaultWorkDirPrefix)) {
                  return l10n.workingDirectoryHint;
                }
                final suffix =
                    text.substring(_defaultWorkDirPrefix.length).trim();
                if (suffix.isNotEmpty && suffix.contains('..')) {
                  return l10n.workingDirectoryHint;
                }
                return null;
              },
              onTap: () {
                if (_workDirCtrl.selection.start <
                    _defaultWorkDirPrefix.length) {
                  _workDirCtrl.selection = TextSelection.collapsed(
                    offset: _defaultWorkDirPrefix.length,
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // LLM Config
            DropdownButtonFormField<String>(
              initialValue: _llmConfigKey ??
                  (_llmConfigs.isNotEmpty ? _llmConfigs.first.key : null),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.llmConfig,
                border: const OutlineInputBorder(),
              ),
              style: bodyStyle,
              items: _llmConfigs
                  .map((c) => DropdownMenuItem(
                        value: c.key,
                        child: Text(c.key,
                            overflow: TextOverflow.ellipsis, style: bodyStyle),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _llmConfigKey = v),
            ),
            const SizedBox(height: 16),

            // Event Type
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.eventType,
                border: const OutlineInputBorder(),
              ),
              style: bodyStyle,
              items: SystemEventTypes.allTypes
                  .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t,
                          overflow: TextOverflow.ellipsis, style: bodyStyle)))
                  .toList(),
              onChanged: (v) => setState(() => _eventType = v!),
            ),
            const SizedBox(height: 16),

            // Execution Mode
            DropdownButtonFormField<ExecutionMode>(
              initialValue: _execMode,
              decoration: InputDecoration(
                labelText: l10n.executionMode,
                border: const OutlineInputBorder(),
              ),
              style: bodyStyle,
              items: [
                DropdownMenuItem(
                    value: ExecutionMode.async_,
                    child: Text(l10n.executionModeAsync, style: bodyStyle)),
                DropdownMenuItem(
                    value: ExecutionMode.sync,
                    child: Text(l10n.executionModeSync, style: bodyStyle)),
              ],
              onChanged: (v) {
                setState(() {
                  _execMode = v!;
                  // Clear deps that are no longer valid for the new mode.
                  final validDeps = _getFilteredDeps().toSet();
                  _selectedDeps.removeWhere((d) => !validDeps.contains(d));
                });
              },
            ),
            const SizedBox(height: 16),

            // Depends On (dropdown to add + chips to show/remove)
            _buildDependsOnField(l10n, bodyStyle),
            const SizedBox(height: 16),

            // Async-only fields
            if (_execMode == ExecutionMode.async_) ...[
              TextFormField(
                controller: _priorityCtrl,
                decoration: InputDecoration(
                  labelText: l10n.priority,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxRetriesCtrl,
                decoration: InputDecoration(
                  labelText: l10n.maxRetries,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],

            // System Prompt
            TextFormField(
              controller: _systemPromptCtrl,
              decoration: InputDecoration(
                labelText: l10n.systemPromptLabel,
                hintText: l10n.systemPromptHint,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),

            // Event Serializer
            DropdownButtonFormField<String?>(
              initialValue: _selectedSerializer,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.eventSerializer,
                border: const OutlineInputBorder(),
              ),
              style: bodyStyle,
              items: [
                DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.eventSerializerDefault, style: bodyStyle)),
                ..._availableSerializers.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: bodyStyle),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedSerializer = v),
            ),
            const SizedBox(height: 16),

            // Enabled
            SwitchListTile(
              title: Text(l10n.enabledLabel),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Depends On" field: a dropdown to pick deps + chips to display/remove.
  Widget _buildDependsOnField(dynamic l10n, TextStyle? bodyStyle) {
    final filteredDeps = _getFilteredDeps();
    // Only show deps not already selected in the dropdown.
    final availableToAdd =
        filteredDeps.where((d) => !_selectedDeps.contains(d)).toList();

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.dependsOn,
        border: const OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected deps as removable chips
          if (_selectedDeps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedDeps.map((dep) {
                  return Chip(
                    label: Text(dep, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _selectedDeps.remove(dep));
                    },
                  );
                }).toList(),
              ),
            ),
          // Dropdown to add new dep
          if (availableToAdd.isNotEmpty)
            DropdownButton<String>(
              isExpanded: true,
              hint: Text(l10n.dependsOnHint, style: bodyStyle),
              style: bodyStyle,
              underline: const SizedBox.shrink(),
              items: availableToAdd
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, style: bodyStyle),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedDeps.add(v));
                }
              },
            )
          else if (_selectedDeps.isEmpty)
            Text(
              l10n.dependsOnHint,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, fontSize: 14),
            ),
        ],
      ),
    );
  }
}

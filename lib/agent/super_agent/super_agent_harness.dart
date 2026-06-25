import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:path/path.dart' as p;

import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/agent/super_agent/pkm_stats_service.dart';
import 'package:memex/agent/super_agent/pending_tool_image_buffer.dart';
import 'package:memex/utils/logger.dart';

final _logger = getLogger('SuperAgentHarness');

/// Harness control plane for the SuperAgent and its capture child workers.
///
/// Adds SuperAgent post-tool / turn-completion guidance without hard-coding
/// workflow gates:
///
/// - **PKM structural-health reminders**: when an agent reads a `/PKM` file,
///   append "file too long / fragmented / churned" advice. PKM organization
///   can happen in child workers or in parent repair flows, so this is wired
///   into both [buildParentHook] and [buildChildHook].
/// - **Idle-skill reminder** (parent only): when the parent keeps a skill
///   active but unused for several turns, gently suggest deactivating it.
///
/// The earlier "you saved a card but didn't organize it into PKM" nudge has
/// been removed: capture now fans PKM out as a parallel child worker by design,
/// so the nudge is obsolete.
class SuperAgentHarness {
  SuperAgentHarness._();

  /// Per-session, per-turn skill-usage tracking, keyed by sessionId. Pure
  /// memory, never persisted. Updated by the post-tool hook, read+cleared by
  /// the turn-completion hook.
  static final Map<String, _CaptureTurnState> _captureState = {};

  /// AgentState.metadata key for cross-turn idle counters:
  /// optional-skill name -> number of consecutive user turns in which none of
  /// that skill's tools were used. Unlike [_captureState], this belongs to the
  /// persisted agent session so close/reopen and app restart preserve the
  /// reminder timing.
  ///
  /// Now that capture fans out to child workers, the SuperAgent itself only
  /// activates a skill for conversational / repair work — typically one skill,
  /// used every turn. So "active but unused for 3 turns straight" cleanly means
  /// the user has moved on, and a gentle deactivate reminder keeps context
  /// focused. (The earlier multi-skill capture flow made this noisy; that flow
  /// is gone.)
  static const _idleSkillTurnsMetadataKey = 'super_agent_idle_skill_turns_v1';

  /// Consecutive idle user turns before reminding to deactivate a skill.
  static const _skillIdleReminderThreshold = 3;

  static _CaptureTurnState _stateFor(String sessionId) =>
      _captureState.putIfAbsent(sessionId, () => _CaptureTurnState());

  /// Parent hook: idle-skill tracking + PKM structural-health reminders on
  /// `/PKM` reads + end-of-turn idle reminder maintenance.
  static AgentHook buildParentHook(String userId) {
    return _SuperAgentHarnessHook(userId: userId, trackIdleSkills: true);
  }

  /// Child-worker hook: PKM structural-health reminders only. Child
  /// workers don't persist across turns and don't manage their own skill
  /// lifecycle, so the idle-skill tracking does not apply to them. Harmless on
  /// card/schedule workers — it only fires when a `/PKM` file is actually read.
  static AgentHook buildChildHook(String userId) {
    return _SuperAgentHarnessHook(userId: userId, trackIdleSkills: false);
  }

  static Future<List<LLMMessage>> _pkmHealthInjectedMessages(
      String userId, FunctionExecutionResult result) async {
    if (result.name == 'Read' && !result.isError) {
      final reminder = await _buildPkmHealthReminder(userId, result);
      if (reminder != null) {
        return [UserMessage.text(reminder)];
      }
    }
    return const [];
  }

  // --- helpers ---

  /// Name of the optional (non-force-active) skill that owns [toolName], or
  /// null if the tool is built-in / belongs to a force-active skill / unknown.
  /// Read dynamically from the agent's skill registry.
  static String? _optionalSkillForTool(StatefulAgent agent, String toolName) {
    final skills = agent.skills;
    if (skills == null) return null;
    for (final skill in skills) {
      if (skill.forceActivate) continue;
      final tools = skill.tools;
      if (tools == null) continue;
      if (tools.any((t) => t.name == toolName)) return skill.name;
    }
    return null;
  }

  /// At the end of a user turn, age the idle counter for each active optional
  /// skill (reset to 0 if any of its tools were used this turn, else +1; drop
  /// counters for skills no longer active), then (re)build the idle-skill
  /// reminder in [state.systemReminders] or clear it when nothing is idle.
  ///
  /// systemReminders is a sticky, self-correcting channel: the reminder is
  /// re-derived from current state every turn, so as soon as the model
  /// deactivates the skill or uses it again, the reminder disappears on its own.
  static void _ageIdleSkillsAndBuildReminder(
    StatefulAgent agent,
    AgentState state,
    Set<String> usedSkills,
  ) {
    final optionalActive = (state.activeSkills ?? const <String>[]).where((n) {
      final skill = agent.skills?.where((s) => s.name == n).firstOrNull;
      return skill != null && !skill.forceActivate;
    }).toSet();

    final counters = _idleTurnsFromMetadata(state);
    counters.removeWhere((name, _) => !optionalActive.contains(name));
    for (final name in optionalActive) {
      counters[name] =
          usedSkills.contains(name) ? 0 : (counters[name] ?? 0) + 1;
    }

    final idle = counters.entries
        .where((e) => e.value >= _skillIdleReminderThreshold)
        .map((e) => e.key)
        .toList();

    _writeIdleTurnsToMetadata(state, counters);

    const reminderKey = 'idle_skills';
    if (idle.isEmpty) {
      state.systemReminders.remove(reminderKey);
    } else {
      state.systemReminders[reminderKey] =
          'These skills have stayed active but unused for the last '
          '$_skillIdleReminderThreshold turns: ${idle.join(', ')}. '
          "If you're done with them, call "
          "deactivate_skills(['${idle.join("', '")}']) to keep your context "
          'focused. If you still need them, ignore this.';
    }
  }

  static Map<String, int> _idleTurnsFromMetadata(AgentState state) {
    final raw = state.metadata[_idleSkillTurnsMetadataKey];
    if (raw is! Map) return <String, int>{};

    final counters = <String, int>{};
    for (final entry in raw.entries) {
      final key = entry.key?.toString();
      if (key == null || key.isEmpty) continue;

      final value = entry.value;
      int? count;
      if (value is int) {
        count = value;
      } else if (value is num) {
        count = value.toInt();
      } else if (value is String) {
        count = int.tryParse(value);
      }

      if (count != null && count > 0) {
        counters[key] = count;
      }
    }
    return counters;
  }

  static void _writeIdleTurnsToMetadata(
    AgentState state,
    Map<String, int> counters,
  ) {
    final positiveCounters = {
      for (final entry in counters.entries)
        if (entry.value > 0) entry.key: entry.value,
    };

    if (positiveCounters.isEmpty) {
      state.metadata.remove(_idleSkillTurnsMetadataKey);
      return;
    }

    state.metadata[_idleSkillTurnsMetadataKey] = positiveCounters;
  }

  static bool _isUnderPkm(String path) {
    final norm = path.startsWith('/') ? path : '/$path';
    return norm == '/PKM' || norm.startsWith('/PKM/');
  }

  static String? _argString(String argumentsJson, String key) {
    try {
      final decoded = jsonDecode(argumentsJson);
      if (decoded is Map && decoded[key] is String) {
        return decoded[key] as String;
      }
    } catch (_) {}
    return null;
  }

  /// Builds PKM structural-health reminders for `/PKM` reads. Returns null
  /// when no reminder applies.
  static Future<String?> _buildPkmHealthReminder(
      String userId, FunctionExecutionResult result) async {
    final filePath = _argString(result.arguments, 'file_path');
    if (filePath == null || !_isUnderPkm(filePath)) return null;

    final workingDirectory =
        FileSystemService.instance.getWorkspacePath(userId);
    final reminders = <String>[];

    // 1. Line count check (from the read result content text).
    final text = _resultText(result);
    final lineCount = '\n'.allMatches(text).length + 1;
    if (lineCount >= 2000) {
      reminders.add(
          'The file "$filePath" contains $lineCount lines, exceeding the 2000-line limit. Adjust it to comply with P.A.R.A. structure after processing.');
    } else if (lineCount > 1000) {
      reminders.add(
          'The file "$filePath" contains $lineCount lines. Consider whether the P.A.R.A. structure is reasonable after processing.');
    }

    // 2. Directory fragmentation check.
    try {
      final parentDir = p.dirname(filePath);
      final grepResult = await FileOperationService.instance.grepFiles(
        pattern: 'fact_id',
        searchPath: parentDir,
        workingDirectory: workingDirectory,
        outputMode: 'count',
        r: false,
      );
      if (!grepResult.startsWith('No matches found')) {
        var fragmented = 0;
        final infos = <String>[];
        for (final line in grepResult.split('\n')) {
          if (line.startsWith('(Output limited')) continue;
          final lastColon = line.lastIndexOf(':');
          if (lastColon == -1) continue;
          final fPath = line.substring(0, lastColon).trim();
          final count = int.tryParse(line.substring(lastColon + 1).trim());
          if (count != null && count <= 1) {
            fragmented++;
            infos.add('${p.basename(fPath)} ($count)');
          }
        }
        if (fragmented > 5) {
          reminders.add(
              'The directory "$parentDir" has $fragmented files with only one fact_id reference each: ${infos.join(", ")}. Consider consolidating to avoid excessive fragmentation after processing.');
        }
      }
    } catch (_) {
      // ignore directory access errors
    }

    // 3. Filename date check.
    final filename = p.basename(filePath);
    if (RegExp(r'20\d{2}-?(?:0[1-9]|1[0-2])-?(?:0[1-9]|[12]\d|3[01])')
        .hasMatch(filename)) {
      reminders.add(
          'The file "$filename" contains a date in its filename. Reconsider whether this name is reasonable (P.A.R.A. names should be topic-based, not time-based) after processing.');
    }

    // 4. Frequent edit check.
    try {
      final editCount =
          await PkmStatsService.instance.getRecentEditCount(userId, filePath);
      if (editCount >= 3) {
        final hasDate = RegExp(r'(20\d{2})').hasMatch(filename);
        reminders.add(hasDate
            ? 'The file "$filename" was modified in $editCount of the last 5 inputs and has a date in its name, suggesting a time-based log. Consider renaming to a topic-based name or splitting it.'
            : 'The file "$filename" was modified in $editCount of the last 5 inputs, suggesting its name is too generic. Consider renaming it to be more specific or splitting it.');
      }
    } catch (_) {
      // ignore stats errors
    }

    if (reminders.isEmpty) return null;
    return '<system-reminder>\nP.A.R.A. structural health for the file you just read:\n- ${reminders.join('\n- ')}\n</system-reminder>';
  }

  static String _resultText(FunctionExecutionResult result) {
    final buffer = StringBuffer();
    for (final part in result.content) {
      if (part is TextPart) buffer.write(part.text);
    }
    return buffer.toString();
  }
}

/// Per-session, per-turn skill-usage tracking. Reset (removed) on turn
/// completion. Feeds the idle-skill reminder.
class _CaptureTurnState {
  /// Optional skills whose tools were used during this user turn.
  final Set<String> usedSkills = {};
}

class _SuperAgentHarnessHook extends AgentHook {
  final String userId;
  final bool trackIdleSkills;

  _SuperAgentHarnessHook({
    required this.userId,
    required this.trackIdleSkills,
  });

  @override
  Future<ToolResultHookResult> afterToolCall(
    ToolResultHookContext context,
  ) async {
    try {
      final result = context.result;
      if (trackIdleSkills && !result.isError) {
        final owningSkill = SuperAgentHarness._optionalSkillForTool(
          context.agent,
          result.name,
        );
        if (owningSkill != null) {
          SuperAgentHarness._stateFor(context.state.sessionId)
              .usedSkills
              .add(owningSkill);
        }
      }

      final injectedMessages = <LLMMessage>[
        ...PendingToolImageBuffer.instance.drainAsMessages(
          context.state.sessionId,
        ),
        ...await SuperAgentHarness._pkmHealthInjectedMessages(userId, result),
      ];

      return ToolResultHookResult.proceed(
        result: result,
        injectedMessages: injectedMessages,
      );
    } catch (e, st) {
      _logger.warning(
        '[${context.agent.name}] super agent after-tool hook failed; skipping reminder.',
        e,
        st,
      );
      return ToolResultHookResult.proceed(result: context.result);
    }
  }

  @override
  TurnCompletionHookResult onTurnCompletion(
    TurnCompletionHookContext context,
  ) {
    if (!trackIdleSkills) {
      return const TurnCompletionHookResult.accept();
    }

    try {
      final sessionId = context.state.sessionId;
      final turn = SuperAgentHarness._captureState[sessionId];

      SuperAgentHarness._ageIdleSkillsAndBuildReminder(
        context.agent,
        context.state,
        turn?.usedSkills ?? const <String>{},
      );
      SuperAgentHarness._captureState.remove(sessionId);
    } catch (e, st) {
      _logger.warning(
        '[${context.agent.name}] super agent turn-completion hook failed; accepting completion.',
        e,
        st,
      );
    }

    return const TurnCompletionHookResult.accept();
  }
}

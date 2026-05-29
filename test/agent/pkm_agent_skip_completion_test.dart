import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/pkm_agent/pkm_agent.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/pkm_agent_handler.dart';

const _factId = '2026/05/18.md#ts_1';

void main() {
  group('PkmAgent non-persistent input detection', () {
    test('detects explicit opt-out phrases', () {
      final inputs = [
        '只是试一下 今天早点睡，不要写成长记忆，也不要影响 导出灰度。',
        '今天有点烦，主要是临时事情太碎，这只是今天状态，不要写成长记忆。',
        '临时提醒，不要长期保存',
        '测试一下，别写进记忆',
        '只是试一下，不要记',
      ];

      for (final input in inputs) {
        final decision = PkmAgent.detectNonPersistentInput(input);
        expect(decision.shouldSkip, isTrue, reason: input);
        expect(decision.evidence, isNotEmpty);
      }
    });

    test('does not skip durable inputs or unrelated negative wording', () {
      final durableInputs = [
        '导出灰度提醒规则需要更新一下，后面每周五看一次。',
        '咖啡喝多了以后不要影响睡眠，帮我记一下这个规律。',
        '不要忘记明天晚上检查导出灰度。',
        '今天早点睡，导出灰度提醒规则继续保留。',
        // Q&A and curiosities must not be skipped — they are PKM material.
        '怎么做 agent 评估呢？',
        '今天看到一支特别想要的钢笔。',
      ];

      for (final input in durableInputs) {
        expect(
          PkmAgent.detectNonPersistentInput(input).shouldSkip,
          isFalse,
          reason: input,
        );
      }
    });
  });

  group('PkmAgent completion evidence', () {
    const factId = '2026/05/18.md#ts_1';

    test('persistent path is complete only with PARA write and insight', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'Write',
            arguments: {'file_path': '/Projects/export.md', 'content': factId},
          ),
          _toolResultMessage(
            name: 'update_timeline_card_insight',
            arguments: {
              'fact_id': factId,
              'insight_text': 'Keep the cadence small.',
            },
          ),
        ],
      );

      expect(evidence.wrotePara, isTrue);
      expect(evidence.updatedInsight, isTrue);
      expect(evidence.skippedPkm, isFalse);
      expect(evidence.isComplete, isTrue);
      expect(evidence.missingRequirements, isEmpty);
    });

    test('write alone remains incomplete and reports missing insight', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'Edit',
            arguments: {'file_path': '/Projects/export.md', 'content': factId},
          ),
        ],
      );

      expect(evidence.wrotePara, isTrue);
      expect(evidence.updatedInsight, isFalse);
      expect(evidence.isComplete, isFalse);
      expect(
        evidence.missingRequirements,
        contains('updated_timeline_card_insight'),
      );
    });

    test('skip tool is a valid no-op completion path without PKM writes', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'skip_pkm_organization',
            arguments: {'evidence': '不要写成长记忆'},
          ),
        ],
      );

      expect(evidence.wrotePara, isFalse);
      expect(evidence.updatedInsight, isFalse);
      expect(evidence.skippedPkm, isTrue);
      expect(evidence.skipEvidence, '不要写成长记忆');
      expect(evidence.isComplete, isTrue);
      expect(evidence.toJson()['skipped_pkm'], isTrue);
    });

    test('skip is not accepted after a successful PKM mutation', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'Write',
            arguments: {
              'file_path': '/Projects/导出灰度提醒设置.md',
              'content': 'accidental write',
            },
          ),
          _toolResultMessage(
            name: 'skip_pkm_organization',
            arguments: {'evidence': '不要影响导出灰度'},
          ),
        ],
      );

      expect(evidence.skippedPkm, isTrue);
      expect(evidence.successfulPkmMutation, isTrue);
      expect(evidence.isComplete, isFalse);
      expect(
        evidence.missingRequirements,
        contains('skip_without_successful_pkm_mutation'),
      );
    });

    test('failed skip tool result is ignored', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'skip_pkm_organization',
            isError: true,
            arguments: {'evidence': '不要写成长记忆'},
          ),
        ],
      );

      expect(evidence.skippedPkm, isFalse);
      expect(evidence.isComplete, isFalse);
      expect(evidence.missingRequirements, contains('skip_pkm_organization'));
    });
  });

  group('PkmAgent skip prompt and tool contract', () {
    test('prompt mentions skip but does not encourage over-skipping', () {
      final prompt = Prompts.pkmSkillSystemPrompt(
        '/',
        'P.A.R.A. example',
        'Use user language for files.',
        'Use user language for insight.',
      );

      // Skip is documented, but only for explicit opt-out.
      expect(prompt, contains('skip_pkm_organization'));
      expect(prompt, contains('explicitly asks not to save'));

      // Clarification responsibility now lives in AskClarificationAgent.
      expect(prompt, isNot(contains('Information-Insufficient Inputs')));
      expect(prompt, isNot(contains('ask_clarification')));
      expect(
        prompt,
        contains(
            'Do not ask users for additional information or clarification.'),
      );

      // Old over-broad / over-specified skip guidance must be gone.
      expect(prompt, isNot(contains('low_signal_noise')));
      expect(prompt, isNot(contains('temporary_state')));
      expect(prompt, isNot(contains('duplicate_existing_memory')));
    });

    test('insight prompt asks for synthesis without narrowing evidence', () {
      final prompt = Prompts.pkmSkillSystemPrompt(
        '/',
        'P.A.R.A. example',
        'Use user language for files.',
        'Use user language for insight.',
      );

      expect(prompt,
          contains('coherent observation rather than an evidence inventory'));
      expect(prompt, contains('The insight can be broad or deep'));
      expect(prompt, contains('calm, perceptive memory companion'));
      expect(prompt, contains('Do not sound like a coach'));
      expect(prompt, contains('project manager'));
      expect(prompt, isNot(contains('Progress State')));
      expect(prompt, isNot(contains('Preference / Identity')));

      final parameters = Prompts.pkmAgentUpdateCardInsightToolParameters;
      final properties = parameters['properties'] as Map<String, dynamic>;
      expect(
        properties['insight_text']['description'] as String,
        contains('Synthesize relevant history'),
      );
      expect(
        properties['related_fact_ids']['description'] as String,
        contains('Complete coverage list of historical fact_ids'),
      );
      expect(
        properties['related_fact_ids']['description'] as String,
        contains('not a citation list for insight_text'),
      );
      expect(
        prompt,
        contains(
            'include it even when the visible insight does not mention it'),
      );
      expect(properties, isNot(contains('summary_text')));
      expect(parameters['required'], ['fact_id', 'insight_text']);
    });

    test('skip tool parameters require only an evidence quote', () {
      final parameters = Prompts.pkmAgentSkipOrganizationToolParameters;
      final properties = parameters['properties'] as Map<String, dynamic>;

      expect(properties.keys, ['evidence']);
      expect(parameters['required'], ['evidence']);
    });
  });

  group('PkmAgent task handler skip path', () {
    test(
      'explicit opt-out input completes without invoking LLM resources',
      () async {
        await expectLater(
          handlePkmAgentImpl(
            'user-a',
            {
              'fact_id': _factId,
              'combined_text': '今天有点烦，这只是今天状态，不要写成长记忆。',
              'created_at_ts': 1779080000,
            },
            TaskContext(taskId: 'task-opt-out', taskType: 'pkm_agent_task'),
          ),
          completes,
        );
      },
    );
  });
}

FunctionExecutionResultMessage _toolResultMessage({
  required String name,
  required Map<String, dynamic> arguments,
  bool isError = false,
}) {
  return FunctionExecutionResultMessage(
    results: [
      FunctionExecutionResult(
        id: 'call_$name',
        name: name,
        isError: isError,
        arguments: jsonEncode(arguments),
        content: [TextPart(isError ? 'failed' : 'ok')],
      ),
    ],
  );
}

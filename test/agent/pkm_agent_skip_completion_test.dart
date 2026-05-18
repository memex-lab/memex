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
    test('detects explicit opt-out phrases from issue 128', () {
      final cases = {
        '只是试一下 今天早点睡，不要写成长记忆，也不要影响 导出灰度。': 'explicit_user_opt_out',
        '今天有点烦，主要是临时事情太碎，这只是今天状态，不要写成长记忆。': 'explicit_user_opt_out',
        '临时提醒，不要长期保存': 'explicit_user_opt_out',
        '测试一下，别写进记忆': 'explicit_user_opt_out',
        '只是试一下，不要记': 'explicit_user_opt_out',
      };

      for (final entry in cases.entries) {
        final decision = PkmAgent.detectNonPersistentInput(entry.key);

        expect(decision.shouldSkip, isTrue, reason: entry.key);
        expect(decision.reason, entry.value, reason: entry.key);
        expect(decision.evidence, isNotEmpty);
      }
    });

    test(
      'detects temporary state plus explicit boundary on existing knowledge',
      () {
        final decision = PkmAgent.detectNonPersistentInput(
          '这只是今天状态，不要影响导出灰度提醒规则。',
        );

        expect(decision.shouldSkip, isTrue);
        expect(decision.reason, 'temporary_state');
        expect(decision.temporalScope, 'temporary');
      },
    );

    test('does not skip durable inputs or unrelated negative wording', () {
      final durableInputs = [
        '导出灰度提醒规则需要更新一下，后面每周五看一次。',
        '咖啡喝多了以后不要影响睡眠，帮我记一下这个规律。',
        '不要忘记明天晚上检查导出灰度。',
        '今天早点睡，导出灰度提醒规则继续保留。',
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

    test(
      'persistent path is complete only with P.A.R.A. write and insight',
      () {
        final evidence = PkmAgent.inspectPkmRunCompletion(
          factId: factId,
          messages: [
            _toolResultMessage(
              name: 'Write',
              arguments: {
                'file_path': '/Projects/export.md',
                'content': factId,
              },
            ),
            _toolResultMessage(
              name: 'update_timeline_card_insight',
              arguments: {
                'fact_id': factId,
                'insight_text': 'Keep the cadence small.',
                'summary_text': 'Updated the related project note.',
              },
            ),
          ],
        );

        expect(evidence.wrotePara, isTrue);
        expect(evidence.updatedInsight, isTrue);
        expect(evidence.skippedPkm, isFalse);
        expect(evidence.isComplete, isTrue);
        expect(evidence.missingRequirements, isEmpty);
      },
    );

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
            arguments: {
              'reason': 'explicit_user_opt_out',
              'temporal_scope': 'temporary',
              'evidence': '不要写成长记忆',
            },
          ),
        ],
      );

      expect(evidence.wrotePara, isFalse);
      expect(evidence.updatedInsight, isFalse);
      expect(evidence.skippedPkm, isTrue);
      expect(evidence.skipReason, 'explicit_user_opt_out');
      expect(evidence.skipTemporalScope, 'temporary');
      expect(evidence.skipEvidence, '不要写成长记忆');
      expect(evidence.isComplete, isTrue);
      expect(evidence.toJson()['skipped_pkm'], isTrue);
    });

    test(
      'clarification request is a valid completion path without PKM writes',
      () {
        final evidence = PkmAgent.inspectPkmRunCompletion(
          factId: factId,
          messages: [
            _toolResultMessage(
              name: 'create_clarification_request',
              arguments: {
                'question': '周末具体是周六还是周日？',
                'response_type': 'single_choice',
                'evidence_fact_ids': [factId],
                'dedupe_key': 'weekend:reminder_time',
              },
            ),
          ],
        );

        expect(evidence.wrotePara, isFalse);
        expect(evidence.updatedInsight, isFalse);
        expect(evidence.clarificationRequested, isTrue);
        expect(evidence.clarificationDedupeKey, 'weekend:reminder_time');
        expect(evidence.isComplete, isTrue);
        expect(evidence.missingRequirements, isEmpty);
        expect(evidence.toJson()['clarification_requested'], isTrue);
      },
    );

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
            arguments: {
              'reason': 'explicit_user_opt_out',
              'temporal_scope': 'temporary',
              'evidence': '不要影响导出灰度',
            },
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

    test('clarification alone is not accepted after a PKM mutation', () {
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
            name: 'create_clarification_request',
            arguments: {
              'question': '要提醒的具体时间是什么？',
              'response_type': 'short_text',
              'dedupe_key': 'reminder:time',
            },
          ),
        ],
      );

      expect(evidence.clarificationRequested, isTrue);
      expect(evidence.successfulPkmMutation, isTrue);
      expect(evidence.isComplete, isFalse);
      expect(
        evidence.missingRequirements,
        contains('clarification_without_persistent_completion'),
      );
    });

    test('failed skip tool result is ignored', () {
      final evidence = PkmAgent.inspectPkmRunCompletion(
        factId: factId,
        messages: [
          _toolResultMessage(
            name: 'skip_pkm_organization',
            isError: true,
            arguments: {
              'reason': 'explicit_user_opt_out',
              'temporal_scope': 'temporary',
              'evidence': '不要写成长记忆',
            },
          ),
        ],
      );

      expect(evidence.skippedPkm, isFalse);
      expect(evidence.isComplete, isFalse);
      expect(evidence.missingRequirements, contains('skip_pkm_organization'));
    });
  });

  group('PkmAgent skip prompt and tool contract', () {
    test('prompt teaches the model to use the explicit skip tool', () {
      final prompt = Prompts.pkmSkillSystemPrompt(
        '/',
        'P.A.R.A. example',
        'Use user language for files.',
        'Use user language for insight.',
      );

      expect(prompt, contains('skip_pkm_organization'));
      expect(prompt, contains('explicitly asks not to persist'));
      expect(prompt, contains('Use this only for explicit'));
      expect(prompt, contains('Information-Insufficient Inputs'));
      expect(prompt, contains('ask_clarification'));
      expect(prompt, isNot(contains('不要写成长记忆')));
      expect(prompt, isNot(contains('不要影响某某项目/规则')));
    });

    test('skip tool parameters expose enum reason and evidence fields', () {
      final parameters = Prompts.pkmAgentSkipOrganizationToolParameters;
      final properties = parameters['properties'] as Map<String, dynamic>;
      final reason = properties['reason'] as Map<String, dynamic>;

      expect(reason['enum'], containsAll(PkmAgent.validSkipReasons));
      expect(
        parameters['required'],
        containsAll(['reason', 'temporal_scope', 'evidence']),
      );
    });
  });

  group('PkmAgent task handler skip path', () {
    test('explicit opt-out input completes without invoking LLM resources',
        () async {
      await expectLater(
        handlePkmAgentImpl(
          'user-a',
          {
            'fact_id': _factId,
            'combined_text': '今天有点烦，这只是今天状态，不要写成长记忆。',
            'created_at_ts': 1779080000,
          },
          TaskContext(
            taskId: 'task-opt-out',
            taskType: 'pkm_agent_task',
          ),
        ),
        completes,
      );
    });
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

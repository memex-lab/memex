import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/schedule_aggregator_agent/schedule_aggregation_run_lifecycle.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:test/test.dart';

void main() {
  group('Schedule aggregation run lifecycle', () {
    test('builds run-scoped session ids with safe path characters', () {
      final sessionId = buildScheduleAggregatorSessionId(
        'user@example.com',
        'task/2026:05:17 refresh',
      );

      expect(
        sessionId,
        'schedule_aggregator_user_example_com_task_2026_05_17_refresh',
      );
    });

    test('normalizes missing run id into a manual run id', () {
      final now = DateTime.fromMicrosecondsSinceEpoch(123456789);

      expect(normalizeScheduleAggregationRunId(' task_1 ', now), 'task_1');
      expect(normalizeScheduleAggregationRunId(' ', now), 'manual_123456789');
      expect(normalizeScheduleAggregationRunId(null, now), 'manual_123456789');
    });

    test('resumes only recent interrupted runs', () {
      final now = DateTime.utc(2026, 5, 17, 12);
      const ttl = Duration(hours: 6);

      expect(
        shouldResumeScheduleAggregatorRun(
          AgentState(
            sessionId: 'recent',
            isRunning: true,
            metadata: {
              'run_started_at':
                  now.subtract(const Duration(hours: 2)).toIso8601String(),
            },
          ),
          now,
          ttl,
        ),
        isTrue,
      );
      expect(
        shouldResumeScheduleAggregatorRun(
          AgentState(
            sessionId: 'stale',
            isRunning: true,
            metadata: {
              'run_started_at':
                  now.subtract(const Duration(hours: 7)).toIso8601String(),
            },
          ),
          now,
          ttl,
        ),
        isFalse,
      );
      expect(
        shouldResumeScheduleAggregatorRun(
          AgentState(sessionId: 'done', isRunning: false),
          now,
          ttl,
        ),
        isFalse,
      );
    });

    test(
      'keeps metadata stable when reloading an existing run state',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp(
          'memex_schedule_state_',
        );
        addTearDown(() async {
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        });
        await FileSystemService.init(tempRoot.path);

        final now = DateTime.utc(2026, 5, 17, 12);
        final original = await loadOrCreateScheduleAggregatorRunState(
          userId: 'state_user',
          runId: 'task_a',
          sessionId: 'schedule_aggregator_state_user_task_a',
          now: now,
        );
        original.isRunning = true;
        original.metadata['extra'] = 'kept';
        await saveAgentState(original);

        final reloaded = await loadOrCreateScheduleAggregatorRunState(
          userId: 'state_user',
          runId: 'task_a',
          sessionId: 'schedule_aggregator_state_user_task_a',
          now: now.add(const Duration(hours: 1)),
        );

        expect(reloaded.isRunning, isTrue);
        expect(reloaded.metadata['run_id'], 'task_a');
        expect(reloaded.metadata['sceneId'], 'task_a');
        expect(reloaded.metadata['extra'], 'kept');
        expect(reloaded.metadata['run_started_at'], now.toIso8601String());
      },
    );
  });
}

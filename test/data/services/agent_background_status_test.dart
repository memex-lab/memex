import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/agent_foreground_task_tracker.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/l10n/app_localizations_zh.dart';

void main() {
  group('AgentBackgroundStatus', () {
    test('stays idle when there are no tasks or terminal messages', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot.empty(),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.idle);
      expect(status.shouldShowSystemSurface, isFalse);
      expect(status.remainingTasks, 0);
      expect(status.detail, 'No background tasks.');
      expect(status.summary, 'No background tasks.');
    });

    test('uses task snapshot counts for active status', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 2,
          processing: 1,
          retrying: 1,
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.active);
      expect(status.remainingTasks, 4);
      expect(status.title, 'Memex Agent');
      expect(status.taskSummary, 'Running 1, Pending 2, Retry 1');
      expect(status.statusText, 'Running 1, Pending 2, Retry 1');
      expect(status.detail, 'Processing 4 queued task(s).');
      expect(status.summary, 'Processing 4 queued task(s).');
      expect(
        status.toPlatformMap(isInBackground: true),
        containsPair('summary', 'Processing 4 queued task(s).'),
      );
      expect(
        status.toPlatformMap(isInBackground: true),
        containsPair('remainingTasks', 4),
      );
      expect(
        status.toPlatformMap(isInBackground: true),
        containsPair('taskSummary', 'Running 1, Pending 2, Retry 1'),
      );
      expect(
        status.toPlatformMap(isInBackground: true),
        containsPair('statusText', 'Running 1, Pending 2, Retry 1'),
      );
      expect(
        status.toPlatformMap(isInBackground: true),
        containsPair('isInBackground', true),
      );
    });

    test('keeps retryable error visible as active while tasks remain', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 0,
          processing: 0,
          retrying: 1,
        ),
        latestMessage: AgentActivityMessageModel(
          id: 1,
          type: AgentActivityType.error,
          title: 'Provider timeout',
          content: 'Will retry automatically',
          agentName: 'Insight Agent',
          agentId: 'insight',
          timestamp: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.active);
      expect(status.stage, 'Provider timeout');
      expect(status.detail, 'Will retry automatically');
      expect(status.summary, 'Will retry automatically');
    });

    test(
      'uses activity content as notification summary without title prefix',
      () {
        final status = AgentBackgroundStatus.fromActivity(
          taskSnapshot: const TaskActivitySnapshot(
            pending: 1,
            processing: 1,
            retrying: 0,
          ),
          latestMessage: AgentActivityMessageModel(
            id: 4,
            type: AgentActivityType.tool_call_response,
            title: 'Tool called',
            content: 'Updated the timeline card',
            agentName: 'Timeline Agent',
            agentId: 'timeline',
            scene: 'timeline',
            sceneId: 'card-123',
            timestamp: DateTime(2026, 1, 1),
          ),
          now: DateTime(2026, 1, 1),
        );

        final platformMap = status.toPlatformMap(isInBackground: true);

        expect(status.title, 'Memex Agent');
        expect(status.stage, 'Tool called');
        expect(status.detail, 'Updated the timeline card');
        expect(status.summary, 'Updated the timeline card');
        expect(status.summary, isNot(contains('Tool called')));
        expect(
          platformMap,
          containsPair('summary', 'Updated the timeline card'),
        );
        expect(platformMap, containsPair('scene', 'timeline'));
        expect(platformMap, containsPair('sceneId', 'card-123'));
      },
    );

    test('falls back to activity title when content is blank', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 1,
          processing: 0,
          retrying: 0,
        ),
        latestMessage: AgentActivityMessageModel(
          id: 5,
          type: AgentActivityType.info,
          title: 'Reading workspace',
          content: ' \n\t ',
          agentName: 'PKM Agent',
          agentId: 'pkm',
          timestamp: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.stage, 'Reading workspace');
      expect(status.detail, 'Processing 1 queued task(s).');
      expect(status.summary, 'Reading workspace');
    });

    test('treats an empty-queue activity error as stale without a run snapshot',
        () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot.empty(),
        latestMessage: AgentActivityMessageModel(
          id: 6,
          type: AgentActivityType.error,
          title: 'Provider error',
          content: 'API key is missing',
          agentName: 'Insight Agent',
          agentId: 'insight',
          timestamp: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.idle);
      expect(status.shouldShowSystemSurface, isFalse);
      expect(status.title, 'Memex Agent');
      expect(status.detail, 'API key is missing');
      expect(status.summary, 'API key is missing');
    });

    test('marks terminal stop as completed only after queue is empty', () {
      final message = AgentActivityMessageModel(
        id: 2,
        type: AgentActivityType.agent_stop,
        title: 'Done',
        agentName: 'Card Agent',
        agentId: 'card',
        timestamp: DateTime(2026, 1, 1),
      );

      final stillRunning = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 1,
          processing: 0,
          retrying: 0,
        ),
        latestMessage: message,
        now: DateTime(2026, 1, 1),
      );
      final completed = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot.empty(),
        latestMessage: message,
        now: DateTime(2026, 1, 1),
      );

      expect(stillRunning.state, AgentBackgroundRunState.active);
      expect(completed.state, AgentBackgroundRunState.completed);
      expect(completed.shouldShowSystemSurface, isFalse);
      expect(completed.detail, 'All background tasks finished.');
      expect(completed.summary, 'Done');
    });

    test('trims multi-line content before sending to platform', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 0,
          processing: 1,
          retrying: 0,
        ),
        latestMessage: AgentActivityMessageModel(
          id: 3,
          type: AgentActivityType.info,
          title: 'Long output',
          content: '${'a' * 80}\n${'b' * 80}',
          agentName: 'PKM Agent',
          agentId: 'pkm',
          timestamp: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.detail, hasLength(140));
      expect(status.detail, endsWith('...'));
      expect(status.detail.contains('\n'), isFalse);
      expect(status.summary, hasLength(140));
      expect(status.summary, status.detail);
      expect(status.summary.contains('\n'), isFalse);
    });

    test('uses localized labels for platform-facing background copy', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 2,
          processing: 1,
          retrying: 1,
        ),
        labels: AgentBackgroundStatusLabels.fromL10n(AppLocalizationsZh()),
        now: DateTime(2026, 1, 1),
      );

      expect(status.title, 'Memex Agent');
      expect(status.stage, '处理中');
      expect(status.detail, '正在处理 4 个后台任务。');
      expect(status.summary, '正在处理 4 个后台任务。');
      expect(status.taskSummary, '执行中 1，排队中 2，重试中 1');
      expect(status.statusText, '执行中 1，排队中 2，重试中 1');
      expect(
        status.toPlatformMap(),
        containsPair('statusText', '执行中 1，排队中 2，重试中 1'),
      );
    });

    test('uses foreground tracker task counts for platform status', () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 1,
          processing: 1,
          retrying: 0,
        ),
        foregroundSnapshot: AgentForegroundTaskSnapshot(
          taskSnapshot: const TaskActivitySnapshot(
            pending: 3,
            processing: 1,
            retrying: 0,
          ),
          activeTaskIds: const {'a', 'b', 'c', 'd'},
          attentionTaskErrors: const {},
          paused: false,
          updatedAt: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.active);
      expect(status.remainingTasks, 4);
      expect(status.taskSummary, 'Running 1, Pending 3, Retry 0');
      expect(status.toPlatformMap(), containsPair('state', 'active'));
      expect(
        status.toPlatformMap(),
        containsPair('taskSummary', 'Running 1, Pending 3, Retry 0'),
      );
    });

    test('maps foreground tracker pause to a visible paused platform status',
        () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot.empty(),
        foregroundSnapshot: AgentForegroundTaskSnapshot(
          taskSnapshot: const TaskActivitySnapshot(
            pending: 3,
            processing: 0,
            retrying: 0,
          ),
          activeTaskIds: const {'a', 'b', 'c'},
          attentionTaskErrors: const {},
          paused: true,
          pausedMessage: 'Background time expired. Memex will continue later.',
          updatedAt: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.paused);
      expect(status.shouldShowSystemSurface, isTrue);
      expect(status.remainingTasks, 3);
      expect(status.taskSummary, 'Running 0, Pending 3, Retry 0');
      expect(status.detail, contains('continue later'));
      expect(status.toPlatformMap(), containsPair('state', 'paused'));
      expect(
        status.toPlatformMap(),
        containsPair('taskSummary', 'Running 0, Pending 3, Retry 0'),
      );
    });

    test(
        'maps foreground tracker attention to a visible needs-attention status',
        () {
      final status = AgentBackgroundStatus.fromActivity(
        taskSnapshot: const TaskActivitySnapshot(
          pending: 2,
          processing: 1,
          retrying: 0,
        ),
        foregroundSnapshot: AgentForegroundTaskSnapshot(
          taskSnapshot: const TaskActivitySnapshot.empty(),
          activeTaskIds: const {},
          attentionTaskErrors: const {'failed-task': 'API key is missing'},
          paused: false,
          updatedAt: DateTime(2026, 1, 1),
        ),
        now: DateTime(2026, 1, 1),
      );

      expect(status.state, AgentBackgroundRunState.failed);
      expect(status.shouldShowSystemSurface, isTrue);
      expect(status.title, 'Memex Agent needs attention');
      expect(status.stage, 'Needs attention');
      expect(status.detail, 'API key is missing');
      expect(status.summary, 'API key is missing');
      expect(status.statusText, 'Needs attention');
      expect(status.toPlatformMap(), containsPair('state', 'failed'));
      expect(
        status.toPlatformMap(),
        containsPair('statusText', 'Needs attention'),
      );
    });
  });
}

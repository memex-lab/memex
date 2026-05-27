import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/agent_background_status.dart';
import 'package:memex/data/services/local_task_executor.dart';

void main() {
  test('builds active status from task snapshot and latest agent message', () {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: const TaskActivitySnapshot(
        pending: 2,
        processing: 1,
        retrying: 1,
      ),
      latestMessage: AgentActivityMessageModel(
        id: 1,
        type: AgentActivityType.tool_call_reqeust,
        title: 'Generating cards',
        content: 'Analyzing today input',
        agentName: 'Card Agent',
        agentId: 'card-agent',
        scene: 'timeline',
        sceneId: 'card-1',
        timestamp: DateTime(2026, 1, 1, 12),
      ),
      now: DateTime(2026, 1, 1, 12, 1),
    );

    expect(status.state, AgentBackgroundRunState.active);
    expect(status.remainingTasks, 4);
    expect(status.stage, 'Generating cards');
    expect(status.detail, 'Analyzing today input');
    expect(status.scene, 'timeline');
    expect(status.toPlatformMap()['remainingTasks'], 4);
  });

  test('falls back to queue summary when the agent message has no content', () {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: const TaskActivitySnapshot(
        pending: 1,
        processing: 2,
        retrying: 3,
      ),
      latestMessage: null,
      now: DateTime(2026, 1, 1),
    );

    expect(status.state, AgentBackgroundRunState.active);
    expect(status.stage, 'Processing');
    expect(status.detail, '6 remaining: 2 running, 1 waiting, 3 retrying');
  });

  test('reports completion only when agent stopped and queue is empty', () {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: const TaskActivitySnapshot.empty(),
      latestMessage: AgentActivityMessageModel(
        id: 2,
        type: AgentActivityType.agent_stop,
        title: 'Done',
        agentName: 'PKM Agent',
        agentId: 'pkm-agent',
        timestamp: DateTime(2026, 1, 1),
      ),
    );

    expect(status.state, AgentBackgroundRunState.completed);
    expect(status.shouldShowSystemSurface, isTrue);
  });

  test('error message wins over an empty queue', () {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: const TaskActivitySnapshot.empty(),
      latestMessage: AgentActivityMessageModel(
        id: 3,
        type: AgentActivityType.error,
        title: 'Model failed',
        content: 'API key expired',
        agentName: 'Insight Agent',
        agentId: 'insight-agent',
        timestamp: DateTime(2026, 1, 1),
      ),
    );

    expect(status.state, AgentBackgroundRunState.failed);
    expect(status.title, 'Memex task needs attention');
    expect(status.detail, 'API key expired');
  });

  test('keeps retryable queue active even when latest message is an error', () {
    final status = AgentBackgroundStatus.fromActivity(
      taskSnapshot: const TaskActivitySnapshot(
        pending: 1,
        processing: 0,
        retrying: 1,
      ),
      latestMessage: AgentActivityMessageModel(
        id: 4,
        type: AgentActivityType.error,
        title: 'Model failed',
        content: 'Retrying after provider timeout',
        agentName: 'Insight Agent',
        agentId: 'insight-agent',
        timestamp: DateTime(2026, 1, 1),
      ),
    );

    expect(status.state, AgentBackgroundRunState.active);
    expect(status.title, 'Memex is processing');
    expect(status.detail, 'Retrying after provider timeout');
  });
}

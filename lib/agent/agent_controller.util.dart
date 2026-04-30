import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/llm_call_record_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _logger = getLogger('AgentControllerUtil');

void addAgentLogger(AgentController controller) {
  controller.on(
    (BeforeCallLLMEvent event) {
      final metadata = event.agent.state.metadata;
      final userId = metadata['userId'] as String?;
      _logger.info(
          '[${event.agent.name}] beforeCallLLM, userId: $userId, sessionId: ${event.agent.state.sessionId}, model:${event.params.modelConfig.model}');
    },
  );
  controller.on(
    (AfterCallLLMEvent event) async {
      if (event.response.usage == null) {
        return; // No usage data, skip recording
      }

      // Get userId from state metadata
      final metadata = event.agent.state.metadata;
      final userId = metadata['userId'] as String?;
      final scene = metadata['scene'] as String?;
      final sceneId = metadata['sceneId'] as String?;
      final name = event.agent.name;

      if (userId == null || scene == null || sceneId == null) {
        return;
      }

      // Record the call using the service
      await LLMCallRecordService.instance.recordCall(
        userId: userId,
        scene: scene,
        sceneId: sceneId,
        agentName: name,
        handlerName: null,
        usage: event.response.usage!,
        model: event.response.model,
        client: event.agent.client,
      );
    },
  );
}

void addAgentActivityCollector(AgentController controller) {
  // Helper to extract agent info safely
  ({String? userId, String? scene, String? sceneId, String name, String id})
      getAgentInfo(StatefulAgent agent) {
    final metadata = agent.state.metadata;
    return (
      userId: metadata['userId'] as String?,
      scene: metadata['scene'] as String?,
      sceneId: metadata['sceneId'] as String?,
      name: agent.name,
      id: agent.id,
    );
  }

  // 1. Plan updated
  controller.on(
    (PlanChangedEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      final plan = event.plan;
      final buffer = StringBuffer();
      for (var step in plan.steps) {
        String icon;
        switch (step.status) {
          case StepStatus.completed:
            icon = "✅";
            break;
          case StepStatus.in_progress:
            icon = "👉";
            break;
          case StepStatus.cancelled:
            icon = "🚫";
            break;
          default:
            icon = "⏳";
        }
        buffer.writeln("- $icon ${step.description}");
      }
      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.plan,
        title: 'Plan Updated',
        content: buffer.toString(),
        icon: '💡',
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
    },
  );

  // 2. Tool Call
  controller.on(
    (BeforeToolCallEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.tool_call_reqeust,
        title: 'Calling Tool',
        icon: '🛠️',
        content:
            '## ${event.functionCall.name} \n\n ${event.functionCall.arguments}',
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
    },
  );

  // 3. Tool Result
  controller.on(
    (AfterToolCallEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      if (event.result.name == 'write_todos') {
        return;
      }
      final content = StringBuffer();
      content.write('## ${event.result.name}\n\n');
      if (event.result.content.isNotEmpty) {
        final firstPart = event.result.content[0];
        if (firstPart is TextPart) {
          if (firstPart.text.length > 200) {
            content.write(firstPart.text.substring(0, 200));
            content.write('...');
          } else {
            content.write(firstPart.text);
          }
        }
      }
      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.tool_call_response,
        title: 'Tool called',
        icon: event.result.isError ? '❌' : '✅',
        content: content.toString(),
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
    },
  );
  // 4. Exception
  controller.on(
    (OnAgentExceptionEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.error,
        title: 'Error Occurred',
        content: event.error.toString(),
        icon: '❌',
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
    },
  );
  // 5. Error
  controller.on(
    (OnAgentErrorEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.error,
        title: 'Error Occurred',
        content: event.error.toString(),
        icon: '❌',
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
    },
  );

  // 6. Chunck
  controller.on(
    (LLMChunkEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      final chunk = event.response;
      if (chunk.thought != null && chunk.thought!.isNotEmpty) {
        await AgentActivityService.instance.pushMessage(
          type: AgentActivityType.thought_chunk,
          title: 'Thought',
          content: chunk.thought,
          icon: '🤔',
          userId: info.userId,
          scene: info.scene,
          sceneId: info.sceneId,
          agentName: info.name,
          agentId: info.id,
        );
      }
      if (chunk.textOutput != null && chunk.textOutput!.isNotEmpty) {
        await AgentActivityService.instance.pushMessage(
          type: AgentActivityType.output_chunk,
          title: 'Output',
          content: chunk.textOutput,
          icon: '💬',
          userId: info.userId,
          scene: info.scene,
          sceneId: info.sceneId,
          agentName: info.name,
          agentId: info.id,
        );
      }
    },
  );

  // 7. Agent Start
  controller.on(
    (AgentStartedEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.agent_start,
        title: 'Agent Started',
        icon: '🚀',
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
      await WakelockPlus.enable();
    },
  );

  // 8. Agent Stop
  controller.on(
    (AgentStoppedEvent event) async {
      final info = getAgentInfo(event.agent);
      if (info.userId == null) return;

      final content = StringBuffer();
      if (event.error != null) {
        content.writeln('with error: ${event.error?.toString()}');
      } else {
        if (event.modelMessages.isNotEmpty) {
          final lastMessage = event.modelMessages.last;
          if (lastMessage.textOutput != null) {
            content.writeln(lastMessage.textOutput);
          }
          content.writeln(
              '\n\nStop reason: ${lastMessage.stopReason ?? 'unknown'}');
        }
      }
      await AgentActivityService.instance.pushMessage(
        type: AgentActivityType.agent_stop,
        title: 'Agent Stopped',
        icon: event.error != null ? '❌' : '✅',
        content: content.toString(),
        userId: info.userId,
        scene: info.scene,
        sceneId: info.sceneId,
        agentName: info.name,
        agentId: info.id,
      );
      await WakelockPlus.disable();
    },
  );
}

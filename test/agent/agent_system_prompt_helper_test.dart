import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:test/test.dart';

void main() {
  group('applyPromptConfig', () {
    test('keeps messages and tools unchanged when config is empty', () {
      final config = AgentPromptConfig();
      final tool = Tool(
        name: 'read',
        description: 'Read a file',
        parameters: const {'type': 'object'},
        executable: () => 'ok',
      );
      final requestMessages = [UserMessage.text('hello')];

      final result = applyPromptConfig(
        config,
        null,
        [tool],
        requestMessages,
      );

      expect(result.systemMessage, isNull);
      expect(result.tools.single, same(tool));
      expect(result.requestMessages.single, same(requestMessages.single));
    });

    test('system override takes precedence over replacements', () {
      final config = AgentPromptConfig();
      config.systemPrompt.overrideContent = 'override content';
      config.systemPrompt.replacements.add(('original', 'replacement'));

      final result = applyPromptConfig(
        config,
        SystemMessage('original content'),
        const [],
        const [],
      );

      expect(result.systemMessage?.content, 'override content');
    });

    test('applies multiple system prompt replacements in order', () {
      final config = AgentPromptConfig();
      config.systemPrompt.replacements.add(('first', 'second'));
      config.systemPrompt.replacements.add(('second', 'third'));

      final result = applyPromptConfig(
        config,
        SystemMessage('first prompt'),
        const [],
        const [],
      );

      expect(result.systemMessage?.content, 'third prompt');
    });

    test('returns SystemCallbackResult and preserves tool parameter mode', () {
      final config = AgentPromptConfig();
      config.systemPrompt.replacements.add(('old system', 'new system'));
      config.toolOverrides['object_tool'] = ToolOverride(
        name: 'object_tool',
        description: 'Updated description',
        parameters: {
          'type': 'object',
          'properties': {
            'query': {'type': 'string'},
          },
        },
      );

      final originalTool = Tool(
        name: 'object_tool',
        description: 'Original description',
        parameters: const {'type': 'object', 'properties': {}},
        executable: (Map<String, dynamic> args) => args,
        namedParameters: const ['unused'],
        parameterMode: ToolParameterMode.object,
      );
      final requestMessages = [UserMessage.text('hello')];

      final result = applyPromptConfig(
        config,
        SystemMessage('old system prompt'),
        [originalTool],
        requestMessages,
      );

      expect(result, isA<SystemCallbackResult>());
      expect(result.systemMessage?.content, 'new system prompt');
      expect(result.tools, hasLength(1));
      expect(result.tools.single.description, 'Updated description');
      expect(result.tools.single.executable, same(originalTool.executable));
      expect(result.tools.single.namedParameters, originalTool.namedParameters);
      expect(result.tools.single.parameterMode, ToolParameterMode.object);
      expect(result.requestMessages.single, same(requestMessages.single));
    });

    test('only overrides matching tools', () {
      final config = AgentPromptConfig();
      config.toolOverrides['target'] = ToolOverride(
        name: 'target',
        parameters: const {
          'type': 'object',
          'required': ['value'],
        },
      );
      final target = Tool(
        name: 'target',
        description: 'Target description',
        parameters: const {'type': 'object'},
      );
      final other = Tool(
        name: 'other',
        description: 'Other description',
        parameters: const {'type': 'object'},
      );

      final result = applyPromptConfig(
        config,
        SystemMessage('system'),
        [target, other],
        const [],
      );

      expect(result.tools.first.description, 'Target description');
      expect(result.tools.first.parameters['required'], ['value']);
      expect(result.tools.last, same(other));
    });
  });
}

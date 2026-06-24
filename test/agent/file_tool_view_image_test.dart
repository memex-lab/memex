import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/super_agent/pending_tool_image_buffer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('view_image tool', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memex_view_image_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('compresses image and queues it for the next model message', () async {
      final image = File('${tempDir.path}/sample.png');
      await image.writeAsBytes(_pngHeader(width: 320, height: 240));
      final compressed = Uint8List.fromList([1, 2, 3, 4]);
      String? compressedPath;
      int? targetSizeSeen;
      int? qualitySeen;

      final factory = FileToolFactory(
        permissionManager: FilePermissionManager(
          'test_user',
          [
            PermissionRule(
              rootPath: tempDir.path,
              access: FileAccessType.read,
            ),
          ],
          withDefaultRules: false,
        ),
        workingDirectory: tempDir.path,
        viewImageCompressor: (
          String filePath, {
          int targetSize = 2048,
          int quality = 85,
        }) async {
          compressedPath = filePath;
          targetSizeSeen = targetSize;
          qualitySeen = quality;
          return compressed;
        },
        viewImageExifInfoBuilder: (userId, imagePath) async =>
            'Image Metadata:\nCapture Time: 2026:06:22 15:30:00\n'
            'GPS Coordinates: 31.230416, 121.473701',
      );
      final tool = factory.buildViewImageTool();
      final properties = tool.parameters['properties'] as Map;
      expect(properties.keys, contains('path'));
      expect(properties.keys, isNot(contains('detail')));
      final state = AgentState(
        sessionId: 'view_image_test',
        metadata: const {'userId': 'test_user'},
      );

      final result = await _runToolCall(
        tool: tool,
        arguments: {'path': image.path},
        state: state,
      );

      expect(result.isError, isFalse);
      expect(
          _text(result), contains('Image attached to the next model message'));
      expect(_text(result), contains('EXIF metadata is included'));
      expect(compressedPath, image.path);
      expect(targetSizeSeen, 2048);
      expect(qualitySeen, 85);

      final pending = PendingToolImageBuffer.instance.drain(state.sessionId);
      expect(pending, hasLength(1));
      expect(pending.single.message, contains('Inspect it now'));
      expect(pending.single.message, contains('Image Metadata:'));
      expect(pending.single.message, contains('Capture Time:'));
      expect(pending.single.message, contains('GPS Coordinates:'));
      expect(pending.single.image.mimeType, 'image/webp');
      expect(pending.single.image.base64Data, base64Encode(compressed));
    });

    test('does not require file permission manager read access', () async {
      final image = File('${tempDir.path}/Facts/assets/sample.png');
      await image.create(recursive: true);
      await image.writeAsBytes(_pngHeader(width: 64, height: 64));
      final compressed = Uint8List.fromList([9, 8, 7, 6]);

      final factory = FileToolFactory(
        permissionManager: FilePermissionManager(
          'test_user',
          const [],
          withDefaultRules: false,
        ),
        workingDirectory: tempDir.path,
        viewImageCompressor: (
          String filePath, {
          int targetSize = 2048,
          int quality = 85,
        }) async {
          expect(filePath, image.path);
          return compressed;
        },
      );
      final tool = factory.buildViewImageTool();
      final state = AgentState(
        sessionId: 'view_image_no_permission_test',
        metadata: const {'userId': 'test_user'},
      );

      final result = await _runToolCall(
        tool: tool,
        arguments: {'path': 'fs://sample.png'},
        state: state,
      );

      expect(result.isError, isFalse);
      expect(
          _text(result), contains('Image attached to the next model message'));

      final pending = PendingToolImageBuffer.instance.drain(state.sessionId);
      expect(pending, hasLength(1));
      expect(pending.single.image.base64Data, base64Encode(compressed));
    });
  });

  group('BatchRead tool', () {
    late Directory tempDir;
    late FileToolFactory factory;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memex_batch_read_');
      factory = FileToolFactory(
        permissionManager: FilePermissionManager(
          'test_user',
          [
            PermissionRule(
              rootPath: tempDir.path,
              access: FileAccessType.read,
            ),
          ],
          withDefaultRules: false,
        ),
        workingDirectory: tempDir.path,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('uses workspace paths in file headers for direct reads', () async {
      final note = File('${tempDir.path}/PKM/Resources/finance/summary.md');
      await note.create(recursive: true);
      await note.writeAsString('balance notes');

      final output = await Function.apply(
        factory.buildBatchReadTool().executable!,
        [
          ['/PKM/Resources/finance/summary.md'],
        ],
      ) as String;

      expect(output, contains('File: /PKM/Resources/finance/summary.md'));
      expect(output, isNot(contains(tempDir.path)));
      expect(output, contains('balance notes'));
    });

    test('uses workspace paths in file headers for glob reads', () async {
      final note = File('${tempDir.path}/PKM/Projects/aurora/plan.md');
      await note.create(recursive: true);
      await note.writeAsString('project plan');

      final output = await Function.apply(
        factory.buildBatchReadTool().executable!,
        [
          ['PKM/Projects/**/*.md'],
        ],
      ) as String;

      expect(output, contains('File: /PKM/Projects/aurora/plan.md'));
      expect(output, isNot(contains(tempDir.path)));
      expect(output, contains('project plan'));
    });
  });
}

Future<FunctionExecutionResult> _runToolCall({
  required Tool tool,
  required Map<String, dynamic> arguments,
  AgentState? state,
}) async {
  final client = _SingleToolCallClient(
    toolName: tool.name,
    arguments: arguments,
  );
  final agentState = state ??
      AgentState(
        sessionId: 'view_image_test_${DateTime.now().microsecondsSinceEpoch}',
      );
  final agent = StatefulAgent(
    name: 'view_image_test_agent',
    client: client,
    modelConfig: ModelConfig(model: 'test-model'),
    state: agentState,
    tools: [tool],
    withGeneralPrinciples: false,
    maxTurns: 3,
  );

  await agent.run([UserMessage.text('run the tool')], useStream: false);

  final resultMessage = agentState.history.messages
      .whereType<FunctionExecutionResultMessage>()
      .single;
  return resultMessage.results.single;
}

String _text(FunctionExecutionResult result) {
  return result.content
      .whereType<TextPart>()
      .map((part) => part.text)
      .join('\n');
}

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient({
    required this.toolName,
    required this.arguments,
  });

  final String toolName;
  final Map<String, dynamic> arguments;
  var _callCount = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    _callCount += 1;
    if (_callCount == 1) {
      return ModelMessage(
        model: modelConfig.model,
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(
            id: 'call_1',
            name: toolName,
            arguments: jsonEncode(arguments),
          ),
        ],
      );
    }
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'stop',
      textOutput: 'done',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}

List<int> _pngHeader({required int width, required int height}) {
  final bytes = Uint8List(33);
  bytes.setAll(0, const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
  ]);
  bytes[16] = (width >> 24) & 0xff;
  bytes[17] = (width >> 16) & 0xff;
  bytes[18] = (width >> 8) & 0xff;
  bytes[19] = width & 0xff;
  bytes[20] = (height >> 24) & 0xff;
  bytes[21] = (height >> 16) & 0xff;
  bytes[22] = (height >> 8) & 0xff;
  bytes[23] = height & 0xff;
  return bytes;
}

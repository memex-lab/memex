import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/super_agent/super_agent_loop_detector.dart';

void main() {
  group('SuperAgentLoopDetector', () {
    test('does not diagnose non-tool turns based on accumulated loop count',
        () async {
      final detector = SuperAgentLoopDetector();

      final result = await detector.detect(
        ModelMessage(
          model: 'test-model',
          stopReason: 'stop',
          textOutput: 'done',
        ),
      );

      expect(result.isLoop, isFalse);
    });

    test('detects repeated identical tool calls', () async {
      final detector = SuperAgentLoopDetector(toolLoopThreshold: 3);

      expect(await detector.detect(_toolCall('1')), _isNotLoop);
      expect(await detector.detect(_toolCall('2')), _isNotLoop);

      final result = await detector.detect(_toolCall('3'));

      expect(result.isLoop, isTrue);
      expect(result.message, contains('same tool called 3 times'));
    });

    test('canonicalizes argument key order before comparing tool calls',
        () async {
      final detector = SuperAgentLoopDetector(toolLoopThreshold: 2);

      expect(
        await detector.detect(_toolCall('1', arguments: '{"b":2,"a":1}')),
        _isNotLoop,
      );

      final result = await detector.detect(
        _toolCall('2', arguments: '{"a":1,"b":2}'),
      );

      expect(result.isLoop, isTrue);
    });
  });
}

Matcher get _isNotLoop => isA<LoopDetectorResult>().having(
      (result) => result.isLoop,
      'isLoop',
      isFalse,
    );

ModelMessage _toolCall(String id, {String arguments = '{"id":"same"}'}) {
  return ModelMessage(
    model: 'test-model',
    functionCalls: [
      FunctionCall(
        id: id,
        name: 'same_tool',
        arguments: arguments,
      ),
    ],
  );
}

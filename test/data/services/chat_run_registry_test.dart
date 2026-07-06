import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/data/services/chat_run_registry.dart';

void main() {
  group('ActiveChatRun.attach', () {
    test('replays missed events then continues live, no duplicates', () async {
      final registry = ChatRunRegistry();
      final run = registry.start('s1');

      run.add(ChatResponseChunkEvent('a'));
      run.add(ChatResponseChunkEvent('b'));

      final received = <String>[];
      final sub = run.attach().listen((event) {
        received.add((event as ChatResponseChunkEvent).text);
      });

      run.add(ChatResponseChunkEvent('c'));
      run.close();
      await sub.asFuture<void>();

      expect(received, ['a', 'b', 'c']);
    });

    test('attach after close replays buffer and completes', () async {
      final registry = ChatRunRegistry();
      final run = registry.start('s2');
      run.add(ChatResponseChunkEvent('x'));
      run.close();

      final events = await run.attach().toList();
      expect(events, hasLength(1));
      expect((events.single as ChatResponseChunkEvent).text, 'x');
    });

    test('registry tracks and removes runs on close', () {
      final registry = ChatRunRegistry();
      final run = registry.start('s3');
      expect(registry.isActive('s3'), isTrue);

      run.close();
      expect(registry.isActive('s3'), isFalse);
      // Closing twice is safe and add() after close is ignored.
      run.close();
      run.add(ChatResponseChunkEvent('ignored'));
    });

    test('getOrStart reuses active run and creates missing run', () {
      final registry = ChatRunRegistry();
      final first = registry.getOrStart('s5');
      final second = registry.getOrStart('s5');

      expect(identical(first, second), isTrue);
      expect(registry.isActive('s5'), isTrue);

      first.close();
      final third = registry.getOrStart('s5');
      expect(identical(first, third), isFalse);
      expect(registry.isActive('s5'), isTrue);
    });

    test('multiple attachments receive the same events', () async {
      final registry = ChatRunRegistry();
      final run = registry.start('s4');
      run.add(ChatResponseChunkEvent('1'));

      final first = run.attach().toList();
      final second = run.attach().toList();
      run.add(ChatResponseChunkEvent('2'));
      run.close();

      expect((await first).length, 2);
      expect((await second).length, 2);
    });

    test('non-replay events are live-only for persisted history events',
        () async {
      final registry = ChatRunRegistry();
      final run = registry.start('s6');

      final liveReceived = <ChatEvent>[];
      final liveSub = run.attach().listen(liveReceived.add);
      await pumpEventQueue();

      final liveOnlyEvent = ChatArtifactsEvent(const []);
      run.add(liveOnlyEvent, replay: false);
      await pumpEventQueue();
      await liveSub.cancel();

      run.add(ChatResponseChunkEvent('later'));
      run.close();

      final replayed = await run.attach().toList();
      expect(liveReceived, [liveOnlyEvent]);
      expect(replayed, hasLength(1));
      expect(replayed.single, isA<ChatResponseChunkEvent>());
    });
  });
}

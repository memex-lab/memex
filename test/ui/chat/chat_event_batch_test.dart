import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/ui/chat/chat_event_batcher.dart';

void main() {
  test('batches token chunks into one flush', () async {
    final applied = <String>[];
    var flushes = 0;
    final batcher = ChatEventBatcher(
      interval: const Duration(milliseconds: 20),
      apply: (event) {
        if (event is ChatResponseChunkEvent) applied.add(event.text);
      },
      onFlush: () => flushes += 1,
    );
    addTearDown(batcher.dispose);

    batcher.add(ChatResponseChunkEvent('t1', 'Hel'));
    batcher.add(ChatResponseChunkEvent('t1', 'lo'));
    expect(applied, isEmpty);
    expect(flushes, 0);

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(applied, ['Hel', 'lo']);
    expect(flushes, 1);
  });

  test('flushes immediately on error so the user sees it now', () {
    final applied = <String>[];
    var flushes = 0;
    final batcher = ChatEventBatcher(
      apply: (event) {
        if (event is ChatResponseChunkEvent) applied.add(event.text);
        if (event is ChatErrorEvent) applied.add(event.error);
      },
      onFlush: () => flushes += 1,
    );
    addTearDown(batcher.dispose);

    batcher.add(ChatResponseChunkEvent('t1', 'Hel'));
    batcher.add(ChatErrorEvent('t1', 'boom'));

    expect(applied, ['Hel', 'boom']);
    expect(flushes, 2);
  });
}

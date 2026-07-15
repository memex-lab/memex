import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_conversation_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';

void main() {
  test('consecutive user bubbles share one rescheduled reply task', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final executor = LocalTaskExecutor.forTesting(db: db);
    final chatService = PersonaChatService.forTesting(db);
    final now = DateTime.parse('2026-07-15T09:00:00+08:00');
    final service = CharacterConversationService.forTesting(
      chatService: chatService,
      taskExecutor: executor,
      clock: () => now,
    );
    addTearDown(() async {
      await executor.stop();
      await db.close();
    });

    await service.sendUserMessage(
      userId: 'user-1',
      characterId: 'yaoyao',
      content: '我刚下楼',
    );
    await service.sendUserMessage(
      userId: 'user-1',
      characterId: 'yaoyao',
      content: '外面有点热',
    );
    await service.sendUserMessage(
      userId: 'user-1',
      characterId: 'yaoyao',
      content: '突然想喝冰的',
    );

    final messages = await chatService.getPendingUserMessages('yaoyao');
    final tasks = await (db.select(db.tasks)
          ..where((task) =>
              task.type.equals(CharacterConversationService.taskType)))
        .get();
    expect(messages.map((message) => message.content), [
      '我刚下楼',
      '外面有点热',
      '突然想喝冰的',
    ]);
    expect(tasks, hasLength(1));
    expect(tasks.single.bizId, 'character_conversation:yaoyao');
    expect(tasks.single.scheduledAt,
        now.add(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000);
    expect(
      jsonDecode(tasks.single.payload!)['character_id'],
      'yaoyao',
    );
  });
}

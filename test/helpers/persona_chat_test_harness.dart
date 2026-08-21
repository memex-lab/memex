import 'dart:io';

import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/data/services/persona_chat_service.dart';

class PersonaChatTestHarness {
  PersonaChatTestHarness._({
    required this.root,
    required this.storage,
    required this.service,
    required this.userId,
  });

  final Directory root;
  final PersonaChatConversationStorage storage;
  final PersonaChatService service;
  final String userId;

  static Future<PersonaChatTestHarness> create({
    String userId = 'test-user',
  }) async {
    final root = await Directory.systemTemp.createTemp('memex_persona_chat_');
    final storage = PersonaChatConversationStorage(
      fileSystem: FileSystemService.detached(dataRoot: root.path),
    );
    return PersonaChatTestHarness._(
      root: root,
      storage: storage,
      service: PersonaChatService.forTesting(
        storage: storage,
        userId: userId,
      ),
      userId: userId,
    );
  }

  Future<void> dispose() async {
    if (await root.exists()) await root.delete(recursive: true);
  }
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await UserStorage.saveUser('chat-preflight-user');
    tempDir = await Directory.systemTemp.createTemp('memex_chat_preflight_');
    await FileSystemService.init(tempDir.path);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
    chatNetworkReachabilityCheck = null;
  });

  tearDown(() async {
    chatNetworkReachabilityCheck = null;
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sendMessage yields network error when reachability check fails',
      () async {
    chatNetworkReachabilityCheck = () async => false;

    final events = await ChatService.instance
        .sendMessage(
          'hello offline',
          sessionId: '',
          agentName: 'memex_agent',
          scene: 'super_agent_home',
        )
        .take(2)
        .toList();

    expect(events.whereType<ChatErrorEvent>(), hasLength(1));
    expect(
      (events.whereType<ChatErrorEvent>().single).error,
      UserStorage.l10n.llmNetworkError,
    );
  });
}

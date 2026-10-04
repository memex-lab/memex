import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/super_agent/super_agent_pre_minted_record_hook.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late String userId;
  const sessionId = 'chat-session-1';
  const turnId = 'turn-1';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    userId = 'fail_card_${DateTime.now().microsecondsSinceEpoch}';
    await UserStorage.saveUser(userId);
    tempRoot = await Directory.systemTemp.createTemp('memex_turn_fail_');
    await FileSystemService.init(tempRoot.path);
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('marks processing placeholder failed when Super Agent turn fails', () async {
    final factId =
        await FileSystemService.instance.allocateCardFactId(userId);
    final state = await loadOrCreateAgentState(sessionId, {'userId': userId});
    state.metadata[SuperAgentPreMintedRecordHook.factIdMetadataKey] = factId;
    state.metadata[SuperAgentPreMintedRecordHook.turnIdMetadataKey] = turnId;
    await saveAgentState(state);

    await markProcessingCardFailedForSuperAgentTurn(
      userId: userId,
      payload: {
        'session_id': sessionId,
        'turn_id': turnId,
      },
      error: Exception('Failed host lookup: api.anthropic.com'),
      resolveAgentStateSessionId: (_) async => sessionId,
    );

    final card =
        await FileSystemService.instance.readCardFile(userId, factId);
    expect(card, isNotNull);
    expect(card!.status, 'failed');
    expect(card.failureReason, UserStorage.l10n.llmNetworkError);
  });
}

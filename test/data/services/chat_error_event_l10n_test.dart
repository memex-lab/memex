import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('chat send errors use existing l10n strings', () {
    expect(chatErrorUserNotLoggedIn(), UserStorage.l10n.userIdNotFound);
    expect(chatErrorEmptyMessage(), UserStorage.l10n.unknownError);
    expect(
      chatErrorOperationFailed('timeout'),
      UserStorage.l10n.operationFailed('timeout'),
    );
    expect(
      chatErrorOperationFailed(
        "Exception: Failed host lookup: 'api.anthropic.com'",
      ),
      UserStorage.l10n.llmNetworkError,
    );
    final agentError = chatErrorOperationFailed(
      AgentException(
        AgentExceptionCode.unknown,
        'run failed',
        error: const SocketException("Failed host lookup: 'api.anthropic.com'"),
      ),
    );
    expect(agentError, UserStorage.l10n.llmNetworkError);
    expect(agentError, isNot(contains('AgentException')));
    expect(agentError, isNot(contains('Failed host lookup')));
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/chat_service.dart';
import 'package:memex/domain/models/task_exceptions.dart';
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
    final missingModel = chatErrorOperationFailed(
      InvalidModelConfigException(
        'The LLM configuration for chat_agent is invalid.',
      ),
    );
    expect(missingModel, UserStorage.l10n.invalidModelConfigPlain);
    expect(missingModel, isNot(contains('chat_agent')));
    expect(missingModel, isNot(contains('InvalidModelConfigException')));

    final oauth = chatErrorOperationFailed(
      InvalidModelConfigException(
        'Gemini OAuth not authorized.',
        InvalidModelConfigReason.oauth,
      ),
    );
    expect(oauth, isNot(UserStorage.l10n.invalidModelConfigPlain));
    expect(oauth, contains('OAuth'));

    final emptyKey = chatErrorOperationFailed(
      InvalidModelConfigException(
        'LLM API Key is empty',
        InvalidModelConfigReason.emptyApiKey,
      ),
    );
    expect(emptyKey, isNot(UserStorage.l10n.invalidModelConfigPlain));
    expect(emptyKey, contains('API Key'));
  });
}

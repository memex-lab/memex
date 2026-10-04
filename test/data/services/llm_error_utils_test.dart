import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('classifyError treats failed host lookup as networkError', () {
    final error = AgentException(
      AgentExceptionCode.unknown,
      'Agent run failed',
      error: Exception(
        "Claude Stream Error: The connection errored: Failed host lookup: "
        "'api.anthropic.com'",
      ),
    );

    expect(classifyError(error), LlmErrorCategory.networkError);
    expect(
      getLocalizedErrorMessage(LlmErrorCategory.networkError, error),
      UserStorage.l10n.llmNetworkError,
    );
  });
}

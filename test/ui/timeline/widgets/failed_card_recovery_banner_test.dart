import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/timeline/widgets/failed_card_recovery_banner.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  testWidgets('failed banner exposes retry and failure reason actions', (
    tester,
  ) async {
    var retryCount = 0;
    var reasonCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FailedCardRecoveryBanner(
            failureReason: '模型服务超时',
            isRetrying: false,
            onRetry: () => retryCount++,
            onShowReason: () => reasonCount++,
          ),
        ),
      ),
    );

    expect(
      find.text(UserStorage.l10n.cardGenerationFailedTitle),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.regenerateCard), findsOneWidget);
    expect(find.text(UserStorage.l10n.failureReason), findsOneWidget);

    await tester.tap(find.text(UserStorage.l10n.regenerateCard));
    await tester.tap(find.text(UserStorage.l10n.failureReason));

    expect(retryCount, 1);
    expect(reasonCount, 1);
  });

  testWidgets('failed banner disables retry while request is running', (
    tester,
  ) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FailedCardRecoveryBanner(
            failureReason: '模型服务超时',
            isRetrying: true,
            onRetry: () => retryCount++,
            onShowReason: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text(UserStorage.l10n.regenerateCard));

    expect(retryCount, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

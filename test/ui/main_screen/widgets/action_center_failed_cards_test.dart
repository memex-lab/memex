import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_generation_retry_result.dart';
import 'package:memex/ui/main_screen/widgets/action_center_sheet.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    AppDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('action center renders failed card aggregate and retries all', (
    tester,
  ) async {
    var failedCount = 3;
    var retryCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionCenterSheet(
            loadPendingAttachments: () async => const [],
            loadFailedCardCount: () async => failedCount,
            retryAllFailedCards: () async {
              retryCalls++;
              failedCount = 0;
              return const CardGenerationRetryResult(
                requested: 3,
                retried: 3,
                skipped: 0,
              );
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(UserStorage.l10n.failedCardsRetryTitle(3)),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.retryAllFailedCards), findsOneWidget);

    await tester.tap(find.text(UserStorage.l10n.retryAllFailedCards));
    await tester.pumpAndSettle();

    expect(retryCalls, 1);
    expect(
      find.text(UserStorage.l10n.failedCardsRetryStarted(3)),
      findsOneWidget,
    );
    expect(find.text(UserStorage.l10n.noPendingActions), findsOneWidget);
  });
}

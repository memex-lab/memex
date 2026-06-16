import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_attachment_service.dart';
import 'package:memex/data/services/clarification_request_service.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_generation_retry_result.dart';
import 'package:memex/ui/card_attachments/card_attachment_data.dart';
import 'package:memex/ui/main_screen/widgets/action_center_sheet.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    await initializeDateFormatting('en');
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

  testWidgets(
    'action center groups mixed sources and clears only card updates',
    (tester) async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var failedCount = 2;
      final dismissCalls = <String?>[];
      final items = <CardAttachmentData>[
        CardAttachmentData(
          id: 'system_action_future-calendar',
          type: CardAttachmentType.systemAction,
          data: {
            'action': SystemAction(
              id: 'future-calendar',
              actionType: 'calendar',
              actionData: jsonEncode({
                'title': 'Future planning',
                'start_time': '2099-06-15 09:00:00',
              }),
              status: SystemActionService.statusPending,
              createdAt: now,
              updatedAt: now,
            ),
          },
        ),
        CardAttachmentData(
          id: 'system_action_past-calendar',
          type: CardAttachmentType.systemAction,
          data: {
            'action': SystemAction(
              id: 'past-calendar',
              actionType: 'calendar',
              actionData: jsonEncode({
                'title': 'Past planning',
                'start_time': '2020-06-15 09:00:00',
              }),
              status: SystemActionService.statusPastDue,
              createdAt: now,
              updatedAt: now,
            ),
          },
        ),
        const CardAttachmentData(
          id: 'clarification_clarification-1',
          type: CardAttachmentType.clarificationRequest,
          data: {
            'request': ClarificationRequest(
              id: 'clarification-1',
              question: 'Which project?',
              responseType: 'short_text',
              status: ClarificationRequestStatus.pending,
            ),
          },
        ),
        CardAttachmentData(
          id: 'card_detail_notification_update-1',
          type: CardAttachmentType.cardDetailNotification,
          data: {
            'notification': UserNotification(
              id: 'update-1',
              userId: 'u',
              notificationType: 'card_detail_update',
              subjectKey: '2026/06/14.md#ts_1',
              payload: jsonEncode({
                'signals': ['comments'],
              }),
              createdAt: now,
              updatedAt: now,
            ),
          },
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionCenterSheet(
              loadPendingAttachments: () async => List.of(items),
              loadFailedCardCount: () async => failedCount,
              retryAllFailedCards: () async {
                failedCount = 0;
                return const CardGenerationRetryResult(
                  requested: 2,
                  retried: 2,
                  skipped: 0,
                );
              },
              dismissPendingAttachments: (type) async {
                dismissCalls.add(type);
                if (type == CardAttachmentType.cardDetailNotification) {
                  items.removeWhere(
                    (item) =>
                        item.type == CardAttachmentType.cardDetailNotification,
                  );
                  return 1;
                }
                return 0;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(UserStorage.l10n.actionCenterBackgroundSection),
        findsOneWidget,
      );
      expect(
        find.text(UserStorage.l10n.actionCenterPendingActionsSection),
        findsOneWidget,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -360));
      await tester.pumpAndSettle();

      expect(
        find.text(UserStorage.l10n.actionCenterPastDueSection),
        findsOneWidget,
      );
      expect(
        find.text(UserStorage.l10n.actionCenterClarificationsSection),
        findsOneWidget,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(
        find.text(UserStorage.l10n.actionCenterCardUpdatesSection),
        findsOneWidget,
      );
      await tester.tap(
        find.text(UserStorage.l10n.actionCenterMarkAllCardUpdatesRead),
      );
      await tester.pumpAndSettle();

      expect(dismissCalls, [CardAttachmentType.cardDetailNotification]);
      expect(
        find.text(UserStorage.l10n.actionCenterCardUpdatesSection),
        findsNothing,
      );

      await tester.drag(find.byType(ListView), const Offset(0, 1000));
      await tester.pumpAndSettle();

      expect(
        find.text(UserStorage.l10n.actionCenterBackgroundSection),
        findsOneWidget,
      );
      expect(
        find.text(UserStorage.l10n.failedCardsRetryTitle(2)),
        findsOneWidget,
      );
    },
  );
}

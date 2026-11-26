import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/user_notification_service.dart';
import 'package:memex/db/app_database.dart';

void main() {
  test('service methods return sentinels when DB is not initialized', () async {
    expect(AppDatabase.isInitialized, isFalse,
        reason:
            'No AppDatabase.init() was called, so isInitialized should be false');

    final realService = UserNotificationService.instance;

    final id = await realService.upsert(
      userId: 'user-a',
      notificationType: 'card_detail_update',
      subjectKey: 'fact-1',
      payload: {
        'signals': ['comments']
      },
    );
    expect(id, isEmpty);

    // dismiss and dismissBy should not throw
    await realService.dismiss('nonexistent');
    await realService.dismissBy(
      userId: 'user-a',
      notificationType: 'card_detail_update',
      subjectKey: 'fact-1',
    );

    final rows = await realService.list(userId: 'user-a');
    expect(rows, isEmpty);
  });
}

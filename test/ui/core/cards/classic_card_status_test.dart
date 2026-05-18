import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/cards/templates/classic_card.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  testWidgets('failed classic card exposes the failure reason sheet',
      (tester) async {
    const failureReason =
        'Card Agent did not produce a completed persisted card.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ClassicCard(
            data: {
              'content': 'A card waiting for recovery.',
              'status': 'failed',
              'failure_reason': failureReason,
            },
          ),
        ),
      ),
    );

    expect(find.text(failureReason), findsNothing);

    await tester.tap(find.text(UserStorage.l10n.failedStatus));
    await tester.pumpAndSettle();

    expect(find.text(failureReason), findsOneWidget);
  });
}

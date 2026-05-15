import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_knowledge_insight_detail.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/widgets/insight_detail_page.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  testWidgets('shows friendly message for missing insight links',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: InsightDetailPage(
          id: 'missing-insight',
          detailLoader: (_) async {
            throw KnowledgeInsightNotFoundException('missing-insight');
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text(
        'This insight is still being generated or was updated. Refresh insights and try again later.',
      ),
      findsWidgets,
    );
    expect(find.textContaining('Knowledge insight card not found'), findsNothing);
  });
}

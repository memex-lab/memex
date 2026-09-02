import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/insight/widgets/insight_cards/summary_card.dart';
import 'package:memex/ui/main_screen/widgets/main_bottom_bar.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:memex/ui/timeline/widgets/timeline_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 'rtl-smoke-test',
      'language': 'ar',
    });
    await UserStorage.setLocale(const Locale('ar'));
    await UserStorage.initL10n();
  });

  Future<void> pumpArabicRtl(
    WidgetTester tester,
    Widget child, {
    Size viewport = const Size(393, 852),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('MainBottomBar lays out without overflow in Arabic RTL', (
    tester,
  ) async {
    await pumpArabicRtl(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MainBottomBar(
            currentTab: 0,
            onTimelineTap: () {},
            onLibraryTap: () {},
            onCenterTap: () {},
            onCenterLongPress: () {},
          ),
        ),
      ),
    );

    expect(find.byType(MainBottomBar), findsOneWidget);
    expect(find.text(UserStorage.l10n.bottomNavTimeline), findsOneWidget);
    expect(find.text(UserStorage.l10n.bottomNavLibrary), findsOneWidget);
  });

  testWidgets('TimelineFilterBar lays out without overflow in Arabic RTL', (
    tester,
  ) async {
    final viewModel = TimelineViewModel(
      router: MemexRouter(),
      autoLoad: false,
    );
    addTearDown(viewModel.dispose);

    await pumpArabicRtl(
      tester,
      SizedBox(
        height: 44,
        child: TimelineFilterBar(
          viewModel: viewModel,
          onPageSelected: (_) {},
          onInsightSelected: () {},
        ),
      ),
    );

    expect(find.byType(TimelineFilterBar), findsOneWidget);
    expect(find.text(UserStorage.l10n.timelineFilterAll), findsOneWidget);
  });

  testWidgets('SummaryCard metrics lay out without overflow in Arabic RTL', (
    tester,
  ) async {
    await pumpArabicRtl(
      tester,
      SingleChildScrollView(
        child: SummaryCard(
          tag: 'ملخص',
          title: 'نشاط الأسبوع',
          date: '٠٢/٠٩',
          insightContent: 'هذا نص تجريبي باللغة العربية للتحقق من الاتجاه.',
          metrics: [
            SummaryMetric(label: 'الخطوات', value: '8,420'),
            SummaryMetric(label: 'الساعات', value: '6.5'),
            SummaryMetric(label: 'الجلسات', value: '12'),
          ],
        ),
      ),
      viewport: const Size(360, 640),
    );

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('8,420'), findsOneWidget);
  });
}

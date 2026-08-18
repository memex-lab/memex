import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/main_screen/widgets/main_bottom_bar.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const timelineKey = ValueKey('test-timeline-tab');
  const libraryKey = ValueKey('test-library-tab');

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'user_id': 'bottom-bar-test',
      'language': 'en',
    });
    await UserStorage.initL10n();
  });

  Future<void> pumpBar(
    WidgetTester tester, {
    required int currentTab,
    required VoidCallback onTimelineTap,
    required VoidCallback onLibraryTap,
    double bottomInset = 0,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(bottom: bottomInset);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MainBottomBar(
                  currentTab: currentTab,
                  onTimelineTap: onTimelineTap,
                  onLibraryTap: onLibraryTap,
                  onCenterTap: () {},
                  onCenterLongPress: () {},
                  timelineTabKey: timelineKey,
                  libraryTabKey: libraryKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('tapping the Timeline label or icon area switches the tab', (
    tester,
  ) async {
    var timelineTaps = 0;
    var libraryTaps = 0;

    await pumpBar(
      tester,
      currentTab: 1,
      onTimelineTap: () => timelineTaps += 1,
      onLibraryTap: () => libraryTaps += 1,
    );

    await tester.tap(find.text(UserStorage.l10n.bottomNavTimeline));
    await tester.pump();
    expect(timelineTaps, 1);

    final tabBox = tester.getRect(find.byKey(timelineKey));
    await tester.tapAt(tabBox.topLeft + const Offset(8, 8));
    await tester.pump();
    expect(timelineTaps, 2);
    expect(libraryTaps, 0);
  });

  testWidgets('tapping the Library tab area switches the tab', (tester) async {
    var libraryTaps = 0;

    await pumpBar(
      tester,
      currentTab: 0,
      onTimelineTap: () {},
      onLibraryTap: () => libraryTaps += 1,
    );

    await tester.tap(find.text(UserStorage.l10n.bottomNavLibrary));
    await tester.pump();
    expect(libraryTaps, 1);
  });

  testWidgets('home-indicator inset keeps tab labels above the gesture zone', (
    tester,
  ) async {
    const inset = 34.0;
    await pumpBar(
      tester,
      currentTab: 0,
      onTimelineTap: () {},
      onLibraryTap: () {},
      bottomInset: inset,
    );

    final labelBottom =
        tester.getBottomLeft(find.text(UserStorage.l10n.bottomNavTimeline)).dy;
    expect(labelBottom, lessThan(852 - inset));
    expect(tester.getSize(find.byType(MainBottomBar)).height, 120.5 + inset);
  });
}

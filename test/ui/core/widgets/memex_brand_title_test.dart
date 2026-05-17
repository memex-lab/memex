import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/core/widgets/memex_brand_title.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    AppFlavor.init('global');
  });

  testWidgets('hides channel badge for stable builds', (tester) async {
    AppFlavor.init('global');

    await tester.pumpWidget(const MaterialApp(home: MemexBrandTitle()));

    expect(find.text('EARLY'), findsNothing);
    expect(find.text('DEV'), findsNothing);
  });

  testWidgets('shows Early channel badge for early builds', (tester) async {
    AppFlavor.init('globalEarly');

    await tester.pumpWidget(const MaterialApp(home: MemexBrandTitle()));

    expect(find.text('EARLY'), findsOneWidget);
    expect(find.text('DEV'), findsNothing);
  });

  testWidgets('shows Dev channel badge for development builds', (tester) async {
    AppFlavor.init('cnDev');

    await tester.pumpWidget(const MaterialApp(home: MemexBrandTitle()));

    expect(find.text('DEV'), findsOneWidget);
    expect(find.text('EARLY'), findsNothing);
  });
}

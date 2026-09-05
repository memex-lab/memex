import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/core/themes/app_theme.dart';
import 'package:memex/ui/core/themes/bundled_google_fonts.dart';
import 'package:memex/ui/core/widgets/memex_brand_title.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(configureBundledGoogleFonts);

  tearDown(() {
    AppFlavor.init('global');
  });

  test('disables runtime font fetching', () {
    expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
  });

  testWidgets('AppTheme and brand title resolve bundled fonts offline',
      (tester) async {
    AppFlavor.init('globalDev');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Column(
            children: [
              MemexBrandTitle(),
              _ImbueSample(),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(MemexBrandTitle), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
    expect(find.text('offline quote'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ImbueSample extends StatelessWidget {
  const _ImbueSample();

  @override
  Widget build(BuildContext context) {
    return Text(
      'offline quote',
      style: GoogleFonts.imbue(fontWeight: FontWeight.w700, fontSize: 24),
    );
  }
}

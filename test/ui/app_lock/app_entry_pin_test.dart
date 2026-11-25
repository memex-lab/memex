import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/main.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('a protected route is reachable only after the saved PIN',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'language': 'en',
      'app_lock_enabled': true,
      'app_lock_password': '4123',
    });
    await UserStorage.initL10n();
    await UserStorage.saveUser('synthetic-reader');
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var opened = false;
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
                  body: Center(
                child: TextButton(
                    onPressed: () => opened = true,
                    child: const Text('Private entry')),
              ))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MemexApp(router: router));
    await tester.pumpAndSettle();
    final entry = find.text('Private entry').hitTestable();
    expect(entry, findsNothing);
    Future<void> enterPin(String pin) async {
      for (final digit in pin.split('')) {
        await tester.tap(find.text(digit));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
    }

    await enterPin('0000');
    expect(entry, findsNothing);
    await enterPin('4123');
    expect(entry, findsOneWidget);
    await tester.tap(entry);
    expect(opened, isTrue);
  });
}

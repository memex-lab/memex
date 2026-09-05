import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/viewport_gated.dart';

void main() {
  testWidgets('builds the child only after it intersects the viewport',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400,
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: ViewportGated(
                      cacheExtent: 0,
                      placeholder:
                          const SizedBox(height: 160, child: Text('ph-1')),
                      builder: (_) => const Text('visible-child'),
                    ),
                  ),
                  const SizedBox(height: 400),
                  SizedBox(
                    height: 180,
                    child: ViewportGated(
                      cacheExtent: 0,
                      placeholder:
                          const SizedBox(height: 160, child: Text('ph-2')),
                      builder: (_) => const Text('offscreen-child'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('visible-child'), findsOneWidget);
    expect(find.text('offscreen-child'), findsNothing);
    expect(find.text('ph-2'), findsOneWidget);
  });

  testWidgets('builds immediately when not inside a scroll view',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ViewportGated(
          placeholder: const Text('placeholder'),
          builder: (_) => const Text('visible-child'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('visible-child'), findsOneWidget);
  });
}

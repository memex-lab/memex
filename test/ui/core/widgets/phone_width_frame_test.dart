import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/phone_width_frame.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    List<DisplayFeature> features = const [],
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          final media = MediaQuery.of(context).copyWith(
            displayFeatures: features,
          );
          return MediaQuery(
            data: media,
            child: Theme(
              data: ThemeData(
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: PhoneWidthFrame(
                  child: _WidthProbe(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('a phone portrait keeps the current full-width layout', (
    tester,
  ) async {
    const size = Size(390, 844);
    await pump(tester, size: size);

    expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 390);
    expect(tester.getTopLeft(find.byKey(_WidthProbe.columnKey)).dx, 0);
    expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 390 * 0.72);
  });

  testWidgets('a phone turned sideways stays full width', (tester) async {
    const size = Size(844, 390);
    await pump(tester, size: size);

    expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 844);
    expect(tester.getTopLeft(find.byKey(_WidthProbe.columnKey)).dx, 0);
    expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 844 * 0.72);
  });

  testWidgets('a large flat screen centers a phone-width column', (
    tester,
  ) async {
    const size = Size(840, 900);
    await pump(
      tester,
      size: size,
      features: const [
        DisplayFeature(
          bounds: Rect.fromLTWH(410, 0, 20, 900),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureFlat,
        ),
      ],
    );

    expect(
      tester.getSize(find.byKey(_WidthProbe.columnKey)).width,
      PhoneWidthFrame.maxWidth,
    );
    expect(
      tester.getTopLeft(find.byKey(_WidthProbe.columnKey)).dx,
      (size.width - PhoneWidthFrame.maxWidth) / 2,
    );
    expect(
      tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width,
      PhoneWidthFrame.maxWidth * 0.72,
    );
  });

  testWidgets('a half-open hinge keeps the full window', (tester) async {
    const size = Size(840, 900);
    await pump(
      tester,
      size: size,
      features: const [
        DisplayFeature(
          bounds: Rect.fromLTWH(400, 0, 40, 900),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );

    expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 840);
    expect(tester.getTopLeft(find.byKey(_WidthProbe.columnKey)).dx, 0);
    expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 840 * 0.72);
  });
}

class _WidthProbe extends StatelessWidget {
  const _WidthProbe();

  static const columnKey = Key('phone-column');
  static const bubbleKey = Key('chat-bubble');

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox.expand(
      key: columnKey,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          key: bubbleKey,
          width: width * 0.72,
          height: 12,
        ),
      ),
    );
  }
}

import 'dart:ui' show DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';

/// Keeps Memex in a centered phone-width column on a large flat canvas.
///
/// A normal phone, including one turned sideways, is left as it is: the short
/// side stays small. A half-open fold is also left full width, because that
/// posture splits the screen instead of making a bigger phone.
class PhoneWidthFrame extends StatelessWidget {
  const PhoneWidthFrame({super.key, required this.child});

  final Widget child;

  /// Slightly wider than the largest phones, so the column still reads as
  /// the current layout rather than a stretched tablet page.
  static const double maxWidth = 480;

  /// Below this, the window is a phone. Unfolded foldables and tablets are
  /// larger on both sides.
  static const double largeCanvasShortestSide = 600;

  static bool frames(MediaQueryData media) {
    if (media.size.shortestSide < largeCanvasShortestSide) return false;
    if (media.size.width <= maxWidth) return false;
    for (final feature in media.displayFeatures) {
      final splitsTheScreen = feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge;
      if (splitsTheScreen &&
          feature.state == DisplayFeatureState.postureHalfOpened) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (!frames(media)) return child;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(maxWidth, media.size.height),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

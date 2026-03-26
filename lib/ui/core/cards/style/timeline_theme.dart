import 'package:flutter/material.dart';

/// Centralized theme for Timeline Cards.
/// Defines colors, typography, and shadows to ensure consistency.
class TimelineTheme {
  const TimelineTheme._(); // Private constructor

  static const colors = AppColors();
  static const typography = AppTextStyles();
  static const shadows = AppShadows();
}

class AppColors {
  const AppColors();

  // Brand
  final Color primary = const Color(0xFF5B6CFF);

  // Semantic
  final Color success = const Color(0xFF10B981);
  final Color warning = const Color(0xFFF59E0B);
  final Color danger = const Color(0xFFF43F5E);

  // Text
  final Color textPrimary = const Color(0xFF0A0A0A);
  final Color textSecondary = const Color(0xFF4A5565);
  final Color textTertiary = const Color(0xFF99A1AF);

  // Backgrounds
  final Color background = const Color(0xFFF7F8FA);
  final Color backgroundSecondary = const Color(0xFFF7F8FA);
  final Color cardBackground = const Color(0xFFFFFFFF);
  final Color glassBorder = const Color(0xFFFFFFFF);
}

class AppTextStyles {
  const AppTextStyles();

  // 24px Bold / Data
  TextStyle get data => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -1.0,
      );

  // 17px SemiBold / Header
  TextStyle get title => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      );

  // 15px Regular / Body
  TextStyle get body => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  // 13px Medium / Subheaders or Metadata
  TextStyle get small => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // 12px Medium / Label
  TextStyle get label => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.15,
        height: 1.4,
      );
}

class AppShadows {
  const AppShadows();

  BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 2),
      );

  BoxShadow get float => BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 6),
      );
}

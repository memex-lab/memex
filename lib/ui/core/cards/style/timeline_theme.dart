import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Semantic Palette
  final Color primary = const Color(0xFF4F46E5); // Indigo-600
  final Color success = const Color(0xFF10B981); // Emerald-500
  final Color warning = const Color(0xFFF59E0B); // Amber-500
  final Color danger = const Color(0xFFF43F5E); // Rose-500

  // Text Colors
  final Color textPrimary = const Color(0xFF0F172A); // Slate-900
  final Color textSecondary = const Color(0xFF475569); // Slate-600
  final Color textTertiary = const Color(0xFF94A3B8); // Slate-400

  // Backgrounds
  final Color background = const Color(0xFFF8FAFC); // Slate-50
  final Color backgroundSecondary =
      const Color(0xFFF1F5F9); // Slate-100 used for panels
  final Color glassBorder =
      const Color(0xFFFFFFFF); // White (opacity controlled in usage)
}

class AppTextStyles {
  const AppTextStyles();

  // 32px Serif / Elegant
  TextStyle get display => GoogleFonts.sourceSerif4(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.5,
      );

  // 24px Bold / Data
  TextStyle get data => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -1.0,
      );

  // 17px Bold / Header
  TextStyle get title => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      );

  // 15px Regular / Body
  TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  // 13px Medium / Subheaders or Metadata
  TextStyle get small => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  // 12px Bold / Label (Caps)
  TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // 14px Mono / Technical
  TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );
}

class AppShadows {
  const AppShadows();

  BoxShadow get card => BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 24,
        offset: const Offset(0, 4),
      );

  BoxShadow get float => BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, 10),
      );
}

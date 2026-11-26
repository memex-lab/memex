import 'dart:ui' show FontWeight;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Load the bundled faces before entering the widget test's fake clock so
/// font-change notifications cannot arrive during widget disposal.
Future<void> loadBundledTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.inter(fontWeight: FontWeight.w500),
    GoogleFonts.inter(fontWeight: FontWeight.w600),
    GoogleFonts.inter(fontWeight: FontWeight.w700),
    GoogleFonts.inter(fontWeight: FontWeight.w800),
    GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w800),
    GoogleFonts.imbue(fontWeight: FontWeight.w700),
  ]);
}

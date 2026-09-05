import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Use the TTFs in `google_fonts/` instead of fetching families at runtime.
///
/// First-run and offline devices cannot reach `fonts.gstatic.com`. The
/// bundled files must keep the google_fonts API names (`Inter-Regular.ttf`,
/// `BricolageGrotesque-ExtraBold.ttf`, `Imbue-Bold.ttf`).
void configureBundledGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['google_fonts', 'Inter'],
      await rootBundle.loadString('google_fonts/OFL-Inter.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      ['google_fonts', 'Bricolage Grotesque'],
      await rootBundle.loadString('google_fonts/OFL-BricolageGrotesque.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      ['google_fonts', 'Imbue'],
      await rootBundle.loadString('google_fonts/OFL-Imbue.txt'),
    );
  });
}

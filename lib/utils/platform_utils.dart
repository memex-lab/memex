import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// Whether the app is running on the web
  static bool get isWeb => kIsWeb;
  
  /// Whether the app is running on a mobile platform (Android or iOS)
  static bool get isMobile {
    if (kIsWeb) return false;
    return io.Platform.isAndroid || io.Platform.isIOS;
  }

  /// Whether the app is running on a desktop platform (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) return false;
    return io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux;
  }

  /// Whether the app is running on Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return io.Platform.isWindows;
  }
}

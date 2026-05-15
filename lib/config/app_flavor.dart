/// App flavor configuration.
///
/// Flavor is determined by the `--flavor` flag passed to `flutter run` / `flutter build`.
/// On Android, the flavor name comes from Gradle productFlavors.
/// On iOS, it comes from the Xcode scheme name.
///
/// Usage:
///   flutter run --flavor global
///   flutter run --flavor cn
///   flutter run --flavor globalEarly
///   flutter run --flavor cnEarly
///   flutter run --flavor globalDev
///   flutter run --flavor cnDev
enum AppFlavorType { global, cn }

enum AppChannelType { stable, early, dev }

class AppFlavor {
  AppFlavor._();

  static AppFlavorType _current = AppFlavorType.global;
  static AppChannelType _channel = AppChannelType.stable;

  static AppFlavorType get current => _current;
  static AppChannelType get channel => _channel;

  static bool get isGlobal => _current == AppFlavorType.global;
  static bool get isCN => _current == AppFlavorType.cn;
  static bool get isStable => _channel == AppChannelType.stable;
  static bool get isEarly => _channel == AppChannelType.early;
  static bool get isDev => _channel == AppChannelType.dev;

  /// Call once at app startup with the flavor string from `appFlavor`.
  static void init(String? flavor) {
    final normalized = flavor?.toLowerCase() ?? '';
    if (normalized.startsWith('cn')) {
      _current = AppFlavorType.cn;
    } else {
      _current = AppFlavorType.global;
    }

    if (normalized.contains('dev')) {
      _channel = AppChannelType.dev;
    } else if (normalized.contains('early')) {
      _channel = AppChannelType.early;
    } else {
      _channel = AppChannelType.stable;
    }
  }
}

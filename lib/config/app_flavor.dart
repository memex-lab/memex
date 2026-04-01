/// App flavor configuration.
///
/// Flavor is determined by the `--flavor` flag passed to `flutter run` / `flutter build`.
/// On Android, the flavor name comes from Gradle productFlavors.
/// On iOS, it comes from the Xcode scheme name.
///
/// Usage:
///   flutter run --flavor global
///   flutter run --flavor cn
enum AppFlavorType { global, cn }

class AppFlavor {
  AppFlavor._();

  static AppFlavorType _current = AppFlavorType.global;

  static AppFlavorType get current => _current;

  static bool get isGlobal => _current == AppFlavorType.global;
  static bool get isCN => _current == AppFlavorType.cn;

  /// Call once at app startup with the flavor string from `appFlavor`.
  static void init(String? flavor) {
    if (flavor != null && flavor.toLowerCase() == 'cn') {
      _current = AppFlavorType.cn;
    } else {
      _current = AppFlavorType.global;
    }
  }
}
